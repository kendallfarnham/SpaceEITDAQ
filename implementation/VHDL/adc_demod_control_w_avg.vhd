----------------------------------------------------------------------------------
-- Company: Thayer School of Engineering, Dartmouth College
-- Engineer: Kendall Farnham
-- 
-- Create Date: 09/13/2023 07:01:54 PM
-- Design Name: 
-- Module Name: adc_demod_control_w_avg - Behavioral
-- Project Name: 2023_DAQ
-- Target Devices: Artix 7 (Trenz Electronics TE0711-01)
-- Tool Versions: Vivado 2022.2
-- Description: Demodulate ADC data -> FIFO -> FFT -> MACC -> AVG -> UART
--              Compute SNR/THD calcultions from FFT spectrum data
--      Outputs: 
--          real and imaginary fft data for signal freqs 1 & 2 (dualtone)
--          DC magnitude (bin zero of FFT, always real)
--          Squared sum of magnitudes (i.e., sum(re^2 + im^2))
-- Revision 0.01 File Created
--
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
--use ieee.std_logic_unsigned.all;

entity adc_demod_control_w_avg is
  Generic (
        DEBUG_MODE : std_logic := '0';
        SLOW_SAMP_CLKDIV : integer := 64; -- divide adc clock by this amount if use_slow_fs = '1'
        FFT_BIN_WIDTH : integer := 10;    -- 2**FFT_BIN_WIDTH number of bins in FFT
        DATA_WIDTH : integer := 16);    -- data bus
  Port ( sysclk : in STD_LOGIC;         -- system clock
        aclk : in STD_LOGIC;            -- adc clock
        enable : in STD_LOGIC;
        reset : in STD_LOGIC;
        adin: in STD_LOGIC_VECTOR (DATA_WIDTH-1 downto 0);    -- from ADC
        adin_sync_start : in STD_LOGIC;
        
        bin_f1 : in STD_LOGIC_VECTOR (FFT_BIN_WIDTH-1 downto 0);    -- fft bin of signal freq 1 (first half)
        bin_f2 : in STD_LOGIC_VECTOR (FFT_BIN_WIDTH-1 downto 0);    -- fft bin of signal freq 2 if dualtone (first half)    
        use_full_spectrum : in STD_LOGIC;                           -- use full FFT spectrum for THD calcs (default is to use half)    
        use_slow_fs : in STD_LOGIC;     -- use slow sampling rate (for low freqs)
        read_en : in STD_LOGIC;         -- enable output
        
        output_rdy : out STD_LOGIC;     -- ready for output
        serial_out : out STD_LOGIC      -- serial out to UART
        );
end adc_demod_control_w_avg;
----------------------------------------------------------------------------------
architecture Behavioral of adc_demod_control_w_avg is
----------------------------------------------------------------------------------
-- Constants
constant NFFT : integer := 2**FFT_BIN_WIDTH;
constant NAVERAGES : integer := 8;      -- number of averages to compute/store
constant ADD_SUM_BITS : integer := 3;   --  add this many bits to DATA_WIDTH for sum/avg
constant MAG2SUM_DATA_WIDTH : integer := 2*DATA_WIDTH;  -- number of bits used in sum mag squared 
-- Output data saved as [ 0000... SumMagSq F_re(k2) F_im(k2) F_re(k1) F_im(k1) F_re(0) F_im(0) nAvg] in min 16-bit packets
constant UART_DATA_WIDTH : integer := MAG2SUM_DATA_WIDTH + 5*DATA_WIDTH; -- width of data sent over uart
constant MACC_DATA_WIDTH : integer := DATA_WIDTH + ADD_SUM_BITS;  -- data width of macc

----------------------------------------------------------------------------------
-- Variable constants

