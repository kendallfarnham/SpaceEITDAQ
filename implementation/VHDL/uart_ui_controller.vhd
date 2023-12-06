----------------------------------------------------------------------------------
-- Company: Thayer School of Engineering, Dartmouth College
-- Engineer: Kendall Farnham
-- 
-- Create Date: 07/13/2023
-- Design Name: 
-- Module Name: uart_ui_controller - Behavioral
-- Project Name: 2023_DAQ
-- Target Devices: Artix 7 (Trenz Electronics TE0711-01)
-- Tool Versions: Vivado 2022.2
-- Description: UART user interface to laptop (MATLAB)
-- 
-- Dependencies: uart_rx
-- 
-- Revision 0.01 - 11/19/2022 File Created
-- Revision 0.02 - 7/13/2023 Copied from 2023_DAQ_64ch_v2.srcs
-- 
----------------------------------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use ieee.numeric_std.all;

entity uart_ui_controller is
Generic ( FREQ_SEL_BITS : integer := 6; 	-- number of select bits for DDS freq control
	PGA_SEL_BITS : integer := 3;	-- number of bits for PGA gain selection
    MUX_SEL_BITS : integer := 6);  	-- number of bits for number of channels (64)
Port ( clk          : in STD_LOGIC;
       uart_in      : in STD_LOGIC;
       usr_reset    : out STD_LOGIC;
       usr_enable   : out STD_LOGIC;
       usr_freq_sweep_en    : out STD_LOGIC;
       usr_naverages        : out integer;
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
       usr_adc_pwr_dwn  : out STD_LOGIC;
       usr_lvds_testpat : out STD_LOGIC);
end uart_ui_controller;

architecture Behavioral of uart_ui_controller is
-------------------------------------------
component uart_rx
	GENERIC(
		clk_freq    :	INTEGER		:= 100_000_000;	--frequency of system clock in Hertz
		baud_rate	:	INTEGER		:= 256_000;		--data link baud rate in bits/second
		os_rate		:	INTEGER		:= 16;			--oversampling rate to find center of receive bits (in samples per baud period)
		d_width		:	INTEGER		:= 8; 			--data bus width
		parity		:	INTEGER		:= 0;			--0 for no parity, 1 for parity
		parity_eo	:	STD_LOGIC	:= '0');		--'0' for even, '1' for odd parity
	PORT(
		clk		:	IN		STD_LOGIC;				--system clock
		reset_n	:	IN		STD_LOGIC;				--ascynchronous reset
		rx			:	IN		STD_LOGIC;			--receive pin
		rx_busy	:	OUT	STD_LOGIC;					--data reception in progress
		rx_error	:	OUT	STD_LOGIC;				--start, parity, or stop bit error detected
		rx_data	:	OUT	STD_LOGIC_VECTOR(d_width-1 DOWNTO 0));	--data received
END component;
-------------------------------------------
-- Constants
constant DATA_WIDTH : integer := 8;
constant N_FREQS : integer := 2**FREQ_SEL_BITS;     -- number of frequencies
constant N_MUX_CHS : integer := 2**MUX_SEL_BITS;	-- number of mux channels in use
constant CMD_IDX_0 : integer := 2**7;				-- start commands at this value (2^6 = 64 for 64 channels, 2^7 = 128 freqs to choose from)

-- User input command values ---> start at CMD_IDX_0
constant UI_RESET_VAL : integer := CMD_IDX_0;         	-- input value to reset all
constant UI_ENABLE_VAL : integer := CMD_IDX_0+1;       	-- input value to enable all
constant UI_DISABLE_VAL : integer := CMD_IDX_0+2;       -- input value to disable all 

constant UI_UART_TX_EN_VAL : integer := CMD_IDX_0+3;    -- input value to enable uart tx
constant UI_UART_TX_DIS_VAL : integer := CMD_IDX_0+4;   -- input value to disable uart tx

