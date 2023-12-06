----------------------------------------------------------------------------------
-- Company: Thayer School of Engineering, Dartmouth College
-- Engineer: Kendall Farnham
-- 
-- Create Date: 08/03/2023
-- Design Name: 
-- Module Name: tb_fft_calcs - testbench
-- Project Name: 2023_DAQ
-- Target Devices: Artix 7 (Trenz Electronics TE0711-01)
-- Tool Versions: Vivado 2022.2
-- Description: testbench for FFT calculations
--              DDS --> FFT --> [fft_calcs]
-- 
-- Dependencies:    xfft_0 (IP core)
-- 
-- Revision:
-- Revision 0.01  File Created 
-- Additional Comments:
-- 
----------------------------------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use ieee.std_logic_unsigned.all;
use ieee.numeric_std.all;

entity tb_fft_calcs is
end tb_fft_calcs;

architecture testbench of tb_fft_calcs is
--------------------------------------------
-- Constants
--------------------------------------------
constant CLOCK_PERIOD: time := 10ns;        -- 10ns = 100 MHz
constant DDS_CLOCK_PERIOD: time := 10ns;     -- 8ns = 125 MHz
constant FFT_CLOCK_PERIOD: time := 70ns;    -- 15 MHz sampling rate
constant PHASE_WIDTH : integer := 24;   	-- number of bits in dds phase control
constant PHASE_LUT_ADDR_WIDTH : integer := 6;      -- bits in ROM address (look up table for dds phase)
constant DAC_DATA_WIDTH : integer := 14;    -- size of data bus out to dac
constant ADC_DATA_WIDTH : integer := 16;    -- size of fft_out bus
constant FFT_BIN_WIDTH : INTEGER := 10; 	-- 2**FFT_BIN_WIDTH number of bins in fft
constant NFFT : integer := 2**FFT_BIN_WIDTH;-- size of fft
constant SLOW_SAMP_CLKDIV : integer := 128; -- divide clock rate by this value if use_slow_fs signal is high
constant FFT_LUT_BIN_WIDTH : integer := 16; -- data bus size of BRAM (extend to pow2)

-------------------------------------------
component fft_calcs is 
Generic (
    FFT_DATA_WIDTH : integer := 16;     -- size of fft_out bus
    FFT_BIN_WIDTH : INTEGER := FFT_BIN_WIDTH);     -- 2**FFT_BIN_WIDTH number of bins 
Port ( clk : in STD_LOGIC;   
       reset : in STD_LOGIC;            -- reset signals and outputs
       enable : in STD_LOGIC;           -- enable fft calculations
       data_in_valid : in STD_LOGIC;    -- fft data in is valid
       re_in : in STD_LOGIC_VECTOR (FFT_DATA_WIDTH-1 downto 0);
       im_in : in STD_LOGIC_VECTOR (FFT_DATA_WIDTH-1 downto 0);
       bin_in: in STD_LOGIC_VECTOR (FFT_BIN_WIDTH-1 downto 0);          -- fft bin number of input data
       bin_f1 : in STD_LOGIC_VECTOR (FFT_BIN_WIDTH-1 downto 0);         -- fft bin of signal freq 1 (first half)
       bin_f2 : in STD_LOGIC_VECTOR (FFT_BIN_WIDTH-1 downto 0);         -- fft bin of signal freq 2 if dualtone (first half)
       use_full_spectrum : in STD_LOGIC;    -- default is to use half spectrum data, set this high to use full spectrum data
       
       data_out_valid : out STD_LOGIC;      -- output data is valid/calculations are finished
       re_im_out_f1 : out STD_LOGIC_VECTOR (2*FFT_DATA_WIDTH-1 downto 0);       -- complex data (Re Im) of signal freq 1 
       re_im_out_f2 : out STD_LOGIC_VECTOR (2*FFT_DATA_WIDTH-1 downto 0);       -- complex data (Re Im) of signal freq 2
       dc_out : out STD_LOGIC_VECTOR (2*FFT_DATA_WIDTH-1 downto 0);               -- dc magnitude (real data of bin 0)
       mag_sum2_out : out STD_LOGIC_VECTOR (4*FFT_DATA_WIDTH-1 downto 0));        -- squared sum of magnitudes (i.e., sum(re^2 + im^2))
