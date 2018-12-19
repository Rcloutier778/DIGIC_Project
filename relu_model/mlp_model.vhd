library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
library adk;
use adk.adk_components.all;
--N, H, M

entity mlp_model is
    generic (
        N : integer :=9; -- # inputs
        H : integer :=20; -- # hidden
        M : integer :=1; -- # outputs
        Qm : integer :=4; -- for Qm.m # of integer bits
        Qn : integer :=4); --for Qm.n # of decimal bits.  Look at part 4 for better explanation
    port (
        clk : in std_logic;
        reset : in std_logic :='0';
        SI : in std_logic := '0'; --scan chain input (serial input used to set all weights and bias values in network for testing)
        SE : in std_logic :='0'; --
        u : in std_logic_vector(N*(Qm+Qn+1)-1 downto 0) := (others => '0');
        yhat : out std_logic_vector(M*(Qm+Qn+1)-1 downto 0) := (others =>'0'));

end mlp_model;

architecture beh of mlp_model is
  
    type xtype is array (0 to N+H+M)  of signed(Qm+Qn downto 0);
    signal x : xtype := (others => (others => '0'));
    --Weights
    type Wtype is array (0 to N+H+M, 0 to N+H+M) of signed(Qm+Qn downto 0); --0,1, ... N,N+1, ... N+H+1
    signal W : Wtype := (others => (others => (others => '0')));    
    signal EOF_W : std_logic := '0'; --if end of W array has been reached
    begin
    
    process (clk)
    variable a : integer := 0; --loop 
    variable b : integer := 0;
    variable tempS : signed(Qm+Qn downto 0) := (others=>'0');
    variable tempSS : signed(2*(Qm+Qn+1)-1 downto 0) := (others=>'0');
    variable W_Index_Counter : integer range 0 to Qm+Qn :=0;
    variable W_Node_Counter : integer range 0 to N+H+M :=0;
    variable W_Node_Counter2 : integer range 0 to N+H+M :=0;
    begin
        --Rising clock edge
        if (clk = '1' and clk'event) then
            if (reset = '0') then
                --Reset is just power input 
                x <= (others => (others => '0'));
                W <= (others => (others => (others => '0')));    
                W_Index_Counter := 0;
                W_Node_Counter := 0;
                W_Node_Counter2 := 0;
                yhat <= (others => '0');
                EOF_W <= '0';
            else
                if (SE = '1') then
                    if EOF_W = '0' then
                        --Read in weights from SI, 1 bit at a time
                        W(W_Node_Counter,W_Node_Counter2)(W_Index_Counter) <= SI;
                        if W_Index_Counter < Qm+Qn then
                            W_Index_Counter := W_Index_Counter + 1;
                        else
                            W_Index_Counter := 0;
                            if W_Node_Counter2 < N+H+M then
                                W_Node_Counter2 := W_Node_Counter2 + 1;
                            else
                                W_Node_Counter2 := 0;
                                if W_Node_Counter < N+H+M then
                                    W_Node_Counter := W_Node_Counter + 1;
                                else
                                    W_Node_Counter := 0;
                                    EOF_W <= '1';
									
                                end if;
                            end if;
                        end if;
                    end if;
                else
                    EOF_W <= '0';
                    --y=hw(u)
                    --x(1) = u
                    --x(L) = f((W^L)*x^(l-L))
                    -- (W^L)*x^(l-L) is a dot product, should produce a single value
                    --f(s) = 1/(1+e^(-s)) --sigmoid
                    --fast sigmoid: f(s) = s/(1+abs(s))
                    -- l is the layer

                    --Input layer
                    for a in 0 to N-1 loop
                        --All inputs and the bias of H are u, rest use sigmoid
                        x(a) <= signed(u(((a+1)*(Qm+Qn+1))-1 downto (a*(Qm+Qn+1))));
                    end loop;
                    
                    --Hidden layer
                    for a in N to N+H loop --For each node in hidden layer
                        --s = --W^L DOT x^(l-L)
                        tempS := (others=>'0');
                        for b in 0 to N-1 loop  --For weights 0 to N in the node 
                            --W(Node weight row in current layer, Node from previous layer acting on it)
                            --   == Weight of node in previous layer acting on node on current layer
                            tempSS :=W(a,b) * x(b);
                            --report(integer'Image(to_integer(signed(tempSS))));
                            tempS := tempS + tempSS(2*(Qn+Qm)-1 downto Qm+Qn);
                            
                        end loop;
                        --ReLU
						if tempS < 0 then
							x(a) <= (others => '0');
						else
							x(a) <= tempS;
						end if;
                    end loop;
                    
                    --Output layer
                    for a in N+H+1 to N+H+M loop --For each node in the output layer
                        --s = --W^L DOT x^(l-L)
                        tempS := (others=>'0');
                        for b in N to N+H loop  --For each node in the hidden layer 
                            tempSS := W(a,b) * x(b);
                            tempS := tempS + tempSS(2*(Qn+Qm)-1 downto Qm+Qn);
                        end loop;
                        --ReLU
						if tempS < 0 then
						    x(a) <= (others => '0');
						else
						    x(a) <= tempS;
						end if;
					end loop;
					for a in 1 to M loop	
                        yhat(a*(Qm+Qn+1)-1 downto (a-1)*(Qm+Qn) ) <= std_logic_vector(x(a+N+H));
                    end loop;
                end if;
            end if;
        end if;
    end process;
end architecture beh;
