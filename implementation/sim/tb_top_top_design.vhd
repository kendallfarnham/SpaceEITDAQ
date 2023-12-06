----------------------------------------------------------------------------------
-- Company: Thayer School of Engineering, Dartmouth College
-- Engineer: Kendall Farnham
-- 
-- Create Date: 02/19/2021 11:56:56 AM
-- Design Name: 
-- Module Name: tb_top_top_design - testbenc
-- Project Name: 
-- Target Devices: Trenz Electronics TE0711-01
-- Tool Versions: Vivado 2018.2.2
-- Description: testbench for top_design
--      Simulates LVDS interface to ADCs and system controls with UART interface
--      ADC testpatterns: 1010000001111111 (one lane mode), 1100110000111111  (two lane mode)
-- 
-- Dependencies: 
-- 
-- Revision: 1.0 - 12/7/22 updated logic to simulate LVDS interface, added testpatterns
-- Revision 0.01 - File Created
-- Additional Comments: 
-- change BIT_TMR_MAX in UART_TX_CTRL.vhd to smaller value for simulation
-- change BRAM_ADDR_MAX in data_to_bram.vhd (or demod_to_bram.vhd) to smaller value for simulation
-- 
----------------------------------------------------------------------------------


library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use IEEE.std_logic_unsigned.all;
use ieee.math_real.all;


entity tb_top_top_design is
end tb_top_top_design;

architecture testbench of tb_top_top_design is

