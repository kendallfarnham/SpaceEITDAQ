----------------------------------------------------------------------------------
-- Company: Thayer School of Engineering, Dartmouth College
-- Engineer: Kendall Farnham
-- 
-- Create Date: 07/13/2023
-- Design Name: 
-- Module Name: fft_controller - Behavioral
-- Project Name: 2023_DAQ
-- Target Devices: Artix 7 (Trenz Electronics TE0711-01)
-- Tool Versions: Vivado 2022.2
-- Description: Compute forward FFT using IP core
-- 
-- Dependencies: xfft_1 (XFFT IP core)
-- 
-- Revision 0.01 - 10/05/2020 File Created
-- Revision 1.0 - added in event catch logic to reconfigure on error 
-- Revision 1.01 - 7/13/2023 Copied from 2023_DAQ_64ch_v2.srcs
-- 
----------------------------------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;


entity fft_controller is
Generic (
    FFT_DATA_WIDTH : integer := 16;    -- size of fft_out bus
    FFT_BIN_WIDTH : INTEGER := 10);     -- 2**FFT_BIN_WIDTH number of bins 
Port ( clk : in STD_LOGIC;     -- fast clock for fft
       enable : in STD_LOGIC;       -- enable fft core
       reset : in STD_LOGIC;        -- reconfigure fwd fft and reset
       data_in : in STD_LOGIC_VECTOR (FFT_DATA_WIDTH-1 downto 0);
       data_in_valid : in STD_LOGIC;    -- enable input to FFT (s_axis_data_tvalid)
       data_in_last : in STD_LOGIC;     -- use to synchronize dds/adc input to fft
       fft_rx_ready : in STD_LOGIC;     -- enable output (m_axis_data_tready)
       re_out : out STD_LOGIC_VECTOR (FFT_DATA_WIDTH-1 downto 0);
       im_out : out STD_LOGIC_VECTOR (FFT_DATA_WIDTH-1 downto 0);
       bin: out STD_LOGIC_VECTOR (FFT_BIN_WIDTH-1 downto 0); -- fft bin number
       fft_failed : out STD_LOGIC;  -- high when error event occurs
       fft_ready : out STD_LOGIC;
       send_last : out STD_LOGIC);
end fft_controller;

architecture Behavioral of fft_controller is

---------------------------------------------------------
COMPONENT xfft_0
  PORT (
    aclk : IN STD_LOGIC;
    aresetn : IN STD_LOGIC;
    s_axis_config_tdata : IN STD_LOGIC_VECTOR(15 DOWNTO 0);
    s_axis_config_tvalid : IN STD_LOGIC;
    s_axis_config_tready : OUT STD_LOGIC;
    s_axis_data_tdata : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
    s_axis_data_tvalid : IN STD_LOGIC;
    s_axis_data_tready : OUT STD_LOGIC;
    s_axis_data_tlast : IN STD_LOGIC;
    m_axis_data_tdata : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
    m_axis_data_tuser : OUT STD_LOGIC_VECTOR(15 DOWNTO 0);
    m_axis_data_tvalid : OUT STD_LOGIC;
    m_axis_data_tlast : OUT STD_LOGIC;
    event_frame_started : OUT STD_LOGIC;
    event_tlast_unexpected : OUT STD_LOGIC;
    event_tlast_missing : OUT STD_LOGIC;
    event_data_in_channel_halt : OUT STD_LOGIC
  );
END COMPONENT;
-----------------------------------------------------------------------
-----------------------------------------------------------------------
-- Signals
-----------------------------------------------------------------------
constant NFFT : integer := 2**FFT_BIN_WIDTH;    -- number of bins in FFT

-- Signals for FSM
type state_type is (Start, Config, Idle, WaitRead, ReadData, DoneRead, ComputeFFT, 
        SendData, EventCatch, ResetCore0, ResetCore1, DisableCore);
signal curr_state, next_state : state_type := Start;
signal send_done, config_fwd_fft, event_catch : std_logic := '0';

-----------------------------------------------------------------------
-- FFT Signals
signal fft_ip_clken, fft_ip_resetn : std_logic := '1';
-- Config slave channel signals
signal s_axis_config_tvalid        : std_logic := '0';  -- payload is valid
signal s_axis_config_tready        : std_logic := '0';  -- slave is ready
signal s_axis_config_tdata         : std_logic_vector(15 downto 0) := (others => '0');  -- data payload

-- Data slave channel signals
signal s_axis_data_tvalid          : std_logic := '0';  -- payload is valid
signal s_axis_data_tready          : std_logic := '1';  -- slave is ready
signal s_axis_data_tdata           : std_logic_vector(31 downto 0) := (others => '0');  -- data payload
signal s_axis_data_tlast           : std_logic := '0';  -- indicates end of packet

