library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

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
    type xtype is array (0 to H)  of std_logic_vector(1+Qm+Qn downto 0);
    signal x : xtype := (others => (others => '0'));
    --Weights
    type Wtype is array (0 to N+H+1, 0 to N+H+1) of std_logic_vector(1+Qm+Qn downto 0); --0,1, ... N,N+1, ... N+H+1
    signal W : Wtype;    
    type stype is array (1 to N+H+1) of std_logic_vector(1+Qm+Qn downto 0);-- := (others=> (others => '0'));
    signal s : stype := (others => (others=>'0'));
    type fstype is array (1 to N+H+1) of std_logic_vector(1+Qm+Qn downto 0);
    signal fs : fstype := (others => (others=> '0'));
    --variable s : real := 0.0;
    
    component fast_sigmoid
        port(
            s : in std_logic_vector(Qm+Qn+1 downto 0);
            fs : out std_logic_vector(Qm+Qn+1 downto 0));
    end component;
begin
    
    GEN_FAST_SIGMOID:
    for I in 1 to H generate
        fast_sigmoidX : fast_sigmoid 
            generic map (Qn=>Qn, Qm=>Qm) 
            port map (s(I+N+1), fs(I+N+1)) ;
    end generate GEN_FAST_SIGMOID;
    process (u)
    variable a : integer; --loop 
    variable b : integer;
    variable tempS : signed(1+Qm+Qn downto 0) := (others=>'0');
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
        x(0) <= std_logic_vector(signed(u));
        --x(0)(a) := Real(to_integer(unsigned'('0' & u(a))));
        for a in 1 to H loop
            --s = --W^L DOT x^(l-L)
            tempS := (others=>'0');
            for b in 1 to N+H+1 loop            
                tempS := tempS + (signed(x(a-1)) * signed(W(N+a,b)));
            s(a) <= std_logic_vector(tempS);
            x(a) <= fs(a);
            end loop;
        end loop;
    end process;
end architecture beh;