end component;
-------------------------------------------
COMPONENT xfft_0
    PORT (
    aclk : IN STD_LOGIC;
    aclken : IN STD_LOGIC;
    aresetn : IN STD_LOGIC;
    s_axis_config_tdata : IN STD_LOGIC_VECTOR(15 DOWNTO 0);
    s_axis_config_tvalid : IN STD_LOGIC;
    s_axis_config_tready : OUT STD_LOGIC;
    s_axis_data_tdata : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
    s_axis_data_tvalid : IN STD_LOGIC;
    s_axis_data_tready : OUT STD_LOGIC;
    s_axis_data_tlast : IN STD_LOGIC;
    m_axis_data_tdata : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
    m_axis_data_tuser : OUT STD_LOGIC_VECTOR(15 DOWNTO 0);
    m_axis_data_tvalid : OUT STD_LOGIC;
    m_axis_data_tlast : OUT STD_LOGIC;
    event_frame_started : OUT STD_LOGIC;
    event_tlast_unexpected : OUT STD_LOGIC;
    event_tlast_missing : OUT STD_LOGIC;
    event_data_in_channel_halt : OUT STD_LOGIC);
END COMPONENT;
-------------------------------------------
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
-------------------------------------------
-- DDS phase LUT 	 
COMPONENT blk_mem_gen_0
  PORT (
    clka : IN STD_LOGIC;
    ena : IN STD_LOGIC;
    addra : IN STD_LOGIC_VECTOR(PHASE_LUT_ADDR_WIDTH-1 DOWNTO 0);
    douta : OUT STD_LOGIC_VECTOR(PHASE_WIDTH-1 DOWNTO 0) 
  );
END COMPONENT;
-------------------------------------------
-- FFT bin LUT 
COMPONENT blk_mem_gen_2
  PORT (
    clka : IN STD_LOGIC;
    ena : IN STD_LOGIC;
    addra : IN STD_LOGIC_VECTOR(PHASE_LUT_ADDR_WIDTH-1 DOWNTO 0);
    douta : OUT STD_LOGIC_VECTOR(FFT_LUT_BIN_WIDTH-1 DOWNTO 0) 
  );
END COMPONENT;
--------------------------------------------
-- Signals
--------------------------------------------
-- Clocks
signal sysclk, aclk, dclk : std_logic := '0';
signal testinteger : integer := 0;

-- Signals for fft_calcs
signal enable_fft_calcs, data_out_valid_fft_calcs : std_logic := '0';
signal bin_f1, bin_f2 : STD_LOGIC_VECTOR (FFT_BIN_WIDTH-1 downto 0) := (others => '0');
signal re_im_out_f1, re_im_out_f2 : STD_LOGIC_VECTOR (2*ADC_DATA_WIDTH-1 downto 0) := (others => '0');
signal dc_out : STD_LOGIC_VECTOR (2*ADC_DATA_WIDTH-1 downto 0) := (others => '0');
signal mag_sum2_out : STD_LOGIC_VECTOR (4*ADC_DATA_WIDTH-1 downto 0) := (others => '0');

-- CDC
signal aclk_d, aclk_dd, aclk_edge : std_logic := '0';

-- Signals for dualtone_dds_controller
signal enable, dds_out_last, slow_dds_out_last, dds_out_valid : std_logic := '0';
signal phase_freq_A, phase_freq_B: STD_LOGIC_VECTOR (2*PHASE_WIDTH-1 downto 0) := (others => '0');
signal dds_out : std_logic_vector(13 downto 0) := (others => '0');
signal phase_lut_addr : std_logic_vector(PHASE_LUT_ADDR_WIDTH-1 downto 0) := (others => '0');
signal phase_lut_dout, freqA, freqB : STD_LOGIC_VECTOR (PHASE_WIDTH-1 downto 0) := (others => '0');
signal fft_bin_lut_data : std_logic_vector(FFT_LUT_BIN_WIDTH-1 downto 0) := (others => '0');
-- Signals for testbench logic
signal testnum : integer := 0;
signal reset, reset_n, set_dual : std_logic := '0';

