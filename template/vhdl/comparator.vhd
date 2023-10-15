library ieee;
use ieee.std_logic_1164.all;

entity comparator is
    port(
        a_31    : in  std_logic;
        b_31    : in  std_logic;
        diff_31 : in  std_logic;
        carry   : in  std_logic;
        zero    : in  std_logic;
        op      : in  std_logic_vector(2 downto 0);
        r       : out std_logic
    );
end comparator;

architecture synth of comparator is
    Signal aSmallerBSigned : std_logic;
    Signal aSmallerBUnsigned : std_logic;
    signal aBiggerBSigned : std_logic;
    signal aBiggerBUnsigned : std_logic ;
    
begin

    aSmallerBSigned <= '1' when  ( (a_31 and not b_31) or ((a_31 xnor b_31) and (diff_31 or zero)) ) else '0';
    aBiggerBSigned <= '1' when ( (not a_31 and b_31) or ((a_31 xnor b_31) and (not diff_31 and not zero)) ) else '0';
    aSmallerBUnsigned <= '1' when (not carry or zero) else '0';
    aBiggerBUnsigned <= '1' when (carry and not zero) else '0';

    with op select r <=
        aSmallerBSigned when "001",
        aBiggerBSigned when "010",
        not (zero) when "011",
        zero when "100",
        aSmallerBUnsigned when "101",
        aBiggerBUnsigned when "110",
        zero when others;

end synth;
