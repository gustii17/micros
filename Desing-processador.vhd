library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

--------------------------------------------------------------------------------
-- alu_8_bit.vhd 
--------------------------------------------------------------------------------
entity alu_8_bit is
    Port (
        clk       : in  STD_LOGIC;
        reset     : in  STD_LOGIC;
        A_in      : in  STD_LOGIC_VECTOR (7 downto 0);
        B_in      : in  STD_LOGIC_VECTOR (7 downto 0);
        ALU_Sel   : in  STD_LOGIC_VECTOR (3 downto 0);
        Result    : out STD_LOGIC_VECTOR (7 downto 0);
        Cout      : out STD_LOGIC;
        Zero_Flag : out STD_LOGIC
    );
end alu_8_bit;

architecture Behavioral of alu_8_bit is
    -- Constantes de operação
    constant ALU_ADD : STD_LOGIC_VECTOR(3 downto 0) := "0000";
    constant ALU_SUB : STD_LOGIC_VECTOR(3 downto 0) := "0001";
    constant ALU_MUL : STD_LOGIC_VECTOR(3 downto 0) := "0010";
    constant ALU_DIV : STD_LOGIC_VECTOR(3 downto 0) := "0011";
    constant ALU_MOD : STD_LOGIC_VECTOR(3 downto 0) := "0100";
    constant ALU_CMP : STD_LOGIC_VECTOR(3 downto 0) := "0101";
    constant ALU_AND : STD_LOGIC_VECTOR(3 downto 0) := "0110";
    constant ALU_OR  : STD_LOGIC_VECTOR(3 downto 0) := "0111";
    constant ALU_NOT : STD_LOGIC_VECTOR(3 downto 0) := "1000";
    constant ALU_XOR : STD_LOGIC_VECTOR(3 downto 0) := "1001";

    -- Registradores de saída
    signal reg_result    : STD_LOGIC_VECTOR(7 downto 0) := (others => '0');
    signal reg_cout      : STD_LOGIC := '0';
    signal reg_zero_flag : STD_LOGIC := '0';

begin
    process(A_in, B_in, ALU_Sel)
        variable A_u, B_u : unsigned(7 downto 0);
        variable v_result : unsigned(7 downto 0);
        variable v_cout   : STD_LOGIC := '0';
        variable v_zero   : STD_LOGIC := '0';
    begin
        A_u := unsigned(A_in);
        B_u := unsigned(B_in);
        v_result := (others => '0');
        v_cout := '0';
        v_zero := '0';

        case ALU_Sel is
            when ALU_ADD =>
                v_result := resize(A_u + B_u, 8);
                if (A_u + B_u) > 255 then
                    v_cout := '1';
                end if;

            when ALU_SUB =>
                v_result := resize(A_u - B_u, 8);
                if A_u < B_u then
                    v_cout := '1';
                end if;

            when ALU_MUL =>
                v_result := resize(A_u * B_u, 8);
                if (A_u * B_u) > 255 then
                    v_cout := '1';
                end if;

            when ALU_DIV =>
                if B_u /= 0 then
                    v_result := A_u / B_u;
                else
                    v_result := (others => '1');
                    v_cout := '1';
                end if;

            when ALU_MOD =>
                if B_u /= 0 then
                    v_result := A_u mod B_u;
                else
                    v_result := (others => '1');
                    v_cout := '1';
                end if;

            when ALU_CMP =>
                if A_u > B_u then
                    v_result := (others => '0');
                    v_result(0) := '1';
                    v_cout := '1';
                else
                    v_result := (others => '0');
                    v_cout := '0';
                end if;
                if A_u = B_u then
                    v_zero := '1';
                end if;

            when ALU_AND =>
                v_result := unsigned(A_in and B_in);

            when ALU_OR =>
                v_result := unsigned(A_in or B_in);

            when ALU_NOT =>
                v_result := unsigned(not A_in);

            when ALU_XOR =>
                v_result := unsigned(A_in xor B_in);

            when others =>
                v_result := (others => '0');
                v_cout := '0';
        end case;

        if v_result = 0 then
            v_zero := '1';
        end if;

        -- Atualiza registradores internos (síncronos depois)
        reg_result <= std_logic_vector(v_result);
        reg_cout   <= v_cout;
        reg_zero_flag <= v_zero;
    end process;

    -- Registrador síncrono (armazenamento dos resultados)
    process(clk, reset)
    begin
        if reset = '1' then
            Result <= (others => '0');
            Cout <= '0';
            Zero_Flag <= '0';
        elsif rising_edge(clk) then
            Result <= reg_result;
            Cout <= reg_cout;
            Zero_Flag <= reg_zero_flag;
        end if;
    end process;