-- Signals for FFT core
signal enable_fft_core : std_logic := '0';
-- Config slave channel signals
signal s_axis_config_tvalid        : std_logic := '0';  -- payload is valid
signal s_axis_config_tready        : std_logic := '1';  -- slave is ready
signal s_axis_config_tdata         : std_logic_vector(15 downto 0) := (others => '0');  -- data payload

-- Data slave channel signals
signal s_axis_data_tvalid          : std_logic := '0';  -- payload is valid
signal s_axis_data_tready          : std_logic := '1';  -- slave is ready
signal s_axis_data_tdata           : std_logic_vector(31 downto 0) := (others => '0');  -- data payload
signal s_axis_data_tlast           : std_logic := '0';  -- indicates end of packet

-- Data master channel signals
signal m_axis_data_tvalid          : std_logic := '0';  -- payload is valid
signal m_axis_data_tdata           : std_logic_vector(31 downto 0) := (others => '0');  -- data payload
signal m_axis_data_tuser           : std_logic_vector(15 downto 0) := (others => '0');  -- user-defined payload
signal m_axis_data_tlast           : std_logic := '0';  -- indicates end of packet

-- Event signals
signal event_frame_started         : std_logic := '0';
signal event_tlast_unexpected      : std_logic := '0';
signal event_tlast_missing         : std_logic := '0';
signal event_data_in_channel_halt  : std_logic := '0';

-----------------------------------------------------------------------
-- Aliases for AXI channel TDATA and TUSER fields
-- These are a convenience for viewing data in a simulator waveform viewer.
-- If using ModelSim or Questa, add "-voptargs=+acc=n" to the vsim command
-- to prevent the simulator optimizing away these signals.
-----------------------------------------------------------------------

-- Config slave channel alias signals
signal s_axis_config_tdata_fwd_inv      : std_logic                    := '0';              -- forward or inverse
signal s_axis_config_tdata_scale_sch    : std_logic_vector(9 downto 0) := (others => '0');  -- scaling schedule

-- Data slave channel alias signals
signal s_axis_data_tdata_re             : std_logic_vector(15 downto 0) := (others => '0');  -- real data
signal s_axis_data_tdata_im             : std_logic_vector(15 downto 0) := (others => '0');  -- imaginary data

-- Data master channel alias signals
signal m_axis_data_tdata_re             : std_logic_vector(15 downto 0) := (others => '0');  -- real data
signal m_axis_data_tdata_im             : std_logic_vector(15 downto 0) := (others => '0');  -- imaginary data
signal m_axis_data_tuser_xk_index       : std_logic_vector(9 downto 0) := (others => '0');  -- sample index


-------------------------------------------
begin
-------------------------------------------
dut: fft_calcs port map (
    clk => aclk,
    reset => reset,
    enable => enable_fft_calcs,
    data_in_valid => m_axis_data_tvalid,
    re_in => m_axis_data_tdata_re,
    im_in => m_axis_data_tdata_im,
    bin_in => m_axis_data_tuser_xk_index,
    bin_f1 => bin_f1,
    bin_f2 => bin_f2,
    data_out_valid => data_out_valid_fft_calcs,
    re_im_out_f1 => re_im_out_f1,
    re_im_out_f2 => re_im_out_f2,
    dc_out => dc_out,
    mag_sum2_out => mag_sum2_out );
 
 -------------------------------------------
  fft_ip_core : xfft_0
    port map (
      aclk                        => aclk,
      aclken                      => enable,
      aresetn                     => reset_n,
      s_axis_config_tvalid        => s_axis_config_tvalid,
      s_axis_config_tready        => s_axis_config_tready,
      s_axis_config_tdata         => s_axis_config_tdata,
      s_axis_data_tvalid          => s_axis_data_tvalid,
      s_axis_data_tready          => s_axis_data_tready,
      s_axis_data_tdata           => s_axis_data_tdata,
      s_axis_data_tlast           => s_axis_data_tlast,
      m_axis_data_tvalid          => m_axis_data_tvalid,
      m_axis_data_tdata           => m_axis_data_tdata,
      m_axis_data_tuser           => m_axis_data_tuser,
      m_axis_data_tlast           => m_axis_data_tlast,
      event_frame_started         => event_frame_started,
      event_tlast_unexpected      => event_tlast_unexpected,
      event_tlast_missing         => event_tlast_missing,
      event_data_in_channel_halt  => event_data_in_channel_halt
      );
