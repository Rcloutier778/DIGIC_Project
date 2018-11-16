library ieee;
use ieee.std_logic_1164.all;


--N, H, M

entity mlp_model is
    generic (
        N : integer; -- # inputs
        H : integer; -- # hidden
        M : integer; -- # outputs
        Qm : integer; -- for Qm.m # of integer bits
        Qn : integer); --for Qm.n # of decimal bits.  Look at part 4 for better explanation
    port (
        SI : in std_logic; --scan chain input (serial input used to set all weights and bias values in network for testing)
        SE : in std_logic; --
        clk : in std_logic;
        u : in std_logic_vector(N*(Qm+Qn+1) downto 0);
        yhat : out std_logic_vector(M*(Qm+Qn+1) downto 0));

end mlp_model;

architecture beh of mlp_model is
    -- x is 2D integer array
    --type x2 is array (0 to (N*(Qm+Qn+1))) of real;
    --type x is array (0 to L) of x2;
    type x is array (0 to L)  of real;
    --Weights
    type W is array (0 to N+H+1) of real; --0,1, ... N,N+1, ... N+H+1
    type s is array (1 to L) of real := 0.0;
    --variable s : real := 0.0;
    variable a : integer; --loop 
    variable L : integer; --size of x, must be set
    variable b : integer;
    variable tempS : real := 0.0;
    component fast_sigmoid
        port(
            s : in integer;
            fs : out integer);
    end component;
begin
    GEN_FAS_SIGMOID:
    for I in 1 to L generate
        fast_sigmoidX : fast_sigmoid port map
            (s(I), fs(I)) generic map (Qn);
    end generate GEN_FAST_SIGMOID;
    process (u)
    begin
        --y=hw(u)
        --x(1) = u
        --x(L) = f((W^L)*x^(l-L))
        -- (W^L)*x^(l-L) is a dot product, should produce a single value
        --f(s) = 1/(1+e^(-s)) --sigmoid
        --fast sigmoid: f(s) = s/(1+abs(s))
        --TODO put all real into Qm.n format for performance?
        
        --activation function
        --u has 1 signed bit, m integer bits, n decimal bits
        x(0) := Real(to_integer(unsigned(u)))/(10*n);
        --x(0)(a) := Real(to_integer(unsigned'('0' & u(a))));
        for a in 1 to L loop
            --s = --W^L DOT x^(l-L)
            tempS := 0.0;
            for b in 1 to W'range loop            
                tempS := tempS + (x(a-1) * W(b));
            s(a) := tempS;
            x(a) := fs(a)
        end loop;


    end process;


end architecture beh;
