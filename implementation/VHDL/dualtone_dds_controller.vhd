----------------------------------------------------------------------------------
-- Company: Thayer School of Engineering, Dartmouth College
-- Engineer: Kendall Farnham
-- 
-- Create Date: 07/13/2023
-- Design Name: 
-- Module Name: dualtone_dds_controller - Behavioral
-- Project Name: 2023_DAQ
-- Target Devices: Artix 7 (Trenz Electronics TE0711-01)
-- Tool Versions: Vivado 2022.2
-- Description: Implement dual-tone DDS output
-- 
-- Dependencies: dds_compiler_1
-- 
-- Revision 0.01 - 01/31/2022 File Created
-- Rev 0.1: streaming_dds_controller2, multitone_controller (multitone_impl_v6 project)
-- Rev 1.1: multitone_dds_controller (2021_08_DAQ_noLVDS project)
-- Rev 1.2: updated multitone_dds_controller logic for more flexibility
        -- constants not hard-coded anymore
        -- removed set_phase entity input - logic included internally
-- Rev 1.3: added fftclk input to count NFFT cycles at the fft sampling rate instead of dclk
-- Rev 1.4: separated combinational logic from state update
-- Rev 2.0: using 125 MHz dclk and 15 MHz aclk
        -- adjusted sample counter to 4*NFFT for correct phase at dds_out_last
        -- consolidated sample counting into one process
-- Rev 2.01 - 7/13/2023 Copied from 2023_DAQ_64ch_v2.srcs
----------------------------------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.numeric_std.all;
use IEEE.std_logic_signed.all;

entity dualtone_dds_controller is
    GENERIC(
        SLOW_SAMP_CLKDIV : integer := 128; -- multiply sample counter for slow_dds_out_last pulse
        NFFT : integer := 1024;        -- size of FFT 
        PHASE_WIDTH : integer := 32;   -- number of bits in phase control
        DDS_BITS :    INTEGER := 14);  -- size of dds_out bus
Port ( dclk : in STD_LOGIC;            -- DDS clock
       fftclk : in STD_LOGIC;          -- ADC sampling clock to sync FFT to correct phase
       enable : in STD_LOGIC;
       reset : in STD_LOGIC;
       phase_freq_A : in STD_LOGIC_VECTOR(2*PHASE_WIDTH-1 downto 0);   -- phase offset (MSB) and frequency (LSB) for ddsA
       phase_freq_B : in STD_LOGIC_VECTOR(2*PHASE_WIDTH-1 downto 0);   -- phase offset (MSB) and frequency (LSB) for ddsB
       dds_out_valid : out STD_LOGIC;       -- dds output is valid
       dds_out_last : out STD_LOGIC;        -- pulse at the start of the dds signal (with respect to phase), every NFFT samples 
       slow_dds_out_last : out STD_LOGIC;   -- pulse at start of dds signal every NFFT*SLOW_SAMP_CLKDIV samples
       dds_out: out STD_LOGIC_VECTOR (DDS_BITS-1 downto 0));
end dualtone_dds_controller;

architecture Behavioral of dualtone_dds_controller is

-----------------------------------------------------------------------
-- Signals to count data samples for dds_out_last flag
constant DDS_IP_PHASE_TDATA_WIDTH : integer := 48;  -- number of bits in dds compiler's s_axis_phase_tdata vector
constant NDDS : integer := 4*NFFT;   -- number of samples (clocked on fftclk) until phase of output is correct (matches input to dds core)
signal slow_sample_cnt : integer range 0 to SLOW_SAMP_CLKDIV-1 := 0; -- use for sync pulse (slow_dds_out_last)
signal sample_cnt : natural range 0 to NDDS-1 := 0; -- use for sync pulse (dds_out_last)

-----------------------------------------------------------------------
-- Signals for logic
signal dds_valid, phase_change : std_logic := '0';
signal phase_freq_A_prev, phase_freq_B_prev : STD_LOGIC_VECTOR(2*PHASE_WIDTH-1 DOWNTO 0) := (others => '0'); 
-----------------------------------------------------------------------
 -- Signals for FSM
 type state_type is (Idle, Reset1, Reset2, RunDDS);
 signal dds_state : state_type := Idle;

-----------------------------------------------------------------------
-- Signals to connect to dds ports
-- Inputs
signal aresetn                         : std_logic := '1';  -- synchronous active low reset, overrides aclken
signal s_axis_phase_tvalid             : std_logic := '0';  -- payload is valid
signal s_axis_phase_tdataA             : std_logic_vector(DDS_IP_PHASE_TDATA_WIDTH-1 downto 0) := (others => '0');  -- data payload 
signal s_axis_phase_tdataB             : std_logic_vector(DDS_IP_PHASE_TDATA_WIDTH-1 downto 0) := (others => '0');  -- data payload 