constant UI_ADC_TESTPAT_EN_VAL : integer := CMD_IDX_0+5;   	-- input value to enable ADC testpattern
constant UI_ADC_TESTPAT_DIS_VAL : integer := CMD_IDX_0+6;  	-- input value to disable ADC testpattern
constant UI_ADC_DEBUG_EN_VAL : integer := CMD_IDX_0+7;      -- input value to enable ADC debug mode
constant UI_ADC_DEBUG_DIS_VAL : integer := CMD_IDX_0+8;     -- input value to disable ADC debug mode
constant UI_ADC_POWER_OFF_VAL : integer := CMD_IDX_0+9;     -- input value to power down ADCs
constant UI_ADC_POWER_ON_VAL : integer := CMD_IDX_0+10;     -- input value to power on ADCs

constant UI_DDS_DIVIDE_1 : integer := CMD_IDX_0+11;         -- input value to divide DDS output by 1
constant UI_DDS_DIVIDE_2 : integer := CMD_IDX_0+12;         -- input value to divide DDS output by 2
constant UI_DDS_DIVIDE_3 : integer := CMD_IDX_0+13;         -- input value to divide DDS output by 3
constant UI_DDS_DIVIDE_4 : integer := CMD_IDX_0+14;         -- input value to divide DDS output by 4

constant UI_SET_N_AVERAGES : integer := CMD_IDX_0+15;       -- input value to set the number of averages to compute/save
constant UI_SET_ADOUT_0 : integer := CMD_IDX_0+16;          -- input value to send no ADC data out
constant UI_SET_ADOUT_1 : integer := CMD_IDX_0+17;          -- input value to send Isense ADC data out
constant UI_SET_ADOUT_2 : integer := CMD_IDX_0+18;          -- input value to send V1 ADC data out
constant UI_SET_ADOUT_3 : integer := CMD_IDX_0+19;          -- input value to send V2 ADC data out
constant UI_USE_FULL_FFT : integer := CMD_IDX_0+20;         -- input value to use full FFT spectrum data for calculations
constant UI_SET_N_DATASETS : integer := CMD_IDX_0+21;       -- input value to set the number of datasets to acquire

constant UI_FREQ_SWEEP_EN_VAL : integer := CMD_IDX_0+32; 	-- input value to run monotone frequency sweep
constant UI_FREQ_SWEEP_DIS_VAL : integer := CMD_IDX_0+33;	-- input value to disable frequency sweep
constant UI_SET_FREQ_1_VAL : integer := CMD_IDX_0+34;    	-- input value to set freq for ddsA
constant UI_SET_FREQ_2_VAL : integer := CMD_IDX_0+35;    	-- input value to set freq for ddsB (dual tone enabled)
constant UI_DUAL_DDS_EN_VAL : integer := CMD_IDX_0+36;   	-- input value to force enable second dds 
constant UI_DUAL_DDS_DIS_VAL : integer := CMD_IDX_0+37;  	-- input value to disable second dds 

constant UI_SET_PGA_ISENSE_VAL : integer := CMD_IDX_0+38; 	-- input value to set Isense PGA gain
constant UI_SET_PGA_VPU1_VAL : integer := CMD_IDX_0+39;     -- input value to set Vpickup Channel 1 PGA gain
constant UI_SET_PGA_VPU2_VAL : integer := CMD_IDX_0+40;     -- input value to set Vpickup Channel 2 PGA gain

constant UI_SET_MUX_VSRC_VAL : integer := CMD_IDX_0+41;  	-- input value to set Vsource mux
constant UI_SET_MUX_VSNK_VAL : integer := CMD_IDX_0+42;  	-- input value to set Vsink mux
constant UI_SET_MUX_VPU1_VAL : integer := CMD_IDX_0+43;   	-- input value to set Vpickup Channel 1 mux
constant UI_SET_MUX_VPU2_VAL : integer := CMD_IDX_0+44;   	-- input value to set Vpickup Channel 2 mux
constant UI_DISABLE_MUXES : integer := CMD_IDX_0+45;   	    -- input value to disable all muxes
constant UI_ENABLE_MUXES : integer := CMD_IDX_0+46;   	    -- input value to enable all muxes