COMPONENT top_top_design
Port ( sysclk : in STD_LOGIC;
    
--    pga_isense: out STD_LOGIC_VECTOR (2 downto 0); -- PGA SPI controls [0:2]: CSn, SI, SCK
--    pga_vpu1: out STD_LOGIC_VECTOR (2 downto 0);
--    pga_vpu2: out STD_LOGIC_VECTOR (2 downto 0);

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
    
    -- Note: Muxes for vsink and vsrc are split between connector J1 (odd # channels) and J2 (even # channels) on DAQ. 
    mux_vsrc_odd  : out STD_LOGIC_VECTOR (5 downto 0);  -- to VS+ Muxes for odd channels [0:5]: S0, S1, S2, S3, NEN1, NEN3
    mux_vsrc_even : out STD_LOGIC_VECTOR (5 downto 0);  -- to VS+ Muxes for even channels [0:5]: S0, S1, S2, S3, NEN2, NEN4
    mux_vsink_odd  : out STD_LOGIC_VECTOR (5 downto 0); -- to VS- Muxes for odd channels [0:5]: S0, S1, S2, S3, NEN1, NEN3
    mux_vsink_even : out STD_LOGIC_VECTOR (5 downto 0); -- to VS- Muxes for even channels [0:5]: S0, S1, S2, S3, NEN2, NEN4
    mux_vpu1 : out STD_LOGIC_VECTOR (5 downto 0);   -- to Vpickup Ch1 Muxes [0:5]: S0, S1, S2, S3, NEN1, NEN2
    mux_vpu2 : out STD_LOGIC_VECTOR (5 downto 0);   -- to Vpickup Ch2 Muxes [0:5]: S0, S1, S2, S3, NEN1, NEN2
    
    lvds_isense_clk_p : out STD_LOGIC;      -- Isense ADC LVDS interface input clock (DCIN)
    lvds_isense_clk_n : out STD_LOGIC;
--    lvds_isense_dco_p : in STD_LOGIC;       -- Isense ADC LVDS interface output clock (DCO)
--    lvds_isense_dco_n : in STD_LOGIC;   
    lvds_isense_da_p : in STD_LOGIC;        -- Isense ADC LVDS interface output data lane A (DA)
    lvds_isense_da_n : in STD_LOGIC;   
    lvds_isense_db_p : in STD_LOGIC;        -- Isense ADC LVDS interface output data lane B (DB)
    lvds_isense_db_n : in STD_LOGIC;   
    
    lvds_vpu1_clk_p : out STD_LOGIC;        -- Vpickup Ch1 ADC LVDS interface input clock (DCIN)
    lvds_vpu1_clk_n : out STD_LOGIC;
--    lvds_vpu1_dco_p : in STD_LOGIC;         -- Vpickup Ch1 ADC LVDS interface output clock (DCO)
--    lvds_vpu1_dco_n : in STD_LOGIC;   
    lvds_vpu1_da_p : in STD_LOGIC;          -- Vpickup Ch1 ADC LVDS interface output data lane A (DA)
    lvds_vpu1_da_n : in STD_LOGIC;   
    lvds_vpu1_db_p : in STD_LOGIC;          -- Vpickup Ch1 ADC LVDS interface output data lane B (DB)
    lvds_vpu1_db_n : in STD_LOGIC;   
    
    lvds_vpu2_clk_p : out STD_LOGIC;        -- Vpickup Ch2 ADC LVDS interface input clock (DCIN)
    lvds_vpu2_clk_n : out STD_LOGIC;
--    lvds_vpu2_dco_p : in STD_LOGIC;         -- Vpickup Ch2 ADC LVDS interface output clock (DCO)
--    lvds_vpu2_dco_n : in STD_LOGIC;   
    lvds_vpu2_da_p : in STD_LOGIC;          -- Vpickup Ch2 ADC LVDS interface output data lane A (DA)
    lvds_vpu2_da_n : in STD_LOGIC;   
    lvds_vpu2_db_p : in STD_LOGIC;          -- Vpickup Ch2 ADC LVDS interface output data lane B (DB)
    lvds_vpu2_db_n : in STD_LOGIC;   

    isense_twolanes : out STD_LOGIC;                    -- ADC digital IO (new)
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
END COMPONENT;
----------------------------------------------------------------------------------
-- Constants
----------------------------------------------------------------------------------
constant SYS_CLOCK_PERIOD   : time := 10ns;         -- 10ns = 100 MHz
constant DWIDTH : integer := 16;    -- size of output buffer
--constant CLK_DELAY : time := 1.6ns;   -- random clk delay through ADC + analog
constant CLK_DELAY : time := 1ns;   -- max clk delay through ADC (CLK to DCO)
constant UART_CLK_PERIOD: time := 3906 ns; -- baud rate in ns
constant UART_DWIDTH: integer := 8;  -- data width
constant CMD_IDX_0 : integer := 2**7;				-- start commands at this value (2^6 = 64 for 64 channels, 2^7 = 128 freqs to choose from)


-----------------------------------------------------------------------
-- Signals
-----------------------------------------------------------------------
-- Clocks
signal sysclk, dclk, aclk, dlclk : std_logic := '0';
-----------------------------------------------------------------------
-- DUT ports
--signal pga_vpu2, pga_vpu1, pga_isense : std_logic_vector(2 downto 0) := (others => '0');
signal pga_isense_cs_n, pga_isense_si, pga_isense_clk: std_logic := '0';
signal pga_vpu1_cs_n, pga_vpu1_si, pga_vpu1_clk: std_logic := '0';
signal pga_vpu2_cs_n, pga_vpu2_si, pga_vpu2_clk: std_logic := '0';
signal lvds_isense_p, lvds_vpu1_p, lvds_vpu2_p : STD_LOGIC_VECTOR(2 downto 0) := (others => '0');
signal lvds_isense_n, lvds_vpu1_n, lvds_vpu2_n : STD_LOGIC_VECTOR(2 downto 0) := (others => '0');
signal lvds_isense_clk_p, lvds_isense_clk_n : std_logic := '0';
signal lvds_vpu1_clk_p, lvds_vpu1_clk_n : std_logic := '0';
signal lvds_vpu2_clk_p, lvds_vpu2_clk_n : std_logic := '0';
signal twolanes, testpat, pwr_dwn : std_logic := '0';
signal mux_vpu1, mux_vpu2 : std_logic_vector(5 downto 0) := (others => '0');
signal mux_vsrc_odd, mux_vsrc_even, mux_vsink_odd, mux_vsink_even : std_logic_vector(5 downto 0) := (others => '0');
signal uart_txd, uart_rx, done_tx : std_logic := '1';
signal dds_out : std_logic_vector(13 downto 0) := (others => '0');
-----------------------------------------------------------------------
-- Testbench signals
signal rx_data : std_logic_vector(UART_DWIDTH-1 downto 0) := (others => '0');
signal testnum : integer := 0;
signal da, db, dco, dcin, reset_lvds : std_logic := '0';
signal adout : STD_LOGIC_VECTOR(DWIDTH-1 downto 0) := (others => '0');
signal bitcnt : integer range 0 to DWIDTH-1 := DWIDTH-1;
-----------------------------------------------------------------------
-- Procedures
-----------------------------------------------------------------------
-- Procedure to write byte to UART rx
procedure uart_write_byte ( 
    data_in : in std_logic_vector(UART_DWIDTH-1 downto 0);
    signal ser_out : out std_logic) is
begin

    -- Send start bit
    ser_out <= '0';
    wait for UART_CLK_PERIOD;
    
    -- Send data
    for ii in 0 to UART_DWIDTH-1 loop
        ser_out <= data_in(ii);
        wait for UART_CLK_PERIOD;
    end loop;
    
    -- Send stop bit
    ser_out <= '1';
    wait for UART_CLK_PERIOD;

end uart_write_byte;
-----------------------------------------------------------------------
begin
-----------------------------------------------------------------------
dut: top_top_design port map(
    sysclk => sysclk,
    
--    pga_isense => pga_isense,
--    pga_vpu1 => pga_vpu1,
--    pga_vpu2 => pga_vpu2,
    
    pga_isense_clk => pga_isense_clk, 
    pga_isense_si => pga_isense_si, 
    pga_isense_cs_n => pga_isense_cs_n,
    pga_vpu1_clk => pga_vpu1_clk,
    pga_vpu1_si => pga_vpu1_si,
    pga_vpu1_cs_n => pga_vpu1_cs_n,
    pga_vpu2_clk => pga_vpu2_clk,
    pga_vpu2_si => pga_vpu2_si,
    pga_vpu2_cs_n => pga_vpu2_cs_n,
    
    dclk_dds => dclk,
    aclk_isense => aclk,
    aclk_vpu1 => open,
    aclk_vpu2 => open,
    dds_out => dds_out,
    
    mux_vsrc_odd => mux_vsrc_odd,
    mux_vsrc_even => mux_vsrc_even,
    mux_vsink_odd => mux_vsink_odd,
    mux_vsink_even => mux_vsink_even,
    mux_vpu1 => mux_vpu1,
    mux_vpu2 => mux_vpu2,
    
    lvds_isense_clk_p => lvds_isense_clk_p,
    lvds_isense_clk_n => lvds_isense_clk_n,
--    lvds_isense_dco_p => lvds_isense_p(0),
--    lvds_isense_dco_n => lvds_isense_n(0),
    lvds_isense_da_p => lvds_isense_p(1),
    lvds_isense_da_n => lvds_isense_n(1),
    lvds_isense_db_p => lvds_isense_p(2),
    lvds_isense_db_n => lvds_isense_n(2),    
        
    lvds_vpu1_clk_p => lvds_vpu1_clk_p,
    lvds_vpu1_clk_n => lvds_vpu1_clk_n,
--    lvds_vpu1_dco_p => lvds_vpu1_p(0),
--    lvds_vpu1_dco_n => lvds_vpu1_n(0),
    lvds_vpu1_da_p => lvds_vpu1_p(1),
    lvds_vpu1_da_n => lvds_vpu1_n(1),
    lvds_vpu1_db_p => lvds_vpu1_p(2),
    lvds_vpu1_db_n => lvds_vpu1_n(2),  
    
    lvds_vpu2_clk_p => lvds_vpu2_clk_p,
    lvds_vpu2_clk_n => lvds_vpu2_clk_n,
--    lvds_vpu2_dco_p => lvds_vpu2_p(0),
--    lvds_vpu2_dco_n => lvds_vpu2_n(0),
    lvds_vpu2_da_p => lvds_vpu2_p(1),
    lvds_vpu2_da_n => lvds_vpu2_n(1),
    lvds_vpu2_db_p => lvds_vpu2_p(2),
    lvds_vpu2_db_n => lvds_vpu2_n(2),  
    
    isense_twolanes => twolanes,
    isense_testpat => testpat,
    isense_pwr_dwn => pwr_dwn,
    
    vpu1_twolanes => twolanes,
    vpu1_testpat => testpat,
    vpu1_pwr_dwn => pwr_dwn,
    
    vpu2_twolanes => twolanes,
    vpu2_testpat => testpat,
    vpu2_pwr_dwn => pwr_dwn,
    
    done_tx => done_tx,
    uart_txd_in => uart_rx,
    uart_txd_out => uart_txd);

-----------------------------------------------------------------------
-- Generate clocks
-----------------------------------------------------------------------
sys_clock_gen : process
begin
    sysclk <= '0';
    wait for SYS_CLOCK_PERIOD;
    loop
        sysclk <= not(sysclk);
        wait for SYS_CLOCK_PERIOD/2;
    end loop;
end process sys_clock_gen;

-----------------------------------------------------------------------
-- Hook up lvds signals
-----------------------------------------------------------------------
lvds_isense_p(0) <= dco;
lvds_isense_n(0) <= not dco;
lvds_isense_p(1) <= da;
lvds_isense_n(1) <= not da;
lvds_isense_p(2) <= db;
lvds_isense_n(2) <= not db;

lvds_vpu1_p(0) <= dco;
lvds_vpu1_n(0) <= not dco;
lvds_vpu1_p(1) <= da;
lvds_vpu1_n(1) <= not da;
lvds_vpu1_p(2) <= db;
lvds_vpu1_n(2) <= not db;

lvds_vpu2_p(0) <= dco;
lvds_vpu2_n(0) <= not dco;
lvds_vpu2_p(1) <= da;
lvds_vpu2_n(1) <= not da;
lvds_vpu2_p(2) <= db;
lvds_vpu2_n(2) <= not db;
-----------------------------------------------------------------------
-- Hook up LVDS clocks
-----------------------------------------------------------------------
dcin <= lvds_isense_clk_p;      -- use isense adc
-----------------------------------------------------------------------
dco <= dcin;
-----------------------------------------------------------------------
-- Generate sampled data (simulate ADC's output to LVDS)
-----------------------------------------------------------------------
--da <= '0';
--db <= '1';
-----------------------------------------------------------------------
da <= adout(bitcnt);
db <= adout(bitcnt-1) when twolanes = '1' and bitcnt > 0
    else '0';
-----------------------------------------------------------------------
count_bits: process(dco, reset_lvds)    -- latch with dco edges
begin
if reset_lvds = '1' then
    bitcnt <= 0; -- set to zero so when reset = 0 the bit counter resets to MSB
else
    if twolanes = '1' then   -- Two-lane mode
        if bitcnt > 1 then
            bitcnt <= bitcnt - 2;
        else
            bitcnt <= DWIDTH-1;
        end if;
            
    else                        -- One-lane mode
        if bitcnt > 0 then
            bitcnt <= bitcnt - 1;
        else
            bitcnt <= DWIDTH-1;
        end if;
    end if;
end if;
end process count_bits;
-----------------------------------------------------------------------
-- Simulation
-----------------------------------------------------------------------
stim_proc: process
begin
    -------------------------------------------------------------------
    -- Set signals
    -------------------------------------------------------------------
    testnum <= 0;
    uart_rx <= '1';     -- start high
    reset_lvds <= '1';  -- set ADC testbench signals
    adout <= x"abcd";
    
    wait until rising_edge(sysclk); 
    wait for SYS_CLOCK_PERIOD*100;
    
    -- Reset system
    rx_data <= std_logic_vector(to_unsigned(CMD_IDX_0,rx_data'length));
    wait until rising_edge(sysclk); -- required for uart_write_byte procedure to work properly
    wait until rising_edge(sysclk); --  "   "   "   "
    uart_write_byte(rx_data, uart_rx); 
    
    -- Clear testbench signal
    reset_lvds <= '0';  
      
    -------------------------------------------------------------------
    -- Set PGAs
    -------------------------------------------------------------------
    -- Isense
    testnum <= testnum + 1;
    rx_data <= std_logic_vector(to_unsigned(CMD_IDX_0+38,rx_data'length)); 
    wait until rising_edge(sysclk);
    wait until rising_edge(sysclk);
    uart_write_byte(rx_data, uart_rx);     
        rx_data <= x"01"; 
        wait until rising_edge(sysclk);
        wait until rising_edge(sysclk);
        uart_write_byte(rx_data, uart_rx);      

    -- Vpickup Ch 1
    rx_data <= std_logic_vector(to_unsigned(CMD_IDX_0+39,rx_data'length));
    wait until rising_edge(sysclk);
    wait until rising_edge(sysclk);
    uart_write_byte(rx_data, uart_rx);     
        rx_data <= x"02"; 
        wait until rising_edge(sysclk);
        wait until rising_edge(sysclk);
        uart_write_byte(rx_data, uart_rx);  

    -- Vpickup Ch 2
    rx_data <= std_logic_vector(to_unsigned(CMD_IDX_0+40,rx_data'length));
    wait until rising_edge(sysclk);
    wait until rising_edge(sysclk);
    uart_write_byte(rx_data, uart_rx);     
        rx_data <= x"04"; 
        wait until rising_edge(sysclk);
        wait until rising_edge(sysclk);
        uart_write_byte(rx_data, uart_rx);  
    -------------------------------------------------------------------
    -- Set Muxes
    -------------------------------------------------------------------
    testnum <= testnum + 1;
    
    -- Disable muxes before setting channels
    rx_data <= std_logic_vector(to_unsigned(CMD_IDX_0+45,rx_data'length));
    wait until rising_edge(sysclk);
    wait until rising_edge(sysclk);
    uart_write_byte(rx_data, uart_rx); 
    
    -- Vsource
    rx_data <= std_logic_vector(to_unsigned(CMD_IDX_0+41,rx_data'length));
    wait until rising_edge(sysclk);
    wait until rising_edge(sysclk);
    uart_write_byte(rx_data, uart_rx);     
        rx_data <= x"02"; 
        wait until rising_edge(sysclk);
        wait until rising_edge(sysclk);
        uart_write_byte(rx_data, uart_rx);  

    -- Vsink
    rx_data <= std_logic_vector(to_unsigned(CMD_IDX_0+42,rx_data'length));
    wait until rising_edge(sysclk);
    wait until rising_edge(sysclk);
    uart_write_byte(rx_data, uart_rx);     
        rx_data <= x"05"; 
        wait until rising_edge(sysclk);
        wait until rising_edge(sysclk);
        uart_write_byte(rx_data, uart_rx);          

    -- Vpickup Ch 1
    rx_data <= std_logic_vector(to_unsigned(CMD_IDX_0+43,rx_data'length));
    wait until rising_edge(sysclk);
    wait until rising_edge(sysclk);
    uart_write_byte(rx_data, uart_rx);     
        rx_data <= x"0A"; 
        wait until rising_edge(sysclk);
        wait until rising_edge(sysclk);
        uart_write_byte(rx_data, uart_rx);  

    -- Vpickup Ch 2
    rx_data <= std_logic_vector(to_unsigned(CMD_IDX_0+44,rx_data'length));
    wait until rising_edge(sysclk);
    wait until rising_edge(sysclk);
    uart_write_byte(rx_data, uart_rx);     
        rx_data <= x"15"; 
        wait until rising_edge(sysclk);
        wait until rising_edge(sysclk);
        uart_write_byte(rx_data, uart_rx);   

    -- Enable muxes
    rx_data <= std_logic_vector(to_unsigned(CMD_IDX_0+46,rx_data'length));
    wait until rising_edge(sysclk);
    wait until rising_edge(sysclk);
    uart_write_byte(rx_data, uart_rx); 

    -------------------------------------------------------------------
    -- Set DDS frequency
    -------------------------------------------------------------------
    testnum <= testnum + 1;
    rx_data <= std_logic_vector(to_unsigned(CMD_IDX_0+34,rx_data'length));
    wait until rising_edge(sysclk);
    wait until rising_edge(sysclk);
    uart_write_byte(rx_data, uart_rx);    
        rx_data <= "00100000";  -- freq index 32
        wait until rising_edge(sysclk);
        wait until rising_edge(sysclk);
        uart_write_byte(rx_data, uart_rx);  


    -------------------------------------------------------------------
    -- Enable Frequency sweep
    -------------------------------------------------------------------
    testnum <= testnum + 1;
    rx_data <= std_logic_vector(to_unsigned(CMD_IDX_0+32,rx_data'length));
    wait until rising_edge(sysclk);
    wait until rising_edge(sysclk);
    uart_write_byte(rx_data, uart_rx); 
    
    -------------------------------------------------------------------
    -- Enable TX
    -------------------------------------------------------------------
    --testnum <= testnum + 1;
    rx_data <= std_logic_vector(to_unsigned(CMD_IDX_0+3,rx_data'length));
    wait until rising_edge(sysclk);
    wait until rising_edge(sysclk);
    uart_write_byte(rx_data, uart_rx);   
    
    -- Wait for UART TX to finish 
    wait until done_tx = '1';   -- Done data transfer
    -- Wait for a couple of send cycles
    wait until done_tx = '0';
    wait until done_tx = '1';  
    wait until done_tx = '0';
    wait until done_tx = '1'; 
    
    -------------------------------------------------------------------
    -- Set DDS frequency
    -------------------------------------------------------------------
    testnum <= testnum + 1;
    rx_data <= std_logic_vector(to_unsigned(CMD_IDX_0+34,rx_data'length));
    wait until rising_edge(sysclk);
    wait until rising_edge(sysclk);
    uart_write_byte(rx_data, uart_rx);    
        rx_data <= "00100001";  -- freq index 33
        wait until rising_edge(sysclk);
        wait until rising_edge(sysclk);
        uart_write_byte(rx_data, uart_rx);  
        
    wait until done_tx = '1';   -- Done data transfer
    
    -- Set DDS frequency
    testnum <= testnum + 1;
    rx_data <= std_logic_vector(to_unsigned(CMD_IDX_0+34,rx_data'length));
    wait until rising_edge(sysclk);
    wait until rising_edge(sysclk);
    uart_write_byte(rx_data, uart_rx);    
    rx_data <= "00100010";  -- freq index 34
    wait until rising_edge(sysclk);
    wait until rising_edge(sysclk);
    uart_write_byte(rx_data, uart_rx);  
    
    wait until done_tx = '1';   -- Done data transfer
        
    -- Set DDS frequency
    testnum <= testnum + 1;
    rx_data <= std_logic_vector(to_unsigned(CMD_IDX_0+34,rx_data'length));
    wait until rising_edge(sysclk);
    wait until rising_edge(sysclk);
    uart_write_byte(rx_data, uart_rx);    
    rx_data <= "00100011";  -- freq index 35
    wait until rising_edge(sysclk);
    wait until rising_edge(sysclk);
    uart_write_byte(rx_data, uart_rx);  
    
    wait until done_tx = '1';   -- done tx 
    
    -- Set DDS frequency
    testnum <= testnum + 1;
    rx_data <= std_logic_vector(to_unsigned(CMD_IDX_0+34,rx_data'length));
    wait until rising_edge(sysclk);
    wait until rising_edge(sysclk);
    uart_write_byte(rx_data, uart_rx);    
    rx_data <= "00100100";  -- freq index 36
    wait until rising_edge(sysclk);
    wait until rising_edge(sysclk);
    uart_write_byte(rx_data, uart_rx);  
    
    wait until done_tx = '0';   -- wait
    wait until done_tx = '1';   -- done tx 
    
    -- Set DDS frequency
    testnum <= testnum + 1;
    rx_data <= std_logic_vector(to_unsigned(CMD_IDX_0+34,rx_data'length));
    wait until rising_edge(sysclk);
    wait until rising_edge(sysclk);
    uart_write_byte(rx_data, uart_rx);    
    rx_data <= "00100101";  -- freq index 37
    wait until rising_edge(sysclk);
    wait until rising_edge(sysclk);
    uart_write_byte(rx_data, uart_rx);  
    
    wait until done_tx = '0';   -- wait
    wait until done_tx = '1';   -- done tx 
    
--    -------------------------------------------------------------------
--    -- Enable send raw data (mux demod block)
--    -------------------------------------------------------------------
--    testnum <= testnum + 1;
--    -- Send Isense ADC data to mux demod block for raw data save/send
--    rx_data <= std_logic_vector(to_unsigned(CMD_IDX_0+17,rx_data'length));
--    wait until rising_edge(sysclk);
--    wait until rising_edge(sysclk);
--    uart_write_byte(rx_data, uart_rx); 
    
--    -- Wait for a couple of send cycles
--    wait until done_tx = '0';
--    wait until done_tx = '1';  
--    wait until done_tx = '0';
----    wait until done_tx = '1'; 
--    wait for SYS_CLOCK_PERIOD*100;
    
--    -------------------------------------------------------------------
--    -- Stop sending raw data
--    -------------------------------------------------------------------
--    testnum <= testnum + 1;
--    -- Disable raw data send
--    rx_data <= std_logic_vector(to_unsigned(CMD_IDX_0+16,rx_data'length));
--    wait until rising_edge(sysclk);
--    wait until rising_edge(sysclk);
--    uart_write_byte(rx_data, uart_rx); 
    
    -- Wait for a couple of send cycles
    wait until done_tx = '0';
    wait until done_tx = '1';  
    wait until done_tx = '0';
    adout <= x"f1f2";           -- change testbench data
    wait until done_tx = '1'; 
    
    -- Disable TX
    rx_data <= std_logic_vector(to_unsigned(CMD_IDX_0+4,rx_data'length));
    wait until rising_edge(sysclk);
    wait until rising_edge(sysclk);
    uart_write_byte(rx_data, uart_rx); 
    
    -------------------------------------------------------------------
    -- Enable Frequency sweep
    -------------------------------------------------------------------
    testnum <= testnum + 1;
    rx_data <= std_logic_vector(to_unsigned(CMD_IDX_0+32,rx_data'length));
    wait until rising_edge(sysclk);
    wait until rising_edge(sysclk);
    uart_write_byte(rx_data, uart_rx); 
    
    -- Enable TX
    rx_data <= std_logic_vector(to_unsigned(CMD_IDX_0+3,rx_data'length));
    wait until rising_edge(sysclk);
    wait until rising_edge(sysclk);
    uart_write_byte(rx_data, uart_rx);   
      
    -- Wait for UART TX to finish 3 datasets (Isense, Vpickup1, Vpickup2)
    wait until done_tx = '0';
    wait until done_tx = '1';   -- Isense done data transfer
    wait until done_tx = '0';
    wait until done_tx = '1';   -- Vpickup 1 done data transfer
    wait until done_tx = '0';
    wait until done_tx = '1';   -- Vpickup 2 done data transfer
    
    -- Wait for second frequency in sweep
    testnum <= testnum + 1;
    wait until done_tx = '0';
    wait until done_tx = '1';   -- Isense 
    wait until done_tx = '0';
    wait until done_tx = '1';   -- Vpickup 1 
    wait until done_tx = '0';
    wait until done_tx = '1';   -- Vpickup 2 
    
    adout <= x"8010";           -- change testbench data    
    
    -- Wait for third frequency in sweep
    testnum <= testnum + 1;
    wait until done_tx = '0';
    wait until done_tx = '1';   -- Isense 
    wait until done_tx = '0';
    wait until done_tx = '1';   -- Vpickup 1 
    wait until done_tx = '0';
    wait until done_tx = '1';   -- Vpickup 2     
 
   -- Wait an extra
   wait until done_tx = '0';
   wait until done_tx = '1';
    
    
    -- End simulation   
    std.env.stop;   
end process stim_proc;

end testbench;
