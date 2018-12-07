library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

--N, H, M

entity mlp_model is
    generic (
        N : integer :=0; -- # inputs
        H : integer :=0; -- # hidden
        M : integer :=0; -- # outputs
        Qm : integer :=0; -- for Qm.m # of integer bits
        Qn : integer :=0); --for Qm.n # of decimal bits.  Look at part 4 for better explanation
    port (
        clk : in std_logic;
        reset : in std_logic;
        SI : in std_logic; --scan chain input (serial input used to set all weights and bias values in network for testing)
        SE : in std_logic; --
        u : in std_logic_vector(N*(Qm+Qn+1)-1 downto 0);
        yhat : out std_logic_vector(M*(Qm+Qn+1)-1 downto 0));

end mlp_model;

architecture beh of mlp_model is
  
    type xtype is array (0 to N+H+1+M)  of std_logic_vector(Qm+Qn downto 0);
    signal x : xtype := (others => (others => '0'));
    --Weights
    type Wtype is array (0 to N+H+1+M, 0 to N+H+1+M) of std_logic_vector(Qm+Qn downto 0); --0,1, ... N,N+1, ... N+H+1
    signal W : Wtype;    
    type stype is array (0 to N+H+2) of std_logic_vector(Qm+Qn downto 0);-- := (others=> (others => '0'));
    signal s : stype := (others => (others=>'0'));
    type fstype is array (0 to N+H+2) of std_logic_vector(Qm+Qn downto 0);
    signal fs : fstype := (others => (others=> '0'));
    
    component fast_sigmoid
        generic( Qn : integer; Qm : integer);
        port(
            s : in std_logic_vector(Qm+Qn downto 0);
            fs : out std_logic_vector(Qm+Qn downto 0));
    end component;
begin
    
    GEN_FAST_SIGMOID:
    for I in 1 to H generate
        fast_sigmoidX : fast_sigmoid 
            generic map (Qn=>Qn, Qm=>Qm) 
            port map (s=> s(I+N+1), fs => fs(I+N+1)) ;
    end generate GEN_FAST_SIGMOID;
    
    process (clk, reset, u, SE)
    variable a : integer; --loop 
    variable b : integer;
    variable tempS : signed(Qm+Qn downto 0) := (others=>'0');
    variable tempSS : signed(2*(Qm+Qn+1)-1 downto 0) := (others=>'0');
    variable W_Index_Counter : integer :=0;
    variable W_Node_Counter : integer :=0;
    variable W_Node_Counter2 : integer :=0;
    begin
        if (reset = '0') then
            --Reset is just power input 
            x <= (others => (others => '0'));
            for a in 0 to N+H+1+M loop
                for b in 0 to N+H+1+M loop
                    W(a,b) <= (others => '0');
                end loop;
            end loop;
            s <= (others => (others => '0'));
            fs <= (others => (others => '0'));
            W_Index_Counter := 0;
            W_Node_Counter := 0;
            W_Node_Counter2 := 0;
            yhat <= (others => '0');
            
        else
            if (clk = '1' and clk'event) then
                --Rising clock edge
                if (SE = '1') then
                    --Read in weights from SI, 1 bit at a time
                    if (W_Node_Counter <= N+H+1+M) then
                        --Check to make sure it doesn't overrun index bounds
                        W(W_Node_Counter,W_Node_Counter2)(W_Index_Counter) <= SI;
                        if W_Index_Counter = Qm+Qn then
                            W_Index_Counter := 0;
                            --If at end of Node, go to next node and start at 0
                            if W_Node_Counter2 = N+H+1+M then
                                W_Node_Counter := W_Node_Counter +1;
                                W_Node_Counter2 := 0;
                            else
                                W_Node_Counter2 := W_Node_Counter2 +1;
                            end if;
                        else
                            --Increment index
                            W_Index_Counter := W_Index_Counter + 1;
                        end if;
                        
                    end if;
                else
                    --y=hw(u)
                    --x(1) = u
                    --x(L) = f((W^L)*x^(l-L))
                    -- (W^L)*x^(l-L) is a dot product, should produce a single value
                    --f(s) = 1/(1+e^(-s)) --sigmoid
                    --fast sigmoid: f(s) = s/(1+abs(s))
                    -- l is the layer
                    for a in 0 to N-1 loop
                        --All inputs and the bias of H are u, rest use sigmoid
                        x(a) <= std_logic_vector(signed(u(((a+1)*(Qm+Qn+1))-1 downto (a*(Qm+Qn+1)))));
                    end loop;
                    
                    --Hidden layer
                    for a in N+2 to N+H+1 loop --For each node in hidden layer
                        --s = --W^L DOT x^(l-L)
                        tempS := (others=>'0');
                        for b in 0 to N loop  --For weights 0 to N in the node 
                            --W(Node weight row in current layer, Node from previous layer acting on it)
                            --   == Weight of node in previous layer acting on node on current layer
                            tempSS := signed(W(a,b)) * signed(x(b));
                            --report(integer'Image(to_integer(signed(tempSS))));
                            tempS := tempS + tempSS(2*(Qn+Qm)-1 downto Qm+Qn);
                            
                        end loop;
                        s(a) <= std_logic_vector(tempS);
                        x(a) <= fs(a);
                    end loop;
                    
                    --Output layer
                    for a in N+H+2 to N+H+1+M loop --For each node in output layer
                        --s = --W^L DOT x^(l-L)
                        tempS := (others=>'0');
                        for b in N+1 to N+1+H loop  --For weights 0 to N in the node 
                            --W(Node weight row in current layer, Node from previous layer acting on it)
                            --   == Weight of node in previous layer acting on node on current layer
                            tempSS := signed(W(a,b)) * signed(x(b));
                            tempS := tempS + tempSS(2*(Qn+Qm)-1 downto Qm+Qn);

                        end loop;
                        s(a) <= std_logic_vector(tempS);
                        x(a) <= fs(a);
                        yhat((a-(N+H+1))*(Qm+Qn) downto ( (a-(N+H+2)) *(Qm+Qn) )   ) <= x(a);
                    end loop;
                end if;
            end if;
        end if;
    end process;
end architecture beh;
