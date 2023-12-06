----------------------------------------------------------------------------------
-- Company: Thayer School of Engineering, Dartmouth College
-- Engineer: Kendall Farnham
-- 
-- Create Date: 07/13/2023
-- Design Name: 
-- Module Name: demod_controller - Behavioral
-- Project Name: 2023_DAQ
-- Target Devices: Artix 7 (Trenz Electronics TE0711-01)
-- Tool Versions: Vivado 2022.2
-- Description: Read digital data into fifo -> fft -> block ram, read out to uart
-- 
-- Dependencies:    fft_controller, xfft_1
--                  fifo_generator_1
--                  blk_mem_gen_1
--                  uart_tx
-- 
-- Revision 0.01 - 03/01/2021 File Created (demod_to_bram.vhd)
-- Revision 0.02 - 7/13/2023 Copied from 2023_DAQ_64ch_v2.srcs
-- 
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use ieee.std_logic_unsigned.all;

entity demod_controller is
  Generic (
        DEBUG_MODE : std_logic := '0';
        SLOW_SAMP_CLKDIV : integer := 64; -- divide adc clock by this amount if use_slow_fs = '1'
        FFT_BIN_WIDTH : INTEGER := 10;    -- 2**FFT_BIN_WIDTH number of bins in FFT
        DATA_WIDTH : integer := 16);    -- data bus
  Port ( sysclk : in STD_LOGIC;         -- system clock
        aclk : in STD_LOGIC;            -- adc clock
        enable : in STD_LOGIC;
        reset : in STD_LOGIC;
        adin: in STD_LOGIC_VECTOR (DATA_WIDTH-1 downto 0);    -- from ADC
        adin_last : in STD_LOGIC;
        use_slow_fs : in STD_LOGIC;     -- use slow sampling rate (for low freqs)
        read_en : in STD_LOGIC;         -- enable output
        output_rdy : out STD_LOGIC;     -- ready for output
        serial_out : out STD_LOGIC      -- serial out to UART
        );
end demod_controller;

architecture Behavioral of demod_controller is

-- Constants
constant NFFT : integer := 2**FFT_BIN_WIDTH;
constant BRAM_ADDR_WIDTH : integer := 11;   -- BRAM address width
constant BRAM_ADDR_DEPTH : integer := 2*NFFT; -- address depth of data BRAM -  1024 * 2 (1024 data, 1024 fft)
--constant BRAM_ADDR_SIM : integer := 5;    -- USE FOR SIMULATION
constant BRAM_ADDR_SIM : integer := 2*NFFT;

-----------------------------------------------------------------------
-- Variable constants
signal BRAM_ADDR_MAX : integer := BRAM_ADDR_DEPTH;
-----------------------------------------------------------------------
-- FFT controller signals
signal fft_data_in, re_out, im_out : std_logic_vector(DATA_WIDTH-1 downto 0);
signal fft_bin : std_logic_vector(FFT_BIN_WIDTH-1 downto 0);
signal fft_ready, fft_out_last, fft_failed : std_logic := '0';
signal fft_rx_ready, fft_data_in_valid, fft_data_in_last : std_logic := '0';
signal count_fft_clk_div : integer := 0;
-----------------------------------------------------------------------
-- Signals for fifo_generator
signal wr_en, rd_en, full, full_d, empty, overflow, underflow : std_logic := '0';
signal fifo_data_in, fifo_data_out : std_logic_vector(DATA_WIDTH-1 downto 0) := (others => '0');
-----------------------------------------------------------------------
-- blk_mem_gen control signals
signal bram_dout, bram_din : std_logic_vector(2*DATA_WIDTH-1 downto 0) := (others => '0');
signal bram_addr : std_logic_vector(BRAM_ADDR_WIDTH-1 downto 0) := (others => '0'); -- use with blk_mem_gen_0
signal bram_wen : std_logic_vector(0 downto 0) := (others => '1');        -- use with blk_mem_gen_0
signal bram_dis : std_logic := '0';
-----------------------------------------------------------------------
-- UART-BRAM communication control signals
signal uart_en, done_tx, tx_busy, reset_n : std_logic := '0'; 
-----------------------------------------------------------------------
-- Signals for  FSM
type state_type is (ResetState, WaitDDS, StartWriteFifo, WriteFifo, WaitRead, ReadFifo, WaitFFT, ReadFFT, 
        WaitUART, ReadUART, SendUART, NextUARTData, DoneSend);
signal curr_state, next_state : state_type := ResetState;

-------------------------------------------
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
--------------------------------------------
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
-------------------------------------------
component blk_mem_gen_1
Port (
    clka : IN STD_LOGIC;
    ena : IN STD_LOGIC;
    wea : IN STD_LOGIC_VECTOR(0 DOWNTO 0);
    addra : IN STD_LOGIC_VECTOR(BRAM_ADDR_WIDTH-1 DOWNTO 0);
    dina : IN STD_LOGIC_VECTOR(2*DATA_WIDTH-1 DOWNTO 0);
    douta : OUT STD_LOGIC_VECTOR(2*DATA_WIDTH-1 DOWNTO 0)
  );
