library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
--use ieee.std_logic_unsigned.all;
--use ieee.std_logic_signed.all;


entity fast_sigmoid is
    generic(Qn : integer:=0;
            Qm : integer:=0);
    port(
        s : in std_logic_vector(Qn+Qm downto 0);
        fs : out std_logic_vector(Qn+Qm downto 0));
end fast_sigmoid;

architecture beh of fast_sigmoid is
signal abs_s_int : unsigned(Qm downto 0);
signal abs_s : unsigned(Qm+Qn downto 0);
signal tfs : unsigned(Qn+Qm downto 0) := (others=>'0');
signal tempSS : unsigned(2*(Qm+Qn+1)-1 downto 0) := (others=>'0');
signal buf : std_logic_vector(Qn downto 0) := (others => '0');
signal notifyier : unsigned(5 downto 0) := (others=>'0');

begin
	
	
    process (s)
	--Conditional Statements
    --Case1 = 5.0
    constant case1_int : std_logic_vector(Qm downto 0) := (3 => '1', 0=> '1', others => '0');
    constant case1_dec : std_logic_vector(Qn-1 downto 0) := (others=>'0');
    constant case1 : unsigned(Qn+Qm downto 0) := unsigned(case1_int(Qm downto 0) & case1_dec(Qn-1 downto 0));
    
    --Case2 = 2.375
    constant case2_int : std_logic_vector(Qm downto 0) := (1 => '1', others => '0');
    constant case2_dec : std_logic_vector(2 downto 0) := "011";
    constant case2_dec_fin : std_logic_vector(Qn+3 downto 0) := (case2_dec & buf);
    constant case2 : unsigned(Qn+Qm downto 0) := unsigned(case2_int(Qm downto 0) & case2_dec_fin(case2_dec_fin'Length-1 downto case2_dec_fin'Length-Qn));
    
    --Case3 = 1.0
    constant case3_int : std_logic_vector(Qm downto 0) := (0 => '1', others => '0');
    constant case3_dec : std_logic_vector(Qn-1 downto 0) := (others => '0');
    constant case3 : unsigned(Qn+Qm downto 0) := unsigned(case3_int & case3_dec);
    
    --Case4 = 0.0
    constant case4 : unsigned(Qn+Qm downto 0) := (others =>'0');
    
    --Multiplication
    constant case1_mult_int : std_logic_vector(Qm downto 0) := (others => '0');
    constant case1_mult_dec : std_logic_vector(4 downto 0) := "00001";
    constant case1_mult_dec_fin : std_logic_vector(Qn+5 downto 0) := (case1_mult_dec & buf);
    constant case1_mult : unsigned(Qn+Qm downto 0) := unsigned(case1_mult_int & case1_mult_dec_fin(case1_mult_dec_fin'Length-1 downto case1_mult_dec_fin'Length-Qn));

    constant case2_mult_int : std_logic_vector(Qm downto 0) := (others => '0');
    constant case2_mult_dec : std_logic_vector(2 downto 0) := "001";
    constant case2_mult_dec_fin : std_logic_vector(Qn+3 downto 0) := (case2_mult_dec & buf);
    constant case2_mult : unsigned(Qn+Qm downto 0) := unsigned(case2_mult_int & case2_mult_dec_fin(case2_mult_dec_fin'Length-1 downto case2_mult_dec_fin'Length-Qn));
    
    
    constant case3_mult_int : std_logic_vector(Qm downto 0) := (others => '0');
    constant case3_mult_dec : std_logic_vector(1 downto 0) := "01";
    constant case3_mult_dec_fin : std_logic_vector(Qn+2 downto 0) := case3_mult_dec & buf;
    constant case3_mult : unsigned(Qn+Qm downto 0) := unsigned(case3_mult_int & case3_mult_dec_fin(case3_mult_dec_fin'Length-1 downto case3_mult_dec_fin'Length-Qn));

    --Addition
    
    --0.84375
    constant case1_add_int : std_logic_vector(Qm downto 0) := (others => '0');
    constant case1_add_dec : std_logic_vector(4 downto 0) := "11011";
    constant case1_add_dec_fin : std_logic_vector(Qn+5 downto 0) := case1_add_dec & buf;
    constant case1_add : unsigned(Qn+Qm downto 0) := unsigned(case1_add_int & case1_add_dec_fin(case1_add_dec_fin'Length-1 downto case1_add_dec_fin'Length-Qn));
    
    --0.625
    constant case2_add_int : std_logic_vector(Qm downto 0) := (others => '0');
    constant case2_add_dec : std_logic_vector(2 downto 0) := "101";
    constant case2_add_dec_fin : std_logic_vector(Qn+3 downto 0) := case2_add_dec & buf;
    constant case2_add : unsigned(Qn+Qm downto 0) := unsigned(case2_add_int & case2_add_dec_fin(case2_add_dec_fin'Length-1 downto case2_add_dec_fin'Length-Qn));
    
    --0.5
    constant case3_add_int : std_logic_vector(Qm downto 0) := (others => '0');
    constant case3_add_dec : std_logic_vector(Qn-1 downto 0) := (Qn-1 => '1', others=>'0');
    constant case3_add : unsigned(Qn+Qm downto 0) := unsigned(case3_add_int & case3_add_dec);
    
    
    begin
        abs_s <= unsigned(std_logic_vector(abs(signed(s(Qn+Qm downto 0)))));
        --fs <= s/(1+s);
        
        --abs value of s
        
        --
        if (unsigned(abs_s) >= case1) then   
            --|X| >=5
            --Y=1
            notifyier(0)<='1';
            tfs(Qn+1)<='1';
        elsif (unsigned(abs_s) >= case2) and (unsigned(abs_s) < case1) then
            --2.375 <= |X| < 5
            --Y=0.03125 |X| + 0.84375
            notifyier(1)<='1';
            tempSS <= case1_mult * abs_s;
			tfs <= case1_add + tempSS(2*(Qn+Qm)-1 downto Qm+Qn);
        elsif abs_s >= case3 and (abs_s < case2) then
            --1 <= |X| < 2.375
            notifyier(2) <='1';
            tempSS <= case2_mult * abs_s;
			tfs <= case2_add + tempSS(2*(Qn+Qm)-1 downto Qm+Qn);
        elsif abs_s >= case4 and abs_s < case3 then
            --0 <= |X| < 1
            notifyier(3)<='1';
			tempSS <= case3_mult * abs_s;
			tfs <= case3_add + tempSS(2*(Qn+Qm)-1 downto Qm+Qn);
        end if;
        if s(Qn+Qm) = '1' then
            notifyier(4)<='1';
            fs <= std_logic_vector(signed(1-tfs(Qm+Qn downto 0)));
        else
            notifyier(5)<='1';
            fs <= std_logic_vector(tfs);
        end if;
    end process;
end architecture beh;
