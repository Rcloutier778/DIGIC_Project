library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
--use ieee.std_logic_unsigned.all;
--use ieee.std_logic_signed.all;


entity fast_sigmoid is
    port(
        s : in real;
        fs : out real);
end fast_sigmoid;

architecture beh of fast_sigmoid is

begin
    process (s)
    variable abs_s : real :=0.0;
    variable tfs : real :=0.0;
    begin
        abs_s := abs(s);
        --fs <= s/(1+s);
        
        --abs value of s
        
        --
        if (abs_s >= 5.0) then
            tfs:=1.0;
        elsif (abs_s >= 2.375) and (abs_s < 5.0) then
            tfs := 0.03125 * abs_s + 0.84375;
        elsif abs_s >= 1.0 and abs_s < 2.375 then
            tfs := 0.125 * abs_s + 0.625;
        elsif abs_s >= 0.0 and abs_s < 1.0 then
            tfs := 0.25 * abs_s + 0.5;
        end if;
        if s < 0.0 then
            fs <= 1.0-tfs;
        else
            fs <= tfs;
        end if;
    end process;
end architecture beh;
