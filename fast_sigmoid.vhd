library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
library adk;
use adk.adk_components.all;
--use ieee.std_logic_unsigned.all;
--use ieee.std_logic_signed.all;


entity fast_sigmoid is
    generic(Qn : integer:=4;
            Qm : integer:=4);
    port(
        s : in std_logic_vector(Qn+Qm downto 0) := (others => '0');
        fs : out std_logic_vector(Qn+Qm downto 0) := (others => '0'));
end fast_sigmoid;

architecture beh of fast_sigmoid is
--signal ttfs : unsigned(Qn+Qm downto 0) := (others=>'0');
signal tempS : unsigned(2*(Qm+Qn+1)-1 downto 0) := (others=>'0');
constant buf : std_logic_vector(Qn downto 0) := (others => '0');
	
    --Conditional Statements
    --Case1 = 5.0
    signal case1_int : std_logic_vector(Qm+3 downto 0) := (2 => '1', 0=> '1', others => '0');
    signal case1_dec : std_logic_vector(Qn-1 downto 0) := (others=>'0');
    signal case1 : unsigned(Qn+Qm downto 0) := unsigned(case1_int(Qm downto 0) & case1_dec(Qn-1 downto 0));
    
    --Case2 = 2.375
    signal case2_int : std_logic_vector(Qm+1 downto 0) := (1 => '1', others => '0');
    signal case2_dec : std_logic_vector(2 downto 0) := "011";
    signal case2_dec_fin : std_logic_vector(Qn+3 downto 0) := (case2_dec & buf);
    signal case2 : unsigned(Qn+Qm downto 0) := unsigned(case2_int(Qm downto 0) & case2_dec_fin(case2_dec_fin'Length-1 downto case2_dec_fin'Length-Qn));
    
    --Case3 = 1.0
    signal case3_int : std_logic_vector(Qm downto 0) := (0 => '1', others => '0');
    signal case3_dec : std_logic_vector(Qn-1 downto 0) := (others => '0');
    signal case3 : unsigned(Qn+Qm downto 0) := unsigned(case3_int & case3_dec);
    
    --Case4 = 0.0
    signal case4 : unsigned(Qn+Qm downto 0) := (others =>'0');
    
    --Multiplication
    signal case1_mult_int : std_logic_vector(Qm downto 0) := (others => '0');
    signal case1_mult_dec : std_logic_vector(4 downto 0) := "00001";
    signal case1_mult_dec_fin : std_logic_vector(Qn+5 downto 0) := (case1_mult_dec & buf);
    signal case1_mult : unsigned(Qn+Qm downto 0) := unsigned(case1_mult_int & case1_mult_dec_fin(case1_mult_dec_fin'Length-1 downto case1_mult_dec_fin'Length-Qn));

    signal case2_mult_int : std_logic_vector(Qm downto 0) := (others => '0');
    signal case2_mult_dec : std_logic_vector(2 downto 0) := "001";
    signal case2_mult_dec_fin : std_logic_vector(Qn+3 downto 0) := (case2_mult_dec & buf);
    signal case2_mult : unsigned(Qn+Qm downto 0) := unsigned(case2_mult_int & case2_mult_dec_fin(case2_mult_dec_fin'Length-1 downto case2_mult_dec_fin'Length-Qn));
    
    
    signal case3_mult_int : std_logic_vector(Qm downto 0) := (others => '0');
    signal case3_mult_dec : std_logic_vector(1 downto 0) := "01";
    signal case3_mult_dec_fin : std_logic_vector(Qn+2 downto 0) := case3_mult_dec & buf;
    signal case3_mult : unsigned(Qn+Qm downto 0) := unsigned(case3_mult_int & case3_mult_dec_fin(case3_mult_dec_fin'Length-1 downto case3_mult_dec_fin'Length-Qn));

    --Addition
    
    --0.84375
    signal case1_add_int : std_logic_vector(Qm downto 0) := (others => '0');
    signal case1_add_dec : std_logic_vector(4 downto 0) := "11011";
    signal case1_add_dec_fin : std_logic_vector(Qn+5 downto 0) := case1_add_dec & buf;
    signal case1_add : unsigned(Qn+Qm downto 0) := unsigned(case1_add_int & case1_add_dec_fin(case1_add_dec_fin'Length-1 downto case1_add_dec_fin'Length-Qn));
    
    --0.625
    signal case2_add_int : std_logic_vector(Qm downto 0) := (others => '0');
    signal case2_add_dec : std_logic_vector(2 downto 0) := "101";
    signal case2_add_dec_fin : std_logic_vector(Qn+3 downto 0) := case2_add_dec & buf;
    signal case2_add : unsigned(Qn+Qm downto 0) := unsigned(case2_add_int & case2_add_dec_fin(case2_add_dec_fin'Length-1 downto case2_add_dec_fin'Length-Qn));
    
    --0.5
    signal case3_add_int : std_logic_vector(Qm downto 0) := (others => '0');
    signal case3_add_dec : std_logic_vector(Qn-1 downto 0) := (Qn-1 => '1', others=>'0');
    signal case3_add : unsigned(Qn+Qm downto 0) := unsigned(case3_add_int & case3_add_dec);
   
    constant twocomp : unsigned(Qm+Qn downto 0) := (0 => '1', others =>'0');
    signal notif : std_logic_vector(3 downto 0) := (others =>'0');
    signal abs_ss : unsigned(Qm+Qn downto 0) := (others =>'0');
    begin
    process(s) 

    variable abs_s : unsigned(Qm+Qn downto 0) := (others =>'0');
    variable tfs : unsigned(Qn+Qm downto 0) := (others =>'0');
    begin
        notif<="0000";
        tfs := (others=>'0');
        abs_s := unsigned(std_logic_vector(abs(signed(s(Qn+Qm downto 0)))));
        abs_ss <= abs_s;
        if (abs_s >= case1) then   
            --|X| >=5
            --Y=1
            notif(0)<='1';
            tfs(Qn+1):='1';
        elsif (abs_s >= case2) and (abs_s < case1) then
            --2.375 <= |X| < 5
            --Y=0.03125 |X| + 0.84375
            notif(1) <='1';
            tempS <= case1_mult * abs_s;
			tfs := case1_add + tempS(2*(Qn+Qm)-1 downto Qm+Qn);
        elsif abs_s >= case3 and (abs_s < case2) then
            --1 <= |X| < 2.375
			--Y=0.125 * |X| + 0.625
            notif(2) <='1';
            tempS <= case2_mult * abs_s;
			tfs := case2_add + tempS(2*(Qn+Qm)-1 downto Qm+Qn);
        elsif abs_s >= case4 and abs_s < case3 then
            --0 <= |X| < 1
			--Y=0.25 * |X| + 0.5
            notif(3) <= '1';
			tempS <= case3_mult * abs_s;
			tfs := case3_add + tempS(2*(Qn+Qm)-1 downto Qm+Qn);
        end if;
        if s(Qn+Qm) = '1' then
            fs <= std_logic_vector(not(tfs)+twocomp);
        else
            fs <= std_logic_vector(tfs);
        end if;
    end process;
end architecture beh;
