----------------------------------------------------------------------------------
-- Company: Thayer School of Engineering, Dartmouth College
-- Engineer: Kendall Farnham
-- 
-- Create Date: 08/17/2023 08:35:03 AM
-- Design Name: 
-- Module Name: tb_dds_freq_demod_controller - testbench
-- Project Name: 2023_DAQ
-- Target Devices: Artix 7 (Trenz Electronics TE0711-01)
-- Tool Versions: Vivado 2022.2
-- Description: testbench for demod_to_bram module (ADC -> FIFO -> FFT -> BRAM -> UART)
--          use 15 MHz ADC clock, 100 MHz sysclk, DDS -> ADC data
-- 
-- Dependencies: 
-- 
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
-- 
----------------------------------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use ieee.std_logic_unsigned.all;
use ieee.numeric_std.all;

entity tb_dds_freq_demod_controller is
end tb_dds_freq_demod_controller;

architecture testbench of tb_dds_freq_demod_controller is
----------------------------------------------------------------------------------
-- Constants
----------------------------------------------------------------------------------
constant CLOCK_PERIOD: time := 10ns;        -- 10ns = 100 MHz
constant DDS_CLOCK_PERIOD: time := 10ns;     -- 8ns = 125 MHz
constant FFT_CLOCK_PERIOD: time := 70ns;    -- 15 MHz sampling rate
constant PHASE_WIDTH : integer := 24;   	-- number of bits in dds phase control
constant PHASE_LUT_ADDR_WIDTH : integer := 6;      -- bits in ROM address (look up table for dds phase)
constant FFT_LUT_BIN_WIDTH : integer := 16; -- data bus size of BRAM (extend to pow2)
constant DAC_DATA_WIDTH : integer := 14;    -- size of data bus out to dac
constant ADC_DATA_WIDTH : integer := 16;    -- size of fft_out bus
constant FFT_BIN_WIDTH : INTEGER := 10; 	-- 2**FFT_BIN_WIDTH number of bins in fft
constant NFFT : integer := 2**FFT_BIN_WIDTH;-- size of fft
constant SLOW_SAMP_CLKDIV : integer := 128; -- divide clock rate by this value if use_slow_fs signal is high
constant SIM_WAIT_TIME: time := 100*CLOCK_PERIOD;        -- 10ns = 100 MHz
----------------------------------------------------------------------------------
-- Signals
----------------------------------------------------------------------------------
-- Clocks
signal sysclk, aclk, dclk : std_logic := '0';

-- Signals for demod_to_bram
signal uart_read_en, uart_output_rdy, uart_tx : std_logic := '0';
signal enable_demod, adin_sync_start, use_slow_fs, use_full_spectrum : std_logic := '0';
signal adin : STD_LOGIC_VECTOR (ADC_DATA_WIDTH-1 downto 0) := (others => '0');
signal n_averages : integer := 16;
signal bin_f1, bin_f2 : std_logic_vector(FFT_BIN_WIDTH-1 downto 0) := (others => '0');

-- Signals for dualtone_dds_controller
signal enable_dds, dds_out_last, slow_dds_out_last, dds_out_valid : std_logic := '0';
signal phase_freq_A, phase_freq_B: STD_LOGIC_VECTOR (2*PHASE_WIDTH-1 downto 0) := (others => '0');
signal dds_out : std_logic_vector(13 downto 0) := (others => '0');

-- Signals for ROMs
signal phase_lut_addr : std_logic_vector(PHASE_LUT_ADDR_WIDTH-1 downto 0) := (others => '0');
signal phase_lut_dout, freqA, freqB : STD_LOGIC_VECTOR (PHASE_WIDTH-1 downto 0) := (others => '0');
signal fft_bin_lut_data : std_logic_vector(FFT_LUT_BIN_WIDTH-1 downto 0) := (others => '0');

-- Signals for testbench logic
signal testnum, sAmplitude, sOffset : integer := 0;
signal enable, reset, set_dual : std_logic := '0';

