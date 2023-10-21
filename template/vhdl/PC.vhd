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
    signal s_add_imm : std_logic_vector(31 downto 0);
    signal s_sel_a : std_logic_vector(31 downto 0);
    signal s_sel_imm : std_logic_vector(31 downto 0);

begin
    dff :process(clk, reset_n)
    begin
        if reset_n = '0' then
            s_curr <= (others => '0');
        elsif rising_edge(clk) and en = '1' then
                s_curr <= s_next;
        end if;
    end process dff;


    s_addFour <= std_logic_vector(signed(s_curr) + signed(4, 32));
    s_add_imm <= std_logic_vector(signed(s_curr) + signed(imm, 32));
    s_sel_a <= (15 downto 0 =>'0') &( a(15 downto 2)) & "00";
    s_sel_imm <= (15 downto 0 =>'0') & (imm(13 downto 0)) & "00";
    s_next <= s_sel_a when sel_a = 1 else
              s_add_imm when add_imm = 1 else
              s_sel_imm when sel_imm = 1 else
              s_addFour; 
    addr <= s_curr;

end synth;