----------------------------------------------------------------------------------
-- FFT controller signals
signal fft_data_in, re_out, im_out : std_logic_vector(DATA_WIDTH-1 downto 0);
signal fft_bin : std_logic_vector(FFT_BIN_WIDTH-1 downto 0);
signal fft_ready, fft_out_last, fft_failed : std_logic := '0';
signal fft_rx_ready, fft_data_in_valid, fft_data_in_last : std_logic := '0';
signal count_fft_clk_div : integer := 0;

----------------------------------------------------------------------------------
-- Signals for fifo_generator
signal wr_en, rd_en, full, full_d, empty, overflow, underflow : std_logic := '0';
signal fifo_data_in, fifo_data_out : std_logic_vector(DATA_WIDTH-1 downto 0) := (others => '0');

----------------------------------------------------------------------------------
-- Signals for fft_calcs
signal enable_fft_calcs, data_out_valid_fft_calcs, fft_data_valid : std_logic := '0';
signal re_im_out_f1, re_im_out_f2 : STD_LOGIC_VECTOR(2*DATA_WIDTH-1 downto 0) := (others => '0');
signal dc_out : STD_LOGIC_VECTOR(2*DATA_WIDTH-1 downto 0) := (others => '0');
signal mag_sum2_out : STD_LOGIC_VECTOR(MAG2SUM_DATA_WIDTH-1 downto 0) := (others => '0');
signal re_f1, im_f1, re_f2, im_f2, re_dc : STD_LOGIC_VECTOR(DATA_WIDTH-1 downto 0) := (others => '0');

----------------------------------------------------------------------------------
-- Signals for summing logic
signal avg_re_f1, avg_im_f1, avg_re_f2, avg_im_f2, avg_re_dc : unsigned(MACC_DATA_WIDTH-1 downto 0) := (others => '0');
signal sum_dc, sum_re_f1, sum_im_f1, sum_re_f2, sum_im_f2 : unsigned(MACC_DATA_WIDTH-1 downto 0) := (others => '0');
signal sum_mag2, avg_mag2 : unsigned(MAG2SUM_DATA_WIDTH+ADD_SUM_BITS downto 0) := (others => '0');
signal done_sum, reset_sum : std_logic := '0';
signal avg_num : integer := 0;  -- counter
----------------------------------------------------------------------------------
-- UART-BRAM communication control signals
signal uart_din : std_logic_vector(UART_DATA_WIDTH-1 downto 0) := (others => '0');
signal uart_en, done_tx, tx_busy, reset_n : std_logic := '0'; 
----------------------------------------------------------------------------------
-- Signals for  FSM
----------------------------------------------------------------------------------
type state_type is (IdleState, WaitDDS, StartWriteFifo, WriteFifo, WaitRead, ReadFifo, WaitFFT, 
        ReadFFT, WaitCalcs, SaveCalcs, NextDataset, ComputeAverage, WaitUART, ReadUART, SendUART, DoneSend);
signal curr_state, next_state : state_type := IdleState;

----------------------------------------------------------------------------------
-- Component declarations
----------------------------------------------------------------------------------
-- FFT core controller
component fft_controller is
Generic (
    FFT_DATA_WIDTH : integer := DATA_WIDTH;    -- size of fft_out bus
    FFT_BIN_WIDTH : integer := FFT_BIN_WIDTH); -- 2**FFT_BIN_WIDTH number of bins 
Port ( clk : in STD_LOGIC;     -- fast clock for fft
       enable : in STD_LOGIC;       -- enable fft core
       reset : in STD_LOGIC;        -- reconfigure fwd fft and reset
       data_in : in STD_LOGIC_VECTOR (FFT_DATA_WIDTH-1 downto 0);
       data_in_valid : in STD_LOGIC;    -- enable input to FFT (s_axis_data_tvalid)
       data_in_last : in STD_LOGIC;     -- use to synchronize dds/adc input to fft
       fft_rx_ready : in STD_LOGIC;     -- enable output (m_axis_data_tready)
       re_out : out STD_LOGIC_VECTOR (FFT_DATA_WIDTH-1 downto 0);
       im_out : out STD_LOGIC_VECTOR (FFT_DATA_WIDTH-1 downto 0);
       bin: out STD_LOGIC_VECTOR (FFT_BIN_WIDTH-1 downto 0); -- fft bin number
       fft_failed : out STD_LOGIC;  -- high when error event occurs
       fft_ready : out STD_LOGIC;
       send_last : out STD_LOGIC);
