library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity processor_core_simplified_tb is
end processor_core_simplified_tb;

architecture Behavioral of processor_core_simplified_tb is

    -- Componente a ser testado (DUT - Device Under Test)
    component processor_core_simplified
        Port (
            clk        : in  STD_LOGIC;
            reset      : in  STD_LOGIC;
            opcode_in  : in  STD_LOGIC_VECTOR (7 downto 0);
            data_A_in  : in  STD_LOGIC_VECTOR (7 downto 0);
            data_B_in  : in  STD_LOGIC_VECTOR (7 downto 0);

            ula_result_out    : out STD_LOGIC_VECTOR (7 downto 0);
            ula_cout_out      : out STD_LOGIC;
            ula_zero_flag_out : out STD_LOGIC; -- Nova saída
            reg_read_data_out : out STD_LOGIC_VECTOR (7 downto 0)
        );
    end component;

    -- Sinais para o testbench
    signal clk_tb        : STD_LOGIC := '0';
    signal reset_tb      : STD_LOGIC := '1'; -- Inicia em reset
    signal opcode_in_tb  : STD_LOGIC_VECTOR (7 downto 0) := (others => '0');
    signal data_A_in_tb  : STD_LOGIC_VECTOR (7 downto 0) := (others => '0');
    signal data_B_in_tb  : STD_LOGIC_VECTOR (7 downto 0) := (others => '0');

    signal ula_result_out_tb    : STD_LOGIC_VECTOR (7 downto 0);
    signal ula_cout_out_tb      : STD_LOGIC;
    signal ula_zero_flag_out_tb : STD_LOGIC; -- Novo sinal
    signal reg_read_data_out_tb : STD_LOGIC_VECTOR (7 downto 0);

    -- Constantes de tempo
    constant CLK_PERIOD : time := 10 ns;

    -- Definições de opcodes (Atualizadas)
    constant OPCODE_MOV_IMM  : STD_LOGIC_VECTOR (7 downto 0) := x"00";
    constant OPCODE_ADD_REG  : STD_LOGIC_VECTOR (7 downto 0) := x"01";
    constant OPCODE_ADD_IMM  : STD_LOGIC_VECTOR (7 downto 0) := x"02";
    constant OPCODE_SUB_REG  : STD_LOGIC_VECTOR (7 downto 0) := x"03";
    constant OPCODE_MUL_REG  : STD_LOGIC_VECTOR (7 downto 0) := x"04";
    constant OPCODE_DIV_REG  : STD_LOGIC_VECTOR (7 downto 0) := x"05";
    constant OPCODE_MOD_REG  : STD_LOGIC_VECTOR (7 downto 0) := x"06";
    constant OPCODE_CMP_REG  : STD_LOGIC_VECTOR (7 downto 0) := x"07";
    constant OPCODE_AND_REG  : STD_LOGIC_VECTOR (7 downto 0) := x"08";
    constant OPCODE_OR_REG   : STD_LOGIC_VECTOR (7 downto 0) := x"09";
    constant OPCODE_NOT_REG  : STD_LOGIC_VECTOR (7 downto 0) := x"0A";
    constant OPCODE_XOR_REG  : STD_LOGIC_VECTOR (7 downto 0) := x"0B";
    constant OPCODE_NOP      : STD_LOGIC_VECTOR (7 downto 0) := x"FF";

