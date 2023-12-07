----------------------------------------------------------------------------------
-- Company: Thayer School of Engineering, Dartmouth College
-- Engineer: Kendall Farnham
-- 
-- Create Date: 07/13/2023
-- Design Name: 
-- Module Name: top_top_design - Behavioral
-- Project Name: 2023_DAQ
-- Target Devices: Artix 7 (Trenz Electronics TE0711-01)
-- Tool Versions: Vivado 2022.2
-- Description: Map IO from top_design (DAQ code) to TE0711 pins
-- 
-- Dependencies: 
--      top_design
--      library UNISIM;	use UNISIM.Vcomponents.ALL; -- for IO Buffers
--
-- Revision 0.01 - 04/12/2023 File Created
-- Revision 0.02 - 7/13/2023 Copied from 2023_DAQ_64ch_v2.srcs
-- 
----------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.std_logic_unsigned.all;
use ieee.math_real.all;

library UNISIM;						
use UNISIM.Vcomponents.ALL; 

entity top_top_design is
Port ( 
    sysclk : in STD_LOGIC;
--    master_reset_in : in STD_LOGIC;
    
    pga_isense_clk : out STD_LOGIC;
    pga_isense_si : out STD_LOGIC;
    pga_isense_cs_n : out STD_LOGIC;
    pga_vpu1_clk : out STD_LOGIC;
    pga_vpu1_si : out STD_LOGIC;
    pga_vpu1_cs_n : out STD_LOGIC;
    pga_vpu2_clk : out STD_LOGIC;
    pga_vpu2_si : out STD_LOGIC;
    pga_vpu2_cs_n : out STD_LOGIC;
    
    dclk_dds : out STD_LOGIC;        -- Forwarded clocks
    aclk_isense : out STD_LOGIC;
    aclk_vpu1 : out STD_LOGIC;
    aclk_vpu2 : out STD_LOGIC;
    
    dds_out: out STD_LOGIC_VECTOR (13 downto 0);    -- to DAC
    
    -- 64 Channel DAQ Rev 2
    -- Note: Muxes for vsink and vsrc are split between connector J1 (odd # channels) and J2 (even # channels) on DAQ. 
    mux_vsrc_odd  : out STD_LOGIC_VECTOR (5 downto 0);  -- to VS+ Muxes for odd channels [0:5]: S0, S1, S2, S3, NEN1, NEN3
    mux_vsrc_even : out STD_LOGIC_VECTOR (5 downto 0);  -- to VS+ Muxes for even channels [0:5]: S0, S1, S2, S3, NEN2, NEN4
    mux_vsink_odd  : out STD_LOGIC_VECTOR (5 downto 0); -- to VS- Muxes for odd channels [0:5]: S0, S1, S2, S3, NEN1, NEN3
    mux_vsink_even : out STD_LOGIC_VECTOR (5 downto 0); -- to VS- Muxes for even channels [0:5]: S0, S1, S2, S3, NEN2, NEN4
    mux_vpu1 : out STD_LOGIC_VECTOR (5 downto 0);   -- to Vpickup Ch1 Muxes [0:5]: S0, S1, S2, S3, NEN1, NEN2
    mux_vpu2 : out STD_LOGIC_VECTOR (5 downto 0);   -- to Vpickup Ch2 Muxes [0:5]: S0, S1, S2, S3, NEN1, NEN2
    
--    -- Anya's 16 Channel MUX board
--    mux_src  : out STD_LOGIC_VECTOR (4 downto 0);  -- to VS+ Muxes  [0:4]: S0, S1, S2, S3, NEN
--    mux_snk  : out STD_LOGIC_VECTOR (4 downto 0);  -- to VS- Muxes  [0:4]: S0, S1, S2, S3, NEN
--    mux_v1  : out STD_LOGIC_VECTOR (4 downto 0);   -- to V1  Muxes  [0:4]: S0, S1, S2, S3, NEN
--    mux_v2  : out STD_LOGIC_VECTOR (4 downto 0);   -- to V2  Muxes  [0:4]: S0, S1, S2, S3, NEN

    lvds_isense_clk_p : out STD_LOGIC;      -- Isense ADC LVDS interface input clock (DCIN)
    lvds_isense_clk_n : out STD_LOGIC;
    lvds_isense_da_p : in STD_LOGIC;        -- Isense ADC LVDS interface output data lane A (DA)
    lvds_isense_da_n : in STD_LOGIC;   
    lvds_isense_db_p : in STD_LOGIC;        -- Isense ADC LVDS interface output data lane B (DB)
    lvds_isense_db_n : in STD_LOGIC;   
    
    lvds_vpu1_clk_p : out STD_LOGIC;        -- Vpickup Ch1 ADC LVDS interface input clock (DCIN)
    lvds_vpu1_clk_n : out STD_LOGIC; 
    lvds_vpu1_da_p : in STD_LOGIC;          -- Vpickup Ch1 ADC LVDS interface output data lane A (DA)
    lvds_vpu1_da_n : in STD_LOGIC;   
    lvds_vpu1_db_p : in STD_LOGIC;          -- Vpickup Ch1 ADC LVDS interface output data lane B (DB)
    lvds_vpu1_db_n : in STD_LOGIC;   
    
    lvds_vpu2_clk_p : out STD_LOGIC;        -- Vpickup Ch2 ADC LVDS interface input clock (DCIN)
    lvds_vpu2_clk_n : out STD_LOGIC;
    lvds_vpu2_da_p : in STD_LOGIC;          -- Vpickup Ch2 ADC LVDS interface output data lane A (DA)
    lvds_vpu2_da_n : in STD_LOGIC;   
    lvds_vpu2_db_p : in STD_LOGIC;          -- Vpickup Ch2 ADC LVDS interface output data lane B (DB)
    lvds_vpu2_db_n : in STD_LOGIC;   
   
--    -- NOTE: PLACEMENT FAILS (NOT ENOUGH BUFFERS ON IO BANK), USING INTERNAL CLK_FWD IN TOP_DESIGN INSTEAD
--    lvds_isense_dco_p : in STD_LOGIC;       -- Isense ADC LVDS interface output clock (DCO)
--    lvds_isense_dco_n : in STD_LOGIC;   
--    lvds_vpu1_dco_p : in STD_LOGIC;         -- Vpickup Ch1 ADC LVDS interface output clock (DCO)
--    lvds_vpu1_dco_n : in STD_LOGIC;  
--    lvds_vpu2_dco_p : in STD_LOGIC;         -- Vpickup Ch2 ADC LVDS interface output clock (DCO)
--    lvds_vpu2_dco_n : in STD_LOGIC;   


    isense_twolanes : out STD_LOGIC;                    -- ADC digital IO 
    isense_testpat : out STD_LOGIC;
    isense_pwr_dwn : out STD_LOGIC;
   
    vpu1_twolanes : out STD_LOGIC;
    vpu1_testpat : out STD_LOGIC;
    vpu1_pwr_dwn : out STD_LOGIC;
    
    vpu2_twolanes : out STD_LOGIC;
    vpu2_testpat : out STD_LOGIC;
    vpu2_pwr_dwn : out STD_LOGIC;
    
    done_tx : out std_logic;        -- testbench signal (REMOVE FOR FINAL IMPLEMENTATION)
    
    
    uart_txd_in: in STD_LOGIC;      -- USB UART interface (Received signals)
    uart_txd_out: out STD_LOGIC);   -- USB UART interface (Transferred signals)
end top_top_design;

architecture Behavioral of top_top_design is

-----------------------------------------------------------------------
-- Constants
-----------------------------------------------------------------------
constant LVDS_DIFF_TERM : boolean := TRUE; -- TRUE to use internal R differential termination
constant LVDS_LOW_PWR : boolean := FALSE;   -- TRUE for low power, FALSE for high performance
constant LVDS_SLEW : string := "FAST";      -- FAST or SLOW
constant LVDS_IO_STD : string := "LVDS_25"; -- Must be LVDS_25 --> HR IO bank only supports this LVDS standard

-----------------------------------------------------------------------
-- Signals
-----------------------------------------------------------------------
signal dclk : std_logic := '0';
signal adc_cnv, adc_twolanes, adc_testpat, adc_pwr_dwn : std_logic := '0';
signal lvds_dcin, lvds_isense_da, lvds_isense_db : std_logic := '0';
signal lvds_vpu1_da, lvds_vpu1_db, lvds_vpu2_da, lvds_vpu2_db : std_logic := '0';
signal lvds_isense_clk, lvds_vpu1_clk, lvds_vpu2_clk : std_logic := '0';
signal mux_vsrc_s, mux_vsink_s : std_logic_vector(7 downto 0) := (others => '0');
signal mux_vpu1_s, mux_vpu2_s : std_logic_vector(5 downto 0) := (others => '0');
--signal pga_isense_clk, pga_isense_si, pga_isense_cs_n: std_logic := '0';
--signal pga_vpu1_clk, pga_vpu1_si, pga_vpu1_cs_n: std_logic := '0';
--signal pga_vpu2_clk, pga_vpu2_si, pga_vpu2_cs_n: std_logic := '0';
signal pga_isense_clk_buf, pga_vpu1_clk_buf, pga_vpu2_clk_buf : std_logic := '0';
-----------------------------------------------------------------------
-- Instantiate Component
-----------------------------------------------------------------------
component top_design
Port ( 
    sysclk : in STD_LOGIC;
    master_reset_in : in STD_LOGIC;

    -- PGA Controls
    pga_isense_clk : out STD_LOGIC;
    pga_isense_si : out STD_LOGIC;
    pga_isense_cs_n : out STD_LOGIC;
    pga_vpu1_clk : out STD_LOGIC;
    pga_vpu1_si : out STD_LOGIC;
    pga_vpu1_cs_n : out STD_LOGIC;
    pga_vpu2_clk : out STD_LOGIC;
    pga_vpu2_si : out STD_LOGIC;
    pga_vpu2_cs_n : out STD_LOGIC;
    
    dclk_dds : out STD_LOGIC;       -- DDS clock
    aclk_cnv : out STD_LOGIC;       -- ADC conversion clock
    
    dds_out: out STD_LOGIC_VECTOR (13 downto 0);    -- to DAC
    
    -- MUX Interface - 64 CHANNEL DAQ REV 2
    mux_vsrc  : out STD_LOGIC_VECTOR (7 downto 0);  -- to VS+ Muxes [0:7]: S0, S1, S2, S3, NEN1, NEN2, NEN3, NEN4
    mux_vsink : out STD_LOGIC_VECTOR (7 downto 0);  -- to VS- Muxes [0:7]: S0, S1, S2, S3, NEN1, NEN2, NEN3, NEN4
    mux_vpu1  : out STD_LOGIC_VECTOR (5 downto 0);  -- to Vpickup 1 Muxes (Odd Ch's) [0:5]: S0, S1, S2, S3, NEN1, NEN2
    mux_vpu2  : out STD_LOGIC_VECTOR (5 downto 0);  -- to Vpickup 2 Muxes (Even Ch's) [0:5]: S0, S1, S2, S3, NEN1, NEN2
    
    -- ADC LVDS Communication    
    lvds_oclk : out STD_LOGIC;              -- ADC LVDS interface input clock (DCIN pin)
    lvds_isense_da : in STD_LOGIC;          -- Isense ADC LVDS interface output data lane A (DA)
    lvds_isense_db : in STD_LOGIC;          -- Isense ADC LVDS interface output data lane B (DB)
    lvds_isense_clk : in STD_LOGIC;         -- Isense ADC LVDS interface output clock (DCO pin)
    lvds_vpu1_da : in STD_LOGIC;            -- Vpickup Ch1 ADC LVDS interface output data lane A (DA)
    lvds_vpu1_db : in STD_LOGIC;            -- Vpickup Ch1 ADC LVDS interface output data lane B (DB)
    lvds_vpu1_clk : in STD_LOGIC;           -- Vpickup Ch1 ADC LVDS interface output clock
    lvds_vpu2_da : in STD_LOGIC;            -- Vpickup Ch2 ADC LVDS interface output data lane A (DA)
    lvds_vpu2_db : in STD_LOGIC;            -- Vpickup Ch2 ADC LVDS interface output data lane B (DB)
    lvds_vpu2_clk : in STD_LOGIC;           -- Vpickup Ch2 ADC LVDS interface output clock
   
    adc_twolanes : out STD_LOGIC;           -- ADC digital IO 
    adc_testpat : out STD_LOGIC;
    adc_pwr_dwn : out STD_LOGIC;
    
    done_tx : out std_logic;        -- testbench signal (REMOVE FOR FINAL IMPLEMENTATION)
    
    uart_txd_in: in STD_LOGIC;      -- USB UART interface (Received signals)
    uart_txd_out: out STD_LOGIC);   -- USB UART interface (Transferred signals)
end component;

-----------------------------------------------------------------------
-----------------------------------------------------------------------
begin
-----------------------------------------------------------------------
-----------------------------------------------------------------------
-- Wire top_design to IO port
top_inst: top_design port map(
    sysclk => sysclk,
    master_reset_in => '0', --master_reset_in,

    pga_isense_clk => pga_isense_clk_buf, 
    pga_isense_si => pga_isense_si, 
    pga_isense_cs_n => pga_isense_cs_n,
    pga_vpu1_clk => pga_vpu1_clk_buf,
    pga_vpu1_si => pga_vpu1_si,
    pga_vpu1_cs_n => pga_vpu1_cs_n,
    pga_vpu2_clk => pga_vpu2_clk_buf,
    pga_vpu2_si => pga_vpu2_si,
    pga_vpu2_cs_n => pga_vpu2_cs_n,
    
    dclk_dds => dclk,
    aclk_cnv => adc_cnv,
    
    dds_out => dds_out,
    
    mux_vsrc => mux_vsrc_s,
    mux_vsink => mux_vsink_s,
    mux_vpu1 => mux_vpu1_s,
    mux_vpu2 => mux_vpu2_s,
    
    lvds_oclk => lvds_dcin,        
    lvds_isense_da => lvds_isense_da,
    lvds_isense_db => lvds_isense_db,
    lvds_isense_clk => '0', --lvds_isense_clk, 
    lvds_vpu1_da => lvds_vpu1_da,
    lvds_vpu1_db => lvds_vpu1_db,
    lvds_vpu1_clk => '0', --lvds_vpu1_clk,
    lvds_vpu2_da => lvds_vpu2_da,
    lvds_vpu2_db => lvds_vpu2_db,
    lvds_vpu2_clk => '0', --lvds_vpu2_clk,
    
    adc_twolanes => adc_twolanes,
    adc_testpat => adc_testpat,
    adc_pwr_dwn => adc_pwr_dwn,
    
    done_tx => done_tx,             -- testbench signal
    uart_txd_in => uart_txd_in,
    uart_txd_out => uart_txd_out);

-----------------------------------------------------------------------
-- High-speed IO buffers
-----------------------------------------------------------------------
-- Clock forwarding off-chip
-----------------------------------------------------------------------
-- ODDR: Output Double Data Rate Output Register with Set, Reset and Clock Enable.
-- 7 Series Xilinx HDL Libraries Guide, version 14.7
---------------------------------------------------------------------
-- DDS clock to DAC (ODDR) 
---------------------------------------------------------------------
dac_clk_forward: ODDR
generic map(
DDR_CLK_EDGE => "SAME_EDGE", -- "OPPOSITE_EDGE" or "SAME_EDGE"
INIT => '0',        -- Initial value for Q port ('1' or '0')
SRTYPE => "SYNC" )  -- Reset Type ("ASYNC" or "SYNC")
port map(
Q => dclk_dds,      --  1-bit DDR output
C => dclk,          --  1-bit clock input
CE => '1',          --  1-bit clock enable input
D1 => '1',          --  1-bit data input (positive edge)
D2 => '0',          --  1-bit data input (negative edge)
R => '0',           --  1-bit reset input 
S => '0' );         --  1-bit set input     

-----------------------------------------------------------------------
-- ADC conversion clock forwarding off-chip
-----------------------------------------------------------------------
-- CNV pulse from ltc2387_16b_adc_interface (ODDR) 
---------------------------------------------------------------------
aclk_i_forward: ODDR
generic map(
DDR_CLK_EDGE => "SAME_EDGE", -- "OPPOSITE_EDGE" or "SAME_EDGE"
INIT => '0',        -- Initial value for Q port ('1' or '0')
SRTYPE => "SYNC" )  -- Reset Type ("ASYNC" or "SYNC")
port map(
Q => aclk_isense,   --  1-bit DDR output
C => adc_cnv,       --  1-bit clock input
CE => '1',          --  1-bit clock enable input
D1 => '1',          --  1-bit data input (positive edge)
D2 => '0',          --  1-bit data input (negative edge)
R => '0',           --  1-bit reset input 
S => '0' );         --  1-bit set input     

aclk_v1_forward: ODDR
generic map(
DDR_CLK_EDGE => "SAME_EDGE", -- "OPPOSITE_EDGE" or "SAME_EDGE"
INIT => '0',        -- Initial value for Q port ('1' or '0')
SRTYPE => "SYNC" )  -- Reset Type ("ASYNC" or "SYNC")
port map(
Q => aclk_vpu1,     --  1-bit DDR output
C => adc_cnv,       --  1-bit clock input
CE => '1',          --  1-bit clock enable input
D1 => '1',          --  1-bit data input (positive edge)
D2 => '0',          --  1-bit data input (negative edge)
R => '0',           --  1-bit reset input 
S => '0' );         --  1-bit set input     


aclk_v2_forward: ODDR
generic map(
DDR_CLK_EDGE => "SAME_EDGE", -- "OPPOSITE_EDGE" or "SAME_EDGE"
INIT => '0',        -- Initial value for Q port ('1' or '0')
SRTYPE => "SYNC" )  -- Reset Type ("ASYNC" or "SYNC")
port map(
Q => aclk_vpu2,     --  1-bit DDR output
C => adc_cnv,       --  1-bit clock input
CE => '1',          --  1-bit clock enable input
D1 => '1',          --  1-bit data input (positive edge)
D2 => '0',          --  1-bit data input (negative edge)
R => '0',           --  1-bit reset input 
S => '0' );         --  1-bit set input     

---------------------------------------------------------------------
---- Direct connection
--aclk_isense <= adc_cnv;
--aclk_vpu1 <= adc_cnv;
--aclk_vpu2 <= adc_cnv;
---------------------------------------------------------------------
-- LVDS signals to/from ADC's
---------------------------------------------------------------------
---------------------------------------------------------------------
-- LVDS signals to/from ADC's -- ISENSE ADC 
---------------------------------------------------------------------
-- Clocks
isense_lvds_clk_inst : OBUFDS   -- LVDS clock
generic map (
    IOSTANDARD => LVDS_IO_STD,    -- Specify the output I/O standard
    SLEW => LVDS_SLEW)          -- Specify the output slew rate
port map (
    O => lvds_isense_clk_p,     -- Diff_p output (connect directly to top-level port)   
    OB => lvds_isense_clk_n,    -- Diff_n output (connect directly to top-level port)
    I => lvds_dcin               -- Buffer input  
);

---- ADC to FPGA
--isense_lvds_dco_inst : IBUFDS   -- LVDS data clock from ADC
--generic map (
--    DIFF_TERM => LVDS_DIFF_TERM,    -- Differential Termination
--    IBUF_LOW_PWR => LVDS_LOW_PWR,   -- Low power (TRUE) vs. performance (FALSE) setting for referenced I/O standards
--    IOSTANDARD => LVDS_IO_STD)      -- Specify the output slew rate
--port map (
--    O => lvds_isense_clk,             -- Buffer output
--    I => lvds_isense_dco_p,      -- Diff_p buffer input (connect directly to top-level port)
--    IB => lvds_isense_dco_n      -- Diff_n buffer input (connect directly to top-level port)
--);
---------------------
-- Data using IBUFDS_DIFF_OUT
isense_lvds_da_inst : IBUFDS_DIFF_OUT    -- Serial LVDS output, lane A
generic map (
    DIFF_TERM => LVDS_DIFF_TERM,    -- Differential Termination
    IBUF_LOW_PWR => LVDS_LOW_PWR,   -- Low power (TRUE) vs. performance (FALSE) setting for referenced I/O standards
    IOSTANDARD => LVDS_IO_STD)
port map (
    O => lvds_isense_da,             -- Buffer output
    OB => open,                 -- Differential buffer output (not in use)
    I => lvds_isense_da_p,      -- Diff_p buffer input (connect directly to top-level port)
    IB => lvds_isense_da_n      -- Diff_n buffer input (connect directly to top-level port)
);

isense_lvds_db_inst : IBUFDS_DIFF_OUT    -- Serial LVDS output, lane B
generic map (
    DIFF_TERM => LVDS_DIFF_TERM,    -- Differential Termination
    IBUF_LOW_PWR => LVDS_LOW_PWR,   -- Low power (TRUE) vs. performance (FALSE) setting for referenced I/O standards
    IOSTANDARD => LVDS_IO_STD)
port map (
    O => lvds_isense_db,             -- Buffer output
    OB => open,                 -- Differential buffer output (not in use)
    I => lvds_isense_db_p,      -- Diff_p buffer input (connect directly to top-level port)
    IB => lvds_isense_db_n      -- Diff_n buffer input (connect directly to top-level port)
);    
-----------------------------------------------------------------------
-- LVDS signals to/from ADC's -- VPICKUP CHANNEL 1 ADC
-----------------------------------------------------------------------
-- Clocks
-- FPGA to ADC
vpu1_lvds_clk_inst : OBUFDS   -- LVDS clock
generic map (
    IOSTANDARD => LVDS_IO_STD,  -- Specify the output I/O standard
    SLEW => LVDS_SLEW)        -- Specify the output slew rate
port map (
    O => lvds_vpu1_clk_p,     -- Diff_p output (connect directly to top-level port)
    OB => lvds_vpu1_clk_n,    -- Diff_n output (connect directly to top-level port)
    I => lvds_dcin            -- Buffer input
);

---- ADC to FPGA
--vpu1_lvds_dco_inst : IBUFDS   -- LVDS data clock from ADC
--generic map (
--    DIFF_TERM => LVDS_DIFF_TERM,    -- Differential Termination
--    IBUF_LOW_PWR => LVDS_LOW_PWR,   -- Low power (TRUE) vs. performance (FALSE) setting for referenced I/O standards
--    IOSTANDARD => LVDS_IO_STD)      -- Specify the output slew rate
--port map (
--    O => lvds_vpu1_clk,             -- Buffer output
--    I => lvds_vpu1_dco_p,      -- Diff_p buffer input (connect directly to top-level port)
--    IB => lvds_vpu1_dco_n      -- Diff_n buffer input (connect directly to top-level port)
--);
-----------------------
-- Data using IBUFDS_DIFF_OUT
vpu1_lvds_da_inst : IBUFDS_DIFF_OUT    -- Serial LVDS output, lane A
generic map (
    DIFF_TERM => LVDS_DIFF_TERM,    -- Differential Termination
    IBUF_LOW_PWR => LVDS_LOW_PWR,   -- Low power (TRUE) vs. performance (FALSE) setting for referenced I/O standards
    IOSTANDARD => LVDS_IO_STD)
port map (
    O => lvds_vpu1_da,             -- Buffer output
    OB => open,               -- Differential buffer output (not in use)
    I => lvds_vpu1_da_p,      -- Diff_p buffer input (connect directly to top-level port)
    IB => lvds_vpu1_da_n      -- Diff_n buffer input (connect directly to top-level port)
);

vpu1_lvds_db_inst : IBUFDS_DIFF_OUT    -- Serial LVDS output, lane B
generic map (
    DIFF_TERM => LVDS_DIFF_TERM,    -- Differential Termination
    IBUF_LOW_PWR => LVDS_LOW_PWR,   -- Low power (TRUE) vs. performance (FALSE) setting for referenced I/O standards
    IOSTANDARD => LVDS_IO_STD)
port map (
    O => lvds_vpu1_db,             -- Buffer output
    OB => open,               -- Differential buffer output (not in use)
    I => lvds_vpu1_db_p,      -- Diff_p buffer input (connect directly to top-level port)
    IB => lvds_vpu1_db_n      -- Diff_n buffer input (connect directly to top-level port)
);    
---------------------------------------------------------------------
-- LVDS signals to/from ADC's -- VPICKUP CHANNEL 2 ADC 
---------------------------------------------------------------------
-- Clocks
-- FPGA to ADC
vpu2_lvds_clk_inst : OBUFDS   -- LVDS clock out to ADC
generic map (
    IOSTANDARD => LVDS_IO_STD,  -- Specify the output I/O standard
    SLEW => LVDS_SLEW)        -- Specify the output slew rate
port map (
    O => lvds_vpu2_clk_p,     -- Diff_p output (connect directly to top-level port)
    OB => lvds_vpu2_clk_n,    -- Diff_n output (connect directly to top-level port)
    I => lvds_dcin            -- Buffer input
);

---- ADC to FPGA
--vpu2_lvds_dco_inst : IBUFDS   -- LVDS data clock from ADC
--generic map (
--    DIFF_TERM => LVDS_DIFF_TERM,    -- Differential Termination
--    IBUF_LOW_PWR => LVDS_LOW_PWR,   -- Low power (TRUE) vs. performance (FALSE) setting for referenced I/O standards
--    IOSTANDARD => LVDS_IO_STD)      -- Specify the output slew rate
--port map (
--    O => lvds_vpu2_clk,             -- Buffer output
--    I => lvds_vpu2_dco_p,      -- Diff_p buffer input (connect directly to top-level port)
--    IB => lvds_vpu2_dco_n      -- Diff_n buffer input (connect directly to top-level port)
--);
-----------------------
-- Data using IBUFDS_DIFF_OUT
vpu2_lvds_da_inst : IBUFDS_DIFF_OUT    -- Serial LVDS output, lane A
generic map (
    DIFF_TERM => LVDS_DIFF_TERM,    -- Differential Termination
    IBUF_LOW_PWR => LVDS_LOW_PWR,   -- Low power (TRUE) vs. performance (FALSE) setting for referenced I/O standards
    IOSTANDARD => LVDS_IO_STD)
port map (
    O => lvds_vpu2_da,             -- Buffer output
    OB => open,               -- Differential buffer output (not in use)
    I => lvds_vpu2_da_p,      -- Diff_p buffer input (connect directly to top-level port)
    IB => lvds_vpu2_da_n      -- Diff_n buffer input (connect directly to top-level port)
);

vpu2_lvds_db_inst : IBUFDS_DIFF_OUT    -- Serial LVDS output, lane B
generic map (
    DIFF_TERM => LVDS_DIFF_TERM,    -- Differential Termination
    IBUF_LOW_PWR => LVDS_LOW_PWR,   -- Low power (TRUE) vs. performance (FALSE) setting for referenced I/O standards
    IOSTANDARD => LVDS_IO_STD)
port map (
    O => lvds_vpu2_db,             -- Buffer output
    OB => open,               -- Differential buffer output (not in use)
    I => lvds_vpu2_db_p,      -- Diff_p buffer input (connect directly to top-level port)
    IB => lvds_vpu2_db_n      -- Diff_n buffer input (connect directly to top-level port)
);    

-------------------------------------------------------------------------
-------------------------------------------------------------------------
---- CRITICAL WARNING: METHODOLOGY - ODDR on non-clock signal
-------------------------------------------------------------------------
-------------------------------------------------------------------------
---- PGA SPI Bus (ODDR)
-------------------------------------------------------------------------
pga_isense_sclk_forward: ODDR
generic map(
DDR_CLK_EDGE => "SAME_EDGE", -- "OPPOSITE_EDGE" or "SAME_EDGE"
INIT => '0',        -- Initial value for Q port ('1' or '0')
SRTYPE => "SYNC" )  -- Reset Type ("ASYNC" or "SYNC")
port map(
Q => pga_isense_clk, --  1-bit DDR output
C => pga_isense_clk_buf,--  1-bit clock input
CE => '1',          --  1-bit clock enable input
D1 => '1',          --  1-bit data input (positive edge)
D2 => '0',          --  1-bit data input (negative edge)
R => '0',           --  1-bit reset input 
S => '0' );         --  1-bit set input     

pga_vpu1_sclk_forward: ODDR
generic map(
DDR_CLK_EDGE => "SAME_EDGE", -- "OPPOSITE_EDGE" or "SAME_EDGE"
INIT => '0',        -- Initial value for Q port ('1' or '0')
SRTYPE => "SYNC" )  -- Reset Type ("ASYNC" or "SYNC")
port map(
Q => pga_vpu1_clk,   --  1-bit DDR output
C => pga_vpu1_clk_buf,  --  1-bit clock input
CE => '1',          --  1-bit clock enable input
D1 => '1',          --  1-bit data input (positive edge)
D2 => '0',          --  1-bit data input (negative edge)
R => '0',           --  1-bit reset input 
S => '0' );         --  1-bit set input       

pga_vpu2_sclk_forward: ODDR
generic map(
DDR_CLK_EDGE => "SAME_EDGE", -- "OPPOSITE_EDGE" or "SAME_EDGE"
INIT => '0',        -- Initial value for Q port ('1' or '0')
SRTYPE => "SYNC" )  -- Reset Type ("ASYNC" or "SYNC")
port map(
Q => pga_vpu2_clk,   --  1-bit DDR output
C => pga_vpu2_clk_buf,  --  1-bit clock input
CE => '1',          --  1-bit clock enable input
D1 => '1',          --  1-bit data input (positive edge)
D2 => '0',          --  1-bit data input (negative edge)
R => '0',           --  1-bit reset input 
S => '0' );         --  1-bit set input    

----------------------------------------------------------------------- 
-----------------------------------------------------------------------
-- Wire DIO signals to ports
----------------------------------------------------------------------- 
----------------------------------------------------------------------- 
-- Mux controls  -- 64 CHANNEL DAQ REV 2
-- Note: odd and even numbered channels are split on the MUX board (J1 is odd, J2 is even ch's)
--      VS+ and VS- muxes are split (share S0-S3 bits, enables 1&3 are odd , 2&4 even ch's)
--      Vpickup Ch 1 is odd channels, Vpickup Ch 2 is even channels
mux_vsrc_odd <= mux_vsrc_s(6) & mux_vsrc_s(4)
            & mux_vsrc_s(3) & mux_vsrc_s(2)
            & mux_vsrc_s(1) & mux_vsrc_s(0);
mux_vsrc_even <= mux_vsrc_s(7) & mux_vsrc_s(5)
            & mux_vsrc_s(3) & mux_vsrc_s(2)
            & mux_vsrc_s(1) & mux_vsrc_s(0);
mux_vsink_odd <= mux_vsink_s(6) & mux_vsink_s(4)
            & mux_vsink_s(3) & mux_vsink_s(2)
            & mux_vsink_s(1) & mux_vsink_s(0);
mux_vsink_even <= mux_vsink_s(7) & mux_vsink_s(5)
            & mux_vsink_s(3) & mux_vsink_s(2)
            & mux_vsink_s(1) & mux_vsink_s(0);
mux_vpu1 <= mux_vpu1_s;
mux_vpu2 <= mux_vpu2_s;

------------------------------------------------------------------------- 
---- Mux controls  -- ANYA'S 16 CHANNEL MUX BOARD
--mux_src <= mux_vsrc_s(4 downto 0);
--mux_snk <= mux_vsink_s(4 downto 0);
--mux_v1 <= mux_vpu1_s(4 downto 0);
--mux_v2 <= mux_vpu2_s(4 downto 0);

----------------------------------------------------------------------- 
-- ADC digital IO 
isense_twolanes <= adc_twolanes;
vpu1_twolanes <= adc_twolanes;
vpu2_twolanes <= adc_twolanes;

isense_testpat <= adc_testpat;
vpu1_testpat <= adc_testpat;
vpu2_testpat <= adc_testpat;

isense_pwr_dwn <= adc_pwr_dwn;
vpu1_pwr_dwn <= adc_pwr_dwn;
vpu2_pwr_dwn <= adc_pwr_dwn;
----------------------------------------------------------------------- 
end Behavioral;
