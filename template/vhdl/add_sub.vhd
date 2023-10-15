library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity add_sub is
    port(
        a        : in  std_logic_vector(31 downto 0);
        b        : in  std_logic_vector(31 downto 0);
        sub_mode : in  std_logic;
        carry    : out std_logic;
        zero     : out std_logic;
        r        : out std_logic_vector(31 downto 0)
    );
end add_sub;

architecture synth of add_sub is
signal mode : std_logic_vector(31 downto 0);
signal xor_b : std_logic_vector(31 downto 0);
signal added : std_logic_vector(32 downto 0);
signal a33 : std_logic_vector(32 downto 0);
signal b33 : std_logic_vector(32 downto 0);
signal vec : std_logic_vector(0 downto 0);
begin
    mode <= (others => sub_mode);
    xor_b  <= b xor mode;
    a33 <= '0' & a;
    b33 <= '0' & xor_b;
    vec(0) <= sub_mode;
    added <= std_logic_vector(unsigned(a33) + unsigned(b33) + unsigned(vec));
    r <= added(31 downto 0);
    carry <= added(32);
    zero <= '1' when added(31 downto 0) = x"00000000" else '0';
end synth;