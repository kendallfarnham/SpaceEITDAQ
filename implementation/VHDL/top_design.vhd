----------------------------------------------------------------------------------
-- Company: Thayer School of Engineering, Dartmouth College
-- Engineer: Kendall Farnham
-- 
-- Create Date: 07/13/2023
-- Design Name: 
-- Module Name: top_design - Behavioral
-- Project Name: 2023_DAQ
-- Target Devices: Artix 7 (Trenz Electronics TE0711-01)
-- Tool Versions: Vivado 2022.2
-- Description: Map IO from code to TE0711 pins
-- 
-- Dependencies: uart_ui_controller, dualtone_dds_controller, adc_interface_x3, demod_controller
--              pga_controller, mux_controller
--      IP Cores: Clock Wizard (clk_wiz), Block Memory Generator (blk_mem_gen)
-- 
-- Revision 0.01 - 02/19/2021 File Created
-- Revision 1.0 - Added ADC digital IO control
-- Revision 2.0 - 4/3/2023 Cleaned up code, added startup state with delay
-- Revision 3.0 - 6/29/2023 Copied to 2023_AFE_v6_1 project and added logic from top_design_2 (working ADCs)
-- Revision 3.01 - 7/13/2023 Copied from 2023_DAQ_64ch_v4_1.srcs
-- 
----------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.std_logic_unsigned.all;
use ieee.math_real.all;

--library UNISIM;						
--use UNISIM.Vcomponents.ALL; 

entity top_design is
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
end top_design;

architecture Behavioral of top_design is
-----------------------------------------------------------------------
-- Constants
-----------------------------------------------------------------------
-- Fixed System Constants
constant DEBUG_MODE : std_logic := '0';         -- use simulation constants when in debug mode  
constant DAC_DATA_WIDTH : integer := 14;        -- size of data bus out to dac
constant ADC_DATA_WIDTH : integer := 16;        -- size of adc sampled data
constant PGA_SEL_BITS : integer := 3; 		    -- number of bits in PGA gain selection
constant MUX_CH_BITS: integer := 6;     	    -- number of bits for number of channels used (e.g. 2^6 = 64, MUX_CH_BITS = 6)
constant STARTUP_CTR_3MS : integer := 300_000;  -- 300,000 = 3 ms on 100 MHz clock
constant STARTUP_CTR_SIM : integer := 11;       -- USE FOR SIMULATION
constant RESET_HOLD_CNT : integer := 70;        -- Hold reset for this many system clock cycles
constant AFE_DELAY_CTR_IMPL : integer := 10_000; -- 50,000 (0.5 ms on 100 MHz clock)
constant AFE_DELAY_CTR_SIM : integer := 11;     -- USE FOR SIMULATION

-- Changable constants for internal logic
constant PHASE_WIDTH : integer := 24;   	    -- number of bits in dds phase control
constant NFREQS_MAX : integer := 64;            -- Max number of freqs in freq sweep
constant FREQ_SEL_BITS : integer := 6; 	        -- number of bits in frequency selection
constant PHASE_LUT_ADDR_WIDTH : integer := 6;   -- bits in ROM address (look up table for dds phase)
constant FFT_BIN_WIDTH : INTEGER := 10; 	    -- 2**FFT_BIN_WIDTH number of bins in fft
constant FFT_LUT_BIN_WIDTH : integer := 16;     -- bits in ROM address (look up table for fft bin)
constant NFFT : integer := 2**FFT_BIN_WIDTH;    -- size of fft
constant SLOW_SAMP_CLKDIV : integer := 128;     -- divide clock rate by this value if use_slow_fs signal is high
-----------------------------------------------------------------------
-- Variable constants --> changed to sim values when DEBUG_MODE = '1'
signal STARTUP_CTR_MAX : integer := STARTUP_CTR_3MS;
signal AFE_DELAY_CTR_MAX : integer := AFE_DELAY_CTR_IMPL;

