--------------------------------------------------------------------------------
--
--   FileName:         uart.vhd
--   Dependencies:     none
--   Design Software:  Quartus II 64-bit Version 13.1.0 Build 162 SJ Web Edition
--
--   HDL CODE IS PROVIDED "AS IS."  DIGI-KEY EXPRESSLY DISCLAIMS ANY
--   WARRANTY OF ANY KIND, WHETHER EXPRESS OR IMPLIED, INCLUDING BUT NOT
--   LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY, FITNESS FOR A
--   PARTICULAR PURPOSE, OR NON-INFRINGEMENT. IN NO EVENT SHALL DIGI-KEY
--   BE LIABLE FOR ANY INCIDENTAL, SPECIAL, INDIRECT OR CONSEQUENTIAL
--   DAMAGES, LOST PROFITS OR LOST DATA, HARM TO YOUR EQUIPMENT, COST OF
--   PROCUREMENT OF SUBSTITUTE GOODS, TECHNOLOGY OR SERVICES, ANY CLAIMS
--   BY THIRD PARTIES (INCLUDING BUT NOT LIMITED TO ANY DEFENSE THEREOF),
--   ANY CLAIMS FOR INDEMNITY OR CONTRIBUTION, OR OTHER SIMILAR COSTS.
--
--   Version History
--   Version 1.0 5/26/2017 Scott Larson
--     Initial Public Release
--    
--------------------------------------------------------------------------------

LIBRARY ieee;
USE ieee.std_logic_1164.all;

ENTITY uart_rx IS
	GENERIC(
		clk_freq		:	INTEGER		:= 100_000_000;	--frequency of system clock in Hertz
		baud_rate	:	INTEGER		:= 256_000;		--data link baud rate in bits/second
		os_rate		:	INTEGER		:= 16;			--oversampling rate to find center of receive bits (in samples per baud period)
		d_width		:	INTEGER		:= 8; 			--data bus width
		parity		:	INTEGER		:= 0;				--0 for no parity, 1 for parity
		parity_eo	:	STD_LOGIC	:= '0');			--'0' for even, '1' for odd parity
	PORT(
		clk		:	IN		STD_LOGIC;										--system clock
		reset_n	:	IN		STD_LOGIC;										--ascynchronous reset
		rx			:	IN		STD_LOGIC;										--receive pin
		rx_busy	:	OUT	STD_LOGIC;										--data reception in progress
		rx_error	:	OUT	STD_LOGIC;										--start, parity, or stop bit error detected
		rx_data	:	OUT	STD_LOGIC_VECTOR(d_width-1 DOWNTO 0));	--data received
END uart_rx;
		
ARCHITECTURE logic OF uart_rx IS
	TYPE 		rx_machine IS(reset_rx, idle, receive);											--receive state machine data type
	SIGNAL	rx_state				:	rx_machine := reset_rx;										--receive state machine
	SIGNAL	os_pulse				:	STD_LOGIC := '0'; 							--periodic pulse that occurs at the oversampling rate
	SIGNAL	parity_error		:	STD_LOGIC;										--receive parity error flag
	SIGNAL	rx_parity			:	STD_LOGIC_VECTOR(d_width DOWNTO 0);		--calculation of receive parity
	SIGNAL	rx_buffer			:	STD_LOGIC_VECTOR(parity+d_width DOWNTO 0) := (OTHERS => '0');  	--values received
	