-- Signals
--signal rx_busy, reset, tx_rdy, freq_sweep, dual_dds_en, lvds_testpat : std_logic := '0';
signal enable_muxes : std_logic := '1';
signal rx_busy, reset, enable, reset_n : std_logic := '1';
signal rx_data : std_logic_vector(DATA_WIDTH-1 downto 0) := (others => '0');
signal mux_sel : std_logic_vector(4*MUX_SEL_BITS-1 downto 0) := (others => '0');
signal freq_sel : std_logic_vector(2*FREQ_SEL_BITS-1 downto 0) := (others => '0');
signal pga_sel : std_logic_vector(3*PGA_SEL_BITS-1 downto 0) := (others => '0');
signal n_dds_to_set : std_logic := '0';	-- 2 dds
signal n_mux_to_set : std_logic_vector(1 downto 0) := (others => '0');	-- 4 muxes (vs+, vs-, vpu1, vpu2)
signal n_mux_enable : std_logic_vector(3 downto 0) := (others => '0');	-- 4 muxes (vs+, vs-, vpu1, vpu2)
signal n_pga_to_set : std_logic_vector(1 downto 0) := (others => '0');	-- 3 pgas (isense, vpu1, vpu2)
signal n_pga_set_gain : std_logic_vector(2 downto 0) := (others => '0');-- 3 pgas (isense, vpu1, vpu2)
--signal naverages, ndatasets : integer := 1;
signal naverages, ndatasets : unsigned(DATA_WIDTH-1 downto 0) := (others => '0');
signal navgsxsets : unsigned(2*DATA_WIDTH-1 downto 0) := (others => '0');

-- FSM signals
type uart_rx_state_type is (WaitRx, RxCommand, SetReset, WaitRxAvgs, RxAvgs, WaitRxDsets, RxDsets,
    WaitRxDDS, RxDDS, WaitRxMUX, RxMUX, WaitRxPGA, RxPGA);
signal uart_rx_state: uart_rx_state_type := SetReset;


