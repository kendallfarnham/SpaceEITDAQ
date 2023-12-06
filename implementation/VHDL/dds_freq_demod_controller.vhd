----------------------------------------------------------------------------------
-- Company: Thayer School of Engineering, Dartmouth College
-- Engineer: Kendall Farnham
-- 
-- Create Date: 08/16/2023 07:01:54 PM
-- Design Name: 
-- Module Name: dds_freq_demod_controller - Behavioral
-- Project Name: 2023_DAQ
-- Target Devices: Artix 7 (Trenz Electronics TE0711-01)
-- Tool Versions: Vivado 2022.2
-- Description: Demodulate ADC data -> FIFO -> FFT -> BRAM
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
use ieee.std_logic_unsigned.all;

entity dds_freq_demod_controller is
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
        n_averages : in integer;        -- Run the ADC->FIFO->FFT n_averages times, save all to BRAM
        use_slow_fs : in STD_LOGIC;     -- use slow sampling rate (for low freqs)
        read_en : in STD_LOGIC;         -- enable output
        
        output_rdy : out STD_LOGIC;     -- ready for output
        serial_out : out STD_LOGIC      -- serial out to UART
        );
end dds_freq_demod_controller;
----------------------------------------------------------------------------------
architecture Behavioral of dds_freq_demod_controller is
----------------------------------------------------------------------------------
-- Constants
constant NFFT : integer := 2**FFT_BIN_WIDTH;
constant MAG2SUM_DATA_WIDTH : integer := 2*DATA_WIDTH;  -- number of bits used in sum mag squared 

-- BRAM data saved as [ 0000... SumMagSq F_re(k2) F_im(k2) F_re(k1) F_im(k1) F_re(0) F_im(0) nAvg] in min 16-bit packets
constant BRAM_DATA_WIDTH : integer := MAG2SUM_DATA_WIDTH + 7*DATA_WIDTH; -- BRAM data width
constant BRAM_ADDR_WIDTH : integer := 11;       -- BRAM address width
constant MAX_AVERAGES : integer := 2**BRAM_ADDR_WIDTH;     -- max number of averages to compute/store (BRAM depth)
--constant MAX_AVERAGES : integer := 6400;     -- max number of averages to compute/store (BRAM depth)
constant MAX_AVERAGES_SIM : integer := 4;       -- USE FOR SIMULATION
constant FIFO_RST_WCLK_CNT_MAX : integer := 6;  -- FIFO reset must be held for at least 5 wr_clk cycles
----------------------------------------------------------------------------------
-- Variable constants
signal BRAM_ADDR_MAX : integer := MAX_AVERAGES;
----------------------------------------------------------------------------------
-- FFT controller signals
signal fft_data_in, re_out, im_out : std_logic_vector(DATA_WIDTH-1 downto 0);
signal fft_bin : std_logic_vector(FFT_BIN_WIDTH-1 downto 0);
signal fft_ready, fft_out_last, fft_failed : std_logic := '0';
signal fft_rx_ready, fft_data_in_valid, fft_data_in_last : std_logic := '0';
signal count_fft_clk_div : integer := 0;

----------------------------------------------------------------------------------
-- Signals for fft_calcs
signal enable_fft_calcs, data_out_valid_fft_calcs, fft_data_valid : std_logic := '0';
signal re_im_out_f1, re_im_out_f2 : STD_LOGIC_VECTOR (2*DATA_WIDTH-1 downto 0) := (others => '0');
signal dc_out : STD_LOGIC_VECTOR (2*DATA_WIDTH-1 downto 0) := (others => '0');
signal mag_sum2_out : STD_LOGIC_VECTOR (MAG2SUM_DATA_WIDTH-1 downto 0) := (others => '0');

----------------------------------------------------------------------------------
-- Signals for fifo_generator
--signal fifo_en_write, fifo_en_write_aclk, fifo_en_read : std_logic := '0';
--signal fifo_stop_write, fifo_wr_en_d, fifo_reset_done : std_logic := '0';
signal wr_en, rd_en, full, full_d, empty, overflow, underflow, reset_fifo : std_logic := '0';
signal fifo_data_in, fifo_data_out : std_logic_vector(DATA_WIDTH-1 downto 0) := (others => '0');
signal aclk_counter : integer range 0 to FIFO_RST_WCLK_CNT_MAX := 0;
----------------------------------------------------------------------------------
-- blk_mem_gen control signals
signal bram_dout, bram_din : std_logic_vector(BRAM_DATA_WIDTH-1 downto 0) := (others => '0');
signal bram_addr : std_logic_vector(BRAM_ADDR_WIDTH-1 downto 0) := (others => '0'); -- use with blk_mem_gen_3
signal bram_wen : std_logic_vector(0 downto 0) := (others => '1');        -- use with blk_mem_gen_3
signal bram_dis, end_of_bram, incr_bram_addr, rst_bram_addr, bram_din_valid : std_logic := '0';
signal avg_num : std_logic_vector(DATA_WIDTH-1 downto 0) := (others => '0');       -- save to bram for debug
----------------------------------------------------------------------------------
-- UART-BRAM communication control signals
signal uart_din : std_logic_vector(BRAM_DATA_WIDTH-1 downto 0) := (others => '0');
signal uart_en, done_tx, tx_busy, reset_n : std_logic := '0'; 
----------------------------------------------------------------------------------
-- Signals for  FSM
----------------------------------------------------------------------------------
type state_type is (IdleState, ResetBramAddr, StartWriteFifo, WriteFifo, WaitRead, ReadFifo, WaitFFT, 
        ReadFFT, WaitCalcs, SaveCalcs, NextDataset, WaitSync, WaitBRAM, WaitUART, ReadUART, SendUART, NextUARTData, DoneSend);
