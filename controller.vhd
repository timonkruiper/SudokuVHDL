LIBRARY IEEE;
USE IEEE.std_logic_1164.ALL;

ENTITY controller IS
  PORT (
  		clk: IN std_logic;
        reset: IN std_logic;

        control: OUT std_logic_vector(2 downto 0);

        btn_state: IN std_logic;
        led_state: OUT std_logic_vector(2 downto 0)
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


	ELSIF rising_edge(clk) THEN
		btn_state_1 <= NOT btn_state;
		IF edge = '1' THEN
			CASE state IS
				WHEN receiving => state <= sending;
				WHEN sending => state <= showing;
				WHEN showing => state <= solving;
				WHEN solving => state <= receiving;
			END CASE;
		END IF;

		CASE state IS
			WHEN receiving => control <= "001"; led_state <= "001";
			WHEN sending => control <= "010"; led_state <= "010";
			WHEN showing => control <= "100"; led_state <= "100";
			WHEN solving => control <= "011"; led_state <= "011";
		END CASE;
	END IF;


END PROCESS;


edge <= NOT btn_state_1 AND NOT btn_state;




END bhv;