end Behavioral;


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

--------------------------------------------------------------------------------
-- Banco_de_registrador_simplificado
--------------------------------------------------------------------------------
entity register_bank_simplified is
    Generic (
        NUM_REGISTERS : natural := 4; -- Número de registradores no banco
        DATA_WIDTH    : natural := 8    -- Largura dos dados em bits
    );
    Port (
        clk        : in  STD_LOGIC;
        reset      : in  STD_LOGIC;
        write_en   : in  STD_LOGIC; -- Habilita escrita
        read_en_A  : in  STD_LOGIC; -- Habilita leitura para operando A
        read_en_B  : in  STD_LOGIC; -- Habilita leitura para operando B
        write_addr : in  STD_LOGIC_VECTOR (1 downto 0); -- Endereço para escrita (2 bits para 4 registradores)
        read_addr_A  : in  STD_LOGIC_VECTOR (1 downto 0);  -- Endereço para leitura do operando A
        read_addr_B  : in  STD_LOGIC_VECTOR (1 downto 0);  -- Endereço para leitura do operando B
        write_data : in  STD_LOGIC_VECTOR (DATA_WIDTH-1 downto 0);
        read_data_A  : out STD_LOGIC_VECTOR (DATA_WIDTH-1 downto 0); -- Saída do dado lido para operando A
        read_data_B  : out STD_LOGIC_VECTOR (DATA_WIDTH-1 downto 0)  -- Saída do dado lido para operando B
    );
end register_bank_simplified;

architecture Behavioral of register_bank_simplified is

    -- Tipo de array para armazenar os registradores
    type reg_array_t is array (0 to NUM_REGISTERS-1) of STD_LOGIC_VECTOR (DATA_WIDTH-1 downto 0);
    signal registers : reg_array_t := (others => (others => '0'));
    constant ZERO_VECTOR : STD_LOGIC_VECTOR(DATA_WIDTH-1 downto 0) := (others => '0');

begin

    -- Processo síncrono para escrita e reset
    process (clk, reset)
    begin
        if reset = '1' then
            registers <= (others => (others => '0')); -- Reseta todos os registradores
        elsif rising_edge(clk) then
            if write_en = '1' then
                registers(to_integer(unsigned(write_addr))) <= write_data;
            end if;
        end if;
    end process;

    -- Leitura assíncrona dos registradores
    read_data_A <= registers(to_integer(unsigned(read_addr_A)));
    read_data_B <= registers(to_integer(unsigned(read_addr_B)));

end Behavioral;

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

--------------------------------------------------------------------------------
-- decodificador_simplificado
--------------------------------------------------------------------------------
entity decoder_controller_simplified is
    Port (
        opcode_in         : in  STD_LOGIC_VECTOR (7 downto 0);
        data_A_in         : in  STD_LOGIC_VECTOR (7 downto 0);
        data_B_in         : in  STD_LOGIC_VECTOR (7 downto 0);

        -- Saídas de Controle para ULA
        alu_enable        : out STD_LOGIC;
        alu_sel           : out STD_LOGIC_VECTOR (3 downto 0); -- Seleção da operação da ULA
        alu_A_src_sel     : out STD_LOGIC; -- 0: Dado do Registrador A, 1: N/A
        alu_B_src_sel     : out STD_LOGIC; -- 0: Dado do Registrador B, 1: Dado Imediato (data_B_in)

        -- Saídas para o Banco de Registradores
        reg_write_en      : out STD_LOGIC;
        reg_read_en_A     : out STD_LOGIC;
        reg_read_en_B     : out STD_LOGIC;
        reg_write_addr    : out STD_LOGIC_VECTOR (1 downto 0);
        reg_read_addr_A   : out STD_LOGIC_VECTOR (1 downto 0);
        reg_read_addr_B   : out STD_LOGIC_VECTOR (1 downto 0);
        reg_write_data    : out STD_LOGIC_VECTOR (7 downto 0)
    );
end decoder_controller_simplified;