begin

    -- Instanciar o DUT (Device Under Test)
    DUT : processor_core_simplified
        Port map (
            clk        => clk_tb,
            reset      => reset_tb,
            opcode_in  => opcode_in_tb,
            data_A_in  => data_A_in_tb,
            data_B_in  => data_B_in_tb,

            ula_result_out    => ula_result_out_tb,
            ula_cout_out      => ula_cout_out_tb,
            ula_zero_flag_out => ula_zero_flag_out_tb, -- Conexão do novo sinal
            reg_read_data_out => reg_read_data_out_tb
        );

    -- Geração do clock
    clk_gen : process
    begin
        loop
            clk_tb <= '0';
            wait for CLK_PERIOD / 2;
            clk_tb <= '1';
            wait for CLK_PERIOD / 2;
        end loop;
    end process;

    -- Processo de geração de estímulos
    stimulus_process : process
    begin
        -- 1. Reset inicial
        reset_tb <= '1';
        wait for CLK_PERIOD * 2;
        reset_tb <= '0';
        wait for CLK_PERIOD * 2;

        -- Inicialização dos Registradores
        report "--- Inicialização: Reg 0 = 0x10, Reg 1 = 0x05, Reg 2 = 0x03, Reg 3 = 0x0F ---" severity note;
        -- Escrever 0x10 no Registrador 0
        opcode_in_tb <= OPCODE_MOV_IMM; data_A_in_tb <= x"10"; data_B_in_tb <= x"00"; wait until rising_edge(clk_tb);wait until rising_edge(clk_tb);
        -- Escrever 0x05 no Registrador 1
        opcode_in_tb <= OPCODE_MOV_IMM; data_A_in_tb <= x"05"; data_B_in_tb <= x"01"; wait until rising_edge(clk_tb);wait until rising_edge(clk_tb);
        -- Escrever 0x03 no Registrador 2
        opcode_in_tb <= OPCODE_MOV_IMM; data_A_in_tb <= x"03"; data_B_in_tb <= x"02"; wait until rising_edge(clk_tb);wait until rising_edge(clk_tb);
        -- Escrever 0x0F no Registrador 3
        opcode_in_tb <= OPCODE_MOV_IMM; data_A_in_tb <= x"0F"; data_B_in_tb <= x"03"; wait until rising_edge(clk_tb);wait until rising_edge(clk_tb);

        -- Testes da ULA (Reg 0 = 0x10, Reg 1 = 0x05, Reg 2 = 0x03, Reg 3 = 0x0F)

        -- 1. Teste ADD_REG (Reg 0 + Reg 1 = 0x10 + 0x05 = 0x15)
        report "--- Teste ADD_REG (Reg 0 + Reg 1 = 0x15) ---" severity note;
        opcode_in_tb <= OPCODE_ADD_REG; data_A_in_tb <= x"00"; data_B_in_tb <= x"01"; wait until rising_edge(clk_tb);wait until rising_edge(clk_tb);
        assert (ula_result_out_tb = x"15" and ula_cout_out_tb = '0') report "Test ADD_REG Failed" severity error;

       -- 2. Teste ADD_IMM (Reg 0 + 0x0A = 0x15 + 0x0A = 0x1F)
        report "--- Teste ADD_IMM (Reg 0 + 0x0A = 0x1F) ---" severity note;
        opcode_in_tb <= OPCODE_ADD_IMM; data_A_in_tb <= x"00"; data_B_in_tb <= x"0A"; wait until rising_edge(clk_tb);wait until rising_edge(clk_tb);
        assert (ula_result_out_tb = x"1F" and ula_cout_out_tb = '0') report "Test ADD_IMM Failed" severity error;
        
        -- 3. Teste SUB_REG (Reg 0 - Reg 1 = 0x1F - 0x05 = 0x1A)
        report "--- Teste SUB_REG (Reg 0 - Reg 1 = 0x1A) ---" severity note;
        opcode_in_tb <= OPCODE_SUB_REG; data_A_in_tb <= x"00"; data_B_in_tb <= x"01"; wait until rising_edge(clk_tb);wait until rising_edge(clk_tb);
        assert (ula_result_out_tb = x"1A" and ula_cout_out_tb = '0') report "Test SUB_REG Failed" severity error;

        -- 4. Teste MUL_REG (Reg 1 * Reg 2 = 0x05 * 0x03 = 0x0F)
        report "--- Teste MUL_REG (Reg 1 * Reg 2 = 0x0F) ---" severity note;
        opcode_in_tb <= OPCODE_MUL_REG; data_A_in_tb <= x"01"; data_B_in_tb <= x"02"; wait until rising_edge(clk_tb);wait until rising_edge(clk_tb);
        assert (ula_result_out_tb = x"0F" and ula_cout_out_tb = '0') report "Test MUL_REG Failed" severity error;

        -- 5. Teste DIV_REG (Reg 0 / Reg 2 = 0x1A / 0x03 = 0x08)
        report "--- Teste DIV_REG (Reg 0 / Reg 2 = 0x08) ---" severity note;
        opcode_in_tb <= OPCODE_DIV_REG; data_A_in_tb <= x"00"; data_B_in_tb <= x"02"; wait until rising_edge(clk_tb);wait until rising_edge(clk_tb);
        assert (ula_result_out_tb = x"08" and ula_cout_out_tb = '0') report "Test DIV_REG Failed" severity error;

        -- 6. Teste MOD_REG (Reg 0 mod Reg 2 = 0x1A mod 0x03 = 0x02)
        -- 0x1A = 26. 26 / 3 = 8, resto 2 (0x02)
        report "--- Teste MOD_REG (Reg 0 mod Reg 2 = 0x02) ---" severity note;
        opcode_in_tb <= OPCODE_MOD_REG; data_A_in_tb <= x"00"; data_B_in_tb <= x"02"; wait until rising_edge(clk_tb);wait until rising_edge(clk_tb);
        assert (ula_result_out_tb = x"02" and ula_cout_out_tb = '0') report "Test MOD_REG Failed" severity error;

       -- Re-inicialização para os testes CMP
		report "--- Re-inicialização para Testes CMP ---" severity note;
		opcode_in_tb <= OPCODE_MOV_IMM; data_A_in_tb <= x"05"; data_B_in_tb <= x"01"; wait until rising_edge(clk_tb);wait until rising_edge(clk_tb); -- Reg 1 = 0x05
		opcode_in_tb <= OPCODE_MOV_IMM; data_A_in_tb <= x"0F"; data_B_in_tb <= x"03"; wait until rising_edge(clk_tb);wait until rising_edge(clk_tb); -- Reg 3 = 0x0F

		-- 7. Teste CMP_REG (Reg 3 > Reg 1 ? 0x0F > 0x05 -> True)
		report "--- Teste CMP_REG (Reg 3 > Reg 1 -> True) ---" severity note;
		opcode_in_tb <= OPCODE_CMP_REG; data_A_in_tb <= x"03"; data_B_in_tb <= x"01"; wait until rising_edge(clk_tb);wait until rising_edge(clk_tb);
