----------------------------------------------------------------------------------
-- Company: Thayer School of Engineering, Dartmouth College
-- Engineer: Kendall Farnham
-- 
-- Create Date: 07/13/2023
-- Design Name: 
-- Module Name: fft_calcs - Behavioral
-- Project Name: 2023_DAQ
-- Target Devices: Artix 7 (Trenz Electronics TE0711-01)
-- Tool Versions: Vivado 2022.2
-- Description: Compute SNR/THD calcultions from FFT spectrum data
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
use ieee.math_real.all;

entity fft_calcs is
    Generic (
        FFT_DATA_WIDTH : integer := 16;     -- size of fft_out bus
        FFT_BIN_WIDTH : INTEGER := 10);     -- 2**FFT_BIN_WIDTH number of bins 
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
           macc_overflow : out STD_LOGIC;       -- overflow on accumulator
           mag_sum2_out : out STD_LOGIC_VECTOR (2*FFT_DATA_WIDTH-1 downto 0));        -- squared sum of magnitudes (i.e., sum(re^2 + im^2))
end fft_calcs;

architecture Behavioral of fft_calcs is

-----------------------------------------------------------------------
-- Signals
-----------------------------------------------------------------------
constant NFFT : integer := 2**FFT_BIN_WIDTH;    -- number of bins in FFT
constant MACC_DATA_WIDTH : integer := 2*FFT_DATA_WIDTH+FFT_BIN_WIDTH+1; -- output data width of macc

signal sample_cnt : integer range 0 to NFFT-1 := 0;
signal done_accum, reset_macc, sample_cnt_tc, macc_carryout : std_logic := '0';
signal squared_sum, mag_sq, re2, im2 : unsigned(MACC_DATA_WIDTH-1 downto 0) := (others => '0');
signal bin_f2_mux : STD_LOGIC_VECTOR (FFT_BIN_WIDTH-1 downto 0); 
signal bin_f1_nfft_carry : STD_LOGIC_VECTOR (FFT_BIN_WIDTH downto 0); 

-- Testbench/alias signals
signal bin_found, exclude_bin : std_logic := '0';
signal f1_re, f1_im, f2_re, f2_im, dc_re, dc_im : std_logic_vector(FFT_DATA_WIDTH-1 downto 0) := (others => '0');

-- FSM
type state_type is (ResetState, IdleState, ComputeSum, DoneMultiply, 
    DoneSum, SetOutput);
signal curr_state, next_state : state_type := ResetState;

begin
-----------------------------------------------------------------------
-- Count number of fft samples coming in, compute the sum of squares
-----------------------------------------------------------------------
data_in_counter: process(clk)
begin
if rising_edge(clk) then
    -- Default
    sample_cnt_tc <= '0';   -- terminal count, signal to fsm 

    if reset_macc = '1' then  -- reset counter
        sample_cnt <= 0;
    else
        if data_in_valid = '1' then     -- Sample Counter 
            if (sample_cnt = NFFT-1) then 
                sample_cnt_tc <= '1';           -- set terminal count high
                sample_cnt <= 0;                -- reset count
                
            else
                sample_cnt <= sample_cnt + 1;   -- increment
            end if;
        end if;
    end if;        
    
end if;
end process data_in_counter;
-----------------------------------------------------------------------
-- Send sum to output and set output data valid signal
-----------------------------------------------------------------------
done_sum: process(clk)
begin
if rising_edge(clk) then  
    exclude_bin <= '0';     -- clear testbench signal
    
    -- Sum square magnitudes, doesn't include DC
    -- Pipelined multiplier accumulator
    -- Stage 1
    -- Multiplier (Real^2 and Imag^2)
    if (data_in_valid = '0') then
        re2 <= (others => '0'); -- set to zero so accumulator doesn't add invalid data
        im2 <= (others => '0');
