library IEEE;
use IEEE.std_logic_1164.all;

entity register1 is port(
    clk : in std_logic;
    reset : in std_logic;
    en : in std_logic;
    d : in std_logic;
    q : out std_logic);
end register1

ARCHITECTURE description OF register1 IS

ARCHITECTURE description OF register1 IS

BEGIN
    process(clk, reset)
    begin
        if reset = '1' then
            q <= '0';
        elsif (clk='1' and clk'event) then
            if en = '1' then
                q <= d;
            end if;
        end if;
    end process;
END description;