architecture Behavioral of decoder_controller_simplified is
    -- Opcodes do Processador (Instruções)
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
    constant OPCODE_NOT_REG  : STD_LOGIC_VECTOR (7 downto 0) := x"0A"; -- NOT só precisa de um operando (data_A_in)
    constant OPCODE_XOR_REG  : STD_LOGIC_VECTOR (7 downto 0) := x"0B";

    -- Opcodes da ULA (devem ser os mesmos definidos em alu_8_bit)
    constant ALU_ADD : STD_LOGIC_VECTOR(3 downto 0) := "0000";
    constant ALU_SUB : STD_LOGIC_VECTOR(3 downto 0) := "0001";
    constant ALU_MUL : STD_LOGIC_VECTOR(3 downto 0) := "0010";
    constant ALU_DIV : STD_LOGIC_VECTOR(3 downto 0) := "0011";
    constant ALU_MOD : STD_LOGIC_VECTOR(3 downto 0) := "0100";
    constant ALU_CMP : STD_LOGIC_VECTOR(3 downto 0) := "0101";
    constant ALU_AND : STD_LOGIC_VECTOR(3 downto 0) := "0110";
    constant ALU_OR  : STD_LOGIC_VECTOR(3 downto 0) := "0111";
    constant ALU_NOT : STD_LOGIC_VECTOR(3 downto 0) := "1000";
    constant ALU_XOR : STD_LOGIC_VECTOR(3 downto 0) := "1001";

begin
    process (opcode_in, data_A_in, data_B_in)
    begin
        -- Valores padrão (NOP)
        alu_enable        <= '0';
        alu_sel           <= (others => '0');
        alu_A_src_sel     <= '0';
        alu_B_src_sel     <= '0';
        reg_write_en      <= '0';
        reg_read_en_A     <= '0';
        reg_read_en_B     <= '0';
        reg_write_addr    <= (others => '0');
        reg_read_addr_A   <= (others => '0');
        reg_read_addr_B   <= (others => '0');
        reg_write_data    <= (others => '0');

        case opcode_in is
            when OPCODE_MOV_IMM =>
                reg_write_en   <= '1';
                reg_write_addr <= data_B_in(1 downto 0); -- Endereço de destino
                reg_write_data <= data_A_in;             -- Dado imediato

            -- Operações Aritméticas/Lógicas (Registrador para Registrador)
            when OPCODE_ADD_REG | OPCODE_SUB_REG | OPCODE_MUL_REG | OPCODE_DIV_REG |
                 OPCODE_MOD_REG | OPCODE_CMP_REG | OPCODE_AND_REG | OPCODE_OR_REG |
                 OPCODE_XOR_REG =>
                alu_enable     <= '1';
                reg_read_en_A  <= '1';
                reg_read_en_B  <= '1';
                reg_read_addr_A <= data_A_in(1 downto 0); -- Endereço do operando A
                reg_read_addr_B <= data_B_in(1 downto 0); -- Endereço do operando B
                alu_A_src_sel  <= '0'; -- A vem do Registrador A
                alu_B_src_sel  <= '0'; -- B vem do Registrador B
                reg_write_addr <= data_A_in(1 downto 0); -- Resultado escrito de volta no Registrador A

                -- Seleção da ULA
                case opcode_in is
                    when OPCODE_ADD_REG => alu_sel <= ALU_ADD; reg_write_en <= '1';
                    when OPCODE_SUB_REG => alu_sel <= ALU_SUB; reg_write_en <= '1';
                    when OPCODE_MUL_REG => alu_sel <= ALU_MUL; reg_write_en <= '1';
                    when OPCODE_DIV_REG => alu_sel <= ALU_DIV; reg_write_en <= '1';
                    when OPCODE_MOD_REG => alu_sel <= ALU_MOD; reg_write_en <= '1';
                    when OPCODE_CMP_REG => alu_sel <= ALU_CMP; reg_write_en <= '0'; -- Comparação não escreve no registrador
                    when OPCODE_AND_REG => alu_sel <= ALU_AND; reg_write_en <= '1';
                    when OPCODE_OR_REG  => alu_sel <= ALU_OR;  reg_write_en <= '1';
                    when OPCODE_XOR_REG => alu_sel <= ALU_XOR; reg_write_en <= '1';
                    when others => alu_sel <= (others => '0'); reg_write_en <= '0';
                end case;

            when OPCODE_NOT_REG =>
                alu_enable     <= '1';
                reg_read_en_A  <= '1';
                reg_read_en_B  <= '0'; -- Não precisa ler o B
                reg_read_addr_A <= data_A_in(1 downto 0); -- Endereço do operando A
                alu_A_src_sel  <= '0'; -- A vem do Registrador A
                alu_B_src_sel  <= '0'; -- B (não usado)
                alu_sel        <= ALU_NOT;
                reg_write_en   <= '1';
                reg_write_addr <= data_A_in(1 downto 0); -- Resultado escrito de volta no Registrador A

            -- Operação Aritmética com Imediato (ADD_IMM)
            when OPCODE_ADD_IMM =>
                alu_enable     <= '1';
                reg_read_en_A  <= '1';
                reg_read_en_B  <= '0';
                reg_read_addr_A <= data_A_in(1 downto 0); -- Endereço do operando A
                alu_A_src_sel  <= '0'; -- A vem do Registrador A
                alu_B_src_sel  <= '1'; -- B vem do dado imediato (data_B_in)
                alu_sel        <= ALU_ADD;
                reg_write_en   <= '1';
                reg_write_addr <= data_A_in(1 downto 0); -- Resultado escrito de volta no Registrador A

            when others =>
                null;
        end case;
    end process;
