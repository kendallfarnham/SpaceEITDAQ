----------------------------------------------------------------------------------
-- Company: Thayer School of Engineering, Dartmouth College
-- Engineer: Kendall Farnham
-- 
-- Create Date: 07/13/2023
-- Design Name: 
-- Module Name: adc_interface_x3 - Behavioral
-- Project Name: 2023_DAQ
-- Target Devices: Artix 7 (Trenz Electronics TE0711-01)
-- Tool Versions: Vivado 2022.2
-- Description: LVDS Deserializer for LTC2387-16
--      15 MHz sampling rate (66.67 ns period)      --> aclk
--      400 MSPS LVDS (200 MHz clock, 5 ns period)  --> lclk
--
--      LTC2387-16 Timing Requirements:
--          Conversion time 65+ ns (CNV to LVDS data out)
--          CNV pulse high for 5+ ns
--          Max time to end of LVDS data transfer from next CNV rising edge is 49 ns
        
--      LTC2387-16 LVDS interface pins
--          Inputs:  CNV+ is "start conversion" pulse (max 66.66 ns period)          --> cnv
--                   CLK+/- differential bit clock (max 400 MHz clock)               --> dcin
--          Outputs: DCO+/- differential output bit clock (echo of CLK+/- in)        --> dco
--                   DA+/- differential data output, Lane A                          --> da
--                   DB+/- differential data output, Lane A                          --> db
--          Control inputs: 
--                   TWOLANES '0' = one-lane mode (Lane A), '1' = two-lane mode (Lanes A & B)   --> twolanes
--                   TESTPAT on when '1' -- One-Lane Mode: 1010 0000 0111 1111,      --> switch on AFE 
--                                       -- Two-Lane Mode: 1100 1100 0011 1111
-- Dependencies: 
--
-- Revision 0.01 - File Created --> lvds_rx.vhd
-- Revision 1.1 - 3/26/2022 --> added FSM logic for ADC interface
-- Revision 1.2 - 11/19/2022 --> removed dependency on dco --> use shifted dcin (dcin_s)
-- Revision 1.3 - 12/1/2022 --> added dco_en to disable clocking jitter
-- Revision 2.0 - 1/10/2023 --> copied from ltc2387_16b_adc_interface.vhd
-- Revision 2.01 - 7/13/2023 Copied from 2023_DAQ_64ch_v4_1.srcs
-- 
----------------------------------------------------------------------------------

library ieee;
    use ieee.std_logic_1164.all;
    use ieee.numeric_std.all;
    
    
library UNISIM;						
use UNISIM.Vcomponents.ALL; 
-----------------------------------------------------------------------
entity adc_interface_x3 is 
Port (
    enable : in STD_LOGIC;      -- Enable LVDS conversion on ADC
    aclk : in STD_LOGIC;        -- Sampling clock (ADC clock, CNV port)
    lclk : in STD_LOGIC;        -- LVDS fast bit clock --> use for FSM clock
    
    cnv : out STD_LOGIC;        -- ADC sample clock input (CNV port)
    dcin : out STD_LOGIC;       -- ADC LVDS fast bit clock input (CLK port)
    dco : in STD_LOGIC;         -- ADC LVDS fast bit clock output (DCO port)
    
    da_1 : in STD_LOGIC;        -- ADC 1 Serial LVDS data (Lanes A and B)
    db_1 : in STD_LOGIC;
    da_2 : in STD_LOGIC;        -- ADC 2 Serial LVDS data (Lanes A and B)
    db_2 : in STD_LOGIC;
    da_3 : in STD_LOGIC;        -- ADC 3 Serial LVDS data (Lanes A and B)
    db_3 : in STD_LOGIC;        
    
    dout_1 : out STD_LOGIC_VECTOR(15 downto 0);    -- ADC 1 Converted data out
    dout_2 : out STD_LOGIC_VECTOR(15 downto 0);    -- ADC 2 Converted data out
    dout_3 : out STD_LOGIC_VECTOR(15 downto 0);    -- ADC 3 Converted data out

    dout_valid : out STD_LOGIC);                   -- Converted output data is valid
end adc_interface_x3;
-----------------------------------------------------------------------
architecture Behavioral of adc_interface_x3 is
-----------------------------------------------------------------------
-- Constants
constant DWIDTH : integer := 16;    -- size of output buffer
constant NCLKS : integer := 4;      -- number of lvds clock cycles per adc conversion

-----------------------------------------------------------------------
-- Signals
-----------------------------------------------------------------------
-- FSM signals
type state_type is (ResetState, EnableCnv, WaitAclk0, WaitAclk, EnableLVDS, 
            WaitData, SaveData, WaitNextSample);     
