----------------------------------------------------------------------------------
-- Company: Thayer School of Engineering, Dartmouth College
-- Engineer: Kendall Farnham
-- 
-- Create Date: 07/13/2023
-- Design Name: 
-- Module Name: uart_controller_8b - Behavioral
-- Project Name: 2023_DAQ
-- Target Devices: Artix 7 (Trenz Electronics TE0711-01)
-- Tool Versions: Vivado 2022.2
-- Description: sends binary data over UART, sends LSByte first , MSByte last
-- 
-- Dependencies: 
-- 
-- Revision:
-- Revision 0.01 - 12/05/2020 File Created (uart_controller_bin.vhd)
--          1.0  - 02/07/2022: using edited uart_tx.vhd in place of UART_TX_CTRL.vhd
--          2.0  - 02/22/2022: changed to uart transceiver code (receiver commented out)
--          2.01 - 7/13/2023 Copied from 2023_DAQ_64ch_v2.srcs
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use ieee.numeric_std.all;


entity uart_controller_8b is
    GENERIC(
    DEBUG_MODE : std_logic := '0';
    DATA_WIDTH    :    INTEGER := 32);  --size of the binary input numbers in bits
Port ( clk : in std_logic;              -- 100 MHz clock
       data_in : in std_logic_vector(DATA_WIDTH-1 downto 0);    -- input from BRAM
       enable_uart_tx : in std_logic;   -- write data_in to uart
       done_tx : out std_logic;         -- finished transfer
       uart_txd : out std_logic);       -- UART out
end uart_controller_8b;

architecture Behavioral of uart_controller_8b is
-- Constants
constant NBYTES : integer := DATA_WIDTH/8;

-- FSM signals
type state_type is (WaitReady, Ready, SendByte, NextByte, WaitSend);
signal curr_state, next_state : state_type := Ready;
signal byte_ctr : integer range 0 to NBYTES := 0;
signal data_shift : std_logic_vector(DATA_WIDTH-1 downto 0);

--UART_TX_CTRL control signals
signal uart_ready : std_logic := '0';
signal uart_send_en : std_logic := '0';
signal uart_data_byte : std_logic_vector (7 downto 0):= "00000000";
-------------------------------------------
component uart_tx_8b
Generic ( DEBUG_MODE : std_logic := DEBUG_MODE);
Port ( send_en : in  STD_LOGIC;
       data_in : in  STD_LOGIC_VECTOR (7 downto 0);
       clk : in  STD_LOGIC;
       ready : out  STD_LOGIC;
       uart_tx_out : out  STD_LOGIC);
end component;
---------------------------------------------------------
begin
---------------------------------------------------------
-- Map ports
uart_tx_8bit_inst: uart_tx_8b port map(
    send_en => uart_send_en,
    data_in => uart_data_byte,
    clk => clk,
    ready => uart_ready,
    uart_tx_out => uart_txd -- direct to output port
);

-----------------------------------------------------------------------																   
-- Shift register
-----------------------------------------------------------------------
shift_data_byte: process(clk)
begin

if rising_edge(clk) then
    case curr_state is
        when Ready =>
            data_shift <= data_in;
            byte_ctr <= 0;  -- reset counter
        
        when NextByte =>
             data_shift <= "00000000" & data_shift(DATA_WIDTH-1 downto 8); -- shift down 1 byte
             byte_ctr <= byte_ctr + 1;  -- increment
             
        when others =>
    end case;
end if;
end process shift_data_byte;
-----------------------------------------------------------------------
uart_data_byte <= data_shift(7 downto 0); -- LSByte
-----------------------------------------------------------------------
-- FSM
-----------------------------------------------------------------------
comb_logic: process(curr_state, enable_uart_tx, uart_ready)
begin

-- Defaults
next_state <= curr_state;   
done_tx <= '0';
uart_send_en <= '0';
 
-- Combinational Logic
case curr_state is    
    when Ready =>
       done_tx <= '1';
       if (enable_uart_tx = '1') then
           next_state <= SendByte;
       end if;
          
   when SendByte =>
       uart_send_en <= '1';    -- single clock cycle pulse
       next_state <= WaitSend;        
        
    when WaitSend =>      -- wait for uart_ready to go low (operation has started)
       if (uart_ready = '0') then
           next_state <= WaitReady;
       end if;
     
    when WaitReady =>   -- wait for uart_ready to go high (operation complete)
       if (uart_ready = '1') then
           if (byte_ctr = NBYTES-1) then
               next_state <= Ready;
           else
               next_state <= NextByte;
           end if;
       end if;
     
   when NextByte =>
       next_state <= SendByte;
        
   when others => next_state <= Ready;
end case;
 
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