signal curr_state, next_state : state_type := IdleState;
-------------------------------------------------------------------------
-- Signals for FIFO FSM
--type fifo_state_type is (FifoDisableWrite, FifoReset, FifoResetHold, 
--        FifoEmpty, FifoFull, FifoStartWrite, FifoWrite, FifoRead); -- FifoWaitSyncRise, FifoWaitSyncFall
--signal fifo_state : fifo_state_type := FifoEmpty;
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
-- BRAM to store FFT calculations
COMPONENT blk_mem_gen_3
  PORT (
    clka : IN STD_LOGIC;
    wea : IN STD_LOGIC_VECTOR(0 DOWNTO 0);
    addra : IN STD_LOGIC_VECTOR(BRAM_ADDR_WIDTH-1 DOWNTO 0);
    dina : IN STD_LOGIC_VECTOR(BRAM_DATA_WIDTH-1 DOWNTO 0);
    douta : OUT STD_LOGIC_VECTOR(BRAM_DATA_WIDTH-1 DOWNTO 0) 
  );
END COMPONENT;
----------------------------------------------------------------------------------
-- UART transfer out
component uart_controller_8b
GENERIC(
    DEBUG_MODE : std_logic := DEBUG_MODE;
    DATA_WIDTH : INTEGER := BRAM_DATA_WIDTH);  --size of the binary input numbers in bits
Port ( clk : in std_logic;              -- 100 MHz clock
   data_in : in std_logic_vector(BRAM_DATA_WIDTH-1 downto 0);    -- input from BRAM
   enable_uart_tx : in std_logic;   -- write data_in to uart
   done_tx : out std_logic;         -- finished transfer
   uart_txd : out std_logic);       -- UART out
end component;
----------------------------------------------------------------------------------
begin
----------------------------------------------------------------------------------
---- Set variable constants --> use sim value when DEBUG_MODE = '1'
--BRAM_ADDR_MAX <= MAX_AVERAGES_SIM when DEBUG_MODE = '1'
--        else n_averages when (n_averages < MAX_AVERAGES)
--        else MAX_AVERAGES;
----------------------------------------------------------------------------------
-- Clock in n_averages input -- failed timing 
set_var_const: process(sysclk)
begin
    if rising_edge(sysclk) then
        if (DEBUG_MODE = '1') then
            BRAM_ADDR_MAX <= MAX_AVERAGES_SIM;
        elsif (n_averages < MAX_AVERAGES) then
            BRAM_ADDR_MAX <= n_averages;
        else
            BRAM_ADDR_MAX <= MAX_AVERAGES;
        end if;
    end if;
