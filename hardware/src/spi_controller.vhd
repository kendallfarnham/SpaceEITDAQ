----------------------------------------------------------------------------------
-- Company: Thayer School of Engineering, Dartmouth College
-- Engineer: Kendall Farnham
-- 
-- Create Date: 09/24/2023
-- Design Name: 
-- Module Name: spi_controller - Behavioral
-- Project Name: 2023_DAQ_v03
-- Target Devices: Artix 7 (Trenz Electronics TE0711-01)
-- Tool Versions: Vivado 2022.2
-- Description: SPI controller with Mode 0,0 Timing for PGA
-- 
-- Dependencies: 
-- 
-- Revision:
-- Revision 0.01 - 06/10/2020 File Created 
-- Revision 1.0 - 7/13/2023 Copied from 2023_DAQ_64ch_v2.srcs
-- Revision 2.0 - 9/24/2023 Copied from 2023_DAQ_v03.srcs -- spi_controller_1_1.vhd
--              - Change to 0,0 mode
-- 
----------------------------------------------------------------------------------


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

library UNISIM;						
use UNISIM.Vcomponents.ALL; 

entity spi_controller is
    Port ( clk : in STD_LOGIC;
           wr_en : in STD_LOGIC;
           s_data_in : in STD_LOGIC_VECTOR(15 downto 0);
           wready : out STD_LOGIC;
           sclk : out STD_LOGIC;
           si : out STD_LOGIC;
           cs_n : out STD_LOGIC);
end spi_controller;

architecture Behavioral of spi_controller is
-----------------------------------------------------------------------
-- Constants
constant DWIDTH : integer := 16;    -- Number of bits in s_data_in


-- Signals for FSM
type state_type is (Init, Ready, LoadData, SetCS, Write, DoneWrite);
signal curr_state, next_state : state_type := Init;

-- Internal, SPI controls
signal bit_cnt : integer := 0;           -- bit index counter for SPI write 
signal bit_cnt_en, bit_cnt_done, reset_cnt : std_logic := '0'; 
signal sclk_en, cs_rise_edge, cs_fall_edge : std_logic := '0';
signal sclk_buf, cs_buf, si_buf : std_logic := '0';

-- Shift register
signal dbus_shift : STD_LOGIC_VECTOR(15 downto 0) := (others => '0');
signal shift_en, load_en, reset_reg : std_logic := '0'; 

-----------------------------------------------------------------------
--attribute IOB: string;
--attribute IOB of sclk_buf, cs_buf, si_buf : signal is "true";
--attribute IOB of cs_buf, si_buf : signal is "true";
-----------------------------------------------------------------------
begin

-----------------------------------------------------------------------
fsm: process(curr_state, wr_en, bit_cnt_done)
begin

-- Defaults
next_state <= curr_state;
wready <= '0';      -- output -- not ready
load_en <= '0';     -- shift register
shift_en <= '0';    -- shift register
reset_reg <= '0';   -- shift register
bit_cnt_en <= '0';  -- bit counter
reset_cnt <= '0';   -- bit counter 

-- Combinational Logic
case curr_state is
    when Init =>
        reset_reg <= '1';   -- reset shift register
        reset_cnt <= '1';   -- reset counter 
        next_state <= Ready;
        
    when Ready =>
        reset_cnt <= '1';    -- reset counter 
        wready <= '1';
        if (wr_en = '1') then   
            next_state <= LoadData;
        end if;
    
    when LoadData =>
        load_en <= '1';     -- load shift register
        next_state <= SetCS;
         
    when SetCS =>
        bit_cnt_en <= '1';  -- enable bit counter
        next_state <= Write;
        
    when Write =>      
        bit_cnt_en <= '1';  -- enable bit counter
        shift_en <= '1';    -- enable shift register
        if (bit_cnt_done = '1') then   
            next_state <= DoneWrite;
        end if;        
                    
     when DoneWrite =>
        next_state <= Ready;  
            
    when others => next_state <= Ready;
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
-- Serial data and chip select ports
si_buf <= dbus_shift(DWIDTH-1);    -- hook up shift register's MSB to output
--cs_buf <= (cs_fall_edge and cs_rise_edge);
cs_buf <= cs_fall_edge;
sclk_buf <= clk and sclk_en;
-----------------------------------------------------------------------
-- hook up IOB to ports
si <= si_buf;
cs_n <= not cs_buf;
sclk <= sclk_buf;
-------------------------------------------------------------------------
-- Chip select
set_chip_select: process(curr_state)
begin
    
if (curr_state = SetCS or curr_state = Write) then 
    cs_rise_edge <= '1';                          
else 
    cs_rise_edge <= '0'; 
end if;

end process set_chip_select;
-----------------------------------------------------------------------
-- Latch CS signal on falling edge (delayed)
cs_falling_edge: process(clk)
begin
if falling_edge(clk) then  
    cs_fall_edge <= cs_rise_edge;
end if;
end process cs_falling_edge;
-----------------------------------------------------------------------
-- Shift register -- shift on falling edge
shift_reg: process(clk)
begin

if falling_edge(clk) then  
    if (reset_reg = '1') then 
        dbus_shift <= (others => '0');  -- Reset register to 0      
    elsif (load_en = '1') then
        dbus_shift <= s_data_in;        -- Load data
    elsif (shift_en = '1') then
        dbus_shift <= dbus_shift(DWIDTH-2 downto 0) & '0';  -- shift MSB out
    end if;
end if;

end process shift_reg;

-----------------------------------------------------------------------
-- Bit counter for shift register/fsm
bit_counter: process(clk)
begin

if rising_edge(clk) then     
    if (reset_cnt = '1') then
        bit_cnt <= 0;               -- reset counter
    elsif (bit_cnt_en = '1') then 
        bit_cnt <= bit_cnt + 1;     -- increment
    end if;
    
    -- FSM signal to switch states
    if (bit_cnt = DWIDTH-1) then
        bit_cnt_done <= '1';        -- set high
    else
        bit_cnt_done <= '0';
    end if;
end if;
end process bit_counter;

-----------------------------------------------------------------------
-- Sclk enable on falling edge
clk_en_falling_edge: process(clk)
begin

if falling_edge(clk) then  
    if (next_state = Write) then -- curr_state = SetCS or 
        sclk_en <= '1';     -- enable output serial clock      
    else
        sclk_en <= '0';     -- disable output serial clock 
    end if;
end if;

end process clk_en_falling_edge;
-----------------------------------------------------------------------
-- Clock
-----------------------------------------------------------------------
--sclk <= clk; -- always connected
--sclk <= clk when sclk_en = '1' else '0';
--sclk <= clk and sclk_en;
-----------------------------------------------------------------------
---- BUFHCE: HROW Clock Buffer for a Single Clocking Region with Clock Enable
----         7 Series
---- Xilinx HDL Language Template, version 2023.1

--BUFHCE_inst : BUFHCE
--generic map (
--   CE_TYPE => "SYNC",   -- "SYNC" (glitchless switching) or "ASYNC" (immediate switch)
--   INIT_OUT => 0        -- Initial output value (0-1)
--)
--port map (
--   O => sclk,       -- 1-bit output: Clock output
--   CE => sclk_en,   -- 1-bit input: Active high enable
--   I => clk         -- 1-bit input: Clock input
--);

-----------------------------------------------------------------------
end Behavioral;