----------------------------------------------------------------------------------
-- Components
----------------------------------------------------------------------------------
component dds_freq_demod_controller is
  Generic (
        DEBUG_MODE : std_logic := '1';
        SLOW_SAMP_CLKDIV : integer := SLOW_SAMP_CLKDIV; -- divide ADC clock by this amount if use_slow_fs = '1'
        FFT_BIN_WIDTH : INTEGER := FFT_BIN_WIDTH;       -- 2**FFT_BIN_WIDTH number of bins in FFT
        DATA_WIDTH : integer := ADC_DATA_WIDTH);            -- ADC data bus width
  Port ( sysclk : in STD_LOGIC;         -- system clock
        aclk : in STD_LOGIC;            -- adc clock
        enable : in STD_LOGIC;
        reset : in STD_LOGIC;
        adin: in STD_LOGIC_VECTOR (DATA_WIDTH-1 downto 0);    -- from ADC
        adin_sync_start : in STD_LOGIC;
        
        bin_f1 : in STD_LOGIC_VECTOR (FFT_BIN_WIDTH-1 downto 0);    -- fft bin of signal freq 1 (first half)
        bin_f2 : in STD_LOGIC_VECTOR (FFT_BIN_WIDTH-1 downto 0);    -- fft bin of signal freq 2 if dualtone (first half)    
        use_full_spectrum : in STD_LOGIC;                           -- use full FFT spectrum for THD calcs (default is to use half)  
        n_averages : in integer;        -- Run the ADC->FIFO->FFT n_averages times, save all to BRAM
        use_slow_fs : in STD_LOGIC;     -- use slow sampling rate (for low freqs)
        read_en : in STD_LOGIC;         -- enable output
        
        output_rdy : out STD_LOGIC;     -- ready for output
        serial_out : out STD_LOGIC      -- serial out to UART
        );
end component;
----------------------------------------------------------------------------------
component dualtone_dds_controller is
    GENERIC(
    SLOW_SAMP_CLKDIV : integer := SLOW_SAMP_CLKDIV; -- multiply sample counter for slow_dds_out_last pulse
    NFFT : integer := NFFT;                 -- size of FFT 
    PHASE_WIDTH : integer := PHASE_WIDTH;   -- number of bits in phase control
    DDS_BITS :    INTEGER := DAC_DATA_WIDTH);  -- size of dds_out bus
Port ( dclk : in STD_LOGIC;        -- DDS clock
   fftclk : in STD_LOGIC;          -- ADC sampling clock to sync FFT to correct phase
   enable : in STD_LOGIC;
   reset : in STD_LOGIC;
   phase_freq_A : in STD_LOGIC_VECTOR(2*PHASE_WIDTH-1 downto 0);   -- phase offset (MSB) and frequency (LSB) for ddsA
   phase_freq_B : in STD_LOGIC_VECTOR(2*PHASE_WIDTH-1 downto 0);   -- phase offset (MSB) and frequency (LSB) for ddsB
   dds_out_valid : out STD_LOGIC;       -- dds output is valid
   dds_out_last : out STD_LOGIC;        -- pulse at the start of the dds signal (with respect to phase), every NFFT samples 
   slow_dds_out_last : out STD_LOGIC;   -- pulse at start of dds signal every NFFT*SLOW_SAMP_CLKDIV samples
   dds_out: out STD_LOGIC_VECTOR (DDS_BITS-1 downto 0));
end component;
----------------------------------------------------------------------------------
-- DDS phase LUT 	 
COMPONENT blk_mem_gen_0
  PORT (
    clka : IN STD_LOGIC;
    addra : IN STD_LOGIC_VECTOR(PHASE_LUT_ADDR_WIDTH-1 DOWNTO 0);
    douta : OUT STD_LOGIC_VECTOR(PHASE_WIDTH-1 DOWNTO 0) 
  );
