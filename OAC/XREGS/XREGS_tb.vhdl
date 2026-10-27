library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity tb_XREGS is
end tb_XREGS;

architecture behavior of tb_XREGS is


    component XREGS
        generic (
            WSIZE : natural := 32
        );
        port (
            clk, wren  : in std_logic;
            rs1, rs2, rd : in std_logic_vector(4 downto 0);
            data       : in std_logic_vector(WSIZE-1 downto 0);
            ro1, ro2   : out std_logic_vector(WSIZE-1 downto 0)
        );
    end component;


    constant WSIZE_TB     : natural := 32;
    constant clock_period : time := 10 ns;

    signal clk_tb, wren_tb : std_logic := '0';
    signal rs1_tb, rs2_tb, rd_tb : std_logic_vector(4 downto 0) := (others => '0');
    signal data_tb : std_logic_vector(WSIZE_TB-1 downto 0) := (others => '0');
    signal ro1_tb, ro2_tb : std_logic_vector(WSIZE_TB-1 downto 0);

begin

    uut: XREGS
        generic map (
            WSIZE => WSIZE_TB
        )
        port map (
            clk  => clk_tb,
            wren => wren_tb,
            rs1  => rs1_tb,
            rs2  => rs2_tb,
            rd   => rd_tb,
            data => data_tb,
            ro1  => ro1_tb,
            ro2  => ro2_tb
        );


    clk_process: process
    begin
        clk_tb <= '0';
        wait for clock_period / 2;
        clk_tb <= '1';
        wait for clock_period / 2;
    end process;


    stim_proc: process
    begin
        wait for clock_period;


        wren_tb <= '1';
        for i in 1 to 31 loop
            rd_tb   <= std_logic_vector(to_unsigned(i, 5));
            data_tb <= std_logic_vector(to_unsigned(i * 10, WSIZE_TB));
            wait for clock_period;
        end loop;

        rd_tb   <= "00000";
        data_tb <= X"FFFFFFFF"; -- Valor arbitrário para tentar alterar o x0
        wait for clock_period;

        wren_tb <= '0';

        for i in 1 to 31 loop
            rs1_tb <= std_logic_vector(to_unsigned(i, 5));
            rs2_tb <= std_logic_vector(to_unsigned(i, 5));
            wait for 2 ns; -- Pequena margem de tempo para propagação dos dados

            assert ro1_tb = std_logic_vector(to_unsigned(i * 10, WSIZE_TB))
                report "Erro na leitura do registrador " & integer'image(i) & " na porta ro1"
                severity error;

            assert ro2_tb = std_logic_vector(to_unsigned(i * 10, WSIZE_TB))
                report "Erro na leitura do registrador " & integer'image(i) & " na porta ro2"
                severity error;
        end loop;


        rs1_tb <= "00000";
        rs2_tb <= "00000";
        wait for 2 ns;

        assert ro1_tb = X"00000000"
            report "Erro: Registrador zero (x0) retornou valor diferente de 0 na porta ro1!"
            severity error;

        assert ro2_tb = X"00000000"
            report "Erro: Registrador zero (x0) retornou valor diferente de 0 na porta ro2!"
            severity error;


        report "--- TESTE CONCLUIDO COM SUCESSO: BANCO DE REGISTRADORES VERIFICADO ---" severity note;
        wait;
    end process;

end behavior;