end component;
-------------------------------------------
component uart_controller_8b
GENERIC(
    DEBUG_MODE : std_logic := DEBUG_MODE;
    DATA_WIDTH : INTEGER := 2*DATA_WIDTH);  --size of the binary input numbers in bits
Port ( clk : in std_logic;              -- 100 MHz clock
   data_in : in std_logic_vector(DATA_WIDTH-1 downto 0);    -- input from BRAM
   enable_uart_tx : in std_logic;   -- write data_in to uart
   done_tx : out std_logic;         -- finished transfer
   uart_txd : out std_logic);       -- UART out
end component;
-------------------------------------------
--component uart_tx IS
--	GENERIC(
--		clk_freq	:	INTEGER		:= 100_000_000;	--frequency of system clock in Hertz
--		baud_rate	:	INTEGER		:= 256_000;		--data link baud rate in bits/second
--		os_rate		:	INTEGER		:= 16;			--oversampling rate to find center of receive bits (in samples per baud period)
--		d_width		:	INTEGER		:= 2*DATA_WIDTH; 			--data bus width
--		parity		:	INTEGER		:= 0;				--0 for no parity, 1 for parity
--		parity_eo	:	STD_LOGIC	:= '0');			--'0' for even, '1' for odd parity
--	PORT(
--		clk		:	IN		STD_LOGIC;										--system clock
--		reset_n	:	IN		STD_LOGIC;										--ascynchronous reset
--		tx_ena	:	IN		STD_LOGIC;										--initiate transmission
--		tx_data	:	IN		STD_LOGIC_VECTOR(d_width-1 DOWNTO 0);  --data to transmit
--		tx_busy	:	OUT	STD_LOGIC;  									--transmission in progress
--		tx			:	OUT	STD_LOGIC);										--transmit pin
--END component;
--------------------------------------------
begin
--------------------------------------------
-- Set variable constants --> use sim value when DEBUG_MODE = '1'
BRAM_ADDR_MAX <= BRAM_ADDR_SIM when DEBUG_MODE = '1' else BRAM_ADDR_DEPTH;
-------------------------------------------
-- Port map
-------------------------------------------
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
--------------------------------------------
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
-------------------------------------------
bram_data : blk_mem_gen_1
  PORT MAP (
    clka => sysclk,    -- use system clock 
    ena => enable,
    wea => bram_wen,
    addra => bram_addr,
    dina => bram_din,  
    douta => bram_dout
  );
  
-------------------------------------------  
uart_tx_ctrl: uart_controller_8b port map( 
    clk => sysclk,          -- 100 MHz clock
    data_in => bram_dout,
    enable_uart_tx => uart_en,
    done_tx => done_tx,
    uart_txd => serial_out);

-------------------------------------------  
--uart_ctrl: uart_tx port map( 
--    clk => sysclk,          -- 100 MHz clock
--    reset_n => reset_n,
--    tx_ena => uart_en,
--    tx_data => bram_dout,
--    tx_busy => tx_busy,
--    tx => serial_out);
-------------------------
--done_tx <= not tx_busy;
--reset_n <= not reset;   
-------------------------------------------  
-- Clock domain crossing
-------------------------------------------  
-- Catch edges of fifo 'full' signal (on slower clock)
fifo_full_aclk : process(aclk)
begin
if (rising_edge(aclk)) then
     full_d <= full;
end if;
end process fifo_full_aclk;

-------------------------------------------
-- Sample ADC data for fft - lower frequencies have slower sample rate
-- Write enable to fifo controlled here bc needs to be synced with aclk (fsm is sysclk)
latch_sample: process(aclk)
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
end process latch_sample;
-------------------------------------------  
-- Connect DDS to FIFO and FIFO to FFT
comb_logic : process(curr_state, adin_last, full_d, full, empty, fft_ready, fft_out_last, 
    enable, reset, done_tx, read_en, fft_failed) 
begin
 -- Defaults
next_state <= curr_state;   
--wr_en <= '0';         -- FIFO - set in process above to sync with aclk (wr_clk)
rd_en <= '0';           -- FIFO
fft_rx_ready <= '0';        -- FFT
fft_data_in_last <= '0';    -- FFT
fft_data_in_valid <= '0';   -- FFT
uart_en <= '0';             -- UART
output_rdy <= '0';

-- Global reset/disable
if (reset = '1' or enable = '0' or fft_failed = '1') then 
    next_state <= ResetState;
