library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use STD.textio.all;
use ieee.std_logic_textio.all;

entity sigmoid_testbench is
end sigmoid_testbench;

architecture beh of sigmoid_testbench is
    component fast_sigmoid 
    generic (
        Qm : integer; -- for Qm.m # of integer bits
        Qn : integer); --for Qm.n # of decimal bits.  Look at part 4 for better explanation
    port (
        s : in std_logic_vector(Qm+Qn downto 0);
        fs : out std_logic_vector(Qm+Qn downto 0));
    end component;

--Signals
file file_v : text;
signal Qm : integer := 4;
signal Qn : integer := 4;

--Inputs
signal s : std_logic_vector(Qm+Qn downto 0) := (others => '0');        
--Outputs
signal fs : std_logic_vector(Qm+Qn downto 0) := (others => '0');

--Clock period defs
begin
    uut: fast_sigmoid generic map(
        Qm => Qm,
        Qn => Qn)
         port map(
        s => s,
        fs => fs);


stim_proc: process
begin
    --Positive
    -- 8
    s<="010000000";
    wait for 100 ns;
    --4
    s<="001000000";
    wait for 100 ns;
    --1.5
    s<="000011000";
    wait for 100 ns;
    --0
    s<="000000000";
    wait for 100 ns;
    
    --Negative
    -- -8
    s<="110000000";
    wait for 100 ns;
    -- -4
    s<="111000000";
    wait for 100 ns;
    -- -1.5
    s<="111101000";
    wait for 100 ns;

end process;
  
end;