-----------------------------------------------------------------------
-- Signals
-----------------------------------------------------------------------
-- Clocking signals
signal clk_15MHz, clk_200MHz, clk_10MHz : std_logic := '0'; -- clk_wiz_0
--signal sysclk_shift, clk_10MHz : std_logic := '0'; -- clk_wiz_1
signal aclk, dclk, pga_clk, lclk : std_logic := '0';  -- alias
signal pga_clkin_i, pga_clkin_v1, pga_clkin_v2 : std_logic := '0';  -- alias
signal mmcm_locked : std_logic := '0';    -- clock controls
-----------------------------------------------------------------------
-- Control signals
signal reset_dds, reset_demod, reset_muxes, reset_pgas : std_logic := '1';
signal reset, reset_mmcm, reset_hold_done : std_logic := '1';
signal enable, enable_dds, enable_muxes, enable_pgas : std_logic := '0';  
signal set_pga_n : std_logic_vector(2 downto 0) := (others => '0');
signal enable_mux_n : std_logic_vector(3 downto 0) := (others => '0');												   
signal isense_sync, vpu1_sync, vpu2_sync : STD_LOGIC_VECTOR (ADC_DATA_WIDTH-1 downto 0) := (others => '0');
signal sine_out, sine_out_div : std_logic_vector (DAC_DATA_WIDTH-1 downto 0 ) := (others => '0');
signal usr_freq_sel : std_logic_vector (2*FREQ_SEL_BITS-1 downto 0) := (others => '0'); -- latches in sw port
signal freq_sel_1, freq_sel_2 : std_logic_vector (FREQ_SEL_BITS-1 downto 0) := (others => '0'); -- latches in sw port
signal adin_valid, adin_dds_last, startup_ctr_done, adin_sync_start, afe_delay_ctr_done : std_logic := '0';
signal phase_lut_addr_a, phase_lut_addr_b : std_logic_vector(PHASE_LUT_ADDR_WIDTH-1 downto 0) := (others => '0');
signal phase_lut_data_a, phase_lut_data_b : std_logic_vector(PHASE_WIDTH-1 downto 0) := (others => '0');
signal startup_ctr : integer range 0 to STARTUP_CTR_3MS := 0;
signal reset_hold_ctr : integer range 0 to RESET_HOLD_CNT := 0;
signal afe_delay_ctr : integer range 0 to AFE_DELAY_CTR_IMPL := 0;
-----------------------------------------------------------------------
-- PGA Signals ----> TODO Automatic gain control
signal isense_pga_cs_n, isense_pga_si, isense_pga_clk: std_logic := '0';
signal vpu1_pga_cs_n, vpu1_pga_si, vpu1_pga_clk: std_logic := '0';
signal vpu2_pga_cs_n, vpu2_pga_si, vpu2_pga_clk: std_logic := '0';
signal isense_gain, vpu1_gain, vpu2_gain : std_logic_vector(PGA_SEL_BITS-1 downto 0) := (others => '0');
-----------------------------------------------------------------------
-- Dualtone controller signals
signal dds_out_valid : std_logic := '0';
signal dds_out_last, slow_dds_out_last : std_logic := '0';
signal phase_offset_freq_A, phase_offset_freq_B : std_logic_vector(2*PHASE_WIDTH-1 downto 0) := (others => '0');  -- multitone_controller inputs
signal freq_selA, offset_selA : std_logic_vector(PHASE_WIDTH-1 downto 0) := (others => '0');  -- select ddsA frequency and phase
signal freq_selB, offset_selB : std_logic_vector(PHASE_WIDTH-1 downto 0) := (others => '0');  -- select ddsB frequency and phase
-----------------------------------------------------------------------
-- Demodulation controller signals
signal use_slow_fs, read_isense, read_v1, read_v2, enable_demod : STD_LOGIC := '0';
signal enable_mux_demod, send_raw_data, mux_demod_output_rdy, uart_tx_adout : STD_LOGIC := '0';
signal mux_adout : STD_LOGIC_VECTOR (ADC_DATA_WIDTH-1 downto 0) := (others => '0');
signal uart_tx_isense, uart_tx_v1, uart_tx_v2, isense_rdy, v1_rdy, v2_rdy : STD_LOGIC := '1';
signal uart_txd, use_full_spectrum : std_logic := '0'; 
signal fft_bin_lut_data_a, fft_bin_lut_data_b : std_logic_vector(FFT_LUT_BIN_WIDTH-1 downto 0) := (others => '0');
signal n_averages : integer := 16;
signal bin_f1, bin_f2 : std_logic_vector(FFT_BIN_WIDTH-1 downto 0) := (others => '0');
-----------------------------------------------------------------------
-- LVDS interface signals
signal adc_cnv, adc_dcin, adc_dco, adc_dcin_d : std_logic := '0';
--signal isense_da, isense_db, vpu1_da, vpu1_db, vpu2_da, vpu2_db  : std_logic := '0';
signal enable_adcs, testpat : std_logic := '0';
signal isense_adout, vpu1_adout, vpu2_adout : STD_LOGIC_VECTOR (ADC_DATA_WIDTH-1 downto 0) := (others => '0');
signal isense_adout_d, vpu1_adout_d, vpu2_adout_d : STD_LOGIC_VECTOR (ADC_DATA_WIDTH-1 downto 0) := (others => '0'); --cdc
signal adout_valid, adout_valid_d : std_logic := '0'; -- CDC
-----------------------------------------------------------------------
-- User Interface controls
signal uart_rx_d, uart_rx, uart_rx_rdy, usr_set_dds, usr_freq_sweep_en, usr_en_adc_debug : std_logic := '0'; 
signal usr_dual_dds_en, usr_adc_pwr_dwn, usr_send_raw_data : std_logic := '0';
--signal usr_pga_dio : std_logic_vector(PGA_SEL_BITS-1 downto 0) := (others => '0'); -- single
signal usr_mux_dio_s : std_logic_vector(4*MUX_CH_BITS-1 downto 0) := (others => '1'); -- 4 muxes
signal usr_pga_dio_s : std_logic_vector(3*PGA_SEL_BITS-1 downto 0) := (others => '0'); -- 3 pgas
signal usr_dds_div_val, usr_adout_sel : std_logic_vector(1 downto 0);
-----------------------------------------------------------------------
-- Signals for BRAM-UART control
type state_type is (StartState, ResetState, IdleState, WaitUser, WaitData, StartSendDataOut, 
    SendRawData, SendIsense, SendV1, SendV2, NextRun, WaitAclk0, WaitAclk1, WaitSyncDDS);
signal curr_state, next_state : state_type := StartState;
-----------------------------------------------------------------------
-- MUX control signals
--signal mux_vsrc_s, mux_vsink_s : std_logic_vector(7 downto 0) := (others => '0');
--signal mux_vpu1_s, mux_vpu2_s : std_logic_vector(5 downto 0) := (others => '0');
signal vsrc_ch, vsink_ch : std_logic_vector(MUX_CH_BITS-1 downto 0) := (others => '0'); -- 64 channels
signal vpu1_ch, vpu2_ch : std_logic_vector(MUX_CH_BITS-2 downto 0) := (others => '0'); -- 32 channels each
-----------------------------------------------------------------------
-- Signal attributes
-----------------------------------------------------------------------
--attribute fsm_encoding : string;
--attribute fsm_encoding of curr_state : signal is "auto_safe_state";
---- KEEP forwarded clocks
--attribute DONT_TOUCH : string;  -- use on forwarded clocks to avoid pruning
--attribute DONT_TOUCH of isense_pga_clk, vpu1_pga_clk, vpu2_pga_clk : signal is "true";
--attribute DONT_TOUCH of pga_clkin_i, pga_clkin_v1, pga_clkin_v2 : signal is "true";

-----------------------------------------------------------------------
--attribute IOB: string;
--attribute IOB of isense_pga_cs_n, isense_pga_si : signal is "true";
--attribute IOB of vpu1_pga_cs_n, vpu1_pga_si : signal is "true";
--attribute IOB of vpu2_pga_cs_n, vpu2_pga_si : signal is "true";
--attribute IOB of isense_pga_clk, vpu1_pga_clk, vpu2_pga_clk : signal is "true";

-----------------------------------------------------------------------
-- Instantiate Components
-----------------------------------------------------------------------
-- Clocks
-----------------------------------------------------------------------
component clk_wiz_0    -- IP core
port (
  clk_out_200M  : out    std_logic;     -- 200 MHz (5 ns period)
  clk_out_15M   : out    std_logic;     -- 14.8571 MHz (70 ns period)
--  clk_out_10M   : out    std_logic;     -- 10 MHz (100 ns period)
  
  reset         : in     std_logic;
  locked        : out    std_logic;
  clk_in1       : in     std_logic      -- 100 MHz (10 ns period)
 );
end component;

-----------------------------------------------------------------------
component clock_gen     -- custom block for slower clocks
Generic ( CLKDIV : integer := 100 );  -- Clock divide for clk_out
Port ( clk_in100 : in STD_LOGIC;    -- input 100 MHz clock
	reset : in STD_LOGIC;			-- reset clocks to 0
	clk_out : out STD_LOGIC);       -- output 100/CLKDIV MHz clock (PGA)
end component;   
-----------------------------------------------------------------------
-- Dual-tone DDS
-----------------------------------------------------------------------
component dualtone_dds_controller is
    GENERIC(
    SLOW_SAMP_CLKDIV : integer := SLOW_SAMP_CLKDIV; -- multiply sample counter for slow_dds_out_last pulse
    NFFT : integer := NFFT;                 -- size of FFT 
    PHASE_WIDTH : integer := PHASE_WIDTH;   -- number of bits in phase control
    DDS_BITS :    INTEGER := DAC_DATA_WIDTH);  -- size of dds_out bus