END COMPONENT;
----------------------------------------------------------------------------------
-- FFT bin LUT 
COMPONENT blk_mem_gen_2
  PORT (
    clka : IN STD_LOGIC;
    addra : IN STD_LOGIC_VECTOR(PHASE_LUT_ADDR_WIDTH-1 DOWNTO 0);
    douta : OUT STD_LOGIC_VECTOR(FFT_LUT_BIN_WIDTH-1 DOWNTO 0) 
  );
END COMPONENT;
----------------------------------------------------------------------------------
begin
----------------------------------------------------------------------------------
dut: dds_freq_demod_controller port map (
    sysclk => sysclk,
    aclk => aclk,
    enable => enable_demod,
    reset => reset,
    adin => adin,
    adin_sync_start => adin_sync_start,
    bin_f1 => bin_f1,
    bin_f2 => bin_f2,
    use_full_spectrum => use_full_spectrum,
    n_averages => n_averages,
    use_slow_fs => use_slow_fs,
    read_en => uart_read_en,
    output_rdy => uart_output_rdy,
    serial_out => uart_tx );
----------------------------------------------------------------------------------
dds_inst : dualtone_dds_controller port map (
    dclk => sysclk,
    fftclk => aclk,
    enable => enable_dds,
    reset => reset, 
    phase_freq_A => phase_freq_A,
    phase_freq_B => phase_freq_B,
    dds_out_valid => dds_out_valid,
    dds_out_last => dds_out_last,
    slow_dds_out_last => slow_dds_out_last,
    dds_out => dds_out);
----------------------------------------------------------------------------------
-- DDS phase lookup table ROM
phase_lut_inst : blk_mem_gen_0
port map (
    clka => sysclk,
    addra => phase_lut_addr,
    douta => phase_lut_dout);
----------------------------------------------------------------------------------
-- FFT bin lookup table ROM
fft_bin_lut_inst : blk_mem_gen_2
port map (
    clka => sysclk,
    addra => phase_lut_addr,
    douta => fft_bin_lut_data);    
----------------------------------------------------------------------------------
dualfreq_lut_mux : process(set_dual, phase_lut_dout, fft_bin_lut_data, reset)
begin
    if reset = '1' then
        freqA <= (others => '0');
        freqB <= (others => '0');
        bin_f1 <= (others => '0');
        bin_f2 <= (others => '0');
    else
        if set_dual = '1' then
            freqB <= phase_lut_dout;
            bin_f2 <= fft_bin_lut_data(FFT_BIN_WIDTH-1 downto 0);  
        else
            freqA <= phase_lut_dout;
            bin_f1 <= fft_bin_lut_data(FFT_BIN_WIDTH-1 downto 0); 
        end if; 
    end if;
end process;
----------------------------------------------------------------------------------
set_adin : process(sAmplitude, sOffset, dds_out)
begin

adin <= std_logic_vector(to_signed(sAmplitude*to_integer(signed(dds_out))+sOffset,ADC_DATA_WIDTH)); -- add dc offset
end process;
----------------------------------------------------------------------------------
-- Connect ports
----------------------------------------------------------------------------------
--adin <= std_logic_vector(resize(signed(dds_out), ADC_DATA_WIDTH));  -- DDS to ADC input
--adin <= dds_out & "00";
--adin <= std_logic_vector(to_signed(to_integer(signed(dds_out))+350,ADC_DATA_WIDTH)); -- add dc offset
adin_sync_start <= dds_out_last;
enable_demod <= enable;
enable_dds <= enable;
----------------------------------------------------------------------------------
-- Async setting of dds params
phase_freq_A(2*PHASE_WIDTH-1 downto PHASE_WIDTH) <= (others => '0');
phase_freq_B(2*PHASE_WIDTH-1 downto PHASE_WIDTH) <= (others => '0');
phase_freq_A(PHASE_WIDTH-1 downto 0) <= freqA;
phase_freq_B(PHASE_WIDTH-1 downto 0) <= freqB;
----------------------------------------------------------------------------------
-- Generate clocks
----------------------------------------------------------------------------------
sys_clock_gen : process
begin
sysclk <= '0';
wait for CLOCK_PERIOD;
loop
  sysclk <= not(sysclk);
  wait for CLOCK_PERIOD/2;
