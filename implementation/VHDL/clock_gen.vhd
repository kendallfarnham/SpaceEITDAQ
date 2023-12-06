----------------------------------------------------------------------------------
-- Company: Thayer School of Engineering, Dartmouth College
-- Engineer: Kendall Farnham
-- 
-- Create Date: 06/08/2020 06:11:32 PM
-- Design Name: 
-- Module Name: clock_gen - Behavioral
-- Project Name: 2023_DAQ
-- Target Devices: Artix 7 (Trenz Electronics TE0711-01)
-- Tool Versions: Vivado 2022.2
-- Description: Generate slow clocks for different modules/testing
-- 
-- Dependencies: 
-- 
-- Revision:
-- Revision 0.01 - 06/08/2020 File Created
-- Revision 1.0 - 07/20/2023 Added reset and generics
-- Additional Comments:
-- 
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

library UNISIM;						
use UNISIM.Vcomponents.ALL; -- for BUFG clock buffers
----------------------------------------------------------------------------------
entity clock_gen is
    Generic ( CLKDIV : integer := 10);  -- Clock divide for clk_out
    Port ( clk_in100 : in STD_LOGIC;    -- input 100 MHz clock
		reset : in STD_LOGIC;			-- reset clocks to 0
        clk_out : out STD_LOGIC);       -- output 100/CLKDIV MHz clock (PGA)
end clock_gen;
----------------------------------------------------------------------------------
architecture Behavioral of clock_gen is
----------------------------------------------------------------------------------
constant CLKDIVHALF : integer := CLKDIV/2;    -- CLKDIV1/2 (half period counter)

-- Signals 
signal count_clk  : integer range 0 to CLKDIV-1 := 0;
signal clk, oclk_int, oclk : std_logic := '0';
----------------------------------------------------------------------------------
begin
----------------------------------------------------------------------------------
-- Connect to ports
clk <= clk_in100;

----------------------------------------------------------------------------------
-- Output clock buffers
clk_out_bufg_inst : BUFG
port map (
   O => oclk_int,     -- 1-bit output: Clock output
   I => oclk          -- 1-bit input: Clock input (S=0)
);

clk_out_bufh_inst : BUFH
port map (
   O => clk_out,      -- 1-bit output: Clock output
   I => oclk_int      -- 1-bit input: Clock input
);
----------------------------------------------------------------------------------
-- Clock counter
clk_counter: process(clk)
begin
    if(rising_edge(clk)) then
		if reset = '1' then
			count_clk <= 0;
		else        
			if count_clk >= CLKDIV-1 then -- should never be > but to be safe...
				count_clk <= 0;            
			else
				count_clk <= count_clk + 1;
			end if;
			
		end if;
    end if;
end process clk_counter;

----------------------------------------------------------------------------------
clock_gen: process(clk)
begin
    if(rising_edge(clk)) then
		if reset = '1' then
			oclk <= '0';
		else   
			-- 50% duty cycle (if clkdiv is even)
			if (count_clk = CLKDIVHALF-1 or count_clk = CLKDIV-1) then 
				oclk <= not oclk; -- toggle clock 
			end if;
		end if;
    end if;
end process clock_gen;
----------------------------------------------------------------------------------
end Behavioral;