-- Resultado é 0x01 e Cout é '1' (GT)
		assert (ula_result_out_tb = x"01" and ula_cout_out_tb = '1' and ula_zero_flag_out_tb = '0') report "Test CMP_REG (GT) Failed" severity error;wait until rising_edge(clk_tb);

        -- 8. Teste CMP_REG (Reg 1 > Reg 3 ? 0x05 > 0x0F -> False)
        report "--- Teste CMP_REG (Reg 1 > Reg 3 -> False) ---" severity note;
        opcode_in_tb <= OPCODE_CMP_REG; data_A_in_tb <= x"01"; data_B_in_tb <= x"03"; wait until rising_edge(clk_tb);wait until rising_edge(clk_tb);
        -- Resultado é 0x00 e Cout é '0'
        assert (ula_result_out_tb = x"00" and ula_cout_out_tb = '0' and ula_zero_flag_out_tb = '1') report "Test CMP_REG (LT) Failed" severity error;

        -- 9. Teste CMP_REG (Reg 1 > Reg 1 ? 0x05 > 0x05 -> Equal)
        report "--- Teste CMP_REG (Reg 1 > Reg 1 -> Equal) ---" severity note;
        opcode_in_tb <= OPCODE_CMP_REG; data_A_in_tb <= x"01"; data_B_in_tb <= x"01"; wait until rising_edge(clk_tb);wait until rising_edge(clk_tb);
        -- Resultado é 0x00, Cout é '0', Zero Flag é '1'
        assert (ula_result_out_tb = x"00" and ula_cout_out_tb = '0' and ula_zero_flag_out_tb = '1') report "Test CMP_REG (EQ) Failed" severity error;

        -- 10. Teste AND_REG (Reg 0 AND Reg 3 = 0x02 AND 0x0F = 0x02)
        -- Reg 0 = 0x02 (00000010), Reg 3 = 0x0F (00001111). Resultado = 0x02 (00000010)
        report "--- Teste AND_REG (Reg 0 AND Reg 3 = 0x00) ---" severity note;
        opcode_in_tb <= OPCODE_AND_REG; data_A_in_tb <= x"00"; data_B_in_tb <= x"03"; wait until rising_edge(clk_tb);wait until rising_edge(clk_tb);
        assert (ula_result_out_tb = x"02") report "Test AND_REG Failed" severity error;

        -- 11. Teste OR_REG (Reg 0 OR Reg 3 = 0x02 OR 0x0F = 0x0F)
        -- Reg 0 = 0x02 (00000010), Reg 3 = 0x0F (00001111). Resultado = 0x0F (00001111)
        report "--- Teste OR_REG (Reg 0 OR Reg 3 = 0x0F) ---" severity note;
        opcode_in_tb <= OPCODE_OR_REG; data_A_in_tb <= x"00"; data_B_in_tb <= x"03"; wait until rising_edge(clk_tb);wait until rising_edge(clk_tb);
        assert (ula_result_out_tb = x"0F") report "Test OR_REG Failed" severity error;

        -- 12. Teste XOR_REG (Reg 0 XOR Reg 3 = 0x02 XOR 0x0F = 0x0D)
        -- Reg 0 = 0x02 (00000010), Reg 3 = 0x0F (00001111). Resultado = 0x0D (00001101)
        report "--- Teste XOR_REG (Reg 0 XOR Reg 3 = 0x00) ---" severity note;
        opcode_in_tb <= OPCODE_XOR_REG; data_A_in_tb <= x"00"; data_B_in_tb <= x"03"; wait until rising_edge(clk_tb);wait until rising_edge(clk_tb);
        assert (ula_result_out_tb = x"00") report "Test XOR_REG Failed" severity error;

        -- 13. Teste NOT_REG (NOT Reg 3 = NOT 0x0F = 0xF0)
        -- Reg 3 = 0x0F (00001111). Resultado = 0xF0 (11110000)
        report "--- Teste NOT_REG (NOT Reg 3 = 0xF0) ---" severity note;
        opcode_in_tb <= OPCODE_NOT_REG; data_A_in_tb <= x"03"; data_B_in_tb <= x"00"; wait until rising_edge(clk_tb);wait until rising_edge(clk_tb);
        assert (ula_result_out_tb = x"F0") report "Test NOT_REG Failed" severity error;

        report "Todos os testes concluídos com sucesso!" severity note;
        wait for 100 ns;
        assert false report "Fim da simulação: testes OK" severity failure;
    end process stimulus_process;

end Behavioral;
