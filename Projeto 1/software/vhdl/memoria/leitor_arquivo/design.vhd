library IEEE;
use IEEE.std_logic_1164.all;
use std.textio.all;

entity leitor_arquivo_tb is
end leitor_arquivo_tb;

architecture tb of leitor_arquivo_tb is
	type mem_array is array (0 to 2) of std_logic_vector(7 downto 0);
    signal memoria : mem_array;
    
begin
	process
    	file f : text open read_mode is "dados.bin";
        variable linha : line;
        variable bits : string (1 to 8);
        variable i : integer := 0;
    begin
    	while not endfile(f) loop
        	readline(f, linha);
            read(linha, bits);
            memoria(i) <= to_stdlogicvector(bits);
            i := i + 1;
        end loop;
        wait;
    end process;
end tb;

function to_stdlogicvector(s: string) return std_logic_vector is
	variable res: std_logic_vector(s'length-1 downto 0);
begin
	for i in s'range loop
    	if s(i) = '1' then
        	res(s'length - i) := '1';
        else
        	res(s'length - i) := '0';
        end if;
    end loop;
    return res;
end function;