Port ( dclk : in STD_LOGIC;        -- DDS clock
   fftclk : in STD_LOGIC;          -- ADC sampling clock to sync FFT to correct phase
   enable : in STD_LOGIC;
   reset : in STD_LOGIC;
   phase_freq_A : in STD_LOGIC_VECTOR(2*PHASE_WIDTH-1 downto 0);   -- phase offset (MSB) and frequency (LSB) for ddsA
   phase_freq_B : in STD_LOGIC_VECTOR(2*PHASE_WIDTH-1 downto 0);   -- phase offset (MSB) and frequency (LSB) for ddsB
   dds_out_valid : out STD_LOGIC;       -- dds output is valid
   dds_out_last : out STD_LOGIC;        -- pulse at the start of the dds signal (with respect to phase), every NFFT samples 
   slow_dds_out_last : out STD_LOGIC;   -- pulse at start of dds signal every NFFT*SLOW_SAMP_CLKDIV samples
   dds_out: out STD_LOGIC_VECTOR (DDS_BITS-1 downto 0));
end component;

-----------------------------------------------------------------------
-- DDS phase LUT 	 
COMPONENT blk_mem_gen_0
  PORT (
    clka : IN STD_LOGIC;
    addra : IN STD_LOGIC_VECTOR(PHASE_LUT_ADDR_WIDTH-1 DOWNTO 0);
    douta : OUT STD_LOGIC_VECTOR(PHASE_WIDTH-1 DOWNTO 0) 
  );
END COMPONENT;
-----------------------------------------------------------------------
-- FFT bin LUT 
COMPONENT blk_mem_gen_2
  PORT (
    clka : IN STD_LOGIC;
    addra : IN STD_LOGIC_VECTOR(PHASE_LUT_ADDR_WIDTH-1 DOWNTO 0);
    douta : OUT STD_LOGIC_VECTOR(FFT_LUT_BIN_WIDTH-1 DOWNTO 0) 
  );
END COMPONENT;
-----------------------------------------------------------------------
-- Demodulation control (ADC data -> FIFO -> FFT -> BRAM -> UART)
-----------------------------------------------------------------------
component demod_controller is
  Generic (
        DEBUG_MODE : std_logic := DEBUG_MODE;
        SLOW_SAMP_CLKDIV : integer := SLOW_SAMP_CLKDIV; -- divide ADC clock by this amount if use_slow_fs = '1'
        FFT_BIN_WIDTH : INTEGER := FFT_BIN_WIDTH;       -- 2**FFT_BIN_WIDTH number of bins in FFT
        DATA_WIDTH : integer := ADC_DATA_WIDTH);            -- ADC data bus width
  Port ( sysclk : in STD_LOGIC;         -- system clock
        aclk : in STD_LOGIC;            -- ADC clock
        enable : in STD_LOGIC;
        reset : in STD_LOGIC;
        adin: in STD_LOGIC_VECTOR (ADC_DATA_WIDTH-1 downto 0);    -- from ADC
        adin_last : in STD_LOGIC;																																																								  
        use_slow_fs : in STD_LOGIC;     -- use slow sampling rate (for low freqs)
        read_en : in STD_LOGIC;         -- enable output
        output_rdy : out STD_LOGIC;     -- ready for read
        serial_out : out STD_LOGIC      -- serial out to UART
        );
end component;
-----------------------------------------------------------------------
-- Demodulation control (ADC data -> FIFO -> FFT -> BRAM -> UART)
-----------------------------------------------------------------------
component dds_freq_demod_controller is
  Generic (
        DEBUG_MODE : std_logic := DEBUG_MODE;
        SLOW_SAMP_CLKDIV : integer := SLOW_SAMP_CLKDIV; -- divide ADC clock by this amount if use_slow_fs = '1'
        FFT_BIN_WIDTH : INTEGER := FFT_BIN_WIDTH;       -- 2**FFT_BIN_WIDTH number of bins in FFT
        DATA_WIDTH : integer := ADC_DATA_WIDTH);            -- ADC data bus width
  Port ( sysclk : in STD_LOGIC;         -- system clock
        aclk : in STD_LOGIC;            -- adc clock
        enable : in STD_LOGIC;
        reset : in STD_LOGIC;
        adin: in STD_LOGIC_VECTOR (DATA_WIDTH-1 downto 0);    -- from ADC
        adin_sync_start : in STD_LOGIC;
        
        bin_f1 : in STD_LOGIC_VECTOR (FFT_BIN_WIDTH-1 downto 0);    -- fft bin of signal freq 1 (first half)
        bin_f2 : in STD_LOGIC_VECTOR (FFT_BIN_WIDTH-1 downto 0);    -- fft bin of signal freq 2 if dualtone (first half)    
        use_full_spectrum : in STD_LOGIC;                           -- use full FFT spectrum for THD calcs (default is to use half)          
        n_averages : in integer;        -- Run the ADC->FIFO->FFT n_averages times, save all to BRAM
        use_slow_fs : in STD_LOGIC;     -- use slow sampling rate (for low freqs)
        read_en : in STD_LOGIC;         -- enable output
        
        output_rdy : out STD_LOGIC;     -- ready for output
        serial_out : out STD_LOGIC      -- serial out to UART
        );
end component;
-----------------------------------------------------------------------
-- Programmable Gain Amplifier control
-----------------------------------------------------------------------
component pga_controller
Port ( clk : in STD_LOGIC;  -- max 10 MHz clock for spi_controller
       enable : in STD_LOGIC;
       reset : in STD_LOGIC;
       set_gain : in STD_LOGIC;
       pga_gain_set : in STD_LOGIC_VECTOR(PGA_SEL_BITS-1 downto 0);   -- pga gain setting
       pga_si : out STD_LOGIC;
       pga_sclk : out STD_LOGIC;    -- max 10 MHz clock
       pga_cs_n : out STD_LOGIC);
