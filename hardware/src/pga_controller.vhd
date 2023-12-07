----------------------------------------------------------------------------------
-- Company: Thayer School of Engineering, Dartmouth College
-- Engineer: Kendall Farnham
-- 
-- Create Date: 07/13/2023
-- Design Name: 
-- Module Name: pga_controller - Behavioral
-- Project Name: 2023_DAQ
-- Target Devices: Trenz Electronics TE0711-01
-- Tool Versions: Vivado 2022.2.2
-- Description: Set the PGA gain via SPI control
--              MCP6S91 Programmable Gain Amplifier
--                     gain register bits 2-0 111 = Gain +32
--                     gain register bits 2-0 110 = Gain +16
--                     gain register bits 2-0 101 = Gain +10
--                     gain register bits 2-0 100 = Gain +8
--                     gain register bits 2-0 011 = Gain +5   
--                     gain register bits 2-0 010 = Gain +4
--                     gain register bits 2-0 001 = Gain +2  
-- 
-- Dependencies: 
--              SPI Interface: SPI 1,1 Mode
-- 
-- Revision 0.01 - 06/09/2020 File Created
-- Revision: 0.02 - Updated 1/17/23 -- changed input from amplitude to gain select bits
-- Revision 0.03 - 7/13/2023 Copied from 2023_DAQ_64ch_v2.srcs
-- 
----------------------------------------------------------------------------------


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.std_logic_unsigned.all;
-----------------------------------------------------------------------
entity pga_controller is
    Port ( clk : in STD_LOGIC;      -- max 10 MHz clock
           enable : in STD_LOGIC;
           reset : in STD_LOGIC;
           set_gain : in STD_LOGIC;
           pga_gain_set : in STD_LOGIC_VECTOR(2 downto 0);   -- pga gain setting
           pga_si : out STD_LOGIC;
           pga_sclk : out STD_LOGIC;
           pga_cs_n : out STD_LOGIC);
end pga_controller;

architecture Behavioral of pga_controller is
-----------------------------------------------------------------------
component spi_controller
Port ( clk : in STD_LOGIC;
   wr_en : in STD_LOGIC;
   s_data_in : in STD_LOGIC_VECTOR(15 downto 0);
   wready : out STD_LOGIC;
   sclk : out STD_LOGIC;
   si : out STD_LOGIC;
   cs_n : out STD_LOGIC);
end component;

-----------------------------------------------------------------------
-- Signals for FSM
constant PGA_SEL_BITS : integer := 3;
type state_type is (Startup, ResetCh, ResetG, SetStandby, SetGain, WaitWrite, Write, WaitStandby, WaitGain);
signal curr_state, next_state, return_state : state_type := Startup; 

-- SPI controls
signal i_reg, d_reg : std_logic_vector(7 downto 0) := (others => '0');
signal s_data_reg : std_logic_vector(15 downto 0) := (others => '0');
signal cs_n, cs_startup, clear_set_gain_flag : std_logic := '0';

-- Internal
signal prev_gain : std_logic_vector(2 downto 0) := (others => '0');										  
signal wready, w_en, set_gain_flag, gain_change : std_logic := '0';   

-----------------------------------------------------------------------
begin
-----------------------------------------------------------------------
spi : spi_controller
port map (
    clk         => clk,
    wr_en       => w_en,
    s_data_in   => s_data_reg,
    wready      => wready,
    sclk        => pga_sclk,
    si          => pga_si,
    cs_n        => pga_cs_n);
    
    
--pga_cs_n <= '0' when curr_state = ToggleCS else cs_n;
-----------------------------------------------------------------------
s_data_reg(15 downto 8) <= i_reg;     -- instruction byte
s_data_reg(7 downto 0) <= d_reg;      -- data byte

-----------------------------------------------------------------------
---- Catch set_gain signal, hold flag high if already writing, will set again next time
--set_gain_flag <= '0' when curr_state = SetGain or curr_state = Startup  -- init/clear flag
--    else '1' when set_gain = '1';       -- hold high until SetGain state	
-----------------------------------------------------------------------
set_gain_cdc: process(clear_set_gain_flag, set_gain, pga_gain_set)
begin
if (set_gain = '1') or (pga_gain_set /= prev_gain) then
    set_gain_flag <= '1';   -- set high, takes precedence
elsif (clear_set_gain_flag = '1') then
    set_gain_flag <= '0';   -- clear or initialize
end if;
   
