library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity TopLevel is
    Port ( 
        clk : in STD_LOGIC;
        reset : in STD_LOGIC;
        result : out STD_LOGIC_VECTOR(7 downto 0);
        flags : out STD_LOGIC_VECTOR(3 downto 0);
        done : out STD_LOGIC  -- Sinal indicando que a execução foi encerrada
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

    -- Sinais de interconexão
    signal opcode_sig : STD_LOGIC_VECTOR(7 downto 0);
    signal operand1_sig : STD_LOGIC_VECTOR(7 downto 0);
    signal operand2_sig : STD_LOGIC_VECTOR(7 downto 0);
    signal instruction_sig : STD_LOGIC_VECTOR(23 downto 0);
    signal write_enable_sig : STD_LOGIC;
    signal address_sig : STD_LOGIC_VECTOR(7 downto 0);
    signal data_out_sig : STD_LOGIC_VECTOR(23 downto 0);
    signal loader_done_sig : STD_LOGIC;
    signal instruction_ready_sig : STD_LOGIC;
    
    -- Sinais do processador
    signal processor_result : STD_LOGIC_VECTOR(7 downto 0);
    signal processor_cout : STD_LOGIC;
    signal processor_reg_data : STD_LOGIC_VECTOR(7 downto 0);
    
    -- Sinais de controle interno
    signal stop_execution : STD_LOGIC := '0';
    signal done_reg : STD_LOGIC := '0';
    
    -- Definição de opcodes especiais
    constant OPCODE_HALT : STD_LOGIC_VECTOR(7 downto 0) := x"FF";  -- Instrução de parada

begin

    -- Mapeamento das saídas
    result <= processor_result;
    flags <= "000" & processor_cout;  -- Flags: [3:1] = zeros, [0] = carry out
    done <= done_reg;

    -- Instância da Memória de Instruções
    instr_mem : InstructionMemory
        port map (
            clk => clk,
            address => address_sig,
            write_enable => write_enable_sig,
            data_in => data_out_sig,
            data_out => instruction_sig
        );

    -- Instância do Carregador de Instruções
    instr_loader : InstructionLoader
        port map (
            clk => clk,
            reset => reset,
            opcode_out => opcode_sig,
            data_A_out => operand1_sig,
            data_B_out => operand2_sig,
            instruction_ready => instruction_ready_sig,
            done => loader_done_sig,
            mem_write_enable => write_enable_sig,
            mem_address => address_sig,
            mem_data_out => data_out_sig
        );

    -- Instância do Processador
    processor : processor_core_simplified
        port map (
            clk => clk,
            reset => reset,
            opcode_in => opcode_sig,
            data_A_in => operand1_sig,
            data_B_in => operand2_sig,
            ula_result_out => processor_result,
            ula_cout_out => processor_cout,
            reg_read_data_out => processor_reg_data
        );

    -- Controle de término de execução
    EXECUTION_CONTROL : process(clk, reset)
    begin
        if reset = '1' then
            done_reg <= '0';
            stop_execution <= '0';
        elsif rising_edge(clk) then
            -- Verifica se é uma instrução de parada (HALT)
            if opcode_sig = OPCODE_HALT then
                stop_execution <= '1';
                done_reg <= '1';
            end if;
            
            -- Se o loader terminou e não há mais instruções válidas
            if loader_done_sig = '1' and instruction_ready_sig = '0' and stop_execution = '0' then
                stop_execution <= '1';
                done_reg <= '1';
            end if;
        end if;
    end process;

end Behavioral;