else
    case(curr_state) is
        when ResetState =>      -- start here
            if (enable = '1' and reset = '0') then
                next_state <= WaitDDS;
            end if;
        
        when WaitDDS =>         -- wait until end of period, then start write
            if (adin_last = '1') then 
                next_state <= StartWriteFifo;
            end if;
            
        when StartWriteFifo =>
            if (adin_last = '0') then    -- adc running on slower clock, wait until falls low 
                next_state <= WriteFifo;
            end if;
            
        when WriteFifo =>       -- write data to fifo (and BRAM), wait for sample to be ready
            if (full = '1') then
                next_state <= WaitRead;
            end if;
            
        when WaitRead =>        -- wait until FFT is ready and fifo "full" signal was high for 1 aclk cycle
            if (fft_ready = '1' and full_d = '1') then
                rd_en <= '1';       -- enable fifo read
                next_state <= ReadFifo;
            end if;
        
        when ReadFifo =>        -- read fifo to FFT
            rd_en <= '1';       -- enable fifo read
            fft_data_in_valid <= '1';   -- set fft data_in_valid
            if (fft_ready = '0') then
                rd_en <= '0';           -- disable fifo read while fft is busy
            elsif (empty = '1') then
                fft_data_in_last <= '1';    -- fft data_in_last
                next_state <= WaitFFT;
            end if;
            
        when WaitFFT =>         -- wait until fft finishes computing spectrum
            fft_rx_ready <= '1';
            if (fft_ready = '1') then
                next_state <= ReadFFT;
            end if;
            
        when ReadFFT =>         -- read fft spectrum
            fft_rx_ready <= '1';
            if (fft_out_last = '1') then
                next_state <= WaitUART;
            end if;
            
        when WaitUART =>        -- Note: discard first 32-bits sent by UART (in MATLAB code)
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
                if (unsigned(bram_addr) < BRAM_ADDR_MAX-1) then
                    next_state <= NextUARTData;
                else                -- at end of BRAM
                    uart_en <= '0';
                    next_state <= DoneSend;         
                end if;
            end if;
        
        when NextUARTData => -- increment block ram address
            output_rdy <= '1';
            next_state <= SendUART;
            uart_en <= '1'; -- hold high
            
        when DoneSend =>    -- hold output_rdy flag high while sending last data
            output_rdy <= '1';
            if (done_tx = '1') then -- wait until last data was sent
                next_state <= WaitDDS;
            end if;
                                      
        when others =>  -- should never reach
            next_state <= ResetState;
            
    end case;
end if;
end process comb_logic;
-------------------------------------------  
 state_update: process(sysclk)
 begin
 
 if rising_edge(sysclk) then
     curr_state <= next_state;
 end if;
 end process state_update;
---------------------------------------------
-- Block RAM address logic
-- clock driven for address increment and data latch
bram_addr_logic : process(sysclk)
begin
    if rising_edge(sysclk) then
    
        -- Defaults
        bram_din <= (others => '0');
        bram_dis <= '0'; -- bram increment enable (flag used in WaitRead/ReadFifo state)
        bram_wen <= (others => '0');

        case curr_state is  
            when WaitRead =>
                bram_wen <= (others => '1'); -- enable write to BRAM
                bram_din(DATA_WIDTH-1 downto 0) <= fifo_data_out;
                bram_addr <= (others => '0'); -- start at beginning of memory
                bram_dis <= '1';    -- disable bram address increment on next clock cycle (1 clock delay)
                
            when ReadFifo =>     -- read fifo data, write to bram, 2 clock cycle delay on bram address increment
                bram_wen <= (others => '1'); -- enable write to BRAM
                bram_din(DATA_WIDTH-1 downto 0) <= fifo_data_out;   -- real data stored in LSB's, imag stored in MSB's (0 in this case)
                if ((unsigned(bram_addr) < NFFT-1) and bram_dis = '0') then -- new sample when bram increment flag is enabled
                    bram_addr <= bram_addr + 1; -- increment once per sample
                end if;
                if (rd_en = '0') then
                    bram_dis <= '1';    -- disable next increment
                end if;
            
            when WaitFFT =>     -- ADDED THIS STATE TO LOGIC 12/9/20 to capture bin 0 data
                if (fft_ready = '1') then
                    bram_wen <= (others => '1'); -- enable write to BRAM
                    bram_addr(BRAM_ADDR_WIDTH-1) <= '1';    -- second set of NFFT samples, set MSB high
                    bram_addr(BRAM_ADDR_WIDTH-2 downto 0) <= fft_bin; -- store spectrum in "bin" address
                    bram_din <= im_out & re_out;
                end if;
                
            when ReadFFT =>     -- write fft spectrum to bram, addr based on bin
                bram_wen <= (others => '1'); -- enable write to BRAM
                bram_addr(BRAM_ADDR_WIDTH-1) <= '1';    -- second set of NFFT samples, set MSB high
                bram_addr(BRAM_ADDR_WIDTH-2 downto 0) <= fft_bin; -- store spectrum in "bin" address
                bram_din <= im_out & re_out;
                
            when WaitUART =>
                bram_addr <= (others => '0'); -- start at beginning of memory for read
                
            when NextUARTData =>
                bram_addr <= bram_addr + 1; -- increment once per sample
                
            when others => -- no address change
            
        end case;
    end if;
end process bram_addr_logic;
------------------------------------------------------------------
fft_data_in <= fifo_data_out;
fifo_data_in <= adin;
      
end Behavioral;