signal lvds_state : state_type := ResetState;   
signal lclkcnt, dcocnt : integer range 0 to NCLKS-1 := 0;         -- Counters for clocking logic
signal cnv_d, enable_dcin, enable_cnv : std_logic := '0';  -- FSM control signals
signal dout1_s, dout2_s, dout3_s : std_logic_vector(DWIDTH-1 downto 0);            -- signal to output port dout
signal dbuf1_p, dbuf1_n : std_logic_vector(DWIDTH/2-1 downto 0);  -- buffers for rising and falling edges of dco
signal dbuf2_p, dbuf2_n : std_logic_vector(DWIDTH/2-1 downto 0);  -- buffers for rising and falling edges of dco
signal dbuf3_p, dbuf3_n : std_logic_vector(DWIDTH/2-1 downto 0);  -- buffers for rising and falling edges of dco
signal reset_dcocnt, reset_buf, done_rx, dco_en : std_logic := '1';
-----------------------------------------------------------------------
begin
-----------------------------------------------------------------------
-- Logic
-----------------------------------------------------------------------
-- Deserialize data ---> shift in data on positive clock edge
deserialize_data_pos_edge : process(dco, reset_buf) 
begin
if (reset_buf = '1') then
    dbuf1_p <= (others => '0');      -- reset buffers
    dbuf2_p <= (others => '0');
    dbuf3_p <= (others => '0');
-- Clock in data on rising edge
elsif (rising_edge(dco)) then
    if (dco_en = '1') then
        dbuf1_p <= dbuf1_p(DWIDTH/2-3 downto 0) & da_1 & db_1;    -- Two-lane mode
        dbuf2_p <= dbuf2_p(DWIDTH/2-3 downto 0) & da_2 & db_2; 
        dbuf3_p <= dbuf3_p(DWIDTH/2-3 downto 0) & da_3 & db_3; 
    end if; 
end if;

end process deserialize_data_pos_edge;  
-----------------------------------------------------------------------
-- Deserialize data ---> shift in data on negative clock edge
deserialize_data_neg_edge : process(dco, reset_buf) 
begin
if (reset_buf = '1') then
    dbuf1_n <= (others => '0');      -- reset buffer
    dbuf2_n <= (others => '0'); 
    dbuf3_n <= (others => '0'); 
-- Clock in data on falling edge of dco
elsif (falling_edge(dco)) then
    if (dco_en = '1') then
        dbuf1_n <= dbuf1_n(DWIDTH/2-3 downto 0) & da_1 & db_1;    -- Two-lane mode
        dbuf2_n <= dbuf2_n(DWIDTH/2-3 downto 0) & da_2 & db_2;
        dbuf3_n <= dbuf3_n(DWIDTH/2-3 downto 0) & da_3 & db_3;
    end if;
end if;
end process deserialize_data_neg_edge;  
-----------------------------------------------------------------------
-- Enable deserializing
dco_en <= '1' when lvds_state = EnableLVDS 
            or (lvds_state = WaitData and done_rx = '0')
    else '0';
-----------------------------------------------------------------------
-- Deserialize data ---> flag to FSM when finished transfer
count_dco : process(dco, reset_dcocnt)
begin
if (reset_dcocnt = '1') then        -- FSM flag triggers before each conversion
    dcocnt <= 0;
    done_rx <= '0';
elsif (falling_edge(dco)) then
    if (dcocnt < NCLKS-1) then 
        done_rx <= '0';
        dcocnt <= dcocnt + 1;  -- increment counter
    else
        dcocnt <= 0;                -- reset
        done_rx <= '1';             -- flag to combine data buffers
    end if;
end if;
end process count_dco;  
-----------------------------------------------------------------------    
reset_dcocnt <= '1' when lvds_state = ResetState
                or lvds_state = WaitAclk0
                or lvds_state = SaveData
    else '0';
-----------------------------------------------------------------------    
reset_buf <= '1' when lvds_state = ResetState 
    else '0'; 
-----------------------------------------------------------------------
-- Combine data buffers
dout1_s <= dbuf1_p(7) & dbuf1_p(6)     -- Two-lane mode
    & dbuf1_n(7) & dbuf1_n(6)
    & dbuf1_p(5) & dbuf1_p(4)
    & dbuf1_n(5) & dbuf1_n(4)
    & dbuf1_p(3) & dbuf1_p(2)            
    & dbuf1_n(3) & dbuf1_n(2)         
    & dbuf1_p(1) & dbuf1_p(0)      
    & dbuf1_n(1) & dbuf1_n(0) ;

dout2_s <= dbuf2_p(7) & dbuf2_p(6)     -- Two-lane mode
    & dbuf2_n(7) & dbuf2_n(6)
    & dbuf2_p(5) & dbuf2_p(4)
    & dbuf2_n(5) & dbuf2_n(4)
    & dbuf2_p(3) & dbuf2_p(2)            
    & dbuf2_n(3) & dbuf2_n(2)         
    & dbuf2_p(1) & dbuf2_p(0)      
    & dbuf2_n(1) & dbuf2_n(0) ;
    