-------------------------------------------
reset_n <= not reset;      
-------------------------------------------
dds_inst : dualtone_dds_controller port map (
    dclk => sysclk,
    fftclk => aclk,
    enable => enable,
    reset => reset, 
    phase_freq_A => phase_freq_A,
    phase_freq_B => phase_freq_B,
    dds_out_valid => dds_out_valid,
    dds_out_last => dds_out_last,
    slow_dds_out_last => slow_dds_out_last,
    dds_out => dds_out);
------------------------------------------- 
-- DDS phase lookup table ROM
phase_lut_inst : blk_mem_gen_0
port map (
    clka => sysclk,
    ena => enable,
    addra => phase_lut_addr,
    douta => phase_lut_dout);
------------------------------------------- 
-- FFT bin lookup table ROM
fftbin_lut_inst : blk_mem_gen_2
port map (
    clka => sysclk,
    ena => enable,
    addra => phase_lut_addr,
    douta => fft_bin_lut_data);   
------------------------------------------- 
phase_lut_mux : process(set_dual, phase_lut_dout, reset)
begin
    if reset = '1' then
        freqA <= (others => '0');
        freqB <= (others => '0');
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
------------------------------------------- 
-- Connect ports
------------------------------------------- 
 testinteger <= to_integer(unsigned(phase_lut_dout)) - 4;
------------------------------------------- 
-- Async setting of dds params
phase_freq_A(2*PHASE_WIDTH-1 downto PHASE_WIDTH) <= (others => '0');
phase_freq_B(2*PHASE_WIDTH-1 downto PHASE_WIDTH) <= (others => '0');
phase_freq_A(PHASE_WIDTH-1 downto 0) <= freqA;
phase_freq_B(PHASE_WIDTH-1 downto 0) <= freqB;


-----------------------------------------------------------------------
-- Assign TDATA / TUSER fields to aliases, for easy simulator waveform viewing
-----------------------------------------------------------------------

-- Config slave channel alias signals
s_axis_config_tdata_fwd_inv    <= s_axis_config_tdata(0);
s_axis_config_tdata_scale_sch  <= s_axis_config_tdata(10 downto 1);

-- Data slave channel alias signals
s_axis_data_tdata_re           <= s_axis_data_tdata(15 downto 0);
s_axis_data_tdata_im           <= s_axis_data_tdata(31 downto 16);

-- Data master channel alias signals
m_axis_data_tdata_re           <= m_axis_data_tdata(15 downto 0);
m_axis_data_tdata_im           <= m_axis_data_tdata(31 downto 16);
m_axis_data_tuser_xk_index     <= m_axis_data_tuser(9 downto 0);

-----------------------------------------------------------------------
-- Set FFT core inputs
-----------------------------------------------------------------------
s_axis_data_tvalid <= dds_out_valid and enable_fft_core;
s_axis_data_tdata(31 downto 16) <= (others => '0'); -- imaginary data in
s_axis_data_tdata(15 downto 0) <= dds_out & "00";  -- scaled DDS to ADC input, real data in
--s_axis_data_tdata(15 downto 0) <= std_logic_vector(resize(signed(dds_out), ADC_DATA_WIDTH));  -- DDS to ADC input;          -- real data in

s_axis_data_tlast <= dds_out_last;

------------------------------------------- 
-- Generate clocks
------------------------------------------- 
sys_clock_gen : process
begin
sysclk <= '0';
wait for CLOCK_PERIOD;
loop
  sysclk <= not(sysclk);
  wait for CLOCK_PERIOD/2;
end loop;
end process sys_clock_gen;

fft_clock_edge_gen : process
begin
aclk_edge <= '0';
wait for CLOCK_PERIOD;
loop
  aclk_edge <= '1';
  wait for CLOCK_PERIOD;    -- high for one sysclk cycle, use as data valid flag?
  aclk_edge <= '0';
  wait for FFT_CLOCK_PERIOD-CLOCK_PERIOD;