-- Data master channel signals ddsA
signal m_axis_data_tvalidA              : std_logic := '0';  -- payload is valid
signal m_axis_data_tdataA               : std_logic_vector(15 downto 0) := (others => '0');  -- data payload

-- Data master channel signals ddsB
signal m_axis_data_tvalidB              : std_logic := '0';  -- payload is valid
signal m_axis_data_tdataB               : std_logic_vector(15 downto 0) := (others => '0');  -- data payload
 
-----------------------------------------------------------------------
-- Initiate DDS Core
COMPONENT dds_compiler_0
  PORT (
    aclk : IN STD_LOGIC;
    aresetn : IN STD_LOGIC;
    s_axis_phase_tvalid : IN STD_LOGIC;
    s_axis_phase_tdata : IN STD_LOGIC_VECTOR(DDS_IP_PHASE_TDATA_WIDTH-1 DOWNTO 0);
    m_axis_data_tvalid : OUT STD_LOGIC;     
    m_axis_data_tdata : OUT STD_LOGIC_VECTOR(15 DOWNTO 0)
  );
END COMPONENT;
 -----------------------------------------------------------------------
 begin
-----------------------------------------------------------------------
-- NOTE:
-- s_axis_frequency <= s_axis_phase_tdata(PHASE_WIDTH-1 downto 0);
-- s_axis_offset <= s_axis_phase_tdata(2*PHASE_WIDTH-1 downto PHASE_WIDTH);

-----------------------------------------------------------------------
ddsA : dds_compiler_0
port map (
     aclk                             => dclk
     ,aresetn                         => aresetn
     ,s_axis_phase_tvalid             => s_axis_phase_tvalid   
     ,s_axis_phase_tdata              => s_axis_phase_tdataA    -- phase offset (MSB) and frequency (LSB)
     ,m_axis_data_tvalid              => m_axis_data_tvalidA
     ,m_axis_data_tdata               => m_axis_data_tdataA
);
-----------------------------------------------------------------------
ddsB : dds_compiler_0
port map (
     aclk                             => dclk
     ,aresetn                         => aresetn
     ,s_axis_phase_tvalid             => s_axis_phase_tvalid
     ,s_axis_phase_tdata              => s_axis_phase_tdataB    -- phase offset (MSB) and frequency (LSB)
     ,m_axis_data_tvalid              => m_axis_data_tvalidB
     ,m_axis_data_tdata               => m_axis_data_tdataB
 );

-----------------------------------------------------------------------
dds_out_valid <= dds_valid; -- connect to port (need to use variable for sample count logic)
-----------------------------------------------------------------------
-- Count NDDS cycles (at fft sampling rate) to sync fft to dds
-- Pulse dds_out_last high on last dds sample of the period
-- Pulse slow_dds_out_last high on last dds sample for the slower sampling rate
dds_sync_proc : process(fftclk)
begin
if (rising_edge(fftclk)) then
 
    -- pulse high on last sample of the sine wave period
    slow_dds_out_last <= '0';   -- defaults
    dds_out_last <= '0';
 
    -- count ADC/FFT samples
    if (dds_valid = '0') then   -- reset sample counters
        slow_sample_cnt <= 0;    
        sample_cnt <= 0;
    else                        -- count samples
        sample_cnt <= sample_cnt + 1;   -- increment NDDS sample counter
        if (sample_cnt = NDDS-3) then       
            dds_out_last <= '1';        -- signal for end of dds period (NDDS samples)
            slow_sample_cnt <= slow_sample_cnt + 1; -- increment SLOW_SAMP_CLKDIV counter
            if (slow_sample_cnt = SLOW_SAMP_CLKDIV-1) then
                slow_sample_cnt <= 0;       -- reset counter
                slow_dds_out_last <= '1';   -- pulse high for last sample using slow fs (NDDS*SLOW_SAMP_CLKDIV samples)
            end if;
        elsif (sample_cnt = NDDS-1) then
            sample_cnt <= 0;    -- reset counter
        end if;
    end if;
    
 
 end if;
 end process dds_sync_proc;
 
-----------------------------------------------------------------------
comb_logic: process(dclk)
begin

if rising_edge(dclk) then
     -- Defaults
     aresetn <= not reset;
     s_axis_phase_tvalid <= '0';
  
  
    if reset = '1' then
        dds_state <= Reset1;
    else
        -- Combinational Logic
        case dds_state is   
            when Idle => 
                 if (enable = '1' or reset = '1' or phase_change = '1') then 
                    dds_state <= Reset1;
                 end if;
         
             when Reset1 =>         
                 aresetn <= '0';
                 if reset = '0' then 
                    dds_state <= Reset2;    -- hold reset low for 2 clock cycles
                 end if;        
                          
             when Reset2 =>
                 aresetn <= '0';
                if enable = '1' then
                    dds_state <= RunDDS;
                else
                    dds_state <= Idle;
                end if;

             when RunDDS =>
                 s_axis_phase_tvalid <= '1';        -- set phase
                 if enable = '0' then 
                    dds_state <= Idle;