end loop;
end process sys_clock_gen;

fft_clock_gen : process
begin
aclk <= '0';
wait for CLOCK_PERIOD;
loop
  aclk <= not(aclk);
  wait for FFT_CLOCK_PERIOD/2;
end loop;
end process fft_clock_gen;

dds_clock_gen : process
begin
dclk <= '0';
wait for CLOCK_PERIOD;
loop
  dclk <= not(dclk);
  wait for DDS_CLOCK_PERIOD/2;
end loop;
end process dds_clock_gen;

----------------------------------------------------------------------------------
-- Simulation
----------------------------------------------------------------------------------
stim_proc: process
begin
    -- Initialize
    testnum <= 0;
    reset <= '1';
    enable <= '0';
    set_dual <= '0';
    use_slow_fs <= '0';
    n_averages <= 3;
    sAmplitude <= 1;
    sOffset <= 350;
    wait for SIM_WAIT_TIME;
    
    enable <= '1';
    reset <= '0';
    
    
    -- Run sequence to end of FFT using in-bin frequencies
    testnum <= testnum + 1;
    phase_lut_addr <= std_logic_vector(to_unsigned(32,PHASE_LUT_ADDR_WIDTH));
    wait for SIM_WAIT_TIME;
    
    
    -- Enable UART TX
    uart_read_en <= '1';
    wait until uart_output_rdy = '1';
    wait until uart_output_rdy = '0';
    wait until uart_output_rdy = '1';
    wait until uart_output_rdy = '0';
    wait for SIM_WAIT_TIME;
    
    -- Async reset
    testnum <= testnum + 1;
    reset <= '1';
    wait for CLOCK_PERIOD;
    reset <= '0';
    sAmplitude <= 2;
    sOffset <= 0;
    
    -- Use single tone DDS
    phase_lut_addr <= std_logic_vector(to_unsigned(34,PHASE_LUT_ADDR_WIDTH));
    wait until uart_output_rdy = '1';
    wait for SIM_WAIT_TIME;
    
    -- Disable read
    uart_read_en <= '0';
    wait for SIM_WAIT_TIME;
    
     
    -- Repeat, use dual dds this time
    testnum <= testnum + 1;
    set_dual <= '1';
    phase_lut_addr <= std_logic_vector(to_unsigned(33,PHASE_LUT_ADDR_WIDTH));
    wait for CLOCK_PERIOD;
    set_dual <= '0';
    phase_lut_addr <= std_logic_vector(to_unsigned(32,PHASE_LUT_ADDR_WIDTH));
    wait for SIM_WAIT_TIME;

    -- Enable UART TX
    uart_read_en <= '1';
    
    wait for SIM_WAIT_TIME;
    wait until uart_output_rdy = '1';
    wait until uart_output_rdy = '0';
    wait until uart_output_rdy = '1';
    wait until uart_output_rdy = '0';
    
    -- Disable, enable, and reset
    testnum <= testnum + 1;
    enable <= '0';
    wait for SIM_WAIT_TIME;
    enable <= '1';
    wait for SIM_WAIT_TIME;
    reset <= '1';
    wait for SIM_WAIT_TIME;
    reset <= '0';
    wait for SIM_WAIT_TIME;
    
    
    -- Disable read
    uart_read_en <= '0';
    wait for SIM_WAIT_TIME;
    
    -- Enable UART TX
    testnum <= testnum + 1;
    uart_read_en <= '1';
    
    wait for SIM_WAIT_TIME;
    wait until uart_output_rdy = '1';
    wait until uart_output_rdy = '0';
    wait until uart_output_rdy = '1';
    wait until uart_output_rdy = '0';
    

    wait for SIM_WAIT_TIME;
    std.env.stop;
end process stim_proc;

end testbench;
