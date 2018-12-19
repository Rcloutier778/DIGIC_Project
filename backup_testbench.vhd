library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use STD.textio.all;
use ieee.std_logic_textio.all;

entity testbench is
end testbench;

architecture beh of testbench is
    component mlp_model 
    generic (
        N : integer; -- # inputs
        H : integer; -- # hidden
        M : integer; -- # outputs
        Qm : integer; -- for Qm.m # of integer bits
        Qn : integer); --for Qm.n # of decimal bits.  Look at part 4 for better explanation
    port (
        clk : in std_logic;
        reset : in std_logic;
        SI : in std_logic; --scan chain input (serial input used to set all weights and bias values in network for testing)
        SE : in std_logic; --
        u : in std_logic_vector(N*(Qm+Qn+1)-1 downto 0);
        yhat : out std_logic_vector(M*(Qm+Qn+1)-1 downto 0));
    end component;

--Signals
file file_v : text;
signal Qm : integer := 4;
signal Qn : integer := 4;
signal N : integer := 9;
signal H : integer := 20;
signal M : integer := 1;


--Inputs
signal clk : std_logic :='0';
signal reset : std_logic := '0' ;
signal SI : std_logic := '0'; --scan chain input (serial input used to set all weights and bias values in network for testing)
signal SE : std_logic := '0'; --
signal u : std_logic_vector(N*(Qm+Qn+1)-1 downto 0) := (others => '0');        
signal u_all : std_logic_vector(65536*(Qm+Qn+1)-1 downto 0) := (others=>'0');
--Outputs
signal yhat : std_logic_vector(M*(Qm+Qn+1)-1 downto 0) := (others => '0');
signal yhat_all : std_logic_vector(M*(Qn+Qm+1)-1 downto 0) := (others=> '0');

--Clock period defs
constant clk_period : time := 10ns;

signal wLoaded : std_logic :='0';
signal uDone : std_logic :='0';

type Wtype is array (0 to N+H+M, 0 to N+H+M) of std_logic_vector(Qm+Qn downto 0); --0,1, ... N,N+1, ... N+H+1
signal W : Wtype;  

begin
    uut: mlp_model generic map(
        N => N,
        H => H,
        M => M,
        Qm => Qm,
        Qn => Qn)
         port map(
        clk => clk,
        reset => reset,
        SI => SI,
        SE => SE,
        u => u,
        yhat => yhat);

clk_proc : process
begin
    clk <= '0';
    wait for clk_period/2;
    clk <= '1';
    wait for clk_period/2;
end process;

stim_proc: process
    variable row : integer :=0;
    variable col : integer :=0;
    variable index : integer :=0;
    begin
    
    reset <= '0';
    wait for clk_period * 10;
    reset <= '1';
	wait for clk_period;
    if wLoaded = '1' then
        SI <= W(0,0)(0);
        wait for clk_period * 2;
        SE <= '1';
        for row in 0 to N+H+M loop
            for col in 0 to N+H+M loop
                for index in 0 to Qm+Qn loop
                    --report(string(std_logic'image(W(row,col)(index))));
                    SI <= W(row, col)(index);
                    wait for clk_period; 
                end loop;
            end loop;
        end loop;
        SE <='0';
        wait for 500 ns;
        for row in 1 to 255 loop
            u <= u_all(row*N*(Qm+Qn+1)-1 downto (row-1)*N*(Qm+Qn+1));
            wait for 1000 ns;
            --yhat_all(row*M*(Qm+Qn+1)-1 downto (row-1)*M*(Qm+Qn+1)) <= yhat;
        end loop;
        
    end if;
    uDone <= '1';
    wait;

end process;
  

weight_proc : process
    variable v_line : line;
    variable v_std : std_logic_vector(Qm+Qn downto 0);
    variable row : integer :=0;
    variable col : integer :=0;
    variable index : integer :=0;
begin
    if wLoaded = '0' then 
        file_open(file_v, "matlab/W.dat", read_mode);
        row :=0;
        col :=0;
        while not endfile(file_v) loop
            readline(file_v, v_line);
            read(v_line, v_std);
            W(row,col) <= v_std;
            col := col + 1;
            if col > N+H+M then
                col := 0;
                row := row + 1;
                if row > N+H+M then
                    exit;
                end if;
            end if;
        end loop;
        file_close(file_v);
        wait for clk_period *2;
        wLoaded <='1';
        file_open(file_v, "matlab/conv_test1.txt", read_mode);
        col :=0;
        while not endfile(file_v) loop
            readline(file_v, v_line);
            read(v_line, v_std);
            u_all((col+1)*(Qm+Qn+1)-1 downto col*(Qm+Qn+1)) <= v_std;
            col := col + 1;
			--if col >= 65535 then 
			--	exit;
			--end if;
        end loop;
        file_close(file_v);
        wait for clk_period *2;
        wLoaded <='1';

        wait;
        
    end if;
end process;

uProc : process
variable v_line : line;
    variable v_std : std_logic_vector(Qm+Qn downto 0);
    variable row : integer :=0;
    variable col : integer :=0;
    variable index : integer :=0;
begin
    wait;
    if uDone = '1' then
        file_open(file_v,"matlab/test1Output.txt",write_mode);
        row :=0;
        col :=0;
        wait;
    end if;
end process;




end;