end process set_gain_cdc;

-----------------------------------------------------------------------
fsm: process(curr_state, enable, wready, reset, set_gain_flag)
begin

-- Defaults
next_state <= curr_state;  
clear_set_gain_flag <= '0';
--return_state <= return_state;    -- set default to avoid inferred latch -- hold value

-- Combinational Logic
case curr_state is 
    when Startup =>                  -- initialize
        clear_set_gain_flag <= '1';
--        return_state <= ResetG;
        if enable = '1' then					   
            next_state <= ResetCh;   -- Reset PGA to put in a valid state
        end if;        
        
    when ResetCh =>		
--        return_state <= ResetG;				
        if (wready = '1') then
            next_state <= Write;  
        end if;
        
    when ResetG => 		
--        return_state <= SetGain;		  
        if (wready = '1') then
            next_state <= Write;
        end if;
    
    when Write =>                   -- SPI controller
        --return_state <= return_state;   -- hold value
        if (wready = '0') then      -- wait for spi controller to start write
            next_state <= WaitWrite;
        end if;
        
    when WaitWrite =>
        --return_state <= return_state;   -- hold value
        if (wready = '1') then
            next_state <= return_state;
        end if;
   
    when SetGain =>		
        clear_set_gain_flag <= '1';
--        return_state <= WaitGain;
        if (wready = '1') then
            next_state <= Write; 
        end if;
        
     when WaitGain =>       -- Wait here if enabled, set gain if signal is high
       -- return_state <= return_state;   -- hold value
--        if (enable = '0') then
--            next_state <= SetStandby;
--        els
        if (reset = '1') then
            next_state <= ResetCh;
        elsif (set_gain_flag = '1') then
            next_state <= SetGain; 
        end if;

    when SetStandby => 
--        return_state <= WaitStandby;
        if (wready = '1') then
            next_state <= Write;	
        end if;
        
    when WaitStandby =>     -- Wait in shutdown mode until enabled
--        return_state <= ResetG;
        if (enable = '1' or reset = '1' ) then
            next_state <= ResetCh;
        end if;        

    when others =>  next_state <= Startup;
    end case;
    
end process fsm;

-----------------------------------------------------------------------
state_update: process(clk)
begin

if rising_edge(clk) then
    curr_state <= next_state;
end if;

end process state_update;
-----------------------------------------------------------------------
latch_pga_buffers: process(clk)
begin

if rising_edge(clk) then

-- Write enable for SPI
if curr_state = Write then
    w_en <= '1';
else
    w_en <= '0';
end if;

-- Data reg to SPI
case next_state is                  -- CHANGED to next_state (was curr_state) -- 7/10/23
    when Startup =>                 -- initialize
        i_reg <= x"41";              -- write to channel reg
        d_reg <= (others => '0');    -- channel register 0x00 = Ch0 
        prev_gain <= (others => '0');

    when ResetCh =>
        i_reg <= x"41";              -- write to channel reg
        d_reg <= (others => '0');    -- channel register 0x00 = Ch0 
        
    when ResetG =>
        i_reg <= x"40";              -- write to gain reg (0 - Gain, 1 - Channel)
        d_reg <= (others => '0');    -- gain register 0x00 = Gain +1  
        prev_gain <= (others => '0');
    
    when WaitGain =>
        i_reg <= x"40";     -- instruction register 0x40 = write mode
        d_reg(PGA_SEL_BITS-1 downto 0) <= pga_gain_set;
        prev_gain <= pga_gain_set;
        
    when SetGain =>
        i_reg <= x"40";     -- instruction register 0x40 = write mode
        d_reg(PGA_SEL_BITS-1 downto 0) <= pga_gain_set;
        prev_gain <= pga_gain_set;

    when SetStandby =>
        i_reg <= x"20";     -- instruction register 0x20 = shutdown mode      
        d_reg <= (others => '0'); 

    when others => -- hold values (do nothing)
end case;
    

-- return state register
case curr_state is                  
   when Startup =>                 
        return_state <= ResetG;
        
    when ResetCh =>		
        return_state <= ResetG;		
        
    when ResetG => 		
        return_state <= SetGain;	
   
    when SetGain =>		
        return_state <= WaitGain;

    when SetStandby => 
        return_state <= WaitStandby;

    when others => -- hold values (do nothing)
end case;
    
end if;

end process latch_pga_buffers;
-----------------------------------------------------------------------

end Behavioral;
