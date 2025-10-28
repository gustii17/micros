library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity TopLevel is
    Port ( 
        clk : in STD_LOGIC;
        reset : in STD_LOGIC;
        result : out STD_LOGIC_VECTOR(7 downto 0);
        flags : out STD_LOGIC_VECTOR(3 downto 0);
        done : out STD_LOGIC
    );
end TopLevel;

architecture Behavioral of TopLevel is

    -- Componente: InstructionMemory
    component InstructionMemory
        Port ( 
            clk : in STD_LOGIC;
            address : in STD_LOGIC_VECTOR(7 downto 0);
            write_enable : in STD_LOGIC;
            data_in : in STD_LOGIC_VECTOR(23 downto 0);
            data_out : out STD_LOGIC_VECTOR(23 downto 0)
        );
    end component;

    -- Componente: InstructionLoader
    component InstructionLoader
        Port ( 
            clk : in STD_LOGIC;
            reset : in STD_LOGIC;
            opcode_out : out STD_LOGIC_VECTOR(7 downto 0);
            data_A_out : out STD_LOGIC_VECTOR(7 downto 0);
            data_B_out : out STD_LOGIC_VECTOR(7 downto 0);
            instruction_ready : out STD_LOGIC;
            done : out STD_LOGIC;
            mem_write_enable : out STD_LOGIC;
            mem_address : out STD_LOGIC_VECTOR(7 downto 0);
            mem_data_out : out STD_LOGIC_VECTOR(23 downto 0)
        );
    end component;

    -- Componente: Processor
    component processor_core_simplified
        Port (
            clk : in STD_LOGIC;
            reset : in STD_LOGIC;
            opcode_in : in STD_LOGIC_VECTOR(7 downto 0);
            data_A_in : in STD_LOGIC_VECTOR(7 downto 0);
            data_B_in : in STD_LOGIC_VECTOR(7 downto 0);
            ula_result_out : out STD_LOGIC_VECTOR(7 downto 0);
            ula_cout_out : out STD_LOGIC;
            reg_read_data_out : out STD_LOGIC_VECTOR(7 downto 0)
        );
    end component;

    -- Sinais do InstructionLoader para InstructionMemory
    signal loader_mem_write : STD_LOGIC;
    signal loader_mem_addr : STD_LOGIC_VECTOR(7 downto 0);
    signal loader_mem_data : STD_LOGIC_VECTOR(23 downto 0);
    signal loader_done_sig : STD_LOGIC;
    
    -- Sinais da InstructionMemory para Processor
    signal memory_data_out : STD_LOGIC_VECTOR(23 downto 0);
    
    -- Sinais de controle do sistema
    signal execution_phase : STD_LOGIC := '0'; -- 0=loading, 1=execution
    signal program_counter : unsigned(7 downto 0) := (others => '0');
    signal current_mem_address : STD_LOGIC_VECTOR(7 downto 0);
    
    -- Sinais do Processor
    signal processor_result : STD_LOGIC_VECTOR(7 downto 0);
    signal processor_cout : STD_LOGIC;
    signal processor_reg_data : STD_LOGIC_VECTOR(7 downto 0);

    -- Sinais de instrução para o Processor
    signal processor_opcode : STD_LOGIC_VECTOR(7 downto 0);
    signal processor_data_A : STD_LOGIC_VECTOR(7 downto 0);
    signal processor_data_B : STD_LOGIC_VECTOR(7 downto 0);

begin

    -- Mapeamento das saídas
    result <= processor_result;
    flags <= "000" & processor_cout;

    -- Instância da Memória de Instruções
    instr_mem : InstructionMemory
        port map (
            clk => clk,
            address => current_mem_address,
            write_enable => loader_mem_write,
            data_in => loader_mem_data,
            data_out => memory_data_out
        );

    -- Instância do Carregador de Instruções
    instr_loader : InstructionLoader
        port map (
            clk => clk,
            reset => reset,
            opcode_out => open,  -- Não usado (processador lê da memória)
            data_A_out => open,  -- Não usado (processador lê da memória)
            data_B_out => open,  -- Não usado (processador lê da memória)
            instruction_ready => open,
            done => loader_done_sig,
            mem_write_enable => loader_mem_write,
            mem_address => loader_mem_addr,
            mem_data_out => loader_mem_data
        );

    -- Instância do Processador
    processor : processor_core_simplified
        port map (
            clk => clk,
            reset => reset,
            opcode_in => processor_opcode,
            data_A_in => processor_data_A,
            data_B_in => processor_data_B,
            ula_result_out => processor_result,
            ula_cout_out => processor_cout,
            reg_read_data_out => processor_reg_data
        );

    -- Controle do endereço de memória
    -- Durante carregamento: InstructionLoader controla o address
    -- Durante execução: Program Counter controla o address
    current_mem_address <= loader_mem_addr when execution_phase = '0' else 
                          STD_LOGIC_VECTOR(program_counter);

    -- Decodificação da instrução da memória para o processador
    -- Memória armazena: [opcode(8) | data_A(8) | data_B(8)]
    processor_opcode <= memory_data_out(23 downto 16) when execution_phase = '1' else 
                       (others => '0');
    processor_data_A <= memory_data_out(15 downto 8) when execution_phase = '1' else 
                       (others => '0');
    processor_data_B <= memory_data_out(7 downto 0) when execution_phase = '1' else 
                       (others => '0');

    -- Controle principal do sistema
    SYSTEM_CONTROL : process(clk, reset)
    begin
        if reset = '1' then
            execution_phase <= '0';
            program_counter <= (others => '0');
            done <= '0';
            
        elsif rising_edge(clk) then
            -- Controle da fase de execução
            if execution_phase = '0' then
                -- Fase de carregamento: aguarda loader terminar
                if loader_done_sig = '1' then
                    execution_phase <= '1';  -- Muda para fase de execução
                    program_counter <= (others => '0');  -- Inicia PC em 0
                end if;
            else
                -- Fase de execução: incrementa program counter
                if program_counter < 255 then
                    program_counter <= program_counter + 1;
                else
                    -- Chegou ao final da memória
                    done <= '1';
                end if;
            end if;
        end if;
    end process;

end Behavioral;
