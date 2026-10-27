library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity XREGS is
    generic (
        WSIZE : natural := 32
    );
    port (
        clk, wren  : in std_logic;
        rs1, rs2, rd : in std_logic_vector(4 downto 0);
        data       : in std_logic_vector(WSIZE-1 downto 0);
        ro1, ro2   : out std_logic_vector(WSIZE-1 downto 0)
    );
end XREGS;

architecture behavioral of XREGS is

    
    type reg_array is array (0 to 31) of std_logic_vector(WSIZE-1 downto 0);
    
    
    signal registers : reg_array := (others => (others => '0'));

begin
    process(clk)
    begin
        if rising_edge(clk) then
            if wren = '1' and unsigned(rd) /= 0 then
                registers(to_integer(unsigned(rd))) <= data;
            end if;
        end if;
    end process;

    ro1 <= (others => '0') when unsigned(rs1) = 0 else registers(to_integer(unsigned(rs1)));
    ro2 <= (others => '0') when unsigned(rs2) = 0 else registers(to_integer(unsigned(rs2)));

end behavioral;