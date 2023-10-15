library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
entity decoder is
    port(
        address : in  std_logic_vector(15 downto 0);
        cs_LEDS : out std_logic;
        cs_RAM  : out std_logic;
        cs_ROM  : out std_logic;
        cs_buttons : out std_logic
    );
end decoder;

architecture synth of decoder is
begin
    cs_ROM <= '1' when (unsigned(address) >= to_unsigned(0, 16)) and (unsigned(address) <= to_unsigned(4092, 16)) else '0';
    cs_RAM <= '1' when (unsigned(address) >= to_unsigned(4096, 16)) and (unsigned(address) <= to_unsigned(8188, 16)) else '0';
    cs_LEDS <= '1' when (unsigned(address) >= to_unsigned(8192, 16)) and (unsigned(address) <= to_unsigned(8204, 16)) else '0';
    cs_buttons <= '1' when (unsigned(address) >= to_unsigned(8240, 16)) and (unsigned(address) <= to_unsigned(8244, 16)) else '0';    
end synth;
