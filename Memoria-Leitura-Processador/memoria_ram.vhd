library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity memory is
    generic (
        DATA_WIDTH : integer := 8;  -- Largura do dado (8 bits)
        ADDR_WIDTH : integer := 12   -- Largura do endereço (4K de memória)
    );
    port (
        clk      : in  std_logic;   -- Sinal de Clock (Entrada)
        we       : in  std_logic;  -- Habilita a escrita
        addr     : in  std_logic_vector(ADDR_WIDTH-1 downto 0); -- Endereço que você quer acessar 
        data_in  : in  std_logic_vector(DATA_WIDTH-1 downto 0); -- Dado para escrever na memória
        data_out : out std_logic_vector(DATA_WIDTH-1 downto 0) -- Dado lido da memória
    );
end entity memory;

architecture rtl of memory is -- Declaração da arquitetura da entidade memory
    type mem_type is array (0 to (2**ADDR_WIDTH)-1) of std_logic_vector(DATA_WIDTH-1 downto 0); -- Cria um array 
    signal mem : mem_type := (others => (others => '0')); -- Define sinal do tipo mem_type  e incializa a memória zerada
begin
    process(clk)
    begin
        if rising_edge(clk) then -- Executa quando clock muda (0 -> 1)
            if we = '1' then -- Se o sinal "we" tive em 1 habilita escrita
                mem(to_integer(unsigned(addr))) <= data_in;
            end if;
            data_out <= mem(to_integer(unsigned(addr))); -- Leitura da memória armazenando em data_out
        end if;
    end process;
end architecture behavioral;
