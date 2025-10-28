library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use STD.TEXTIO.ALL;

entity bin_reader_tb is
    generic (
        FILENAME : string := "program.bin"
    );
    port (
        clk         : in  std_logic;
        start       : in  std_logic;    -- Sinal para iniciar a leitura
        done        : out std_logic;    -- Sinaliza quando terminou de ler
        -- Saídas que conectam DIRETAMENTE no seu processador
        opcode_out  : out STD_LOGIC_VECTOR (7 downto 0);  -- Código da instrução
        data_A_out  : out STD_LOGIC_VECTOR (7 downto 0);  -- Primeiro operando
        data_B_out  : out STD_LOGIC_VECTOR (7 downto 0);  -- Segundo operando
        error       : out std_logic     -- Indica erro na leitura do arquivo
    );
end entity bin_reader_tb;

architecture behavioral of bin_reader_tb is
    -- Máquina de estados para controlar a leitura
    type state_type is (IDLE, READING_OPCODE, READING_DATA_A, READING_DATA_B, DONE_STATE, ERROR_STATE);
    signal state : state_type := IDLE;
    signal instruction_counter : integer := 0;  -- Contador de instruções lidas
    
    -- Definições dos opcodes do processador
    constant OPCODE_MOV_IMM  : STD_LOGIC_VECTOR (7 downto 0) := x"00";  -- Move valor para registrador
    constant OPCODE_ADD_REG  : STD_LOGIC_VECTOR (7 downto 0) := x"01";  -- Soma dois registradores
    constant OPCODE_ADD_IMM  : STD_LOGIC_VECTOR (7 downto 0) := x"02";  -- Soma com valor imediato
    constant OPCODE_NOP      : STD_LOGIC_VECTOR (7 downto 0) := x"FF";  -- Não faz nada
    
begin
    -- Processo principal de leitura
    process
        file bin_file : text;                    -- Arquivo que vai ser lido
        variable line_val : line;                -- Linha lida do arquivo
        variable bin_data : bit_vector(7 downto 0);  -- Dados de 8 bits por linha
        variable file_status : file_open_status; -- Status da abertura do arquivo
        variable temp_opcode : std_logic_vector(7 downto 0);  -- Opcode temporário
        variable temp_data_A : std_logic_vector(7 downto 0);  -- Dado A temporário
        variable temp_data_B : std_logic_vector(7 downto 0);  -- Dado B temporário
    begin
        wait until rising_edge(clk);  -- Sincronizado com o clock
        
        case state is
            when IDLE =>
                -- Estado inicial: esperando comando para começar
                done <= '0';
                error <= '0';
                instruction_counter <= 0;
                opcode_out <= (others => '0');  -- Zera as saídas
                data_A_out <= (others => '0');
                data_B_out <= (others => '0');
                
                if start = '1' then
                    -- Tenta abrir o arquivo quando recebe start
                    file_open(file_status, bin_file, FILENAME, read_mode);
                    
                    if file_status = open_ok then
                        state <= READING_OPCODE;  -- Arquivo aberto, começa a ler
                        report "Arquivo " & FILENAME & " aberto com sucesso!" severity note;
                    else
                        state <= ERROR_STATE;  -- Erro na abertura
                        error <= '1';
                        report "ERRO: Não foi possível abrir " & FILENAME severity error;
                    end if;
                end if;
                
            when READING_OPCODE =>
                -- Lendo o OPCODE (primeiro byte da instrução)
                if not endfile(bin_file) then
                    readline(bin_file, line_val);    -- Lê uma linha do arquivo
                    read(line_val, bin_data);        -- Converte para bits
                    temp_opcode := to_stdlogicvector(bin_data);  -- Converte para std_logic
                    state <= READING_DATA_A;         -- Vai ler o próximo byte
                    
                    report "Lendo OPCODE: " & to_string(temp_opcode) severity note;
                else
                    -- Chegou no fim do arquivo
                    file_close(bin_file);
                    state <= DONE_STATE;
                end if;
                
            when READING_DATA_A =>
                -- Lendo o DATA_A (segundo byte da instrução)
                if not endfile(bin_file) then
                    readline(bin_file, line_val);
                    read(line_val, bin_data);
                    temp_data_A := to_stdlogicvector(bin_data);
                    state <= READING_DATA_B;  -- Vai ler o último byte
                    
                    report "Lendo DATA_A: " & to_string(temp_data_A) severity note;
                else
                    file_close(bin_file);
                    state <= DONE_STATE;
                end if;
                
            when READING_DATA_B =>
                -- Lendo o DATA_B (terceiro byte da instrução)
                if not endfile(bin_file) then
                    readline(bin_file, line_val);
                    read(line_val, bin_data);
                    temp_data_B := to_stdlogicvector(bin_data);
                    
                    opcode_out <= temp_opcode;  -- Envia opcode para o processador
                    data_A_out <= temp_data_A;  -- Envia dado A para o processador  
                    data_B_out <= temp_data_B;  -- Envia dado B para o processador
                    
                    instruction_counter <= instruction_counter + 1;  -- Conta +1 instrução
                    
                    report "Instrução " & integer'image(instruction_counter) & 
                           " completa: OPCODE=" & to_string(temp_opcode) & 
                           " DATA_A=" & to_string(temp_data_A) &
                           " DATA_B=" & to_string(temp_data_B) severity note;
                    
                    -- Volta para ler próxima instrução
                    state <= READING_OPCODE;
                    
                else
                    -- Fim do arquivo
                    file_close(bin_file);
                    state <= DONE_STATE;
                end if;
                
            when DONE_STATE =>
                -- Estado final: leitura concluída
                done <= '1';  -- Avisa que terminou
                opcode_out <= OPCODE_NOP;  -- Manda NOP para o processador
                data_A_out <= (others => '0');
                data_B_out <= (others => '0');
                
                report "Carregamento concluído! " & 
                       integer'image(instruction_counter) & " instruções carregadas." severity note;
                
                -- Espera o sinal start voltar a zero para poder recomeçar
                if start = '0' then
                    state <= IDLE;
                end if;
                
            when ERROR_STATE =>
                -- Estado de erro
                error <= '1';
                done <= '0';
                -- Espera start voltar a zero para tentar novamente
                if start = '0' then
                    state <= IDLE;
                end if;
        end case;
    end process;
end architecture behavioral;