end Behavioral;

--------------------------------------------------------------------------------
-- processor_core_simplified 
--------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity processor_core_simplified is
    Port (
        clk        : in  STD_LOGIC;
        reset      : in  STD_LOGIC;
        opcode_in  : in  STD_LOGIC_VECTOR (7 downto 0);
        data_A_in  : in  STD_LOGIC_VECTOR (7 downto 0);
        data_B_in  : in  STD_LOGIC_VECTOR (7 downto 0);
        ula_result_out    : out STD_LOGIC_VECTOR (7 downto 0);
        ula_cout_out      : out STD_LOGIC;
        ula_zero_flag_out : out STD_LOGIC;
        reg_read_data_out : out STD_LOGIC_VECTOR (7 downto 0)
    );
end processor_core_simplified;

architecture Structural of processor_core_simplified is

    -- Componentes -------------------------------------------------------------
    component alu_8_bit
        Port (
            clk       : in  STD_LOGIC;
            reset     : in  STD_LOGIC;
            A_in      : in  STD_LOGIC_VECTOR (7 downto 0);
            B_in      : in  STD_LOGIC_VECTOR (7 downto 0);
            ALU_Sel   : in  STD_LOGIC_VECTOR (3 downto 0);
            Result    : out STD_LOGIC_VECTOR (7 downto 0);
            Cout      : out STD_LOGIC;
            Zero_Flag : out STD_LOGIC
        );
    end component;

    component register_bank_simplified
        Generic (
            NUM_REGISTERS : natural := 4;
            DATA_WIDTH    : natural := 8
        );
        Port (
            clk        : in  STD_LOGIC;
            reset      : in  STD_LOGIC;
            write_en   : in  STD_LOGIC;
            read_en_A  : in  STD_LOGIC;
            read_en_B  : in  STD_LOGIC;
            write_addr : in  STD_LOGIC_VECTOR (1 downto 0);
            read_addr_A  : in  STD_LOGIC_VECTOR (1 downto 0);
            read_addr_B  : in  STD_LOGIC_VECTOR (1 downto 0);
            write_data : in  STD_LOGIC_VECTOR (DATA_WIDTH-1 downto 0);
            read_data_A  : out STD_LOGIC_VECTOR (DATA_WIDTH-1 downto 0);
            read_data_B  : out STD_LOGIC_VECTOR (DATA_WIDTH-1 downto 0)
        );
    end component;

    component decoder_controller_simplified
        Port (
            opcode_in         : in  STD_LOGIC_VECTOR (7 downto 0);
            data_A_in         : in  STD_LOGIC_VECTOR (7 downto 0);
            data_B_in         : in  STD_LOGIC_VECTOR (7 downto 0);
            alu_enable        : out STD_LOGIC;
            alu_sel           : out STD_LOGIC_VECTOR (3 downto 0);
            alu_A_src_sel     : out STD_LOGIC;
            alu_B_src_sel     : out STD_LOGIC;
            reg_write_en      : out STD_LOGIC;
            reg_read_en_A     : out STD_LOGIC;
            reg_read_en_B     : out STD_LOGIC;
            reg_write_addr    : out STD_LOGIC_VECTOR (1 downto 0);
            reg_read_addr_A   : out STD_LOGIC_VECTOR (1 downto 0);
            reg_read_addr_B   : out STD_LOGIC_VECTOR (1 downto 0);
            reg_write_data    : out STD_LOGIC_VECTOR (7 downto 0)
        );
    end component;

    -- Sinais internos ---------------------------------------------------------
    signal s_alu_enable     : STD_LOGIC;
    signal s_alu_sel        : STD_LOGIC_VECTOR (3 downto 0);
    signal s_alu_A_src_sel  : STD_LOGIC;
    signal s_alu_B_src_sel  : STD_LOGIC;
    signal s_reg_write_en   : STD_LOGIC;
    signal s_reg_read_en_A  : STD_LOGIC;
    signal s_reg_read_en_B  : STD_LOGIC;
    signal s_reg_write_addr : STD_LOGIC_VECTOR (1 downto 0);
    signal s_reg_read_addr_A: STD_LOGIC_VECTOR (1 downto 0);
    signal s_reg_read_addr_B: STD_LOGIC_VECTOR (1 downto 0);
    signal s_reg_write_data : STD_LOGIC_VECTOR (7 downto 0);

    signal s_alu_A_in, s_alu_B_in : STD_LOGIC_VECTOR (7 downto 0);
    signal s_ula_result           : STD_LOGIC_VECTOR (7 downto 0);
    signal s_ula_cout             : STD_LOGIC;
    signal s_ula_zero_flag        : STD_LOGIC;
    signal s_reg_read_data_A, s_reg_read_data_B : STD_LOGIC_VECTOR (7 downto 0);
    signal s_final_write_data     : STD_LOGIC_VECTOR (7 downto 0);

