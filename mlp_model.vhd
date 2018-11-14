library ieee;
use ieee.std_logic_1164.all;


--N, H, M

entity mlp_model is
    generic (
        N : integer; -- # inputs
        H : integer; -- # hidden
        M : integer; -- # outputs
        m : integer; -- for Qm.n
        n : integer); --for Qm.n
    port (
        SI : in std_logic; --scan chain input (serial input used to set all weights and bias values in network for testing)
        SE : in std_logic; --
        clk : in std_logic;
        u : in std_logic_vector(N*(m+n+1) downto 0);
        yhat : out std_logic_vector(M*(m+n+1) downto 0);
        );

end mlp_model;

architecture beh of mlp_model is
    -- x is 2D integer array
    type x2 is array (0 to (N*(m+n+1))) of integer;
    type x is array (0 to l) of x2;
    --Weights
    type W is array (0 to l) of integer;
    signal s : integer;
    signal a : integer; --loop 
    signal l : integer; --size of x, must be set

    component fast_sigmoid
        port(
            s : in integer;
            fs : out integer);
    end component;
begin
    GEN_FAS_SIGMOID:
    for I in 0 to (N*(m+n+1)) generate
        fast_sigmoidX : fast_sigmoid port map
            (s(I), fs(I));
    end generate GEN_FAST_SIGMOID;
    process (u)
    begin
        --y=hw(u)
        --x(1) = u
        --x(l) = f((W^l)*x^(l-1))
        -- (W^l)*x^(l-1) is a dot product, should produce a single value
        --f(s) = 1/(1+e^(-s)) --sigmoid
        --fast sigmoid: f(s) = s/(1+abs(s))
        
        --activation function
        --x(0)
        for a in 0 to (N*(m+n+1)) loop
            x(0)(a) <= to_integer(unsigned'('0' & u(a));
        end loop;
        for a in 0 to l loop
            s = --W^l DOT x^(l-1)
            x(
        end loop;


    end process;


end architecture beh;