--    elsif (use_full_spectrum = '0' and bin_in(FFT_BIN_WIDTH-1) = '1') -- use half spectrum only
--            or (bin_in = 0) then
    elsif (bin_in = 0 or (use_full_spectrum = '0' and bin_in > NFFT/2-1)) then -- use half spectrum only
        re2 <= (others => '0'); -- set to zero so accumulator doesn't add bins N/2 to N-1 or bin 0
        im2 <= (others => '0');
        exclude_bin <= '1';     -- testbench signal
    else
        re2 <= to_unsigned(to_integer(signed(re_in))*to_integer(signed(re_in)),re2'length);
        im2 <= to_unsigned(to_integer(signed(im_in))*to_integer(signed(im_in)),im2'length);
    end if;
    
    -- Stages 2 & 3
    -- Accumulator (Mag = Real^2 + Imag^2, then Sum += Mag)
    if (reset_macc = '1') then  -- reset sum
        squared_sum <= (others => '0');
        mag_sq <= (others => '0');
    else
        -- pipelined multiplier accumulator -- 2 clock cycle latency
        mag_sq <= re2 + im2;
        squared_sum <= squared_sum + mag_sq; -- unsigned accumulator
    end if;
    
    -- Carryout/MACC overflow 
    if (squared_sum(MACC_DATA_WIDTH-1 downto mag_sum2_out'length) /= 0) then 
        macc_overflow <= '1';       -- sum exceeds output data width
    else
        macc_overflow <= '0';       -- clear overflow bit
    end if;   
     
    -- Set output sum port
    data_out_valid <= '0';  -- output valid signal
    if reset = '1' then     -- clear output
        mag_sum2_out <= (others => '0');
    elsif done_accum = '1' then       
        data_out_valid <= '1';          -- output valid, pulse high  
        mag_sum2_out <= std_logic_vector(squared_sum(mag_sum2_out'length-1 downto 0));
        --mag_sum2_out <= std_logic_vector(squared_sum(MACC_DATA_WIDTH-2 downto FFT_BIN_WIDTH)); -- Divide by NFFT (shift by FFT_BIN_WIDTH)
    end if;        
end if;
end process done_sum;
-----------------------------------------------------------------------
-- Check frequency 2 bin k2, if zero set to NFFT-k1
-----------------------------------------------------------------------
bin_f1_nfft_carry <= std_logic_vector(to_unsigned(NFFT - to_integer(unsigned(bin_f1)),FFT_BIN_WIDTH+1));
-----------------------------------------------------------------------
bin_f2_mux <= bin_f2 when bin_f2 /= 0
    else bin_f1_nfft_carry(FFT_BIN_WIDTH-1 downto 0);  -- drop carry bit
-----------------------------------------------------------------------
-- Set alias signals for easier testbench viewing
-----------------------------------------------------------------------
set_fft_bin_found: process(clk)
begin
if rising_edge(clk) then
    if enable = '1' and data_in_valid = '1' and
            (bin_in = bin_f1 or bin_in = bin_f2_mux or bin_in = 0) then
        bin_found <= '1';    -- input matches signal or dc fft bin 
     else
        bin_found <= '0';   -- clear
    end if;        
end if;
end process set_fft_bin_found;
-----------------------------------------------------------------------
-- Capture the signal magnitudes (and dc)
-----------------------------------------------------------------------
get_signal_data: process(clk)
begin
if rising_edge(clk) then
    if reset = '1' then         -- reset takes precedence
        f1_re <= (others => '0');   -- clear all
        f1_im <= (others => '0');
        f2_re <= (others => '0');
        f2_im <= (others => '0');
        dc_re <= (others => '0');
        dc_im <= (others => '0');
    elsif enable = '1' and data_in_valid = '1' then
        if bin_in = bin_f1 then
            f1_re <= re_in;
            f1_im <= im_in;
        elsif bin_in = bin_f2_mux then
            f2_re <= re_in;
            f2_im <= im_in;
        elsif bin_in = 0 then
            dc_re <= re_in;
            dc_im <= im_in;
        end if;    
    end if;        
end if;
end process get_signal_data;
-----------------------------------------------------------------------
-- Hook up alias signals to outputs
-----------------------------------------------------------------------
re_im_out_f1 <= f1_re & f1_im;      -- concatenate real and imag data
re_im_out_f2 <= f2_re & f2_im;      -- concatenate real and imag data
dc_out <= dc_re & dc_im;
-----------------------------------------------------------------------
-- FSM
-----------------------------------------------------------------------
comb_logic : process(curr_state, reset, enable, data_in_valid, sample_cnt_tc)
begin
     -- Defaults
    next_state <= curr_state;   
    done_accum <= '0';          -- Pipelined Multiplier/Accumulator finished, save sum
    reset_macc <= '0';          -- Reset MACC
    
    -- Global reset/disable
    if (reset = '1' or enable = '0') then 
        next_state <= ResetState;
    else
        case(curr_state) is
            when ResetState =>      -- start here
                reset_macc <= '1';
                if (enable = '1' and reset = '0') then
                    next_state <= IdleState;
                end if;
            
            when IdleState =>
                reset_macc <= '1';      -- reset MACC
                if (data_in_valid = '1') then
                    next_state <= ComputeSum;
                end if;
            
            when ComputeSum =>        
                if (sample_cnt_tc = '1') then 
                    next_state <= DoneMultiply;
                end if;
            
            when DoneMultiply =>        -- Pipelined MACC
                next_state <= DoneSum;
                
            when DoneSum =>             -- Accumulator finished
                next_state <= SetOutput;
                
            when SetOutput =>           -- Save MACC output
                done_accum <= '1';
                next_state <= IdleState;
                
            when others =>
                next_state <= ResetState;
                
            end case;
     end if;

end process comb_logic;

-----------------------------------------------------------------------
-- State update
-----------------------------------------------------------------------
 state_update: process(clk)
 begin
 
 if rising_edge(clk) then
     curr_state <= next_state;
 end if;
 end process state_update;

-----------------------------------------------------------------------
end Behavioral;