begin

    -- Decoder ----------------------------------------------------------------
    DECODER_CTRL : decoder_controller_simplified
        Port map (
            opcode_in       => opcode_in,
            data_A_in       => data_A_in,
            data_B_in       => data_B_in,
            alu_enable      => s_alu_enable,
            alu_sel         => s_alu_sel,
            alu_A_src_sel   => s_alu_A_src_sel,
            alu_B_src_sel   => s_alu_B_src_sel,
            reg_write_en    => s_reg_write_en,
            reg_read_en_A   => s_reg_read_en_A,
            reg_read_en_B   => s_reg_read_en_B,
            reg_write_addr  => s_reg_write_addr,
            reg_read_addr_A => s_reg_read_addr_A,
            reg_read_addr_B => s_reg_read_addr_B,
            reg_write_data  => s_reg_write_data
        );

    -- Seleção de entradas da ULA ----------------------------------------------
    s_alu_A_in <= s_reg_read_data_A;
    s_alu_B_in <= s_reg_read_data_B when s_alu_B_src_sel = '0' else data_B_in;
    -- Instanciação da ULA registrada ------------------------------------------
    ULA : alu_8_bit
        Port map (
            clk       => clk,
            reset     => reset,
            A_in      => s_alu_A_in,
            B_in      => s_alu_B_in,
            ALU_Sel   => s_alu_sel,
            Result    => s_ula_result,
            Cout      => s_ula_cout,
            Zero_Flag => s_ula_zero_flag
        );

    -- Seleção do dado final de escrita ----------------------------------------
    s_final_write_data <= s_ula_result when s_alu_enable = '1' else s_reg_write_data;

    -- Banco de registradores --------------------------------------------------
    REG_BANK : register_bank_simplified
        Generic map (NUM_REGISTERS => 4, DATA_WIDTH => 8)
        Port map (
            clk         => clk,
            reset       => reset,
            write_en    => s_reg_write_en,
            read_en_A   => s_reg_read_en_A,
            read_en_B   => s_reg_read_en_B,
            write_addr  => s_reg_write_addr,
            read_addr_A => s_reg_read_addr_A,
            read_addr_B => s_reg_read_addr_B,
            write_data  => s_final_write_data,
            read_data_A => s_reg_read_data_A,
            read_data_B => s_reg_read_data_B
        );

    -- Saídas de debug ---------------------------------------------------------
    ula_result_out    <= s_ula_result;
    ula_cout_out      <= s_ula_cout;
    ula_zero_flag_out <= s_ula_zero_flag;
    reg_read_data_out <= s_reg_read_data_A;

end Structural;
