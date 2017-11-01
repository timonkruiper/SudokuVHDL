LIBRARY IEEE;
USE IEEE.std_logic_1164.ALL;

ENTITY hidden_singles IS
	PORT (
		reset:  IN std_logic;
		clk: IN std_logic;
		solve_control_data: IN std_logic_vector(2 downto 0);
		hidden_singles_done: OUT std_logic;
		hidden_singles_failed : OUT std_logic;
		
		mem_read_address: OUT integer range 0 to 255;
		mem_data_out: IN std_logic_vector(3 downto 0);

		mem_store_address: OUT integer range 0 to 255;
		mem_write_enable: OUT std_logic;
		mem_data_in : OUT std_logic_vector(3 downto 0)	
		);
END ENTITY hidden_singles;

ARCHITECTURE bhv OF hidden_singles IS
	
	TYPE hidden_single_store IS ARRAY (1 TO 9, 1 TO 3) OF natural range 0 to 9;
	SIGNAL hsa : hidden_single_store;
-- hsa(i,1) is the number of times a certain candidate (i) appears
-- hsa(i,2) is the x value of the latest candidate of value (i)
-- hsa(i,3) is the y value of the latest candidate	of value (i)

	PROCEDURE reset_hsa IS
		IF n THEN
			FOR a IN 1 to 9 LOOP
				FOR b IN 1 to 3 LOOP
					hsa(a,b) <= 0;
				END LOOP;
			END LOOP;
		END IF;
	END reset_hsa;

BEGIN

	PROCESS(clk,reset,solve_control_data)
	BEGIN
		IF reset = '0' THEN
			hidden_singles_done <= '0';
			hidden_singles_failed <= '1';
		ELSIF solve_control_data = "001" THEN
			hidden_singles_done <= '0';
			hidden_singles_failed <= '1';
		ELSIF solve_control_data = "011" THEN
			hidden_singles_done <= '0';
			hidden_singles_failed <= '1';
			FOR x IN 1 to 9 LOOP -- find hidden singles in rows
				FOR y IN 1 to 9 LOOP
					IF candboard(x,y,0) = 0 and candboard(x,y,10) > 1; -- several candidates found
						FOR I IN 1 to 9;
							IF candboard(x,y,I) /= 0 THEN
								hsa(I,1) <= hsa(I,1) + 1;
								hsa(I,2) <= x;
								hsa(I,3) <= y;
							END IF;
						END LOOP;
					END IF;
				END LOOP;
			END LOOP;
			FOR I IN 1 to 9;
				IF hsa(I,1) = 1 THEN
					candboard(hsa(I,2),hsa(I,3),0) <= hsa(I,1);
					candboard(hsa(I,2),hsa(I,3),I) <= 0;
					candboard(hsa(I,2),hsa(I,3),10) <= 0;
					hidden_singles_failed <= '0';
				END IF;
			END LOOP;

			reset_hsa;

			FOR y IN 1 to 9 LOOP -- find hidden singles in columns
				FOR x IN 1 to 9 LOOP
					IF candboard(x,y,0) = 0 and candboard(x,y,10) > 1; -- several candidates found
						FOR I IN 1 to 9;
							IF candboard(x,y,I) /= 0 THEN
								hsa(I,1) <= hsa(I,1) + 1;
								hsa(I,2) <= x;
								hsa(I,3) <= y;
							END IF;
						END LOOP;
					END IF;
				END LOOP;
			END LOOP;
			FOR I IN 1 to 9;
				IF hsa(I,1) = 1 THEN
					candboard(hsa(I,2),hsa(I,3),0) <= hsa(I,1);
					candboard(hsa(I,2),hsa(I,3),I) <= 0;
					candboard(hsa(I,2),hsa(I,3),10) <= 0;
					hidden_singles_failed <= '0';
				END IF;
			END LOOP;

			reset_hsa;

			seg := 1;
			WHILE (seg <= 9) LOOP -- find hidden singles in segment 
				FOR x IN 1 to 9 LOOP
					FOR y IN 1 to 9 LOOP
						IF candboard(x,y,11) = seg THEN
							IF candboard(x,y,0) = 0 and candboard(x,y,10) > 1; -- several candidates found
								FOR I IN 1 to 9 LOOP
									IF candboard(x,y,I) /= 0 THEN
										hsa(I,1) <= hsa(I,1) + 1;
										hsa(I,2) <= x;
										hsa(I,3) <= y;
									END IF;
								END LOOP;
							END IF;
						END IF;
					END LOOP;
				END LOOP;
				FOR I IN 1 to 9;
					IF hsa(I,1) = 1 THEN
						candboard(hsa(I,2),hsa(I,3),0) <= hsa(I,1);
						candboard(hsa(I,2),hsa(I,3),I) <= 0;
						candboard(hsa(I,2),hsa(I,3),10) <= 0;
						hidden_singles_failed <= '0';
					END IF;
				END LOOP;
				seg := seg + 1;
			END LOOP;
			hidden_singles_done <= '1';
		END IF;
	END PROCESS;
END bhv;