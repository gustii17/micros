library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity TopLevelCorrected is
    Port ( 
        clk : in STD_LOGIC;
        reset : in STD_LOGIC;
        result : out STD_LOGIC_VECTOR(7 downto 0);
        flags : out STD_LOGIC_VECTOR(3 downto 0);
        done : out STD_LOGIC
    );
end TopLevelCorrected;

architecture Behavioral of TopLevelCorrected is

    -- Componentes
    component InstructionMemory
        Port ( 
            clk : in STD_LOGIC;
            address : in STD_LOGIC_VECTOR(7 downto 0);
            write_enable : in STD_LOGIC;
            data_in : in STD_LOGIC_VECTOR(23 downto 0);
            data_out : out STD_LOGIC_VECTOR(23 downto 0)
        );
    end component;

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

    -- Sinais para o LOADER → MEMÓRIA
    signal loader_to_mem_write : STD_LOGIC;
    signal loader_to_mem_addr : STD_LOGIC_VECTOR(7 downto 0);
    signal loader_to_mem_data : STD_LOGIC_VECTOR(23 downto 0);
    
    -- Sinais para MEMÓRIA → PROCESSADOR
    signal mem_to_proc_data : STD_LOGIC_VECTOR(23 downto 0);
    signal proc_read_addr : STD_LOGIC_VECTOR(7 downto 0);
    
    -- Sinais de controle
    signal loader_done_sig : STD_LOGIC;
    signal execution_mode : STD_LOGIC := '0'; -- 0=loading, 1=execution
    signal program_counter : unsigned(7 downto 0) := (others => '0');
    
    -- Sinais do processador
    signal processor_result : STD_LOGIC_VECTOR(7 downto 0);
    signal processor_cout : STD_LOGIC;

begin

    result <= processor_result;
    flags <= "000" & processor_cout;

    -- Memória de Instruções
    instr_mem : InstructionMemory
        port map (
            clk => clk,
            address => proc_read_addr when execution_mode = '1' else loader_to_mem_addr,
            write_enable => loader_to_mem_write when execution_mode = '0' else '0',
            data_in => loader_to_mem_data,
            data_out => mem_to_proc_data
        );

    -- Carregador de Instruções
    instr_loader : InstructionLoader
        port map (
            clk => clk,
            reset => reset,
            opcode_out => open,  -- Não conectado (processador lê da memória)
            data_A_out => open,
            data_B_out => open,
            instruction_ready => open,
            done => loader_done_sig,
            mem_write_enable => loader_to_mem_write,
            mem_address => loader_to_mem_addr,
            mem_data_out => loader_to_mem_data
        );

    -- Processador (agora lê da MEMÓRIA)
    processor : processor_core_simplified
        port map (
            clk => clk,
            reset => reset,
            opcode_in => mem_to_proc_data(23 downto 16),  -- Lê da memória!
            data_A_in => mem_to_proc_data(15 downto 8),   -- Lê da memória!
            data_B_in => mem_to_proc_data(7 downto 0),    -- Lê da memória!
            ula_result_out => processor_result,
            ula_cout_out => processor_cout,
            reg_read_data_out => open
        );

    -- Controle de endereço de memória
    proc_read_addr <= STD_LOGIC_VECTOR(program_counter);

    -- Máquina de estados do sistema
    SYSTEM_CONTROL : process(clk, reset)
    begin
        if reset = '1' then
            execution_mode <= '0';
            program_counter <= (others => '0');
            done <= '0';
            
        elsif rising_edge(clk) then
            if execution_mode = '0' then
                -- Fase de carregamento
                if loader_done_sig = '1' then
                    execution_mode <= '1';  -- Muda para fase de execução
                    program_counter <= (others => '0');  -- PC começa em 0
                end if;
            else
                -- Fase de execução
                if program_counter < 255 then
                    program_counter <= program_counter + 1;  -- Incrementa PC
                else
                    done <= '1';  -- Fim da execução
                end if;
            end if;
        end if;
    end process;

end Behavioral;
