----------------------------------------------------------------------------
--	ORIGINAL FILE: UART_TX_CTRL.vhd -- UART Data Transfer Component
--  Updated 02/07/2022 by Kendall Farnham (see Revision notes)
----------------------------------------------------------------------------
-- Author:  Sam Bobrowicz
--          Copyright 2011 Digilent, Inc.
----------------------------------------------------------------------------
--
----------------------------------------------------------------------------
--	This component may be used to transfer data over a UART device. It will
-- serialize a byte of data and transmit it over a TXD line. The serialized
-- data has the following characteristics:
--         *256000 Baud Rate
--         *8 data bits, LSB first
--         *1 stop bit
--         *no parity
--         				
-- Port Descriptions:
--
--    send_en - Used to trigger a send operation. The upper layer logic should 
--           set this signal high for a single clock cycle to trigger a 
--           send. When this signal is set high data_in must be valid . Should 
--           not be asserted unless READY is high.
--    data_in - The parallel data to be sent. Must be valid the clock cycle
--           that send_en has gone high.
--    clk  - A 100 MHz clock is expected
--   READY - This signal goes low once a send operation has begun and
--           remains low until it has completed and the module is ready to
--           send another byte.
-- UART_TX - This signal should be routed to the appropriate TX pin of the 
--           external UART device.
--   
----------------------------------------------------------------------------
--
----------------------------------------------------------------------------
-- Revision History:
--  08/08/2011(SamB): Created using Xilinx Tools 13.2
--  02/07/2022 : edited by Kendall Farnham 
--        --> separated combinational logic from state update, combined clocked processes
--            baud rate increased to 256000 (from 9600)
--  7/13/2023 Copied from 2023_DAQ_64ch_v2.srcs (UART_TX_CTRL.vhd)
----------------------------------------------------------------------------
-- https://reference.digilentinc.com/learn/programmable-logic/tutorials/arty-general-io-demo/start
----------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.std_logic_unsigned.all;

entity uart_tx_8b is
    Generic ( DEBUG_MODE : std_logic := '0');
    Port ( send_en : in  STD_LOGIC;
           data_in : in  STD_LOGIC_VECTOR (7 downto 0);
           clk : in  STD_LOGIC;
           ready : out  STD_LOGIC;
           uart_tx_out : out  STD_LOGIC);
end uart_tx_8b;

architecture Behavioral of uart_tx_8b is

type state_type is (ReadyState, LoadBit, SendBit);

constant BIT_INDEX_MAX : natural := 10;
constant BIT_TMR_BAUD : std_logic_vector(8 downto 0) := "110000110";   -- 390 = (round(100MHz / 256000)) - 1
constant BIT_TMR_SIM : std_logic_vector(8 downto 0) := "000000011";   -- USE IN SIMULATION

--Counter for number of clock cycles the current bit has been held over the uart_tx line
signal BIT_TMR_MAX : std_logic_vector(8 downto 0) := (others => '0');
signal bit_timer : std_logic_vector(8 downto 0) := (others => '0');
signal bit_done : std_logic := '0';

--Contains the index of the next bit in tx_data_reg that needs to be transferred 
signal bit_index : natural;

--a register that holds the current data being sent over the UART TX line
signal tx_bit : std_logic := '1';

--A register that contains the whole data packet to be sent, including start and stop bits. 
signal tx_data_reg : std_logic_vector(BIT_INDEX_MAX-1 downto 0);

signal tx_state : state_type := ReadyState;

begin
---------------------------------------------
-- FSM: Original logic from UART_TX_CONTROLLER.vhd
--------------------------------------------- 
--Next state logic
next_state_process : process (clk)
begin
	if (rising_edge(clk)) then
		case tx_state is 
		when ReadyState =>
			if (send_en = '1') then
				tx_state <= LoadBit;
			end if;
		when LoadBit =>
			tx_state <= SendBit;
		when SendBit =>
			if (bit_done = '1') then
				if (bit_index = BIT_INDEX_MAX) then
					tx_state <= ReadyState;
				else
					tx_state <= LoadBit;
				end if;
			end if;
		when others=> --should never be reached
			tx_state <= ReadyState;
		end case;
	end if;
end process next_state_process;
---------------------------------------------
bit_timing_process : process (clk)
begin
	if (rising_edge(clk)) then
		if (tx_state = ReadyState) then
			bit_timer <= (others => '0');
		else
			if (bit_done = '1') then
				bit_timer <= (others => '0');
			else
				bit_timer <= bit_timer + 1;
			end if;
		end if;
	end if;
end process bit_timing_process;
---------------------------------------------
bit_counting_process : process (clk)
begin
	if (rising_edge(clk)) then
		if (tx_state = ReadyState) then
			bit_index <= 0;
		elsif (tx_state = LoadBit) then
			bit_index <= bit_index + 1;
		end if;
	end if;
end process bit_counting_process;
---------------------------------------------
tx_data_latch_process : process (clk)
begin
	if (rising_edge(clk)) then
		if (send_en = '1') then
			tx_data_reg <= '1' & data_in & '0';
		end if;
	end if;
end process tx_data_latch_process;
---------------------------------------------
tx_bit_process : process (clk)
begin
	if (rising_edge(clk)) then
		if (tx_state = ReadyState) then
			tx_bit <= '1';
		elsif (tx_state = LoadBit) then
			tx_bit <= tx_data_reg(bit_index);
		end if;
	end if;
end process tx_bit_process;
---------------------------------------------
-- Set bit timer max value
BIT_TMR_MAX <= BIT_TMR_SIM when DEBUG_MODE = '1' else BIT_TMR_BAUD;
---------------------------------------------
-- Connect to output ports
uart_tx_out <= tx_bit;  
bit_done <= '1' when (bit_timer = BIT_TMR_MAX) else '0';
ready <= '1' when (tx_state = ReadyState) else '0';

---------------------------------------------
end Behavioral;

