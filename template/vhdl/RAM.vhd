library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity RAM is
    port(
        clk     : in  std_logic;
        cs      : in  std_logic;
        read    : in  std_logic;
        write   : in  std_logic;
        address : in  std_logic_vector(9 downto 0);
        wrdata  : in  std_logic_vector(31 downto 0);
        rddata  : out std_logic_vector(31 downto 0));
end RAM;

architecture synth of RAM is
    type ram_type is array (0 to 4095) of std_logic_vector(31 downto 0);
    signal ram : ram_type;
    signal flag : std_logic := '0';

begin
    process(clk, cs, read)
    begin
        rddata <= (others => 'Z');
        if cs = '1' then
            rddata <= (others => '0');
            if rising_edge(clk) then
                if read = '1' then
                    rddata <= ram(to_integer(unsigned(address)));
                end if;
                if write = '1' then
                    ram(to_integer(unsigned(address))) <= wrdata;
                end if;
            else 
                if read ='1' then
                    rddata <= (others => 'Z');
                end if;
            end if;
        end if;
    end process;
end synth;
