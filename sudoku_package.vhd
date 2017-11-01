PACKAGE sudoku_package IS
	
END sudoku_package;

PACKAGE BODY sudoku_package IS
	PROCEDURE wcandboard(x:natural, y: natural, i:natural, d:natural) -- write to memory
		tmp_write_address <= to_unsigned(i,4) & to_unsigned(y-1,4) & to_unsigned(x-1,4);
		tmp_data_in <= to_unsigned(d,4);
	END wcandboard;


	FUNCTION candboard(x:natural, y: natural, i:natural) RETURN natural RANGE 1 to 9  -- read from memory
		tmp_read_address <= to_unsigned(i,4) & to_unsigned(y-1,4) & to_unsigned(x-1,4);
		return to_integer(unsigned(mem_data_out));
	END candboard;

END sudoku_package;