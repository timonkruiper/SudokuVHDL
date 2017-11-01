LIBRARY IEEE;
USE IEEE.std_logic_1164.ALL;
USE IEEE.numeric_std.ALL;

ENTITY controller IS
	PORT (
		clk: IN std_logic;
		reset: IN std_logic;

		control: OUT std_logic_vector(2 downto 0);

		btn_state: IN std_logic;
		led_state: OUT std_logic_vector(2 downto 0);

		mem_we : OUT std_logic;

		sw_mode: IN std_logic;
		raspi_receive: IN std_logic;
		raspi_send: OUT std_logic;

		HEX5: OUT std_logic_vector(6 downto 0)
	);		
END ENTITY controller;

ARCHITECTURE bhv of controller IS

	SIGNAL edge: std_logic;
	SIGNAL btn_state_1: std_logic;

	TYPE states IS (receiving, sending, showing, solving);
	SIGNAL state: states := receiving;

BEGIN

	PROCESS(clk,reset)
	BEGIN
		IF reset = '0' THEN
			state <= receiving;
		ELSIF rising_edge(clk) THEN
			btn_state_1 <= NOT btn_state;
			IF sw_mode = '0' THEN
				-- manual mode
				IF edge = '1' THEN
					CASE state IS
						WHEN receiving => state <= sending;
						WHEN sending => state <= showing;
						WHEN showing => state <= solving;
						WHEN solving => state <= receiving;
					END CASE;
				END IF;				
			ELSE
				-- automatic mode
				--IF raspi_receive = '1' THEN
				--	state <= receiving;
				--END IF;
			END IF;

			CASE state IS
				WHEN receiving =>	control <= "001";
									led_state <= "001";
									mem_we <= '1';
				WHEN sending =>	control <= "010";
								led_state <= "010";
								mem_we <= '0';
				WHEN showing => control <= "100";
								led_state <= "100";
								mem_we <= '0';
				WHEN solving => control <= "011";
								led_state <= "011";
								mem_we <= '1';
			END CASE;

		END IF;
	END PROCESS;

	edge <= NOT btn_state_1 AND NOT btn_state;
	HEX5 <= NOT "1110111" WHEN sw_mode = '1' ELSE NOT "1110110";

END bhv;