dout3_s <= dbuf3_p(7) & dbuf3_p(6)     -- Two-lane mode
    & dbuf3_n(7) & dbuf3_n(6)
    & dbuf3_p(5) & dbuf3_p(4)
    & dbuf3_n(5) & dbuf3_n(4)
    & dbuf3_p(3) & dbuf3_p(2)            
    & dbuf3_n(3) & dbuf3_n(2)         
    & dbuf3_p(1) & dbuf3_p(0)      
    & dbuf3_n(1) & dbuf3_n(0) ;
-----------------------------------------------------------------------
-- Data valid output port 
iserdes_dout_valid : process(lclk)
begin

if rising_edge(lclk) then
    if (lvds_state = ResetState) then
        dout_valid <= '0';          -- reset
        dout_1 <= (others => '0');
        dout_2 <= (others => '0');
        dout_3 <= (others => '0');
    elsif (lvds_state = SaveData) then
        dout_valid <= '1';          -- high after first conversion
        dout_1 <= dout1_s;          -- latch converted data out
        dout_2 <= dout2_s;
        dout_3 <= dout3_s;
    end if;
end if;
end process iserdes_dout_valid;  
-----------------------------------------------------------------------
-- LVDS signals out to ADC
-----------------------------------------------------------------------
dcin <= lclk and enable_dcin;
--BUFGCE_inst : BUFGCE
--port map (
--   O => dcin,           -- 1-bit output: Clock output
--   CE => enable_dcin,   -- 1-bit input: Active high enable
--   I => lclk            -- 1-bit input: Clock input
--);
-----------------------------------------------------------------------
-- Delay dcin clock
delay_dcin_proc : process(lclk)
begin
if falling_edge(lclk) then
    if (lvds_state = EnableLVDS) then
        enable_dcin <= '1';     -- enable clock
    else 
        enable_dcin <= '0';     -- disable clock   
    end if;  
end if;
end process delay_dcin_proc;   
-----------------------------------------------------------------------
-- Delay CNV pulse --> rising edge with first dcin clock, falling edge after bits sent
--cnv <= cnv_d or cnv_dd;     -- extend CNV pulse
cnv <= cnv_d;       -- CHANGED 7/4/23
-------
delay_cnv_proc : process(lclk)
begin
if rising_edge(lclk) then
    -- Delayed one lclk cycle after Enable state
    if (lvds_state = EnableLVDS or lvds_state = EnableCnv)  then
        cnv_d <= '1'; 
    else 
        cnv_d <= '0';     
    end if;  
end if;
end process delay_cnv_proc;
-----------------------------------------------------------------------
-- Count lvds clock cycles for bit clock to ADC (dcin module port)
lclk_cnt_process : process(lclk)
begin
if rising_edge(lclk) then
    -- Counter
    if (lvds_state = EnableLVDS) then
--        if (lclkcnt = NCLKS-1) then     -- Send 8 clock cycles for 1-lane, 4 for 2-lane  
--            lclkcnt <= 0;       -- reset counter 
--        else
            lclkcnt <= lclkcnt+1;    -- increment
--        end if;
    else 
        lclkcnt <= 0;   -- reset counter   
    end if;  
end if;
end process lclk_cnt_process;
-----------------------------------------------------------------------
-- ResetState, EnableCnv, WaitAclk0, WaitAclk, EnableLVDS, 
--      WaitData, SaveData, WaitNextSample
-- State machine for LVDS conversion 
lvds_fsm : process(lclk)
begin
if rising_edge(lclk) then
    
    if (enable = '0') then
        lvds_state <= ResetState;
    else
        case(lvds_state) is
            -------------------------------------------------------------------
            -- Start
            when ResetState =>              
                if (enable = '1') and (aclk = '0') then     -- enable aclk (CNV) once low
                    lvds_state <= EnableCnv;
                end if;
                
            when EnableCnv =>               -- wait for rising edge of aclk to send first CNV pulse
                if (aclk = '1') then
                    lvds_state <= WaitAclk0;
                end if;          
                
            when WaitAclk0 =>               -- wait for aclk to go low
                if (aclk = '0') then
                    lvds_state <= WaitAclk;
                end if; 
            
            when WaitAclk =>                -- wait for next rising edge of aclk to convert first sample
                if (aclk = '1') then
                    lvds_state <= EnableLVDS;
                end if;
            
            -------------------------------------------------------------------
            -- Enable LVDS interface --> send bit clock (lclk) to CLK+/CLK- ports on ADC
            when EnableLVDS =>              -- latch in DA and DB inputs, count bit clock
                if (lclkcnt = NCLKS-1) then    
                    lvds_state <= WaitData;
                end if;
                
            when WaitData =>                -- wait for final DCO clock, then save converted data
                if (done_rx = '1') then
                    lvds_state <= SaveData;   
                end if;
                
            when SaveData =>                -- save converted data
                lvds_state <= WaitNextSample;   

            when WaitNextSample =>                -- wait for next rising edge of aclk to convert first sample
                if (aclk = '1') then
                    lvds_state <= EnableLVDS;
                end if;
                    
            when others => -- should never reach
                lvds_state <= ResetState;
        end case;
    end if;
end if;
end process lvds_fsm;

-----------------------------------------------------------------------
end Behavioral;
