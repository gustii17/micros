-- Declaração das bibliotecas necessárias
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;      -- Para tipos std_logic e std_logic_vector
use IEEE.NUMERIC_STD.ALL;         -- Para tipos unsigned e operações numéricas

-- Definição da entidade (interface do módulo)
entity InstructionMemory is
    Port ( 
        clk : in STD_LOGIC;                       -- Sinal de clock
        address : in STD_LOGIC_VECTOR(7 downto 0); -- Endereço da instrução (8 bits = 256 posições)
        write_enable : in STD_LOGIC;               -- Habilita escrita ('1' = escrita, '0' = leitura)
        data_in : in STD_LOGIC_VECTOR(23 downto 0); -- Dados de entrada (instrução completa de 24 bits)
        data_out : out STD_LOGIC_VECTOR(23 downto 0) -- Dados de saída (instrução completa de 24 bits)
    );
end InstructionMemory;

-- Definição da arquitetura (implementação do módulo)
architecture Behavioral of InstructionMemory is
    -- Definição do tipo de memória: array de 256 posições de 24 bits cada
    type memory_type is array (0 to 255) of STD_LOGIC_VECTOR(23 downto 0);
    
    -- Declaração da memória com inicialização (opcional)
    signal memory : memory_type := (
        -- Inicializa toda memória com zeros
        others => (others => '0')
    );
    
    -- Sinal interno para o dado de saída
    signal data_out_reg : STD_LOGIC_VECTOR(23 downto 0) := (others => '0');

begin
    -- Processo síncrono: sensível apenas à borda de subida do clock
    process(clk)
    begin
        -- Borda de subida do clock
        if rising_edge(clk) then
            -- Operação de escrita tem prioridade
            if write_enable = '1' then
                -- Escreve na memória na posição especificada pelo address
                memory(to_integer(unsigned(address))) <= data_in;
            end if;
            
            -- Sempre lê da memória (operações de leitura são sempre realizadas)
            -- A leitura é síncrona, ocorre na mesma borda de clock da escrita
            data_out_reg <= memory(to_integer(unsigned(address)));
        end if;
    end process;
    
    -- Conexão direta do sinal interno para a saída
    data_out <= data_out_reg;

end Behavioral;
