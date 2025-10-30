library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity testbench is
end testbench;

architecture test of testbench is
    signal clk, reset, done : std_logic;
    signal result : std_logic_vector(7 downto 0);
    signal flags : std_logic_vector(3 downto 0);
    
    constant CLK_PERIOD : time := 20 ns;
begin
    -- Instância do TopLevel
    DUT: entity work.TopLevel
        port map(
            clk => clk,
            reset => reset,
            result => result,
            flags => flags,
            done => done
        );
    
    -- Processo do clock
    clk_process: process
    begin
        clk <= '0';
        wait for CLK_PERIOD/2;
        clk <= '1';
        wait for CLK_PERIOD/2;
    end process;
    
    -- Processo de estímulo
    stim_process: process
    begin
        -- Reset inicial
        reset <= '1';
        wait for 50 ns;
        reset <= '0';
        
        -- Aguarda a simulação
        wait for 1000 ns;
        
        -- Finaliza
        assert false report "Simulação concluída!" severity note;
        wait;
    end process;
end test;