end component;
-----------------------------------------------------------------------
-- MUX control
-----------------------------------------------------------------------
component mux_controller 
Generic ( CH_BITS : integer := MUX_CH_BITS);  -- number of bits for number of channels (64)
Port (  clk       : in STD_LOGIC;
        enable    : in STD_LOGIC;                      -- check enable bits (en_mux_n) and set accordingly
        en_mux_n  : in STD_LOGIC_VECTOR(3 downto 0);   -- enable mux set [VSRC, VSNK, VPU1, VPU2]
        reset     : in STD_LOGIC;
        vsrc_ch   : in STD_LOGIC_VECTOR(CH_BITS-1 downto 0);
        vsink_ch  : in STD_LOGIC_VECTOR(CH_BITS-1 downto 0);
        vpu1_ch   : in STD_LOGIC_VECTOR(CH_BITS-2 downto 0);    -- odd channels
        vpu2_ch   : in STD_LOGIC_VECTOR(CH_BITS-2 downto 0);    -- even channels
        
        mux_vsrc  : out STD_LOGIC_VECTOR (7 downto 0);  -- to VS+ Muxes [0:7]: S0, S1, S2, S3, NEN1, NEN2, NEN3, NEN4
        mux_vsink : out STD_LOGIC_VECTOR (7 downto 0);  -- to VS- Muxes [0:7]: S0, S1, S2, S3, NEN1, NEN2, NEN3, NEN4
        mux_vpu1  : out STD_LOGIC_VECTOR (5 downto 0);  -- to Vpickup 1 Muxes (Odd Ch's) [0:5]: S0, S1, S2, S3, NEN1, NEN2
        mux_vpu2  : out STD_LOGIC_VECTOR (5 downto 0)); -- to Vpickup 2 Muxes (Even Ch's [0:5]: S0, S1, S2, S3, NEN1, NEN2
                
end component;
-----------------------------------------------------------------------
-- ADC LVDS interface
-----------------------------------------------------------------------
component adc_interface_x3 is
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
    
    dout_1 : out STD_LOGIC_VECTOR(ADC_DATA_WIDTH-1 downto 0);    -- ADC 1 Converted data out
    dout_2 : out STD_LOGIC_VECTOR(ADC_DATA_WIDTH-1 downto 0);    -- ADC 2 Converted data out
    dout_3 : out STD_LOGIC_VECTOR(ADC_DATA_WIDTH-1 downto 0);    -- ADC 3 Converted data out
    dout_valid : out STD_LOGIC);                   -- Converted output data is valid
end component;
-----------------------------------------------------------------------
-- User interface (controlled using UART RX)
-----------------------------------------------------------------------
component uart_ui_controller 
Generic ( FREQ_SEL_BITS : integer := FREQ_SEL_BITS; 	-- number of select bits for DDS freq control
	PGA_SEL_BITS : integer := PGA_SEL_BITS;	   -- number of bits for PGA gain selection
    MUX_SEL_BITS : integer := MUX_CH_BITS);  	-- number of bits for number of channels (64)
Port ( clk : in STD_LOGIC;
       uart_in : in STD_LOGIC;
       usr_reset : out STD_LOGIC;
       usr_enable : out STD_LOGIC;
       usr_freq_sweep_en    : out STD_LOGIC;
       usr_naverages    : out integer;
       usr_use_full_fft : out STD_LOGIC;
       usr_adout_sel    : out STD_LOGIC_VECTOR(1 downto 0);
       usr_freq_sel     : out STD_LOGIC_VECTOR(2*FREQ_SEL_BITS-1 downto 0); -- 2 DDS (DDS B MSB, DDS A LSB)
       usr_dual_dds_en  : out STD_LOGIC;
       usr_dds_div_val  : out STD_LOGIC_VECTOR(1 downto 0);
       usr_uart_tx_rdy  : out STD_LOGIC;
       usr_pga_sel      : out STD_LOGIC_VECTOR(3*PGA_SEL_BITS-1 downto 0);	-- 3 PGAs (Isense MSB, Vpu 1, Vpu 2 LSB)
       usr_pga_set_gain : out STD_LOGIC_VECTOR(2 downto 0); -- single pulse set signal, 3 PGAs (Isense MSB, Vpu 1, Vpu 2 LSB)
       usr_mux_sel      : out STD_LOGIC_VECTOR(4*MUX_SEL_BITS-1 downto 0);	-- 4 MUXes (Vsrc MSB, Vsink, Vpu1, Vpu2 LSB)
       usr_mux_en       : out STD_LOGIC_VECTOR(3 downto 0); -- 4 MUXes (Vsrc MSB, Vsink, Vpu1, Vpu2 LSB) 
       usr_adc_debug_mode   : out STD_LOGIC;
       usr_adc_pwr_dwn : out STD_LOGIC;
       usr_lvds_testpat : out STD_LOGIC);
end component;
-----------------------------------------------------------------------
-----------------------------------------------------------------------
begin
-----------------------------------------------------------------------
-- Set variable constants --> use sim value when DEBUG_MODE = '1'
STARTUP_CTR_MAX <= STARTUP_CTR_SIM when DEBUG_MODE = '1' else STARTUP_CTR_3MS;
AFE_DELAY_CTR_MAX <= AFE_DELAY_CTR_SIM when DEBUG_MODE = '1' else AFE_DELAY_CTR_IMPL;

-----------------------------------------------------------------------
-- Port map
-----------------------------------------------------------------------
-- Clocks for ADC communication
adc_mmcm_inst : clk_wiz_0
port map ( 
    clk_out_200M  => clk_200MHz,
    clk_out_15M   => clk_15MHz,
--    clk_out_10M   => clk_10MHz,
    reset         => reset_mmcm,
    locked        => mmcm_locked,
    clk_in1       => sysclk);
---------------------------------------------------------------------
-- Synchronous reset of MMCM IP core with disable input -- FAILS TIMING
-----------------------------------
reset_mmcm <= '0';  -- never reset, fails timing if synced with rising edge of sysclk  
   
    
-----------------------------------------------------------------------
-- UART User interface       	   
-----------------------------------------------------------------------
uart_ui : uart_ui_controller port map(
    clk => sysclk,
    uart_in => uart_rx,
    usr_reset => reset,
    usr_enable => enable,
    usr_freq_sweep_en => usr_freq_sweep_en,
    usr_naverages => n_averages,
    usr_use_full_fft => use_full_spectrum,
    usr_adout_sel => usr_adout_sel,
    usr_freq_sel => usr_freq_sel, 
    usr_dual_dds_en => usr_dual_dds_en,
    usr_dds_div_val => usr_dds_div_val,
    usr_uart_tx_rdy => uart_rx_rdy,
    usr_pga_sel => usr_pga_dio_s,
    usr_pga_set_gain => set_pga_n,
    usr_mux_sel => usr_mux_dio_s,
    usr_mux_en => enable_mux_n,
    usr_adc_debug_mode => usr_en_adc_debug,
    usr_adc_pwr_dwn => usr_adc_pwr_dwn,
    usr_lvds_testpat => testpat);
    
---------------------------------------------------------------------
---------------------------------------------------------------------
-- Assign DAC clocks
---------------------------------------------------------------------
dclk <= sysclk;         -- DAC clock (internal logic)
dclk_dds <= sysclk;     -- DAC clock out to AFE
---------------------------------------------------------------------
-- Dual-tone DDS controller
dds_inst : dualtone_dds_controller 
port map (
    dclk => dclk,
    fftclk => aclk,
    enable => enable_dds,
    reset => reset_dds, 
    phase_freq_A => phase_offset_freq_A,
    phase_freq_B => phase_offset_freq_B,
    dds_out_valid => dds_out_valid, -- USE IN DEBUG MODE
    dds_out_last => dds_out_last,
    slow_dds_out_last => slow_dds_out_last,
    dds_out => sine_out);
-----------------------------------------------------------------------
-- DDS phase lookup table ROMs
phase_lut_inst_1 : blk_mem_gen_0
port map (
    clka => sysclk,
    addra => phase_lut_addr_a,
    douta => phase_lut_data_a);

phase_lut_inst_2 : blk_mem_gen_0
port map (
    clka => sysclk,
    addra => phase_lut_addr_b,
    douta => phase_lut_data_b);
----------------------------------------------------------------------	
-- FFT bin lookup table ROMs
fft_bin_lut_inst_1 : blk_mem_gen_2
port map (
    clka => sysclk,
    addra => phase_lut_addr_a,
    douta => fft_bin_lut_data_a);    
    

fft_bin_lut_inst_2 : blk_mem_gen_2
port map (
    clka => sysclk,
    addra => phase_lut_addr_b,
    douta => fft_bin_lut_data_b);    
-----------------------------------------------------------------------
bin_f1 <= fft_bin_lut_data_a(FFT_BIN_WIDTH-1 downto 0); 
bin_f2 <= fft_bin_lut_data_b(FFT_BIN_WIDTH-1 downto 0) when usr_dual_dds_en = '1'
    else (others => '0'); 
----------------------------------------------------------------------
----------------------------------------------------------------------
-- Assign ADC clocks
----------------------------------------------------------------------
aclk <= clk_15MHz;      -- ADC (FFT) sampling clock
lclk <= sysclk;         -- ADC LVDS interface clock (internal logic)
lvds_oclk <= adc_dcin;  -- ADC LVDS interface clock out to AFE
aclk_cnv <= adc_cnv;    -- ADC conversion pulse out to AFE
-----------------------------------------------------------------------
-- Set DCO clock
--adc_dco <= lvds_isense_clk;
--adc_dco <= adc_dcin_d;       -- internal clock forward with delay
adc_dco <= adc_dcin when DEBUG_MODE = '1' else adc_dcin_d;
-----------------------------------------------------------------------
delay_adc_clocks:  process(clk_200MHz)
begin
    if rising_edge(clk_200MHz) then     -- delayed 2.5 ns
        adc_dcin_d <= adc_dcin;  
    end if;
end process delay_adc_clocks;

-----------------------------------------------------------------------
-- ADC interface (3x) 
-----------------------------------------------------------------------
adc_interface_inst : adc_interface_x3 port map( 
    enable => enable_adcs,
    aclk => aclk,
    lclk => lclk,
    cnv => adc_cnv,
    dcin => adc_dcin,
    dco => adc_dco,   
    da_1 => lvds_isense_da,
    db_1 => lvds_isense_db,
    da_2 => lvds_vpu1_da,
    db_2 => lvds_vpu1_db,    
    da_3 => lvds_vpu2_da,
    db_3 => lvds_vpu2_db,  
    
    dout_1 => isense_adout,
    dout_2 => vpu1_adout,
    dout_3 => vpu2_adout,
    
    dout_valid => adout_valid);       

-----------------------------------------------------------------------
-- Demodulation control (ADC data -> FIFO -> FFT -> BRAM -> UART)
-----------------------------------------------------------------------
demod_isense: dds_freq_demod_controller port map (
    sysclk => sysclk,
    aclk => aclk,
    enable => enable_demod,
    reset => reset_demod,
    adin => isense_sync,
    adin_sync_start => adin_sync_start,
    bin_f1 => bin_f1,
    bin_f2 => bin_f2,
    use_full_spectrum => use_full_spectrum,
    n_averages => n_averages,
    use_slow_fs => use_slow_fs,
    read_en => read_isense,
    output_rdy => isense_rdy,
    serial_out => uart_tx_isense );
-------------------------------------------
demod_v1: dds_freq_demod_controller port map (
    sysclk => sysclk,
    aclk => aclk,
    enable => enable_demod,
    reset => reset_demod,
    adin => vpu1_sync,
    adin_sync_start => adin_sync_start,
    bin_f1 => bin_f1,
    bin_f2 => bin_f2,
    use_full_spectrum => use_full_spectrum,
    n_averages => n_averages,		   
    use_slow_fs => use_slow_fs,
    read_en => read_v1,
    output_rdy => v1_rdy,
    serial_out => uart_tx_v1 );
-------------------------------------------
demod_v2: dds_freq_demod_controller port map (
    sysclk => sysclk,
    aclk => aclk,
    enable => enable_demod,
    reset => reset_demod,
    adin => vpu2_sync,
    adin_sync_start => adin_sync_start,
    bin_f1 => bin_f1,
    bin_f2 => bin_f2,
    use_full_spectrum => use_full_spectrum,
    n_averages => n_averages,		   
    use_slow_fs => use_slow_fs,
    read_en => read_v2,
    output_rdy => v2_rdy,
    serial_out => uart_tx_v2 );      
-----------------------------------------------------------------------
-- Demodulation control (ADC data -> FIFO -> FFT -> BRAM -> UART)
-----------------------------------------------------------------------
demod_mux_adc : demod_controller port map (
    sysclk => sysclk,
    aclk => aclk,
    enable => enable_demod,
    reset => reset_demod,
    adin => mux_adout,
    adin_last => adin_dds_last,			 
    use_slow_fs => use_slow_fs,
    read_en => send_raw_data,
    output_rdy => mux_demod_output_rdy,
    serial_out => uart_tx_adout );

-----------------------------------------------------------------------   
-- Enable demod_controller if sending raw data
enable_mux_demod <= (usr_adout_sel(0) or usr_adout_sel(1));  -- enabled as normal demod block if applicable
-----------------------------------------------------------------------
-- Programmable Gain Amplifier control
-----------------------------------------------------------------------
pga_isense_inst: pga_controller port map(
    clk => pga_clkin_i,     
    enable => enable_pgas,        
    reset => reset_pgas,  
    set_gain => set_pga_n(0),
    pga_gain_set => isense_gain,
    pga_si => isense_pga_si,
    pga_sclk => isense_pga_clk,
    pga_cs_n => isense_pga_cs_n);
-------------------------------------------    
pga_vpu1_inst: pga_controller port map(
    clk => pga_clkin_v1,     
    enable => enable_pgas,        
    reset => reset_pgas,  
    set_gain => set_pga_n(1),
    pga_gain_set => vpu1_gain,
    pga_si => vpu1_pga_si,
    pga_sclk => vpu1_pga_clk,
    pga_cs_n => vpu1_pga_cs_n);
-------------------------------------------    
pga_vpu2_inst: pga_controller port map(
    clk => pga_clkin_v2,    
    enable => enable_pgas,        
    reset => reset_pgas,  
    set_gain => set_pga_n(2),
    pga_gain_set => vpu2_gain,
    pga_si => vpu2_pga_si,
    pga_sclk => vpu2_pga_clk,
    pga_cs_n => vpu2_pga_cs_n);
-----------------------------------------------------------------------
-- PGA SPI clock inputs to pga controllers
pga_clkin_i <= pga_clk;	
pga_clkin_v1 <= pga_clk;
pga_clkin_v2 <= pga_clk;
--pga_clk <= clk_10MHz;
----------------------------------------------------------------------- 
-- Slow PGA clock forwarding
-----------------------------------------------------------------------
-- Clock for PGA instances (SPI clock)
pga_clk_inst_v1: clock_gen    
Generic map (CLKDIV => 100)
port map(     
    clk_in100 => sysclk,      -- 100 MHz system clock
	reset => reset_mmcm,
    clk_out => pga_clk);      -- PGA SPI clock
-----------------------------------------------------------------------
---- Clock for PGA instances (SPI clock)
--pga_clk_inst_i: clock_gen    
--Generic map (CLKDIV => 120)
--port map(     
--    clk_in100 => sysclk,      -- 100 MHz system clock
--	reset => reset_mmcm,
--    clk_out => pga_clkin_i);      -- PGA SPI clock
    
-----------------------------------------------------------------------
-- MUX control
-----------------------------------------------------------------------
mux_inst: mux_controller port map(
    clk => sysclk,
    enable => enable_muxes,
    en_mux_n => enable_mux_n,
    reset => reset_muxes,
    vsrc_ch => vsrc_ch,
    vsink_ch => vsink_ch,
    vpu1_ch => vpu1_ch,
    vpu2_ch => vpu2_ch,
    
    mux_vsrc => mux_vsrc,
    mux_vsink => mux_vsink,
    mux_vpu1 => mux_vpu1,
    mux_vpu2 => mux_vpu2
);
-----------------------------------------------------------------------
-----------------------------------------------------------------------
-- Clock domain crossings
-----------------------------------------------------------------------
adc_intfc_cdc_proc : process(aclk)  
begin
if rising_edge(aclk) then  
    
    if (usr_en_adc_debug = '1' or DEBUG_MODE = '1') then        -- Clock in DDS (chain FF for CDC)
        adin_valid <= dds_out_valid;    -- from dds controller
        isense_sync <= isense_adout_d;
        vpu1_sync <= vpu1_adout_d;
        vpu2_sync <= vpu2_adout_d;
        isense_adout_d <= std_logic_vector(to_signed(to_integer(signed(sine_out_div)),ADC_DATA_WIDTH));    -- dds
        vpu1_adout_d <= std_logic_vector(to_signed(to_integer(signed(sine_out_div)),ADC_DATA_WIDTH));    -- dds
        vpu2_adout_d <= std_logic_vector(to_signed(to_integer(signed(sine_out_div)),ADC_DATA_WIDTH));    -- dds     
        
    else
        adin_valid <= adout_valid and dds_out_valid;    -- adout_valid from adc interface
        isense_sync <= isense_adout;  -- stable
        vpu1_sync <= vpu1_adout;      -- stable
        vpu2_sync <= vpu2_adout;      -- stable       
        
    end if;

    -- MUX data into old demod block
    case usr_adout_sel is
        when "00" => mux_adout <= std_logic_vector(to_signed(to_integer(signed(sine_out_div)),ADC_DATA_WIDTH));    -- dds
        when "01" => mux_adout <= isense_adout;
        when "10" => mux_adout <= vpu1_adout;
        when "11" => mux_adout <= vpu2_adout;
        when others => mux_adout <= (others => '0');
    end case;
        
    -- Synchronize acquisition of adcs
    adin_sync_start <= dds_out_last;                -- To new demod block -- always use faster counter
    if (use_slow_fs = '1' and DEBUG_MODE = '0') then    -- use slow signal for implementation only
        adin_dds_last <= slow_dds_out_last;         -- To old demod block 
        --adin_sync_start <= slow_dds_out_last;       -- To new demod block 
    else
        adin_dds_last <= dds_out_last;              -- To old demod block 
        --adin_sync_start <= dds_out_last;            -- To new demod block 
    end if;  


end if;
end process adc_intfc_cdc_proc;
-----------------------------------------------------------------------
-- Clock IO data
-----------------------------------------------------------------------
-- Latch DDS output on DAC clock edge
-- Divide by user selection
clock_dds_output: process(dclk) 
variable msb : std_logic;
begin
    if rising_edge(dclk) then
        msb := sine_out(DAC_DATA_WIDTH-1);
        if (enable = '1') then      -- send output if enabled
            case usr_dds_div_val is -- shift
--                when "00" =>   sine_out_div <= sine_out;       -- from DDS controller to DAC -- no scaling
--                when "01" =>   sine_out_div <= msb & sine_out(DAC_DATA_WIDTH-1 downto 1);  -- divide by 2
---------------------------------------------------------------------------------------------------
                when "00" =>   sine_out_div <= msb & msb & sine_out(DAC_DATA_WIDTH-1 downto 2);  -- divide by 4 (repeat MSB in two's complement)
                when "01" =>   sine_out_div <= msb & msb & msb & sine_out(DAC_DATA_WIDTH-1 downto 3);  -- divide by 8
                when "10" =>   sine_out_div <= msb & msb & msb & msb & sine_out(DAC_DATA_WIDTH-1 downto 4);  -- divide by 16
                when "11" =>   sine_out_div <= msb & msb & msb & msb & msb & sine_out(DAC_DATA_WIDTH-1 downto 5);  -- divide by 32
                when others =>
                               sine_out_div <= sine_out;
            end case;
        else
            sine_out_div <= (others => '0');
        end if;
        
        -- Assign output 
        dds_out <= sine_out_div;    
    end if;
end process clock_dds_output;
-----------------------------------------------------------------------

-----------------------------------------------------------------------
-- Control processes 
-----------------------------------------------------------------------
-- Control the freq_sel switch for frequency sweep
next_freq: process(sysclk)
begin

if rising_edge(sysclk) then
    -- Clock in frequency #1
    if (usr_freq_sweep_en = '1') then   -- sweep through freqs using first dds
        if (curr_state = ResetState or curr_state = WaitUser) then   -- Reset/restart
            freq_sel_1 <= (others => '0');          -- start counter at 0
        elsif (curr_state = NextRun) then        -- increment during NextRun state    --->> CHANGED 3/27/23 to SendV1, clock delay through ROM to DDS Phase set
            if (freq_sel_1 < NFREQS_MAX-1) then 
                freq_sel_1 <= freq_sel_1 + 1;   -- increment frequency counter, use for counting frequencies in sweep...
            else
                freq_sel_1 <= (others => '0');          -- reset to 0
            end if;
        end if;
    else 
        freq_sel_1 <= usr_freq_sel(FREQ_SEL_BITS-1 downto 0);
    end if;
    
    -- Clock in frequency #2 if enabled
    freq_sel_2 <= usr_freq_sel(2*FREQ_SEL_BITS-1 downto FREQ_SEL_BITS); 
    
    -- Sample on slow clock for frequencies in the first half of the phase LUT
    if (freq_sel_1 < NFREQS_MAX/2 and DEBUG_MODE = '0' and testpat = '0') then
        use_slow_fs <= '1';
    else
        use_slow_fs <= '0';
    end if;
end if;
end process next_freq;
-----------------------------------------------------------------------
-- Set DDS frequency using LUT ----> MATCH TO FFT BIN & SAMPLING FREQ
phase_lut_addr_a <= freq_sel_1;     -- Set ROM addresses
phase_lut_addr_b <= freq_sel_2;		
offset_selA <= (others => '0');     -- clear offset A
offset_selB <= (others => '0');     -- clear offset B
freq_selA <= phase_lut_data_a(PHASE_WIDTH-1 downto 0);
freq_selB <= phase_lut_data_b(PHASE_WIDTH-1 downto 0) when usr_dual_dds_en = '1'
    else (others => '0');

																											   
-----------------------------------------------------------------------
-- Clock in phase bits on dclk for sysclk-->dclk CDC
latch_phase_bits : process(dclk)
begin

if rising_edge(dclk) then

    -- Multitone controller freq/phase offset inputs
    phase_offset_freq_A(2*PHASE_WIDTH-1 downto PHASE_WIDTH) <= offset_selA;
    phase_offset_freq_A(PHASE_WIDTH-1 downto 0) <= freq_selA;
    phase_offset_freq_B(2*PHASE_WIDTH-1 downto PHASE_WIDTH) <= offset_selB;
    phase_offset_freq_B(PHASE_WIDTH-1 downto 0) <= freq_selB;
end if;
end process latch_phase_bits;

-----------------------------------------------------------------------
-- Count clock cycles for startup delay
startup_delay: process(sysclk)
begin
if (rising_edge(sysclk)) then
    
    -- Default
    startup_ctr_done <= '0';    -- flag for FSM

    if (curr_state = StartState) then
        if (startup_ctr < STARTUP_CTR_MAX) then
            startup_ctr <= startup_ctr + 1;
        else 
            startup_ctr_done <= '1';    -- counter finished
            startup_ctr <= 0;           -- reset count
        end if;
    else   
        startup_ctr <= 0;
    end if;
end if;
end process startup_delay;
-----------------------------------------------------------------------
-- Count clock cycles for holding reset 
---l reset_hold_ctr : integer range 0 to RESET_HOLD_CNT := 0;
reset_hold_counter : process(sysclk)
begin
if (rising_edge(sysclk)) then
    
    -- Default
    reset_hold_done <= '0';

    if (curr_state = ResetState) then
        if (reset_hold_ctr < RESET_HOLD_CNT) then
            reset_hold_ctr <= reset_hold_ctr + 1;
        else 
            reset_hold_done <= '1';     -- counter finished
            reset_hold_ctr <= 0;        -- reset count
        end if;
    else   
        reset_hold_ctr <= 0;
    end if;
end if;
end process reset_hold_counter;
-----------------------------------------------------------------------
-- Count clock cycles for analog trace delay
dds_through_afe_delay_counter: process(sysclk)
begin
if (rising_edge(sysclk)) then

    -- Default
    afe_delay_ctr_done <= '0';    -- flag for FSM

    if (curr_state = WaitAclk0) then
        if (afe_delay_ctr < AFE_DELAY_CTR_MAX) then
            afe_delay_ctr <= afe_delay_ctr + 1;
        else 
            afe_delay_ctr_done <= '1';    -- counter finished
            afe_delay_ctr <= 0;           -- reset count
        end if;
    else   
        afe_delay_ctr <= 0;
    end if;

end if;
end process dds_through_afe_delay_counter;
-----------------------------------------------------------------------
-- State logic for sending demod data out to MATLAB through UART
-----------------------------------------------------------------------
comb_logic : process(curr_state, startup_ctr_done, enable, reset, adin_valid, 
    uart_rx_rdy, mux_demod_output_rdy, isense_rdy, v1_rdy, v2_rdy,
    reset_hold_done, usr_freq_sweep_en, afe_delay_ctr_done) 
begin
 -- Defaults
next_state <= curr_state;   
read_isense <= '0';
read_v1 <= '0';
read_v2 <= '0';
send_raw_data <= '0'; 
enable_demod <= '0';    -- dds_freq_demod_controller enable
enable_adcs <= '1';     -- adc lvds interface enable -- DEFAULT ENABLED
enable_pgas <= '1';     -- pga controller enable -- DEFAULT ENABLED
enable_muxes <= '1';    -- mux controller enable -- DEFAULT ENABLED
enable_dds <= '1';      -- dds controller enable -- DEFAULT ENABLED
reset_demod <= '0';
reset_dds <= '0';
reset_pgas <= '0';
reset_muxes <= '0';
done_tx <= '0';         -- testbench signal (REMOVE FOR FINAL IMPLEMENTATION)

-- Global reset/disable
if (master_reset_in = '1') then
    next_state <= StartState;   -- restart
elsif (reset = '1' and (curr_state /= StartState or DEBUG_MODE = '1')) then
    next_state <= ResetState;   -- reset modules
elsif (enable = '0') then
    next_state <= IdleState;    -- disable outputs
else
    case(curr_state) is
        when StartState =>          -- START HERE. Disable all modules during startup. 
            enable_pgas <= '0';     -- disable signals with default enable
            enable_muxes <= '0';
            enable_dds <= '0';
            enable_adcs <= '0';
            if (startup_ctr_done = '1') then
                next_state <= ResetState;
            end if;

        when ResetState =>        
            enable_muxes <= '0';    -- disable muxes (default enabled)
            reset_demod <= '1';     -- reset modules
            reset_dds <= '1';
            reset_pgas <= '1';
            reset_muxes <= '1';
            if (reset = '0' and reset_hold_done = '1') then
                next_state <= WaitUser;
            end if;
        
        when IdleState =>           -- Disable state
            enable_muxes <= '0';    -- disable signals with default enable
            enable_dds <= '0';
            reset_demod <= '1';     -- reset demodulation controller
            if (enable = '1') then
                next_state <= WaitUser;
                --next_state <= ResetState;
            end if;            
    
        when WaitUser =>
            if (uart_rx_rdy = '1') then     -- wait for user to start
                next_state <= WaitSyncDDS; 
            end if;
            
        when WaitSyncDDS =>         -- wait for DDS to start sync after frequency change (freq_sweep enabled)
            if (adin_valid = '1') then      -- wait for ADC LVDS interface data
                next_state <= WaitData; 
            end if;
            
        when WaitData =>
            enable_demod <= '1';    -- enable demodulation controller
            if ((isense_rdy = '1' and enable_mux_demod = '0')
                    or (mux_demod_output_rdy = '1' and enable_mux_demod = '1')) then
                next_state <= StartSendDataOut;
            end if;
               
        when StartSendDataOut =>     -- delay one clock cycle
            enable_demod <= '1';    -- enable demodulation controller
            if (enable_mux_demod = '0') then
                next_state <= SendIsense;          
            else
                next_state <= SendRawData;
            end if;     
            
        when SendRawData =>
            enable_demod <= '1';
            send_raw_data <= '1';   -- read enable
--            if (mux_demod_output_rdy = '0') then    -- done send
--               next_state <= NextRun;               -- go to next 
--            end if;
            if (uart_rx_rdy = '0') then
                reset_demod <= '1';     -- reset demodulation controller
                next_state <= WaitUser;             -- wait for user to read next
            elsif (mux_demod_output_rdy = '0') then -- done send
                next_state <= NextRun;              -- go to next 
            end if;
            
        when SendIsense =>     
            enable_demod <= '1';    -- enable demodulation controller
            read_isense <= '1';
--            if (isense_rdy = '0') then
--                next_state <= SendV1;
--            end if;
            if (uart_rx_rdy = '0') then
                reset_demod <= '1';         -- reset demodulation controller
                next_state <= WaitUser;     -- wait for user to read next
            elsif (isense_rdy = '0') then   -- done send, read next ADC
                next_state <= SendV1;          
            end if;            
            
        when SendV1 =>     
            enable_demod <= '1';    -- enable demodulation controller
            read_v1 <= '1';
--            if (v1_rdy = '0') then
--                next_state <= SendV2;
--            end if;
            if (uart_rx_rdy = '0') then
                reset_demod <= '1';     -- reset demodulation controller
                next_state <= WaitUser; -- wait for user to read next
            elsif (v1_rdy = '0') then   -- done send, read next ADC
                next_state <= SendV2;          
            end if;       
            
        when SendV2 =>     
            enable_demod <= '1';    -- enable demodulation controller
            read_v2 <= '1';
--            if (v2_rdy = '0') then
--                next_state <= NextRun;
--            end if;
            if (uart_rx_rdy = '0') then
                reset_demod <= '1';     -- reset demodulation controller
                next_state <= WaitUser; -- wait for user to read next
            elsif (v2_rdy = '0') then   -- done send
                next_state <= NextRun;       
            end if;            
             
        when NextRun =>          
            done_tx <= '1';
            enable_demod <= '1';    -- enable demodulation controller
            if (usr_freq_sweep_en = '1' or uart_rx_rdy = '1') then
                next_state <= WaitAclk0; 
            else
                next_state <= WaitUser;
            end if;

        when WaitAclk0 =>           -- delay while frequency is being incremented
            if afe_delay_ctr_done = '1' then
                next_state <= WaitAclk1;
            end if;
       
        when WaitAclk1 =>           -- delay while frequency is being incremented
            if (uart_rx_rdy = '1') then
                next_state <= WaitSyncDDS; 
            else
                next_state <= WaitUser;
            end if;
                                    
        when others =>  -- should never reach
            next_state <= ResetState;
            
    end case;
end if;
end process comb_logic;
-----------------------------------------------------------------------
 state_update: process(sysclk)
 begin
 
 if rising_edge(sysclk) then
     curr_state <= next_state;  
 end if;
 end process state_update;
-----------------------------------------------------------------------
-- Clock UART rx and tx bits
uart_io_control: process(sysclk)
begin
if rising_edge(sysclk) then
    uart_txd_out <= uart_txd;
    uart_rx_d <= uart_txd_in;       -- "debounce" since it's an input
    uart_rx <= uart_rx_d;
end if;
end process uart_io_control;
-----------------------------------------------------------------------
uart_txd <= uart_tx_isense when (curr_state = SendIsense) else
            uart_tx_v1 when (curr_state = SendV1) else
            uart_tx_v2 when (curr_state = SendV2) else
            uart_tx_adout when (curr_state = SendRawData) else
            '1';       
-----------------------------------------------------------------------
-- Wire signals to ports
----------------------------------------------------------------------- 
---- Latch time-sensitive IO (SPI bus to PGA)
--latch_spi_outputs: process(sysclk)
--begin
--if rising_edge(sysclk) then
--    -- PGA SPI controls [0:2]: CSn, SI, SCK
--    pga_isense_cs_n <= isense_pga_cs_n;
--    pga_isense_si   <= isense_pga_si;               -- add delay to isense serial input
--    pga_isense_clk  <= isense_pga_clk;
    
--    pga_vpu1_cs_n   <= vpu1_pga_cs_n;
--    pga_vpu1_si     <= vpu1_pga_si;
--    pga_vpu1_clk    <= vpu1_pga_clk;
    
--    pga_vpu2_cs_n   <= vpu2_pga_cs_n;
--    pga_vpu2_si     <= vpu2_pga_si;
--    pga_vpu2_clk    <= vpu2_pga_clk;
--end if;
--end process latch_spi_outputs;

-------------------------------------------------------------------------
-- PGA SPI controls [0:2]: CSn, SI, SCK
pga_isense_cs_n <= isense_pga_cs_n;     -- chip select
pga_vpu1_cs_n   <= vpu1_pga_cs_n;
pga_vpu2_cs_n   <= vpu2_pga_cs_n;
pga_isense_si   <= isense_pga_si;       -- serial data
pga_vpu1_si     <= vpu1_pga_si;
pga_vpu2_si     <= vpu2_pga_si;
pga_isense_clk  <= isense_pga_clk;      -- spi clock
pga_vpu1_clk    <= vpu1_pga_clk;
pga_vpu2_clk    <= vpu2_pga_clk;
----------------------------------------------------------------------- 
-- Forward user interface selections to modules
forward_ui_selections: process(sysclk)
begin
if rising_edge(sysclk) then
    -- MUX Channels
    vsrc_ch <= usr_mux_dio_s(4*MUX_CH_BITS-1 downto 3*MUX_CH_BITS);
    vsink_ch <= usr_mux_dio_s(3*MUX_CH_BITS-1 downto 2*MUX_CH_BITS);
    vpu1_ch <= usr_mux_dio_s(2*MUX_CH_BITS-2 downto MUX_CH_BITS);       -- discard MSB (odd chs only)
    vpu2_ch <= usr_mux_dio_s(MUX_CH_BITS-2 downto 0);                   -- discard MSB (even chs only)
    
    -- PGA gain -----> TODO automatic gain control
    isense_gain <= usr_pga_dio_s(3*PGA_SEL_BITS-1 downto 2*PGA_SEL_BITS);
    vpu1_gain <= usr_pga_dio_s(2*PGA_SEL_BITS-1 downto PGA_SEL_BITS);
    vpu2_gain <= usr_pga_dio_s(PGA_SEL_BITS-1 downto 0);
    
end if;
end process forward_ui_selections;
-----------------------------------------------------------------------
-- Manually set PGA gain -----> TODO automatic gain control
-----------------------------------------------------------------------
--isense_gain <= usr_pga_dio_s(3*PGA_SEL_BITS-1 downto 2*PGA_SEL_BITS);
--vpu1_gain <= usr_pga_dio_s(2*PGA_SEL_BITS-1 downto PGA_SEL_BITS);
--vpu2_gain <= usr_pga_dio_s(PGA_SEL_BITS-1 downto 0);
-----------------------------------------------------------------------

-------------------------------------------------------------------------
---- MUX Channels --> Set from UI
--vsrc_ch <= usr_mux_dio_s(4*MUX_CH_BITS-1 downto 3*MUX_CH_BITS);
--vsink_ch <= usr_mux_dio_s(3*MUX_CH_BITS-1 downto 2*MUX_CH_BITS);
--vpu1_ch <= usr_mux_dio_s(2*MUX_CH_BITS-1 downto MUX_CH_BITS);
--vpu2_ch <= usr_mux_dio_s(MUX_CH_BITS-1 downto 0);

----------------------------------------------------------------------- 
-- ADC digital IO 
adc_twolanes <= '1'; -- fixed to twolane mode (adc_interface logic depends on it)

-- Update testpattern/powerdown functions once adc lvds interface is disabled 
update_adc_dio : process(sysclk)
begin
-- Trigger on each state change, but only update if adc interface is off
if rising_edge(sysclk) then
    if (curr_state = StartState) then
        adc_testpat <= '0';
        adc_pwr_dwn <= '1';    -- active low   
    else
    --elsif (curr_state /= WaitData and curr_state /= WaitSyncDDS) then
        adc_testpat <= testpat;
        adc_pwr_dwn <= not usr_adc_pwr_dwn;    -- active low
    end if;
end if;
end process update_adc_dio;
----------------------------------------------------------------------- 
end Behavioral;
