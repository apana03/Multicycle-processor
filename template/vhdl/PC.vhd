library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity PC is
    port(
        clk     : in  std_logic;
        reset_n : in  std_logic;
        en      : in  std_logic;
        sel_a   : in  std_logic;
        sel_imm : in  std_logic;
        add_imm : in  std_logic;
        imm     : in  std_logic_vector(15 downto 0);
        a       : in  std_logic_vector(15 downto 0);
        addr    : out std_logic_vector(31 downto 0)
    );
end PC;

architecture synth of PC is
    signal s_curr : std_logic_vector(31 downto 0);
    signal s_next : std_logic_vector(31 downto 0);
    signal s_addFour : std_logic_vector(31 downto 0);
begin
    dff :process(clk, reset_n)
    begin
        if reset_n = '0' then
            s_curr <= (others => '0');
        elsif rising_edge(clk) then
            s_curr <= s_next;
        end if;
    end process dff;


    s_addFour <= std_logic_vector(signed(s_curr) + 4);
    s_next <= s_addFour when en = '1' else s_curr;                                                
    addr <= s_curr;

end synth;
