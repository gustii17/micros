library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use STD.TEXTIO.ALL;

entity bin_reader is
    generic (
        DATA_WIDTH : integer := 8; 
        ADDR_WIDTH : integer := 12;
        FILENAME   : string := "dados.bin" -- Arquivo que vai ser lido
    );
    port (
        clk         : in  std_logic; -- Clock do sistema
        start       : in  std_logic; -- Sinal para iniciar a leitura
        done        : out std_logic; -- Sinal para finalizar a leitura
        mem_we      : out std_logic;
        mem_addr    : out std_logic_vector(ADDR_WIDTH-1 downto 0); -- Endereço 
        mem_data    : out std_logic_vector(DATA_WIDTH-1 downto 0); -- Dado
        error       : out std_logic
    );
end entity bin_reader;

architecture behavioral of bin_reader is
    type state_type is (IDLE, READING, DONE_STATE, ERROR_STATE); -- 4 estados (esperando start, lendo arquivo, leitura concluida, erro)
    signal state : state_type := IDLE; -- Estado atual, iniciando em IDLE (esperando start)
    signal address_counter : unsigned(ADDR_WIDTH-1 downto 0) := (others => '0'); -- Contador de endereço, iniciando em 0
begin
    process
        file bin_file : text; -- Objeto arquivo do tipo texto
        variable line_val : line; -- Variavel que armazena uma linha do arquivo
        variable bin_data : bit_vector(DATA_WIDTH-1 downto 0); -- Variavel que armazena os dados lidos
        variable file_status : file_open_status; -- Status da abertura do arquivo
    begin
        wait until rising_edge(clk);
        
        case state is
            when IDLE => -- Esperando start reseta tudo
                done <= '0';
                error <= '0';
                mem_we <= '0';
                address_counter <= (others => '0');
                
                if start = '1' then
                    file_open(file_status, bin_file, FILENAME, read_mode);
                    
                    if file_status = open_ok then
                        state <= READING;
                    else
                        state <= ERROR_STATE;
                        error <= '1';
                    end if;
                end if;
                
            when READING => -- No estado lendo
                if not endfile(bin_file) then
                    readline(bin_file, line_val); -- Le uma linha do arquivo
                    read(line_val, bin_data);
                    
                    -- Escreve na memória
                    mem_we <= '1'; -- Ativa escrita na memória
                    mem_addr <= std_logic_vector(address_counter); -- Armazena o endereço
                    mem_data <= to_stdlogicvector(bin_data); -- Armazena o dado
                    
                    address_counter <= address_counter + 1; -- Prepara o próximo endereço
                else -- Se no fim do arquivo
                    file_close(bin_file); -- Fecha arquivo
                    mem_we <= '0'; -- Desativa escrita
                    state <= DONE_STATE; -- Estado de concluído
                end if;
                
            when DONE_STATE => -- No estado concluído
                done <= '1'; -- Leitura terminou
                mem_we <= '0'; -- Mantem leitura desativada
                if start = '0' then -- Quando start volta a 0 retorna ao estado IDLE
                    state <= IDLE;
                end if;
                
            when ERROR_STATE =>
                error <= '1';
                if start = '0' then
                    state <= IDLE;
                end if;
        end case;
    end process;
end architecture behavioral;