end process set_var_const;
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
    reset => reset_fifo,
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
    rst => reset_fifo,
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
bram_data : blk_mem_gen_3
  PORT MAP (
    clka => sysclk,    -- use system clock 
    wea => bram_wen,
    addra => bram_addr,
    dina => bram_din,  
    douta => bram_dout
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
uart_din <= bram_dout;    -- BRAM to UART

-- Hook up FIFO inputs and outputs
fifo_data_in <= adin;                   -- ADC to FIFO
fft_data_in <= fifo_data_out;           -- FIFO to FFT

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
-- Set BRAM inputs
----------------------------------------------------------------------------------
-- Write data from fft calcs to BRAM, read to UART
-- [ 0000... SumMagSq F_re(k2) F_im(k2) F_re(k1) F_im(k1) F_re(0) F_im(0) nAvg]
write_fftcalcs_to_bram: process(sysclk)
begin
if rising_edge(sysclk) then   
    -- Data in (concat)
    bram_din_valid <= '0';              -- default
    if (curr_state = IdleState) then
        bram_din <= (others => '0');    -- initialize/clear intput data
    elsif (data_out_valid_fft_calcs = '1') then
        bram_din <= mag_sum2_out & re_im_out_f2 & re_im_out_f1 & dc_out & avg_num;
        bram_din_valid <= '1';          -- write to bram on next clock cycle
    end if;
    
    avg_num <= (others => '0'); -- set MSBs to 0
    avg_num(BRAM_ADDR_WIDTH-1 downto 0) <= bram_addr;   -- store dataset number (also bram address)
    
    -- Write enable
    if (bram_din_valid = '1') then
        bram_wen <= (others => '1');    -- write data to BRAM
    else
        bram_wen <= (others => '0');    -- disable write
    end if;
    
    -- Address logic
    if (rst_bram_addr = '1') then       -- reset takes precedence
        bram_addr <= (others => '0');   -- reset address for the next read/write
    elsif (incr_bram_addr = '1') then
        if (unsigned(bram_addr) = BRAM_ADDR_MAX-1) then
            bram_addr <= (others => '0');   -- reset address to start
        else            
            bram_addr <= bram_addr + 1;     -- increment block ram address 
        end if;
    end if;
    
    -- End of BRAM signal
    if (curr_state = IdleState or curr_state = WaitUART ) then
        end_of_bram <= '0';             -- clear signal, not at end of bram
    elsif (unsigned(bram_addr) = BRAM_ADDR_MAX-1) then
        end_of_bram <= '1';             -- set signal to fsm     
    end if;
    
end if;
end process write_fftcalcs_to_bram;

----------------------------------------------------------------------------------
-- Logic to connect ADC --> FIFO --> FFT --> BRAM --> UART
----------------------------------------------------------------------------------
comb_logic : process(curr_state, full_d, full, empty, fft_ready, fft_out_last, adin_sync_start,
    data_out_valid_fft_calcs, end_of_bram, enable, reset, done_tx, read_en, fft_failed) 
begin
 -- Defaults
next_state <= curr_state;   
rd_en <= '0';               -- FIFO
reset_fifo <= '0';          -- FIFO
fft_rx_ready <= '0';        -- FFT controller
fft_data_in_last <= '0';    -- FFT
fft_data_in_valid <= '0';   -- FFT
fft_data_valid <= '0';      -- FFT spectrum calculations (data in)
enable_fft_calcs <= '0';    -- FFT spectrum calculations
uart_en <= '0';             -- UART
incr_bram_addr <= '0';      -- BRAM
rst_bram_addr <= '0';       -- BRAM
output_rdy <= '0';

-- Global reset/disable
if (reset = '1' or enable = '0' or fft_failed = '1') then 
    next_state <= IdleState;
else
    case(curr_state) is
        when IdleState =>      -- start here
            rst_bram_addr <= '1';
            reset_fifo <= '1';
            if (enable = '1' and reset = '0') then
                next_state <= ResetBramAddr;
            end if;
            
        when ResetBramAddr =>
            rst_bram_addr <= '1';   -- reset bram address after DoneSend state
            next_state <= WaitSync;
--            if (adin_sync_start = '1') then 
--                next_state <= StartWriteFifo;
--            end if;
            
        when WaitSync =>            -- wait until end of period, then start write
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
            
        when WaitCalcs =>       -- wait for calcs to be valid before writing to bram
            enable_fft_calcs <= '1';
            if (data_out_valid_fft_calcs = '1') then
                next_state <= SaveCalcs;
            end if;
                        
        when SaveCalcs =>       -- write to BRAM
            enable_fft_calcs <= '1';
            next_state <= NextDataset;
        
        when NextDataset =>         
            if end_of_bram = '1' then
                rst_bram_addr <= '1';   -- reset address to 0 prior to send to UART
                next_state <= WaitBRAM; 
            else            -- increment block ram address and repeat
                incr_bram_addr <= '1';  -- increment address
                next_state <= WriteFifo;
                --next_state <= WaitSync; -- added about 50% more time to acquisition
            end if;
       
        
        when WaitBRAM =>            -- wait for BRAM read latency after rst_bram_addr = '1'
            next_state <= WaitUART;
            
        when WaitUART =>        -- Note: discard first 32-bits sent by UART (in MATLAB code)
            output_rdy <= '1';
            if (read_en = '1' and done_tx = '1') then
                next_state <= SendUART;
            end if;
            
         when SendUART =>    -- Send data over UART - LSB is real data/spectrum     
            output_rdy <= '1';
            uart_en <= '1'; 
            if (done_tx = '0') then     -- wait until UART signal goes low
                incr_bram_addr <= '1';  -- increment address (2 clock cycle latency for read)
                next_state <= ReadUART;
            end if;            
                
        when ReadUART =>    -- Read data to UART controller - MSB is imaginary data/spectrum, LSB is real
            output_rdy <= '1';
            uart_en <= '1';
            if (done_tx = '1') then  -- wait until finished transfer to send next
                next_state <= NextUARTData;
            end if;
        
        when NextUARTData => -- increment block ram address
            output_rdy <= '1';
            uart_en <= '1'; -- hold high
            if end_of_bram = '1' then
                uart_en <= '0';
                next_state <= DoneSend; 
            else            -- increment block ram address and repeat
                next_state <= SendUART;
            end if;
                        
        when DoneSend =>    -- hold output_rdy flag high while sending last data
            output_rdy <= '1';
            if (done_tx = '1') then -- wait until last data was sent
                next_state <= ResetBramAddr;
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