end component;
----------------------------------------------------------------------------------
-- FFT calculations (DC bin, signal bin, sum magnitude squared)
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
       dc_out : out STD_LOGIC_VECTOR (2*FFT_DATA_WIDTH-1 downto 0);             -- complex data (Re Im) of bin 0 - dc magnitude, im data is 0
       macc_overflow : out STD_LOGIC;                                           -- overflow on accumulator
       mag_sum2_out : out STD_LOGIC_VECTOR (MAG2SUM_DATA_WIDTH-1 downto 0));    -- squared sum of magnitudes (i.e., sum(re^2 + im^2))
end component;
------------------------------------------------------------------------------------
-- FIFO IP core
COMPONENT fifo_generator_0
  PORT (
    rst : IN STD_LOGIC;
    wr_clk : IN STD_LOGIC;
    rd_clk : IN STD_LOGIC;
    din : IN STD_LOGIC_VECTOR(DATA_WIDTH-1 DOWNTO 0);
    wr_en : IN STD_LOGIC;
    rd_en : IN STD_LOGIC;
    dout : OUT STD_LOGIC_VECTOR(DATA_WIDTH-1 DOWNTO 0);
    full : OUT STD_LOGIC;
    overflow : OUT STD_LOGIC;
    empty : OUT STD_LOGIC;
    underflow : OUT STD_LOGIC
  );
END COMPONENT;

----------------------------------------------------------------------------------
-- UART transfer out
component uart_controller_8b
GENERIC(
    DEBUG_MODE : std_logic := DEBUG_MODE;
    DATA_WIDTH : INTEGER := UART_DATA_WIDTH);  --size of the binary input numbers in bits
Port ( clk : in std_logic;              -- 100 MHz clock
   data_in : in std_logic_vector(UART_DATA_WIDTH-1 downto 0);    -- input from BRAM
   enable_uart_tx : in std_logic;   -- write data_in to uart
   done_tx : out std_logic;         -- finished transfer
   uart_txd : out std_logic);       -- UART out
end component;
----------------------------------------------------------------------------------
begin
----------------------------------------------------------------------------------
-- Port map
----------------------------------------------------------------------------------
fft: fft_controller port map (
    clk => sysclk,
    enable => enable,
    reset => reset,         -- reconfigure fwd fft and reset
    data_in => fft_data_in, -- data from fifo
    data_in_valid => fft_data_in_valid,   -- enable input to FFT (s_axis_data_tvalid)
    data_in_last => fft_data_in_last,
    fft_rx_ready => fft_rx_ready,     -- enable output (m_axis_data_tready)
    re_out => re_out,
    im_out => im_out,
    bin => fft_bin,             -- fft bin number
    fft_failed => fft_failed,
    fft_ready => fft_ready,
    send_last => fft_out_last);
----------------------------------------------------------------------------------
fft_computations: fft_calcs port map (
    clk => sysclk,
    reset => reset,
    enable => enable_fft_calcs,     -- use enable to only calculate when valid fft output (m_axis_data_tvalid)
    data_in_valid => fft_data_valid,     -- hooked up to s/m_axis_data_tvalid in fft_controller
    re_in => re_out,
    im_in => im_out,
    bin_in => fft_bin,
    bin_f1 => bin_f1,
    bin_f2 => bin_f2,
    use_full_spectrum => use_full_spectrum,
    data_out_valid => data_out_valid_fft_calcs,
    re_im_out_f1 => re_im_out_f1,
    re_im_out_f2 => re_im_out_f2,
    dc_out => dc_out,
    macc_overflow => open,
    mag_sum2_out => mag_sum2_out );