-- Data master channel signals
signal m_axis_data_tvalid          : std_logic := '0';  -- payload is valid
--signal m_axis_data_tready          : std_logic := '1';  -- slave is ready
signal m_axis_data_tdata           : std_logic_vector(31 downto 0) := (others => '0');  -- data payload
signal m_axis_data_tlast           : std_logic := '0';  -- indicates end of packet
signal m_axis_data_tuser           : std_logic_vector(15 downto 0) := (others => '0');  -- user-defined payload

-- Event signals
signal event_frame_started         : std_logic := '0';
signal event_tlast_unexpected      : std_logic := '0';
signal event_tlast_missing         : std_logic := '0';
signal event_status_channel_halt   : std_logic := '0';
signal event_data_in_channel_halt  : std_logic := '0';
signal event_data_out_channel_halt : std_logic := '0';

begin
-----------------------------------------------------------------------
-- Instantiate FFT IP core
-----------------------------------------------------------------------
fft : xfft_0
    port map (
  aclk                        => clk,
  --aclken                      => fft_ip_clken,
  aresetn                     => fft_ip_resetn,
  s_axis_config_tvalid        => s_axis_config_tvalid,
  s_axis_config_tready        => s_axis_config_tready,
  s_axis_config_tdata         => s_axis_config_tdata,
  s_axis_data_tvalid          => s_axis_data_tvalid,
  s_axis_data_tready          => s_axis_data_tready,
  s_axis_data_tdata           => s_axis_data_tdata,
  s_axis_data_tlast           => s_axis_data_tlast,
  m_axis_data_tvalid          => m_axis_data_tvalid,
  m_axis_data_tdata           => m_axis_data_tdata,
  m_axis_data_tuser           => m_axis_data_tuser,
  m_axis_data_tlast           => m_axis_data_tlast,
  event_frame_started         => event_frame_started,
  event_tlast_unexpected      => event_tlast_unexpected,
  event_tlast_missing         => event_tlast_missing,
  event_data_in_channel_halt  => event_data_in_channel_halt
  );

-----------------------------------------------------------------------
-- Configure the FFT Core to FWD
-- Config state process, configuration independent of sampling data
config_fwd: process(clk)
begin

if rising_edge(clk) then
    s_axis_config_tdata(10 downto 0) <= "10101010111"; -- FWD FFT, Default scaling
    --s_axis_config_tdata(0) <= '1';      -- FWD FFT, zero scaling
    s_axis_config_tvalid <= '0'; -- Default
    
    if (curr_state = Config) then   -- configure fft scaling inputs
        config_fwd_fft <= '1';      -- flag high when get to Config state
        s_axis_config_tvalid <= '1';

     elsif (config_fwd_fft = '1' and s_axis_config_tready = '0') then -- still waiting to configure fft
        s_axis_config_tvalid <= '1'; -- hold high
        
     elsif (config_fwd_fft = '1' and s_axis_config_tready = '1') then -- finished config
        config_fwd_fft <= '0';      -- set flag low when finished config
     
     end if;
end if;
end process config_fwd;

-----------------------------------------------------------------------
-- Connect data input to FFT input - begin transform!
-- ReadData state process
read_data_in: process(clk)
begin

if rising_edge(clk) then
    if (curr_state = ReadData) then 
        s_axis_data_tlast <= data_in_last;
    else
        s_axis_data_tlast <= '0';
    end if;
    
    -- Send data to fft input
    if (curr_state = ReadData or next_state = ReadData) then -- signals set for start of ReadData state
        s_axis_data_tdata(31 downto 16) <= (others => '0'); -- imaginary data in
        s_axis_data_tdata(15 downto 0) <= data_in;          -- real data in
        s_axis_data_tvalid <= data_in_valid;                -- data is valid
    else
        s_axis_data_tdata <= (others => '0'); 
        s_axis_data_tvalid <= '0'; -- deassert tvalid
    end if;
    
end if;
end process read_data_in;

-----------------------------------------------------------------------
-- Send transform data
-- SendData state process
fft_rx_ready_out: process(clk)
begin

if rising_edge(clk) then
    if (curr_state = SendData or next_state = SendData) then
        re_out <= m_axis_data_tdata(15 downto 0); 
        im_out <= m_axis_data_tdata(31 downto 16);
        bin <= m_axis_data_tuser(FFT_BIN_WIDTH-1 downto 0);
        send_last <= m_axis_data_tlast;
    else
        re_out <= (others => '0'); 
        im_out <= (others => '0'); 
        bin <= (others => '0'); 
        send_last <= '0'; 
    end if;
    
    if (m_axis_data_tlast = '1') then 
        send_done <= '1';       -- signal to switch states in FSM 
    else
        send_done <= '0';
    end if;
    