end loop;
end process fft_clock_edge_gen;

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

------------------------------------------- 
-- Simulation
------------------------------------------- 
stim_proc: process
begin
    -- Startup, disable and reset
    testnum <= 0;
    reset <= '1';
    enable <= '0';
    enable_fft_calcs <= '0';
    enable_fft_core <= '0';
    set_dual <= '0';
    
    -- Defaults
    s_axis_config_tdata(10 downto 0) <= "10101010111"; -- FWD FFT, Default scaling
    phase_lut_addr <= (others => '0');
    wait for CLOCK_PERIOD*10;
    
    
    -- Set frequency, enable core
    wait until rising_edge(sysclk);     -- synch
    reset <= '0';
    enable <= '1';
    phase_lut_addr <= std_logic_vector(to_unsigned(8,PHASE_LUT_ADDR_WIDTH));
    wait for CLOCK_PERIOD*2;
    
    enable_fft_core <= '1';     -- enable config/data input to fft ip core
    
    -- Configure fft core
    s_axis_config_tvalid <= '1';
    wait until s_axis_config_tready = '0';
    wait until s_axis_config_tready = '1';
    s_axis_config_tvalid <= '0';  -- Done configure
    
    -- Run sequence to end of FFT using in-bin frequencies
    testnum <= testnum + 1;
    --enable <= '0';  -- disable dds while incrementing phase
    phase_lut_addr <= std_logic_vector(to_unsigned(35,PHASE_LUT_ADDR_WIDTH));
--    bin_f1 <= std_logic_vector(to_unsigned(2,FFT_BIN_WIDTH));
--    bin_f2 <= std_logic_vector(to_unsigned(4,FFT_BIN_WIDTH));
    wait for CLOCK_PERIOD*10;
    --enable <= '1';
        
    -- Enable FFT calcs 
    --wait until dds_out_last = '1';
    wait until m_axis_data_tvalid = '0';
    enable_fft_calcs <= '1';
    wait until data_out_valid_fft_calcs = '1';
    wait for CLOCK_PERIOD;
    enable_fft_calcs <= '0';
    wait for CLOCK_PERIOD*10;
    
    -- Run sequence to end of FFT using in-bin frequencies
    testnum <= testnum + 1;
    phase_lut_addr <= std_logic_vector(to_unsigned(64,PHASE_LUT_ADDR_WIDTH));
--    bin_f1 <= std_logic_vector(to_unsigned(4,FFT_BIN_WIDTH));
--    bin_f2 <= std_logic_vector(to_unsigned(1020,FFT_BIN_WIDTH)); -- see upper bin value
    wait for CLOCK_PERIOD*10;
    
     -- Enable FFT calcs and core
    --wait until dds_out_last = '1';
    wait until m_axis_data_tvalid = '0';
    enable_fft_calcs <= '1';
    wait until data_out_valid_fft_calcs = '1';
    wait for CLOCK_PERIOD;
    
    wait for CLOCK_PERIOD*100;
    enable_fft_calcs <= '0';
    
    -- Repeat, use dual dds this time
    -- Run sequence to end of FFT using in-bin frequencies
    testnum <= testnum + 1;
    wait for CLOCK_PERIOD;
    set_dual <= '1';
    phase_lut_addr <= std_logic_vector(to_unsigned(33,PHASE_LUT_ADDR_WIDTH));
    wait for CLOCK_PERIOD;
    set_dual <= '0';
    phase_lut_addr <= std_logic_vector(to_unsigned(32,PHASE_LUT_ADDR_WIDTH));
--    bin_f1 <= std_logic_vector(to_unsigned(2,FFT_BIN_WIDTH));
--    bin_f2 <= std_logic_vector(to_unsigned(4,FFT_BIN_WIDTH));
    wait for CLOCK_PERIOD*10;

    -- Enable FFT calcs and core
    --wait until dds_out_last = '1';
    
    wait until m_axis_data_tvalid = '0';
    enable_fft_calcs <= '1';
    wait until data_out_valid_fft_calcs = '1';
    wait for CLOCK_PERIOD*8000;
    
    std.env.stop;
end process stim_proc;

end testbench;