----------------------------------------------------------------------------------
fifo : fifo_generator_0
  PORT MAP (
    rst => reset,
    wr_clk => aclk,         -- fft data sampling rate (fastest)
    rd_clk => sysclk,       -- fast clock for read to fft controller
    din => fifo_data_in,
    wr_en => wr_en,         -- use wr_en to control slower sampling rates
    rd_en => rd_en,
    dout => fifo_data_out,
    full => full,
    overflow => overflow,
    empty => empty,
    underflow => underflow
  );
 
----------------------------------------------------------------------------------
uart_tx_ctrl: uart_controller_8b port map( 
    clk => sysclk,          -- 100 MHz clock
    data_in => uart_din,
    enable_uart_tx => uart_en,
    done_tx => done_tx,
    uart_txd => serial_out);

----------------------------------------------------------------------------------
-- Connect modules
----------------------------------------------------------------------------------
-- Hook up uart input data to relevant bytes
uart_din <= std_logic_vector(avg_mag2(MAG2SUM_DATA_WIDTH-1 downto 0)
        & avg_re_f2(DATA_WIDTH-1 downto 0) & avg_im_f2(DATA_WIDTH-1 downto 0) 
        & avg_re_f1(DATA_WIDTH-1 downto 0) & avg_im_f1(DATA_WIDTH-1 downto 0) & avg_re_dc(DATA_WIDTH-1 downto 0));

-- Hook up FIFO inputs and outputs
fifo_data_in <= adin;                   -- ADC to FIFO
fft_data_in <= fifo_data_out;           -- FIFO to FFT

-- Alias
re_f1 <= re_im_out_f1(2*DATA_WIDTH-1 downto DATA_WIDTH);
im_f1 <= re_im_out_f1(DATA_WIDTH-1 downto 0);
re_f2 <= re_im_out_f2(2*DATA_WIDTH-1 downto DATA_WIDTH);
im_f2 <= re_im_out_f2(DATA_WIDTH-1 downto 0);
re_dc <= dc_out(2*DATA_WIDTH-1 downto DATA_WIDTH);

----------------------------------------------------------------------------------
-- Clock domain crossing (FIFO write clock is slower than read clock)
----------------------------------------------------------------------------------
-- Catch edges of fifo 'full' signal (on slower clock)
fifo_full_aclk : process(aclk)
begin
if (rising_edge(aclk)) then
     full_d <= full;
end if;
end process fifo_full_aclk;

----------------------------------------------------------------------------------
-- Sample ADC data for fft - lower frequencies have slower sample rate
-- Write enable to fifo controlled here bc needs to be synced with aclk (fsm is sysclk)
write_adc_sample_to_fifo: process(aclk)
begin
if rising_edge(aclk) then      
    if (next_state = StartWriteFifo) then       
        if (use_slow_fs = '1') then -- sample on slow clock           
            count_fft_clk_div <= SLOW_SAMP_CLKDIV-1;  -- reset counter to capture first data sample
        else
            wr_en <= '1';   -- enable write to fifo on this clock cycle to capture first sample when using aclk
        end if;
        
    elsif (next_state = WriteFifo or curr_state = WriteFifo) then -- start counting on rising edge of curr_state = WriteFifo
        if (use_slow_fs = '1') then -- sample on slow clock
            if (count_fft_clk_div = SLOW_SAMP_CLKDIV-1) then -- clk period (156.25 kHz = aclk/64, or sysclk/640)
                count_fft_clk_div <= 0;  -- reset counter
                wr_en <= '1';   -- enable write to fifo
            else
                count_fft_clk_div <= count_fft_clk_div + 1;
                wr_en <= '0';
            end if;
        else    -- sample other frequencies on aclk
            wr_en <= '1';   -- enable write to fifo
        end if;
        
    else
        count_fft_clk_div <= SLOW_SAMP_CLKDIV-1;  -- capture the first data sample of the period
        wr_en <= '0';
    end if;