end if;
end process fft_rx_ready_out;
-----------------------------------------------------------------------
-- Catch error events
fft_event_catch: process(event_frame_started,event_tlast_unexpected,event_tlast_missing,event_data_in_channel_halt)
begin

if (event_tlast_unexpected = '1' or event_tlast_missing = '1' or event_data_in_channel_halt = '1') then
    event_catch <= '1';
else
    event_catch <= '0';
end if;

end process fft_event_catch;
-----------------------------------------------------------------------
---- FFT IP core clock enable and reset
--fft_ip_clken <= '1';        -- always enable
--fft_ip_resetn <= '1';       -- never reset
-----------------------------------------------------------------------
-- FFT IP core clock enable and reset (resetn must be held low for 2 clock cycles)
fft_ip_reset_extend : process(clk)
begin
    if rising_edge(clk) then
        -- reset core
        if (curr_state = ResetCore0 or curr_state = ResetCore1) then
            fft_ip_resetn <= '0';   -- active low reset
        else
            fft_ip_resetn <= '1';   -- not reset (active low input)
        end if;
        
        fft_ip_clken <= '1';   -- enable
        -- enable core when controller is enabled or to reset and reconfigure
--        if (curr_state = DisableCore) then
--            fft_ip_clken <= '0';   -- disable
--        else
--            fft_ip_clken <= '1';   -- enable
--        end if;
    end if;
end process;
-----------------------------------------------------------------------
-- Combinational logic
comb_logic: process(curr_state, reset, enable, data_in_valid, data_in_last, m_axis_data_tvalid,
        fft_rx_ready, send_done, s_axis_data_tready, s_axis_config_tready, event_catch)
begin

-- Defaults
next_state <= curr_state;   
fft_ready <= '0';   -- not ready while configuring/computing fft
fft_failed <= '0';  -- high only in EventCatch state

-- Combinational Logic
if (reset = '1') then
    next_state <= ResetCore0;    -- reset and reconfigure ip core 
elsif (enable = '0') then   
    next_state <= DisableCore;  -- wait until re-enabled
elsif (event_catch = '1') then
    next_state <= EventCatch;   -- output error signal to top module
else
    case curr_state is
        when Start =>
            if (s_axis_config_tready = '1') then
                next_state <= Config;
            end if;
        
        when DisableCore =>
            if (enable = '1') then
                next_state <= Idle; -- re-enable
            end if;
                
        when ResetCore0 =>          -- hold ip core reset low for 2 clock cycles
            next_state <= ResetCore1;   
                        
        when ResetCore1 =>          -- hold ip core reset low for 2 clock cycles
            next_state <= Config;   -- reconfigure after reset 
                        
        when Config =>
            next_state <= Idle;
        
        when Idle =>    -- Note: data_in_valid takes precedent over send_data
            fft_ready <= '1';
            if (data_in_valid = '1' and s_axis_data_tready = '1') then  -- ready to read
                next_state <= ReadData;     -- wait until the start of period before reading data
            end if;
            
        when ReadData =>
            fft_ready <= s_axis_data_tready;    -- hook up to slave ready signal
            if (data_in_last = '1') then
                next_state <= DoneRead;         -- compute fft with samples given, wait one clock cycle 
            elsif (data_in_valid = '0') then
                next_state <= Idle;             -- start over, not all data read is valid
            end if;
        
        when DoneRead =>    -- wait for m_axis_data_tvalid to go low
            if (m_axis_data_tvalid = '0') then
                next_state <= ComputeFFT;
            end if;
           
        when ComputeFFT =>
            fft_ready <= m_axis_data_tvalid;    -- hook up to master ready signal 
            if (m_axis_data_tvalid = '1' and fft_rx_ready = '1') then -- wait until fft is complete
                next_state <= SendData;
            end if;
            
        when SendData =>
            fft_ready <= m_axis_data_tvalid;    -- hook up to master ready signal
            if (send_done = '1') then
                next_state <= Idle;
            end if;
               
        when EventCatch =>
            fft_failed <= '1';      -- output to top module
            next_state <= Config;
            
        when others => next_state <= Config; -- should never reach
    end case;
end if;
end process comb_logic;

-----------------------------------------------------------------------
state_update: process(clk)
begin
if rising_edge(clk) then
    curr_state <= next_state;
end if;
end process state_update;
-----------------------------------------------------------------------


end Behavioral;