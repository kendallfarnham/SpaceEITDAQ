----------------------------------------------------------------------------------
-- Company: Thayer School of Engineering, Dartmouth College
-- Engineer: Kendall Farnham
-- 
-- Create Date: 07/21/2023
-- Design Name: 
-- Module Name: tb_mux_controller - testbench
-- Project Name: 2023_DAQ
-- Target Devices: Artix 7 (Trenz Electronics TE0711-01)
-- Tool Versions: Vivado 2022.2
-- Description: 
-- 
-- Dependencies: 
--
-- Revision 0.01 - File Created
-- 
----------------------------------------------------------------------------------


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use ieee.numeric_std.all;


entity tb_mux_controller is
end tb_mux_controller;

architecture testbench of tb_mux_controller is

-- instantiate controller and clock gen
component mux_controller 
Generic ( CH_BITS : integer := 6);  -- number of bits for input iivvs
Port (  clk       : in STD_LOGIC;
        enable    : in STD_LOGIC;   -- enable mux output
		en_mux_n  : in STD_LOGIC_VECTOR(3 downto 0);   -- enable mux set (4 mux sets, VSRC, VSNK, VPU1, VPU2)																								 
        reset     : in STD_LOGIC;   -- reset mux select bits to 0
        vsrc_ch   : in STD_LOGIC_VECTOR(CH_BITS-1 downto 0);
        vsink_ch  : in STD_LOGIC_VECTOR(CH_BITS-1 downto 0);
        vpu1_ch   : in STD_LOGIC_VECTOR(CH_BITS-2 downto 0);    -- odd channels
        vpu2_ch   : in STD_LOGIC_VECTOR(CH_BITS-2 downto 0);    -- even channels
        
        mux_vsrc  : out STD_LOGIC_VECTOR (7 downto 0);  -- to VS+ Muxes [0:7]: S0, S1, S2, S3, NEN1, NEN2, NEN3, NEN4
        mux_vsink : out STD_LOGIC_VECTOR (7 downto 0);  -- to VS- Muxes [0:7]: S0, S1, S2, S3, NEN1, NEN2, NEN3, NEN4
        mux_vpu1  : out STD_LOGIC_VECTOR (5 downto 0);  -- to Vpickup 1 Muxes (Odd Ch's) [0:5]: S0, S1, S2, S3, NEN1, NEN2
        mux_vpu2  : out STD_LOGIC_VECTOR (5 downto 0)); -- to Vpickup 2 Muxes (Even Ch's [0:5]: S0, S1, S2, S3, NEN1, NEN2
                
end component;
constant CH_BITS : integer := 6;        -- 64 channels
constant clk_period: time := 10ns;      -- 100 MHz system clock
constant wait_period : time := 100ns;   -- standard wait time between switching inputs (in this sim)

-- signals to connect to DUT ports
signal clk, enable, reset : std_logic := '0';
signal en_mux_n : std_logic_vector(3 downto 0) := (others => '0');
signal mux_vsrc, mux_vsink : std_logic_vector(7 downto 0) := (others => '0');
signal mux_vpu1, mux_vpu2 : std_logic_vector(5 downto 0) := (others => '0');
signal vsrc_ch, vsink_ch : std_logic_vector(CH_BITS-1 downto 0) := (others => '0'); -- 64 channels
signal vpu1_ch, vpu2_ch : std_logic_vector(CH_BITS-2 downto 0) := (others => '0'); -- 32 channels each

    
begin

-- Map ports
dut: mux_controller port map(
    clk => clk,
    enable => enable,
    en_mux_n => en_mux_n,
    reset => reset,
    vsrc_ch => vsrc_ch,
    vsink_ch => vsink_ch,
    vpu1_ch => vpu1_ch,
    vpu2_ch => vpu2_ch,
    
    mux_vsrc => mux_vsrc,
    mux_vsink => mux_vsink,
    mux_vpu1 => mux_vpu1,
    mux_vpu2 => mux_vpu2
);


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
    -- Startup state
    enable <= '0';
    reset <= '0';
    en_mux_n <= (others => '0');
    vsrc_ch <= (others => '0');
    vsink_ch <= (others => '0');
    vpu1_ch <= (others => '0');
    vpu2_ch <= (others => '0');
    wait for wait_period;
    
    -- Reset
    reset <= '1';
    wait for clk_period;    -- toggle high one clock cycle
    reset <= '0';
    wait for wait_period;
    
    
    -- Enable
    enable <= '1';
    reset <= '0';
    wait for wait_period;
    
    -- Set muxes one at a time
     en_mux_n(0) <= '1';
     vsrc_ch <= std_logic_vector(to_unsigned(4,vsrc_ch'length));
     wait for wait_period;
     
     en_mux_n(1) <= '1';
     vsink_ch <= std_logic_vector(to_unsigned(1,vsink_ch'length));
     wait for wait_period;
     
     en_mux_n(2) <= '1';
     vpu1_ch <= std_logic_vector(to_unsigned(5,vpu1_ch'length));
     wait for wait_period;
     
     en_mux_n(3) <= '1';
     vpu2_ch <= std_logic_vector(to_unsigned(5,vpu2_ch'length));
     wait for wait_period;
     
    -- Reset
    enable <= '0';
    reset <= '1';
    wait for 2*clk_period;    -- toggle high 
    reset <= '0';
    wait for wait_period;
    
    -- Enable
    enable <= '1';
    wait for wait_period;
    
    -- Set channels 
    vsrc_ch <= std_logic_vector(to_unsigned(15,vsrc_ch'length));
    vsink_ch <= std_logic_vector(to_unsigned(0,vsink_ch'length));
    vpu1_ch <= std_logic_vector(to_unsigned(1,vpu1_ch'length));
    vpu2_ch <= std_logic_vector(to_unsigned(3,vpu2_ch'length));
    wait for wait_period;
    
    
    
    -- End simulation        
    std.env.stop;   
end process stim_proc;

end testbench;

