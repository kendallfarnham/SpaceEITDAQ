----------------------------------------------------------------------------------
-- Company: Thayer School of Engineering, Dartmouth College
-- Engineer: Kendall Farnham
-- 
-- Create Date: 07/13/2023
-- Design Name: 
-- Module Name: mux_controller - Behavioral
-- Project Name: 2023_DAQ
-- Target Devices: Artix 7 (Trenz Electronics TE0711-01)
-- Tool Versions: Vivado 2022.2
-- Description: 64-channel MUX/AFE Rev 2 digital interface
--      Odd and even numbered channels are split on the MUX board (J1 is odd, J2 is even ch's)
--      VS+ and VS- muxes are split (share S0-S3 bits, enables 1&3 are odd , 2&4 even ch's)
--      Vpickup Ch 1 is odd channels, Vpickup Ch 2 is even channels 
--          (assuming channel # 1-64 ---> in binary, encoded 0-63)
-- 
--      Vs+/- Muxes: en1 ch1:31 odd, en2 ch2:32 even, en3 ch33:63 odd, en4 34:64 even
--      Vpu1 Muxes: en1 ch1:31 odd, en2 ch33:63 odd
--      Vpu2 Muxes: en1 ch2:32 even, en2 ch34:64 even
-- 
-- Dependencies: 
-- 
-- Revision:
-- Revision 0.01 - 10/24/2022 File Created
-- Revision 1.0 - 7/13/2023 Copied from 2023_DAQ_64ch_v2.srcs
--      Changed vpickup channel selections to 32 (from 64), added enable bit constants
-- Additional Comments: 

----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity mux_controller is
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
                
end mux_controller;

----------------------------------------------------------------------------------
architecture Behavioral of mux_controller is
----------------------------------------------------------------------------------
-- Constants
constant MUX_SEL_BITS : integer := 4;   -- number of select bits in each mux ic
constant VS_MUX_EN_BITS : integer := 4; -- number of vsource/vsink muxes
constant VP_MUX_EN_BITS : integer := 2; -- number of vpickup ch 1/2 muxes

-- Signals
signal vsrc_mux_sel, vsink_mux_sel, vpu1_mux_sel, vpu2_mux_sel : STD_LOGIC_VECTOR (MUX_SEL_BITS-1 downto 0) := (others => '0');
signal vsrc_mux_en, vsink_mux_en : STD_LOGIC_VECTOR (VS_MUX_EN_BITS-1 downto 0) := (others => '0');    -- Vs+/- Muxes
signal vpu1_mux_en, vpu2_mux_en : STD_LOGIC_VECTOR (VP_MUX_EN_BITS-1 downto 0) := (others => '0');     -- Muxes for each Vpickup lane
----------------------------------------------------------------------------------
begin
----------------------------------------------------------------------------------
-- Odd and even numbered channels are split on the MUX board (J1 is odd, J2 is even ch's)
--      Vs+/- Muxes: en1 ch1:31 odd, en2 ch2:32 even, en3 ch33:63 odd, en4 34:64 even
--      Vpu1 Muxes: en1 ch1:31 odd, en2 ch33:63 odd
--      Vpu2 Muxes: en1 ch2:32 even, en2 ch34:64 even

----------------------------------------------------------------------------------
-- Update select bits
-- Mux select bits are 64-channel bits divided by 2 (shift right)
update_mux_sel_bits: process(clk)
begin
if rising_edge(clk) then
    -- Update select bits upon reset or enable
    if (reset = '1') then           -- clear to first channel
        vsrc_mux_sel <= (others => '0');
        vsink_mux_sel <= (others => '0');
        vpu1_mux_sel <= (others => '0');
        vpu2_mux_sel <= (others => '0');
    
    else 
        -- Take middle bits (i.e., exclude MSBs) of channel number to get Select bits
        vsrc_mux_sel <= vsrc_ch(MUX_SEL_BITS downto 1);     -- exclude LSB because vs+/- muxes are split by even/odd channels
        vsink_mux_sel <= vsink_ch(MUX_SEL_BITS downto 1);
        vpu1_mux_sel <= vpu1_ch(MUX_SEL_BITS-1 downto 0);   -- include LSB, vpu muxes are already 32 channels
        vpu2_mux_sel <= vpu2_ch(MUX_SEL_BITS-1 downto 0);
        
    end if;
end if;
end process update_mux_sel_bits;

----------------------------------------------------------------------------------
-- Update enable bits
update_mux_en_bits: process(clk)
begin
if rising_edge(clk) then
    if (reset = '1') then               -- reset enable bits to disable all muxes
        vsrc_mux_en <= (others => '0');
        vsink_mux_en <= (others => '0');
        vpu1_mux_en <= (others => '0');
        vpu2_mux_en <= (others => '0');
   else
        -- Set enable bits -- Vsource (Vs+)
        if en_mux_n(3) = '1' then
            if (vsrc_ch(0) = '0' and vsrc_ch(CH_BITS-1) = '0') then -- odd channel, mux 1 (ch 1-32) --> binary 0-31
                vsrc_mux_en <= "0001";
            elsif (vsrc_ch(0) = '0' and vsrc_ch(CH_BITS-1) = '1') then -- odd channel, mux 3 (ch 33-64) --> binary 32-63
                vsrc_mux_en <= "0100";
            elsif (vsrc_ch(0) = '1' and vsrc_ch(CH_BITS-1) = '0') then -- even channel, mux 2 (ch 1-32)
                vsrc_mux_en <= "0010";
            elsif (vsrc_ch(0) = '1' and vsrc_ch(CH_BITS-1) = '1') then -- even channel, mux 4 (ch 33-64)
                vsrc_mux_en <= "1000";
            end if;
        else
            vsrc_mux_en <= (others => '0'); -- disable
        end if;
        
        -- Set enable bits -- Vsink (Vs-)
        if en_mux_n(2) = '1' then
            if (vsink_ch(0) = '0' and vsink_ch(CH_BITS-1) = '0') then -- odd channel, mux 1 (ch 1-32) --> binary 0-31
                vsink_mux_en <= "0001";
            elsif (vsink_ch(0) = '0' and vsink_ch(CH_BITS-1) = '1') then -- odd channel, mux 3 (ch 33-64) --> binary 32-63
                vsink_mux_en <= "0100";
            elsif (vsink_ch(0) = '1' and vsink_ch(CH_BITS-1) = '0') then -- even channel, mux 2 (ch 1-32)
                vsink_mux_en <= "0010";
            elsif (vsink_ch(0) = '1' and vsink_ch(CH_BITS-1) = '1') then -- even channel, mux 4 (ch 33-64)
                vsink_mux_en <= "1000";
            end if;
        else
            vsink_mux_en <= (others => '0'); -- disable
        end if;
        
        -- Set enable bits -- Vpickup Lane 1 (V1) -- Odd Channels
        if en_mux_n(1) = '1' then 
            if (vpu1_ch(CH_BITS-2) = '0') then  -- channel 1-31, mux 1  --> binary 0-30 odd channels
                vpu1_mux_en <= "01";
            else                        -- channel 33-63, mux 2 --> binary 32-62 odd channels
                vpu1_mux_en <= "10";
            end if;
        else
            vpu1_mux_en <= (others => '0'); -- disable
        end if;      
          
        -- Set enable bits -- Vpickup Lane 2 (V2) -- Even Channels
        if en_mux_n(0) = '1' then 
            if (vpu2_ch(CH_BITS-2) = '0') then  -- channel 2-32, mux 1  --> binary 1-31 even channels
                vpu2_mux_en <= "01";
            else                        -- channel 34-64, mux 2 --> binary 33-63 even channels
                vpu2_mux_en <= "10";
            end if;
        else
            vpu2_mux_en <= (others => '0'); -- disable
        end if;
    end if;

end if;
end process update_mux_en_bits;

----------------------------------------------------------------------------------
-- Hook up internal signals to outputs 
-- Flip enable (Muxes are active low), tack on select bits (LSBs)
update_outputs: process(clk)
begin
if rising_edge(clk) then
    -- Update enable bits: enables are ACTIVE LOW
    if (enable = '1') then 
        mux_vsrc(VS_MUX_EN_BITS+MUX_SEL_BITS-1 downto MUX_SEL_BITS) <= not vsrc_mux_en;
        mux_vsink(VS_MUX_EN_BITS+MUX_SEL_BITS-1 downto MUX_SEL_BITS) <= not vsink_mux_en;
        mux_vpu1(VP_MUX_EN_BITS+MUX_SEL_BITS-1 downto MUX_SEL_BITS) <= not vpu1_mux_en;
        mux_vpu2(VP_MUX_EN_BITS+MUX_SEL_BITS-1 downto MUX_SEL_BITS) <= not vpu2_mux_en;
    else
        mux_vsrc(VS_MUX_EN_BITS+MUX_SEL_BITS-1 downto MUX_SEL_BITS) <= (others => '1');
        mux_vsink(VS_MUX_EN_BITS+MUX_SEL_BITS-1 downto MUX_SEL_BITS) <= (others => '1');
        mux_vpu1(VP_MUX_EN_BITS+MUX_SEL_BITS-1 downto MUX_SEL_BITS) <= (others => '1');
        mux_vpu2(VP_MUX_EN_BITS+MUX_SEL_BITS-1 downto MUX_SEL_BITS) <= (others => '1');
   
    end if;
    
    -- Update select bits
    mux_vsrc(MUX_SEL_BITS-1 downto 0) <= vsrc_mux_sel;
    mux_vsink(MUX_SEL_BITS-1 downto 0) <= vsink_mux_sel;
    mux_vpu1(MUX_SEL_BITS-1 downto 0) <= vpu1_mux_sel;
    mux_vpu2(MUX_SEL_BITS-1 downto 0) <= vpu2_mux_sel;
end if;
end process; 
----------------------------------------------------------------------------------

end Behavioral;