-------------------------------------------
-- Author Jonathon Bromley
-- https://groups.google.com/d/msg/comp.lang.vhdl/eBZQXrw2Ngk/4H7oL8hdHMcJ
function reverse_any_vector (a: in std_logic_vector)
return std_logic_vector is
  variable result: std_logic_vector(a'RANGE);
  alias aa: std_logic_vector(a'REVERSE_RANGE) is a;
begin
  for i in aa'RANGE loop
    result(i) := aa(i);
  end loop;
  return result;
end; -- function reverse_any_vector


-------------------------------------------
begin
-------------------------------------------

uart_ctrl: uart_rx port map(
    clk => clk,
    reset_n => reset_n,
    rx => uart_in,
    rx_busy => rx_busy,
    rx_error => open,
    rx_data => rx_data);
 
 
-------------------------------------------
-- UART RX state machine
-------------------------------------------
uart_rx_fsm : process(clk)
begin

if rising_edge(clk) then

    -- Defaults
    reset <= '0';
    n_pga_set_gain <= (others => '0');  -- single pulse to top level to set pgas

    case uart_rx_state is
        when WaitRx =>
            if (rx_busy = '1') then -- uart RX started
                uart_rx_state <= RxCommand;
            else
                uart_rx_state <= WaitRx;
            end if;
			
		when RxCommand =>
            if (rx_busy = '0') then -- wait for rx to finish
            
                -- System settings
                if (rx_data = std_logic_vector(to_unsigned(UI_RESET_VAL,DATA_WIDTH))) then          -- reset all
                    reset <= '1';           -- hold reset high for 2 clock cycles
                    uart_rx_state <= SetReset;  -- reset user values in SetReset state
				elsif (rx_data = std_logic_vector(to_unsigned(UI_ENABLE_VAL,DATA_WIDTH))) then     -- enable all
                    enable <= '1';          -- enable
                    enable_muxes <= '1';  
                    uart_rx_state <= WaitRx;
                elsif (rx_data = std_logic_vector(to_unsigned(UI_DISABLE_VAL,DATA_WIDTH))) then     -- disable all
                    enable <= '0';          -- disable all
                    n_mux_enable <= (others => '0');      -- disable muxes
                    enable_muxes <= '0';
                    uart_rx_state <= WaitRx;
                elsif (rx_data = std_logic_vector(to_unsigned(UI_UART_TX_EN_VAL,DATA_WIDTH))) then  -- enable tx back to MATLAB
                    usr_uart_tx_rdy <= '1';          -- uart write enable
                    uart_rx_state <= WaitRx;
                elsif (rx_data = std_logic_vector(to_unsigned(UI_UART_TX_DIS_VAL,DATA_WIDTH))) then  -- disable tx back to MATLAB
                    usr_uart_tx_rdy <= '0';          -- disable uart write
                    uart_rx_state <= WaitRx;
								
				 -- ADC settings
                elsif (rx_data = std_logic_vector(to_unsigned(UI_ADC_TESTPAT_EN_VAL,DATA_WIDTH))) then	-- enable ADC testpattern
                    usr_lvds_testpat <= '1';        -- turn testpattern on
                    uart_rx_state <= WaitRx;
                elsif (rx_data = std_logic_vector(to_unsigned(UI_ADC_TESTPAT_DIS_VAL,DATA_WIDTH))) then  -- disable ADC testpattern
                    usr_lvds_testpat <= '0';        -- testpattern off
                    uart_rx_state <= WaitRx;
                elsif (rx_data = std_logic_vector(to_unsigned(UI_ADC_DEBUG_EN_VAL,DATA_WIDTH))) then    -- enable ADC debug mode
                    usr_adc_debug_mode <= '1';      -- enable debug mode
                    uart_rx_state <= WaitRx;    
                elsif (rx_data = std_logic_vector(to_unsigned(UI_ADC_DEBUG_DIS_VAL,DATA_WIDTH))) then    -- disable ADC debug mode
                    usr_adc_debug_mode <= '0';      -- disable debug mode
                    uart_rx_state <= WaitRx;    
                elsif (rx_data = std_logic_vector(to_unsigned(UI_ADC_POWER_OFF_VAL,DATA_WIDTH))) then    -- power down ADCs
                    usr_adc_pwr_dwn <= '1';         -- power down ADCs
                    uart_rx_state <= WaitRx;                    
                elsif (rx_data = std_logic_vector(to_unsigned(UI_ADC_POWER_ON_VAL,DATA_WIDTH))) then    -- power on ADCs
                    usr_adc_pwr_dwn <= '0';         -- turn ADCs on
                    uart_rx_state <= WaitRx;     
                    
                -- DDS settings
                elsif (rx_data = std_logic_vector(to_unsigned(UI_FREQ_SWEEP_EN_VAL,DATA_WIDTH))) then  	-- enable monotone frequency sweep
                    usr_freq_sweep_en <= '1';  -- enable frequency sweep
                    freq_sel <= (others => '0');    -- clear
                    uart_rx_state <= WaitRx;
                elsif (rx_data = std_logic_vector(to_unsigned(UI_FREQ_SWEEP_DIS_VAL,DATA_WIDTH))) then  -- disable frequency sweep
                    usr_freq_sweep_en <= '0';  -- disable frequency sweep
                    uart_rx_state <= WaitRx;
				elsif (rx_data = std_logic_vector(to_unsigned(UI_SET_FREQ_1_VAL,DATA_WIDTH))) then  	-- set first dds frequency
                    n_dds_to_set <= '0';
					uart_rx_state <= WaitRxDDS;					
                elsif (rx_data = std_logic_vector(to_unsigned(UI_SET_FREQ_2_VAL,DATA_WIDTH))) then  	-- set second dds frequency
                    n_dds_to_set <= '1';
					uart_rx_state <= WaitRxDDS;	
                elsif (rx_data = std_logic_vector(to_unsigned(UI_DUAL_DDS_EN_VAL,DATA_WIDTH))) then  	-- enable second dds
                    usr_dual_dds_en <= '1';  -- enable second dds
                    uart_rx_state <= WaitRx;		
                elsif (rx_data = std_logic_vector(to_unsigned(UI_DUAL_DDS_DIS_VAL,DATA_WIDTH))) then  	-- disable second dds
                    usr_dual_dds_en <= '0';  -- disable second dds
                    uart_rx_state <= WaitRx;								
                elsif (rx_data = std_logic_vector(to_unsigned(UI_DDS_DIVIDE_1,DATA_WIDTH))) then	   -- divide dds output by 1 (no shift)
                    usr_dds_div_val <= "00";   
                    uart_rx_state <= WaitRx;
                elsif (rx_data = std_logic_vector(to_unsigned(UI_DDS_DIVIDE_2,DATA_WIDTH))) then	   -- divide dds output by 2 (shift 1 bit)
                    usr_dds_div_val <= "01";   
                    uart_rx_state <= WaitRx;					
                elsif (rx_data = std_logic_vector(to_unsigned(UI_DDS_DIVIDE_3,DATA_WIDTH))) then	   -- divide dds output by 4 (shift 2 bits)
                    usr_dds_div_val <= "10";   
                    uart_rx_state <= WaitRx;					
                elsif (rx_data = std_logic_vector(to_unsigned(UI_DDS_DIVIDE_4,DATA_WIDTH))) then	   -- divide dds output by 8 (shift 3 bits)
                    usr_dds_div_val <= "11";   
                    uart_rx_state <= WaitRx;
                    
                -- Demodulation settings				
                elsif (rx_data = std_logic_vector(to_unsigned(UI_SET_N_AVERAGES,DATA_WIDTH))) then      -- set number of averages to compute/save
					uart_rx_state <= WaitRxAvgs;		
                elsif (rx_data = std_logic_vector(to_unsigned(UI_SET_N_DATASETS,DATA_WIDTH))) then      -- set number of datasets to acquire
					uart_rx_state <= WaitRxDsets;	
                elsif (rx_data = std_logic_vector(to_unsigned(UI_SET_ADOUT_0,DATA_WIDTH))) then	        -- send no ADC data out
                    usr_adout_sel <= "00";   
                    uart_rx_state <= WaitRx;
                elsif (rx_data = std_logic_vector(to_unsigned(UI_SET_ADOUT_1,DATA_WIDTH))) then	        -- send isense ADC data out
                    usr_adout_sel <= "01";   
                    uart_rx_state <= WaitRx;					
                elsif (rx_data = std_logic_vector(to_unsigned(UI_SET_ADOUT_2,DATA_WIDTH))) then	        -- send vpickup 1 ADC data out
                    usr_adout_sel <= "10";   
                    uart_rx_state <= WaitRx;					
                elsif (rx_data = std_logic_vector(to_unsigned(UI_SET_ADOUT_3,DATA_WIDTH))) then	        -- send vpickup 2 ADC data out
                    usr_adout_sel <= "11";   
                    uart_rx_state <= WaitRx;	
                elsif (rx_data = std_logic_vector(to_unsigned(UI_USE_FULL_FFT,DATA_WIDTH))) then	    -- use full fft spectrum for calcs (default is use half)
                    usr_use_full_fft <= '1';   
                    uart_rx_state <= WaitRx;                    
                    
                    					
                -- MUX settings
                elsif (rx_data = std_logic_vector(to_unsigned(UI_SET_MUX_VSRC_VAL,DATA_WIDTH))) then    -- set Vsource mux
					n_mux_to_set <= "00";
                    uart_rx_state <= WaitRxMUX;					
                 elsif (rx_data = std_logic_vector(to_unsigned(UI_SET_MUX_VSNK_VAL,DATA_WIDTH))) then    -- set Vsink mux
					n_mux_to_set <= "01";
                    uart_rx_state <= WaitRxMUX;              
                elsif (rx_data = std_logic_vector(to_unsigned(UI_SET_MUX_VPU1_VAL,DATA_WIDTH))) then    -- set Vpickup Ch 1 mux
					n_mux_to_set <= "10";
                    uart_rx_state <= WaitRxMUX;
                elsif (rx_data = std_logic_vector(to_unsigned(UI_SET_MUX_VPU2_VAL,DATA_WIDTH))) then    -- set Vpickup Ch 2 mux
					n_mux_to_set <= "11";
                    uart_rx_state <= WaitRxMUX;
                elsif (rx_data = std_logic_vector(to_unsigned(UI_DISABLE_MUXES,DATA_WIDTH))) then       -- Disable muxes
                    n_mux_enable <= (others => '0');      -- disable all
                    enable_muxes <= '0';
                    uart_rx_state <= WaitRx;		
                elsif (rx_data = std_logic_vector(to_unsigned(UI_ENABLE_MUXES,DATA_WIDTH))) then        -- Enable muxes that have been set
                    enable_muxes <= '1';
                    uart_rx_state <= WaitRx;		                    
                                      
                -- PGA settings
                elsif (rx_data = std_logic_vector(to_unsigned(UI_SET_PGA_ISENSE_VAL,DATA_WIDTH))) then 	-- set Isense PGA    
					n_pga_to_set <= "00";
                    uart_rx_state <= WaitRxPGA;
				elsif (rx_data = std_logic_vector(to_unsigned(UI_SET_PGA_VPU1_VAL,DATA_WIDTH))) then  	-- set Vpickup Ch 1 PGA
					n_pga_to_set <= "01";
                    uart_rx_state <= WaitRxPGA;
                elsif (rx_data = std_logic_vector(to_unsigned(UI_SET_PGA_VPU2_VAL,DATA_WIDTH))) then    -- set Vpickup Ch 2 PGA
					n_pga_to_set <= "10";
                    uart_rx_state <= WaitRxPGA;
                else
                    uart_rx_state <= WaitRx;
                end if;
            else
                uart_rx_state <= RxCommand;
            end if;	
			
		-- Set DDS frequencies
		when WaitRxDDS =>
            if (rx_busy = '1') then -- uart RX started
                uart_rx_state <= RxDDS;
            else
                uart_rx_state <= WaitRxDDS;
            end if;		  
		
        when RxDDS =>
            if (rx_busy = '0') then -- wait for rx to finish    
				if n_dds_to_set = '0' then	-- set dds freq 1
					freq_sel(FREQ_SEL_BITS-1 downto 0) <= rx_data(FREQ_SEL_BITS-1 downto 0);
				else						-- set dds freq 2 and enable dual dds
					freq_sel(2*FREQ_SEL_BITS-1 downto FREQ_SEL_BITS) <= rx_data(FREQ_SEL_BITS-1 downto 0);
					usr_dual_dds_en <= '1'; -- enable second dds
				end if;
				uart_rx_state <= WaitRx;	
            else
                uart_rx_state <= RxDDS;
            end if;		
            
        -- Set demodulation parameters
        when WaitRxAvgs =>	
            if (rx_busy = '1') then -- uart RX started
                uart_rx_state <= RxAvgs;
            else
                uart_rx_state <= WaitRxAvgs;
            end if;		
       
        when RxAvgs =>
            if (rx_busy = '0') then -- wait for rx to finish    
				naverages <= unsigned(rx_data);
				uart_rx_state <= WaitRx;	
            else
                uart_rx_state <= RxAvgs;
            end if;	
            
        -- Set number of datasets to acquire
        when WaitRxDsets =>	
            if (rx_busy = '1') then -- uart RX started
                uart_rx_state <= RxDsets;
            else
                uart_rx_state <= WaitRxDsets;
            end if;		
       
        when RxDsets =>
            if (rx_busy = '0') then -- wait for rx to finish    
				ndatasets <= unsigned(rx_data);
				uart_rx_state <= WaitRx;	
            else
                uart_rx_state <= RxDsets;
            end if;	
            	
		-- Set PGA gains
        when WaitRxPGA =>
            if (rx_busy = '1') then -- uart RX started
                uart_rx_state <= RxPGA;
            else
                uart_rx_state <= WaitRxPGA;
            end if;        
            
        when RxPGA =>
            if (rx_busy = '0') then -- wait for rx to finish    
				if n_pga_to_set = "00" then		-- set isense pga
					pga_sel(3*PGA_SEL_BITS-1 downto 2*PGA_SEL_BITS) <= rx_data(PGA_SEL_BITS-1 downto 0);
					n_pga_set_gain(0) <= '1';
				elsif n_pga_to_set = "01" then		-- set vpu 1 pga
					pga_sel(2*PGA_SEL_BITS-1 downto PGA_SEL_BITS) <= rx_data(PGA_SEL_BITS-1 downto 0);
					n_pga_set_gain(1) <= '1';
				elsif n_pga_to_set = "10" then		-- set vpu 2 pga
					pga_sel(PGA_SEL_BITS-1 downto 0) <= rx_data(PGA_SEL_BITS-1 downto 0);		
					n_pga_set_gain(2) <= '1';			
				end if;
				uart_rx_state <= WaitRx;	
            else
                uart_rx_state <= RxPGA;
            end if;		
			
		-- Set MUX channels
        when WaitRxMUX =>
            if (rx_busy = '1') then -- uart RX started
                uart_rx_state <= RxMUX;
            else
                uart_rx_state <= WaitRxMUX;
            end if;       
            		
	    when RxMUX =>
            if (rx_busy = '0') then -- wait for rx to finish    
				if n_mux_to_set = "00" then			-- set and enable vsource pga
					mux_sel(4*MUX_SEL_BITS-1 downto 3*MUX_SEL_BITS) <= rx_data(MUX_SEL_BITS-1 downto 0);
					n_mux_enable(3) <= '1';            
				elsif n_mux_to_set = "01" then		-- set and enable vsink pga
					mux_sel(3*MUX_SEL_BITS-1 downto 2*MUX_SEL_BITS) <= rx_data(MUX_SEL_BITS-1 downto 0);
					n_mux_enable(2) <= '1';
				elsif n_mux_to_set = "10" then		-- set and enable vpu 1 pga
					mux_sel(2*MUX_SEL_BITS-1 downto MUX_SEL_BITS) <= rx_data(MUX_SEL_BITS-1 downto 0);	
					n_mux_enable(1) <= '1';			
				elsif n_mux_to_set = "11" then		-- set and enable vpu 2 pga
					mux_sel(MUX_SEL_BITS-1 downto 0) <= rx_data(MUX_SEL_BITS-1 downto 0);	
					n_mux_enable(0) <= '1';	
				end if;
																							  
				uart_rx_state <= WaitRx;	
            else
                uart_rx_state <= RxMUX;
            end if;	
     
        -- Global reset
        when SetReset =>
            reset <= '1';       -- hold reset high for 2 clock cycles
            enable <= '1';      -- enable
            naverages <= to_unsigned(64,DATA_WIDTH);    -- default averaging
            ndatasets <= to_unsigned(1,DATA_WIDTH);     -- default number of datasets to acquire
            usr_adout_sel <= "00";          -- don't send ADC data
            usr_use_full_fft <= '0';        -- use half spectrum as default 
            usr_uart_tx_rdy <= '0';         -- clear ready signal
            enable_muxes <= '0';            -- disable muxes
            n_mux_enable <= (others => '0');
            mux_sel <= (others => '0');     -- reset muxes
            pga_sel <= (others => '0');     -- reset pga gains to 1
            n_pga_set_gain <= (others => '1');          -- pulse to top level controller to set pgas
            freq_sel <= (others => '0');    -- reset dds freqs
            usr_freq_sweep_en <= '0';       -- disable frequency sweep
            usr_dual_dds_en <= '0';         -- disable dualtone dds
            usr_dds_div_val <= (others => '0');         -- default dds "divide by" selection
            usr_lvds_testpat <= '0';        -- ADC testpattern off
            usr_adc_debug_mode <= '0';      -- disable debug mode
            usr_adc_pwr_dwn <= '0';         -- ADCs on
            uart_rx_state <= WaitRx;
                
        when others =>
            uart_rx_state <= WaitRx;
    end case;
end if;

end process uart_rx_fsm;    


----------------------------------------------------------
-- Clock outputs for high fanout signal timing
latch_outputs : process(clk)
begin

if rising_edge(clk) then
    reset_n <= not reset;   -- active low reset
    usr_reset <= reset;
    usr_enable <= enable;
    usr_mux_sel <= mux_sel;
    usr_freq_sel <= freq_sel;
    usr_pga_sel <= pga_sel;
    usr_pga_set_gain <= n_pga_set_gain;
    navgsxsets <= naverages*ndatasets;
    usr_naverages <= TO_INTEGER(navgsxsets);
    
    if (enable_muxes = '1') then 
        usr_mux_en <= n_mux_enable; 
    else 
        usr_mux_en <= (others => '0');
    end if;
end if;

end process latch_outputs;
----------------------------------------------------------
--reset_n <= not reset;   -- active low reset
--usr_reset <= reset;
--usr_enable <= enable;
--usr_mux_sel <= mux_sel;
--usr_mux_en <= n_mux_enable when enable_muxes = '1' else (others => '0');
--usr_freq_sel <= freq_sel;
--usr_pga_sel <= pga_sel;
--usr_pga_set_gain <= n_pga_set_gain;
--usr_naverages <= naverages*ndatasets;

end Behavioral;
