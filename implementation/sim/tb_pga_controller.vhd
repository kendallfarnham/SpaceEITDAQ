----------------------------------------------------------------------------------
-- Company: Thayer School of Engineering, Dartmouth College
-- Engineer: Kendall Farnham
-- 
-- Create Date: 07/13/2023
-- Design Name: 
-- Module Name: tb_pga_controller - testbench
-- Project Name: 2023_DAQ
-- Target Devices: Artix 7 (Trenz Electronics TE0711-01)
-- Tool Versions: Vivado 2022.2
-- Description: 
-- 
-- Dependencies: 
--
-- Revision 0.01 - File Created
-- Revision 0.02 - 7/13/2023 Copied from 2023_DAQ_64ch_v2.srcs
-- 
----------------------------------------------------------------------------------


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity tb_pga_controller is
end tb_pga_controller;

architecture testbench of tb_pga_controller is

-- instantiate controller and clock gen
component pga_controller 
Port ( clk : in STD_LOGIC;      -- max 10 MHz clock
       enable : in STD_LOGIC;
       reset : in STD_LOGIC;
       set_gain : in STD_LOGIC;
       pga_gain_set : in STD_LOGIC_VECTOR(2 downto 0);   -- pga gain setting
       pga_si : out STD_LOGIC;
       pga_sclk : out STD_LOGIC;
       pga_cs_n : out STD_LOGIC);
end component;
    
constant clk_period: time := 10ns;  -- 100 MHz
constant wait_spi_cnt : integer := 100;

-- signals to connect to DUT ports
signal clk, SCK : std_logic := '0';
signal pga_en, SI, CSn, CS, pga_reset, set_gain : std_logic := '0';
signal pga_gain_set : std_logic_vector(2 downto 0);

    
begin

-- Map ports
dut: pga_controller port map(
    clk => clk,
    enable => pga_en,
    reset => pga_reset,
    set_gain => set_gain,
    pga_gain_set => pga_gain_set,
    pga_si => SI,
    pga_sclk => SCK,
    pga_cs_n => CSn);


clk_proc: process
begin
    clk <= '0';
    loop
        wait for clk_period/2;
        clk <= not(clk);
    end loop;
end process clk_proc;


stim_proc: process
begin
    pga_gain_set <= "000";
    set_gain <= '0';
    
    -- Start up PGA, test reset quick pulse
    pga_en <= '0'; wait for clk_period;
    pga_reset <= '1'; wait for clk_period;
    pga_reset <= '0'; wait for wait_spi_cnt*clk_period;   
    
    -- Test reset, slow
    pga_reset <= '1'; wait for wait_spi_cnt*clk_period;
    pga_reset <= '0'; wait for wait_spi_cnt*clk_period;
    pga_en <= '1'; wait for wait_spi_cnt*clk_period;
    pga_gain_set <= "001"; wait for wait_spi_cnt*clk_period;
    
    -- Test gain change
    pga_en <= '1'; 
    pga_gain_set <= "101"; wait for wait_spi_cnt*clk_period;
    set_gain <= '1'; wait for clk_period;
    set_gain <= '0'; wait for wait_spi_cnt*clk_period;
    pga_gain_set <= "011"; wait for wait_spi_cnt*clk_period;
    set_gain <= '1'; wait for clk_period;
    set_gain <= '0'; wait for wait_spi_cnt*clk_period;
    pga_gain_set <= "010"; wait for wait_spi_cnt*clk_period;
    
    -- Disable
    pga_en <= '0'; wait for wait_spi_cnt*clk_period;
    pga_gain_set <= "110"; wait for wait_spi_cnt*clk_period;
    
    -- Re-enable
    pga_en <= '1'; wait for wait_spi_cnt*clk_period;
    pga_gain_set <= "011"; wait for 2*wait_spi_cnt*clk_period;
    set_gain <= '1'; wait for clk_period;
    set_gain <= '0'; wait for wait_spi_cnt*clk_period;
    
    pga_reset <= '1'; wait for wait_spi_cnt*clk_period;
    pga_reset <= '0'; wait for wait_spi_cnt*clk_period;


    -- End simulation        
    std.env.stop;   
end process stim_proc;

end testbench;

