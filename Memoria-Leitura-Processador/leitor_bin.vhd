library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use STD.TEXTIO.ALL;

entity InstructionLoader is
    Port ( 
        clk : in STD_LOGIC;
        reset : in STD_LOGIC;
        opcode_out : out STD_LOGIC_VECTOR(7 downto 0);
        data_A_out : out STD_LOGIC_VECTOR(7 downto 0);
        data_B_out : out STD_LOGIC_VECTOR(7 downto 0);
        instruction_ready : out STD_LOGIC;
        done : out STD_LOGIC;
        -- Novas interfaces para a memória externa
        mem_write_enable : out STD_LOGIC;
        mem_address : out STD_LOGIC_VECTOR(7 downto 0);
        mem_data_out : out STD_LOGIC_VECTOR(23 downto 0)
    );
end InstructionLoader;

architecture Behavioral of InstructionLoader is
    -- Definição do tipo de memória interna para carregar do arquivo
    type memory_type is array (0 to 255) of STD_LOGIC_VECTOR(7 downto 0);
    
    -- Função para carregar arquivo binário na memória interna
    impure function load_memory_file(filename : in string) return memory_type is
        file file_ptr : text;
        variable file_line : line;
        variable memory_content : memory_type;
        variable bit_vector : bit_vector(7 downto 0);
        variable current_line : integer := 0;
    begin
        -- Inicializa memória com zeros
        for i in 0 to 255 loop
            memory_content(i) := (others => '0');
        end loop;
        
        -- Tenta abrir e ler o arquivo
        file_open(file_ptr, filename, READ_MODE);
        
        while (not endfile(file_ptr) and current_line < 256) loop
            readline(file_ptr, file_line);
            read(file_line, bit_vector);
            memory_content(current_line) := to_stdlogicvector(bit_vector);
            current_line := current_line + 1;
        end loop;
        
        file_close(file_ptr);
        return memory_content;
    end function;
    
    -- Sinais internos
    signal memory : memory_type := load_memory_file("instructions.bin");
    signal pc : unsigned(7 downto 0) := (others => '0');
    signal state : unsigned(2 downto 0) := (others => '0');
    
    signal opcode_reg : STD_LOGIC_VECTOR(7 downto 0) := (others => '0');
    signal data_A_reg : STD_LOGIC_VECTOR(7 downto 0) := (others => '0');
    signal data_B_reg : STD_LOGIC_VECTOR(7 downto 0) := (others => '0');
    signal instruction_ready_reg : STD_LOGIC := '0';
    signal done_reg : STD_LOGIC := '0';
    
    -- Sinais para controle da memória externa
    signal mem_write_enable_reg : STD_LOGIC := '0';
    signal mem_address_reg : STD_LOGIC_VECTOR(7 downto 0) := (others => '0');
    signal mem_data_out_reg : STD_LOGIC_VECTOR(23 downto 0) := (others => '0');
    
    -- Estados da máquina de estados
    constant LOAD_OPCODE   : unsigned(2 downto 0) := "000";
    constant LOAD_DATA_A   : unsigned(2 downto 0) := "001";
    constant LOAD_DATA_B   : unsigned(2 downto 0) := "010";
    constant WRITE_MEMORY  : unsigned(2 downto 0) := "011";
    constant OUTPUT_READY  : unsigned(2 downto 0) := "100";
    constant DONE_STATE    : unsigned(2 downto 0) := "101";
    
begin
    -- Conexão dos sinais de saída
    opcode_out <= opcode_reg;
    data_A_out <= data_A_reg;
    data_B_out <= data_B_reg;
    instruction_ready <= instruction_ready_reg;
    done <= done_reg;
    
    -- Conexão dos sinais de memória externa
    mem_write_enable <= mem_write_enable_reg;
    mem_address <= mem_address_reg;
    mem_data_out <= mem_data_out_reg;

    process(clk, reset)
        variable instruction_count : integer := 0;
    begin
        if reset = '1' then
            -- Reset assíncrono
            pc <= (others => '0');
            opcode_reg <= (others => '0');
            data_A_reg <= (others => '0');
            data_B_reg <= (others => '0');
            instruction_ready_reg <= '0';
            done_reg <= '0';
            mem_write_enable_reg <= '0';
            mem_address_reg <= (others => '0');
            mem_data_out_reg <= (others => '0');
            state <= LOAD_OPCODE;
            instruction_count := 0;
            
        elsif rising_edge(clk) then
            -- Valores padrão
            instruction_ready_reg <= '0';
            mem_write_enable_reg <= '0';
            
            case state is
                when LOAD_OPCODE =>
                    if pc < 256 then
                        opcode_reg <= memory(to_integer(pc));
                        pc <= pc + 1;
                        state <= LOAD_DATA_A;
                    else
                        state <= DONE_STATE;
                    end if;
                    
                when LOAD_DATA_A =>
                    data_A_reg <= memory(to_integer(pc));
                    pc <= pc + 1;
                    state <= LOAD_DATA_B;
                    
                when LOAD_DATA_B =>
                    data_B_reg <= memory(to_integer(pc));
                    pc <= pc + 1;
                    state <= WRITE_MEMORY;
                    
                when WRITE_MEMORY =>
                    -- Prepara dados para escrita na memória externa
                    mem_write_enable_reg <= '1';
                    mem_address_reg <= STD_LOGIC_VECTOR(to_unsigned(instruction_count, 8));
                    mem_data_out_reg <= opcode_reg & data_A_reg & data_B_reg;
                    instruction_count := instruction_count + 1;
                    state <= OUTPUT_READY;
                    
                when OUTPUT_READY =>
                    -- Instrução completa carregada e escrita na memória, sinaliza pronta
                    instruction_ready_reg <= '1';
                    state <= LOAD_OPCODE;
                    
                when DONE_STATE =>
                    done_reg <= '1';
                    instruction_ready_reg <= '0';
                    
                when others =>
                    state <= LOAD_OPCODE;
            end case;
        end if;
    end process;

end Behavioral;
