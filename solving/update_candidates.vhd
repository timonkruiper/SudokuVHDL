LIBRARY IEEE;
USE IEEE.std_logic_1164.ALL;

ENTITY update_candidates IS
	PORT (
		clk: IN std_logic;
		reset:  IN std_logic;
		solve_control_data: IN std_logic_vector(2 downto 0);
		update_candidates_done: OUT std_logic;
		
		mem_read_address: OUT integer range 0 to 255;
		mem_data_out: IN std_logic_vector(3 downto 0);

		mem_store_address: OUT integer range 0 to 255;
		mem_write_enable: OUT std_logic;
		mem_data_in : OUT std_logic_vector(3 downto 0)	
		);
END ENTITY update_candidates;

ARCHITECTURE bhv OF update_candidates IS
	
	SIGNAL tmp_read_address : unsigned(7 downto 0);
	SIGNAL tmp_write_address : unsigned(7 downto 0);
	SIGNAL tmp_data_in : std_logic_vector(3 downto 0);
	SIGNAL first_candidate_initialise : std_logic := 0;


	
BEGIN

	PROCESS(clk,reset)

		VARIABLE i : natural := 1;
		
	BEGIN

		IF solve_control_data = "010" THEN
			update_candidates_done <= '0';
		ELSIF solve_control_data = "001" THEN
		
		
			IF first_candidate_initialise = '0' THEN				
				FOR x IN 1 to 9 LOOP -- intitialise candidates
					FOR y IN 1 to 9 LOOP
						wcandboard(x,y,11,seg_assign(x,y));
						IF candboard(x,y,0) = 0 THEN
							FOR I IN 0 to 9 LOOP
								wcandboard(x,y,I,I);
							END LOOP;
							wcandboard(x,y,I,9);
						END IF;
					END LOOP;
				END LOOP;
				first_candidate_initialise <= '1';
			END IF;
		
			FOR x IN 1 to 9 LOOP -- update cadidates: elimination
				FOR y IN 1 to 9 LOOP
					IF candboard(x,y,0) /= 0 THEN
						FOR xc IN 1 to 9 LOOP -- eliminate in row
							IF 	candboard(xc,y,0) = 0 THEN
								wcandboard(xc,y,(candboard(x,y,0)),0);
								candboard(xc,y,10) <= candboard(xc,y,10) - 1;
							END IF;
						END LOOP;
						FOR yc IN 1 to 9 LOOP -- eliminate in column
							IF 	candboard(x,yc,0) = 0 THEN
								candboard(x,yc,(candboard(x,y,0))) <= 0;
								candboard(x,yc,10) <= candboard(x,yc,10) - 1;
							END IF;
						END LOOP;
						

						
						WHILE (i <= 9) LOOP -- eliminate in segment
							FOR xc IN 1 to 9 LOOP
								FOR yc IN 1 to 9 LOOP
									IF	candboard(xc,yc,11) = candboard(x,y,11) THEN
										candboard(x,yc,(candboard(x,y,0))) <= 0;
										candboard(x,yc,10) <= candboard(x,yc,10) - 1;
										i := i + 1;
									END IF;
								END LOOP;
							END LOOP;
						END LOOP;
						i := 0;
					END IF;
				END LOOP;
			END LOOP;
			update_candidates_done <= '1';
		END IF;
		
	END PROCESS;

	mem_read_address <= (OTHERS => 'Z') WHEN control /= "001" 
		ELSE tmp_read_address;

	mem_write_address <= (OTHERS => 'Z') WHEN control /= "001" 
		ELSE tmp_write_address;
		
	mem_data_in <= (OTHERS => 'Z') WHEN control /= "001" 
		ELSE tmp_data_in;

END bhv;