end if;
end process write_adc_sample_to_fifo;

----------------------------------------------------------------------------------
-- Sum the absolute values of fft calc outputs
----------------------------------------------------------------------------------
macc_sum_process: process(sysclk)
begin
if rising_edge(sysclk) then   
    -- Adder
    if (reset_sum = '1') then
        sum_dc <= (others => '0');    -- initialize/clear intput data
        sum_re_f1 <= (others => '0'); 
        sum_im_f1 <= (others => '0'); 
        sum_re_f2 <= (others => '0'); 
        sum_im_f2 <= (others => '0'); 
        sum_mag2 <= (others => '0'); 
        avg_num <= 0;
    elsif (data_out_valid_fft_calcs = '1') then     -- sum
        sum_dc <= sum_dc + to_unsigned(to_integer(abs(signed(re_dc))),MACC_DATA_WIDTH);
        sum_re_f1 <= sum_re_f1 + to_unsigned(to_integer(abs(signed(re_f1))),MACC_DATA_WIDTH);
        sum_im_f1 <= sum_im_f1 + to_unsigned(to_integer(abs(signed(im_f1))),MACC_DATA_WIDTH);
        sum_re_f2 <= sum_re_f2 + to_unsigned(to_integer(abs(signed(re_f2))),MACC_DATA_WIDTH);
        sum_im_f2 <= sum_im_f2 + to_unsigned(to_integer(abs(signed(im_f2))),MACC_DATA_WIDTH);
        sum_mag2 <= sum_mag2 + to_unsigned(to_integer(unsigned(mag_sum2_out)),sum_mag2'length);
        avg_num <= avg_num + 1; -- increment counter
    end if;
    
    -- FSM flag
    if avg_num = NAVERAGES then
        done_sum <= '1';            -- set fsm flag high
    else
        done_sum <= '1';            -- clear
    end if;
    
    -- Take average
    if (reset_sum = '1') then
        avg_re_dc <= (others => '0');
        avg_re_f1 <= (others => '0');
        avg_im_f1 <= (others => '0');
        avg_re_f2 <= (others => '0');
        avg_im_f2 <= (others => '0');
        avg_mag2 <= (others => '0');
    elsif (curr_state = ComputeAverage) then
        avg_re_dc <= sum_dc/NAVERAGES;
        avg_re_f1 <= sum_re_f1/NAVERAGES;
        avg_im_f1 <= sum_im_f1/NAVERAGES;
        avg_re_f2 <= sum_re_f2/NAVERAGES;
        avg_im_f2 <= sum_im_f2/NAVERAGES;
        avg_mag2 <= sum_mag2/NAVERAGES;
    end if;
    
    
end if;
end process macc_sum_process;

----------------------------------------------------------------------------------
-- Logic to connect ADC --> FIFO --> FFT --> MACC --> AVG --> UART
----------------------------------------------------------------------------------
comb_logic : process(curr_state, full_d, full, empty, fft_ready, fft_out_last, adin_sync_start,
    data_out_valid_fft_calcs, done_sum, enable, reset, done_tx, read_en, fft_failed) 
begin
 -- Defaults
next_state <= curr_state;   
rd_en <= '0';               -- FIFO
fft_rx_ready <= '0';        -- FFT controller
fft_data_in_last <= '0';    -- FFT
fft_data_in_valid <= '0';   -- FFT
fft_data_valid <= '0';      -- FFT spectrum calculations (data in)
enable_fft_calcs <= '0';    -- FFT spectrum calculations
uart_en <= '0';             -- UART
reset_sum <= '0';           -- MACC
output_rdy <= '0';

-- Global reset/disable
if (reset = '1' or enable = '0' or fft_failed = '1') then 
    next_state <= IdleState;
else
    case(curr_state) is
        when IdleState =>      -- start here
            reset_sum <= '1';
            if (enable = '1' and reset = '0') then
                next_state <= WaitDDS;
            end if;
            
        when WaitDDS =>         -- wait until end of period, then start write
            reset_sum <= '1';     -- reset bram address after DoneSend state
            if (adin_sync_start = '1') then 
                next_state <= StartWriteFifo;
            end if;
            
        when StartWriteFifo =>
            if (adin_sync_start = '0') then    -- adc running on slower clock, wait until falls low 
                next_state <= WriteFifo;
            end if;
            
        when WriteFifo =>       -- write data to fifo (and BRAM), wait for sample to be ready
            if (full = '1') then
                next_state <= WaitRead;
            end if;            
        
            
        when WaitRead =>        -- wait until FFT is ready and fifo "full" signal was high for 1 aclk cycle
            if (fft_ready = '1' and full_d = '1') then
                rd_en <= '1';           -- enable fifo read
                next_state <= ReadFifo;
            end if;
        
        when ReadFifo =>        -- read fifo to FFT
            rd_en <= '1';           -- enable fifo read
            fft_data_in_valid <= '1';   -- set fft data_in_valid
            if (fft_ready = '0') then
                rd_en <= '0';           -- disable fifo read while fft is busy
            elsif (empty = '1') then
                fft_data_in_last <= '1';    -- fft data_in_last
                next_state <= WaitFFT;
            end if;
            
        when WaitFFT =>                 -- wait until fft finishes computing spectrum
            fft_rx_ready <= '1';
            enable_fft_calcs <= '1';
            if (fft_ready = '1') then
                fft_data_valid <= '1';  -- to fft calcs
                next_state <= ReadFFT;
            end if;
            
        when ReadFFT =>         -- read fft spectrum
            fft_rx_ready <= '1';
            enable_fft_calcs <= '1';
            fft_data_valid <= '1';  -- to fft calcs
            if (fft_out_last = '1') then
                next_state <= WaitCalcs;
            end if;
            
        when WaitCalcs =>       -- wait for calcs to be valid
            enable_fft_calcs <= '1';
            if (data_out_valid_fft_calcs = '1') then
                next_state <= SaveCalcs;
            end if;
                        
        when SaveCalcs =>       -- add to MACC
            enable_fft_calcs <= '1';
            next_state <= NextDataset;
        
        when NextDataset =>         
            if done_sum = '1' then
                next_state <= ComputeAverage;   -- done acquisition, take average of sums
            else            
                next_state <= WriteFifo;        -- increment avg num and repeat
            end if;
            
        when ComputeAverage =>
            next_state <= WaitUART;
        
        when WaitUART =>       
            output_rdy <= '1';
            if (read_en = '1' and done_tx = '1') then
                next_state <= SendUART;
            end if;
            
         when SendUART =>    -- Send data over UART - LSB is real data/spectrum     
            output_rdy <= '1';
            uart_en <= '1'; 
            if (done_tx = '0') then     -- wait until UART signal goes low
                next_state <= ReadUART;
            end if;            
                
        when ReadUART =>    -- Read data to UART controller - MSB is imaginary data/spectrum, LSB is real
            output_rdy <= '1';
            uart_en <= '1';
            if (done_tx = '1') then  -- wait until finished transfer to send next
                next_state <= DoneSend;
            end if;
                        
        when DoneSend =>    -- hold output_rdy flag high while sending last data
            output_rdy <= '1';
            if (done_tx = '1') then -- wait until last data was sent
                next_state <= WaitDDS;
            end if;
                                      
        when others =>  -- should never reach
            next_state <= IdleState;
            
    end case;
end if;
end process comb_logic;
----------------------------------------------------------------------------------
state_update: process(sysclk)
begin
    if rising_edge(sysclk) then
        curr_state <= next_state;
    end if;
end process state_update;
----------------------------------------------------------------------------------

      
end Behavioral;