BEGIN

	--generate clock enable pulses at the baud rate and the oversampling rate
	PROCESS(reset_n, clk)
		VARIABLE count_os		:	INTEGER RANGE 0 TO clk_freq/baud_rate/os_rate-1 := 0;	--counter to determine oversampling period
	BEGIN
		IF(reset_n = '0') THEN											--asynchronous reset asserted
			os_pulse <= '0';													--reset oversampling rate pulse
			count_os := 0;														--reset oversampling period counter
		ELSIF(clk'EVENT AND clk = '1') THEN
			--create oversampling enable pulse
			IF(count_os < clk_freq/baud_rate/os_rate-1) THEN	--oversampling period not reached
				count_os := count_os + 1;									--increment oversampling period counter
				os_pulse <= '0';												--deassert oversampling rate pulse		
			ELSE																--oversampling period reached
				count_os := 0;													--reset oversampling period counter
				os_pulse <= '1';												--assert oversampling pulse
			END IF;
		END IF;
	END PROCESS;

	--receive state machine
	PROCESS(reset_n, clk)
			VARIABLE rx_count	:	INTEGER RANGE 0 TO parity+d_width+2 := 0;		--count the bits received
			VARIABLE	os_count	:	INTEGER RANGE 0 TO os_rate-1 := 0;				--count the oversampling rate pulses
	BEGIN
		IF(reset_n = '0') THEN																--asynchronous reset asserted
			os_count := 0;																			--clear oversampling pulse counter
			rx_count := 0;																			--clear receive bit counter
			rx_busy <= '0';																		--clear receive busy signal
			rx_error <= '0';																		--clear receive errors
			rx_data <= (OTHERS => '0');														--clear received data output
			rx_state <= idle;																		--put in idle state
		ELSIF(clk'EVENT AND clk = '1' AND os_pulse = '1') THEN  					--enable clock at oversampling rate
			CASE rx_state IS
			    WHEN reset_rx => -- startup state
                    os_count := 0;																			--clear oversampling pulse counter
                    rx_count := 0;                                                                            --clear receive bit counter
                    rx_busy <= '0';                                                                        --clear receive busy signal
                    rx_error <= '0';                                                                        --clear receive errors
                    rx_data <= (OTHERS => '0');                                                        --clear received data output
                    rx_state <= idle;                                                                        --put in idle state		    
			    
				WHEN idle =>																		--idle state
					rx_busy <= '0';																	--clear receive busy flag
					IF(rx = '0') THEN 																--start bit might be present
						IF(os_count < os_rate/2) THEN													--oversampling pulse counter is not at start bit center
							os_count := os_count + 1;														--increment oversampling pulse counter
							rx_state <= idle;																	--remain in idle state
						ELSE																					--oversampling pulse counter is at bit center
							os_count := 0;																		--clear oversampling pulse counter
							rx_count := 0;																		--clear the bits received counter
							rx_busy <= '1';																	--assert busy flag
							rx_state <= receive;																--advance to receive state
						END IF;
					ELSE																					--start bit not present
						os_count := 0;																		--clear oversampling pulse counter
						rx_state <= idle;																	--remain in idle state
					END IF;
					
				WHEN receive =>																	--receive state
					IF(os_count < os_rate-1) THEN													--not center of bit
						os_count := os_count + 1;														--increment oversampling pulse counter
						rx_state <= receive;																--remain in receive state
					ELSIF(rx_count < parity+d_width) THEN										--center of bit and not all bits received
						os_count := 0;  																	--reset oversampling pulse counter		
						rx_count := rx_count + 1;														--increment number of bits received counter
						rx_buffer <= rx & rx_buffer(parity+d_width DOWNTO 1);					--shift new received bit into receive buffer
						rx_state <= receive;																--remain in receive state
					ELSE																					--center of stop bit
						rx_data <= rx_buffer(d_width DOWNTO 1);									--output data received to user logic
						rx_error <= rx_buffer(0) OR parity_error OR NOT rx;					--output start, parity, and stop bit error flag
						rx_busy <= '0';																	--deassert received busy flag
						rx_state <= idle;																	--return to idle state
					END IF;
			END CASE;
		END IF;
	END PROCESS;
		
	--receive parity calculation logic
	rx_parity(0) <= parity_eo;
	rx_parity_logic: FOR i IN 0 to d_width-1 GENERATE
		rx_parity(i+1) <= rx_parity(i) XOR rx_buffer(i+1);
	END GENERATE;
	WITH parity SELECT  --compare calculated parity bit with received parity bit to determine error
		parity_error <= 	rx_parity(d_width) XOR rx_buffer(parity+d_width) WHEN 1,	--using parity
								'0' WHEN OTHERS;														--not using parity
		
END logic;