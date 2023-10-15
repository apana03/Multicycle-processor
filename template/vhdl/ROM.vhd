library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity ROM is
    port(
        clk     : in  std_logic;
        cs      : in  std_logic;
        read    : in  std_logic;
        address : in  std_logic_vector(9 downto 0);
        rddata  : out std_logic_vector(31 downto 0)
    );
end ROM;

architecture synth of ROM is
    type rom_type is array(0 to 4095) of std_logic_vector(31 downto 0);
    signal rom : rom_type;
    signal rddata_reg : std_logic_vector(31 downto 0);
begin
    rom_block_inst : entity work.ROM_Block
        port map(
            address => address,
            clock   => clk,
            q => rddata
        );
    process(clk)
    begin 
        if rising_edge(clk) then
            if cs = '1' then
                rddata_reg <= rom(to_integer(unsigned(address)));
            end if;
        end if;
        rddata <= rddata_reg;
    end process;
end synth;