--                 elsif phase_change = '1' then 
--                    dds_state <= Reset1; -- reset to resync both dds
                 end if;                 
                 
             when others => dds_state <= Idle;
         end case;
     end if;
 end if;
 end process comb_logic;
 -----------------------------------------------------------------------
 -----------------------------------------------------------------------
 -- Check for change in frequency or phase selection
 -- phase_change flag forces reset for resyncing dds_compiler's
 reset_phase_proc : process(dclk)
 begin
 if (rising_edge(dclk)) then
 
    -- Check if phase_freq has changed for either DDS
    if (phase_freq_A_prev /= phase_freq_A) or (phase_freq_B_prev /= phase_freq_B) then
        phase_change <= '1';
    else
        phase_change <= '0';
    end if;
    
    -- Save last value
    phase_freq_A_prev <= phase_freq_A;
    phase_freq_B_prev <= phase_freq_B;
    
    -- Update dds_compiler inputs --> phase offset in MSBs, freq in LSBs
    s_axis_phase_tdataA(DDS_IP_PHASE_TDATA_WIDTH/2+PHASE_WIDTH-1 downto DDS_IP_PHASE_TDATA_WIDTH/2) <=
        phase_freq_A(2*PHASE_WIDTH-1 downto PHASE_WIDTH);
    s_axis_phase_tdataA(PHASE_WIDTH-1 downto 0) <= phase_freq_A(PHASE_WIDTH-1 downto 0);
    s_axis_phase_tdataB(DDS_IP_PHASE_TDATA_WIDTH/2+PHASE_WIDTH-1 downto DDS_IP_PHASE_TDATA_WIDTH/2) <=
        phase_freq_B(2*PHASE_WIDTH-1 downto PHASE_WIDTH);
    s_axis_phase_tdataB(PHASE_WIDTH-1 downto 0) <= phase_freq_B(PHASE_WIDTH-1 downto 0); 
    
 end if;
 end process reset_phase_proc;
 
 -----------------------------------------------------------------------
 -- Clock-driven multi-tone DDS output to port
 dds_output: process(dclk)
    variable sine_AB : std_logic_vector(DDS_BITS downto 0) := (others => '0');  -- data payload ddsA + ddsB (extra bit)
 begin
 
 if rising_edge(dclk) then
 
    if (enable = '0' or reset = '1' or phase_change = '1') then -- next clock cycle will be Idle or Reset state, turn off output
        dds_valid <= '0';
        dds_out <= (others => '0');
    elsif (dds_state = RunDDS) then   -- in RunDDS state, assign outputs
        if (phase_freq_A(PHASE_WIDTH-1 downto 0) > 0 and 
            phase_freq_B(PHASE_WIDTH-1 downto 0) > 0) then   -- dual-tone signal, amplitudes halved to avoid overflow
            sine_AB := std_logic_vector(  -- add the sine waves -- extra bit to avoid overflow
                  signed(std_logic_vector(resize(signed(m_axis_data_tdataA(DDS_BITS-1 downto 0)),sine_AB'length))) + 
                  signed(std_logic_vector(resize(signed(m_axis_data_tdataB(DDS_BITS-1 downto 0)),sine_AB'length)))); 
            dds_out <= sine_AB(DDS_BITS downto 1);    -- remove LSB for 14-bit output
            dds_valid <= m_axis_data_tvalidA and m_axis_data_tvalidB; -- master (output) data is valid
            
        elsif (phase_freq_A(PHASE_WIDTH-1 downto 0) > 0) then  -- phase_freq_B = 0 so ddsB is off
            dds_out <= m_axis_data_tdataA(DDS_BITS-1 downto 0);    -- full-scale monotone output
            dds_valid <= m_axis_data_tvalidA;
            
        elsif (phase_freq_B(PHASE_WIDTH-1 downto 0) > 0) then  -- phase_freq_A = 0 so ddsA is off
            dds_out <= m_axis_data_tdataB(DDS_BITS-1 downto 0);    -- full-scale monotone output
            dds_valid <= m_axis_data_tvalidB;
            
        else
            dds_out <= (others => '0'); -- both dds are off
            dds_valid <= '0';
        end if;
    else   -- if in Reset or Idle state, turn off output
        dds_valid <= '0';
        dds_out <= (others => '0');
    end if;
 end if;
 
 end process dds_output;
 -----------------------------------------------------------------------



end Behavioral;
