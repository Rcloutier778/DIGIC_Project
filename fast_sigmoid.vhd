library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity fast_sigmoid is
    port(
        s : in integer;
        fs : out integer);
end fast_sigmoid;

architecture beh of fast_sigmoid is
signal abs_s : integer;
begin
    process (s, abs_s)
        --fs <= s/(1+s);
        
        --abs value of s
        
        --
        if abs_s >= 5 then
            fs<=1;
        elsif abs_s >= 2.375 and abs_s < 5 then
            fs <= 0.03125 * abs_s + 0.84375;
        elsif abs_s >= 1 and abs_s < 2.375 then
            fs <= 0.125 * abs_s + 0.625;
        elsif abs_s >= 0 and abs_s < 1 then
            fs <= 0.25 * abs_s + 0.5;
        end if;
        if s < 0 then
            fs <= 1-fs;
        end if;
    end process;
end architecture beh;
