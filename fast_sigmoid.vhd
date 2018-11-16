library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
--use ieee.std_logic_unsigned.all;
--use ieee.std_logic_signed.all;


entity fast_sigmoid is
    generic(Qn : integer; Qm : integer);
    port(
        s : in std_logic_vector(Qn+Qm+1 downto 0);
        fs : out std_logic_vector(Qn+Qm+1 downto 0));
end fast_sigmoid;

architecture beh of fast_sigmoid is

begin
    process (s)
    signal tfs : unsigned(Qn+Qm+1 downto 0) := (others=>'0');

    --Conditional Statements
    constant case1_int : std_logic_vector(Qm+1 downto 0) := (1 => '1', others => '0');
    constant case1_dec : std_logic_vector(2 downto 0) := "011";
    constant case1_buffer : std_logic_vector(Qn-3 downto 0) := (others => '0');
    constant case1 : unsigned(Qn+Qm+1 downto 0) := unsigned(case1_int & case1_dec & case1_buffer);
    
    constant case2_int : std_logic_vector(Qm+1 downto 0) := (0 => '1', others => '0');
    constant case2_dec : std_logic_vector(Qn downto 0) := (others => '0');
    constant case2 : unsigned(Qn+Qm+1 downto 0) := unsigned(case2_int & case2_dec);
    
    
    constant case3_int : std_logic_vector(Qm+1 downto 0) := (0 => '1', others => '0');
    constant case3_dec : std_logic_vector(2 downto 0) := "101";
    constant case3_buffer : std_logic_vector(Qn-3 downto 0) := (others => '0');
    constant case3 : unsigned(Qn+Qm+1 downto 0) := unsigned(case3_int & case3_dec & case3_buffer);
    
    --Multiplication
    constant case1_mult_int : std_logic_vector(Qm+1 downto 0) := (others => '0');
    constant case1_mult_dec : std_logic_vector(4 downto 0) := "00001";
    constant case1_mult_buffer : std_logic_vector(Qn-5 downto 0) := (others => '0');
    constant case1_mult : unsigned(Qn+Qm+1 downto 0) := unsigned(case1_mult_int & case1_mult_dec & case1_mult_buffer);
    
    constant case2_mult_int : std_logic_vector(Qm+1 downto 0) := (others => '0');
    constant case2_mult_dec : std_logic_vector(2 downto 0) := "001";
    constant case2_mult_buffer : std_logic_vector(Qn-3 downto 0) := (others => '0');
    constant case2_mult : unsigned(Qn+Qm+1 downto 0) := unsigned(case2_mult_int & case2_mult_dec & case2_mult_buffer);
    
    
    constant case3_mult_int : std_logic_vector(Qm+1 downto 0) := (others => '0');
    constant case3_mult_dec : std_logic_vector(1 downto 0) := "01";
    constant case3_mult_buffer : std_logic_vector(Qn-2 downto 0) := (others => '0');
    constant case3_mult : unsigned(Qn+Qm+1 downto 0) := unsigned(case3_mult_int & case3_mult_dec & case3_mult_buffer);

    --Addition
    constant case1_add_int : std_logic_vector(Qm+1 downto 0) := (others => '0');
    constant case1_add_dec : std_logic_vector(4 downto 0) := "11011";
    constant case1_add_buffer : std_logic_vector(Qn-5 downto 0) := (others => '0');
    constant case1_add : unsigned(Qn+Qm+1 downto 0) := unsigned(case1_add_int & case1_add_dec & case1_add_buffer);
    
    constant case2_add_int : std_logic_vector(Qm+1 downto 0) := (others => '0');
    constant case2_add_dec : std_logic_vector(2 downto 0) := "101";
    constant case2_add_buffer : std_logic_vector(Qn-3 downto 0) := (others => '0');
    constant case2_add : unsigned(Qn+Qm+1 downto 0) := unsigned(case2_add_int & case2_add_dec & case2_add_buffer);
    
    
    constant case3_add_int : std_logic_vector(Qm+1 downto 0) := (others => '0');
    constant case3_add_buffer : std_logic_vector(Qn-1 downto 0) := (others => '0');
    constant case3_add : unsigned(Qn+Qm+1 downto 0) := unsigned(case3_add_int & '1' & case3_add_buffer);
 
    signal abs_s_int : unsigned(Qm+1 downto 0);
    signal abs_s : unsigned(Qm+Qn+1 downto 0);
    begin
        abs_s_int <= std_logic_vector(unsigned(s(Qn+Qm+1 downto Qn)));
        abs_s <= unsigned(abs_s_int(Qm+1 downto 0) & s(Qn downto 0));
        --fs <= s/(1+s);
        
        --abs value of s
        
        --
        if (unsigned(abs_s_int) >= 5) then   --|X| >=5
            tfs(Qn+1)<='1';
        elsif (unsigned(abs_s) >= case1) and (unsigned(abs_s) >= 5) then
            --2.375 <= |X| < 5
            tfs <= case1_mult * abs_s;
            tfs_dec := std_logic_vector(to_unsigned(tfs_dec,Qn+1) + 84375);
        elsif abs_s_int >= 1 and (abs_s_int < 2 and unsigned(s_dec) < 375) then
            --1 <= |X| < 2.375
            tfs := 0.125 * abs_s;
            tfs_dec := std_logic_vector(to_unsigned(tfs_dec,Qn+1) + 625);
        elsif abs_s_int >= 0 and abs_s_int < 1 then
            --0 <= |X| < 1
            tfs := 0.25 * abs_s_int;
            tfs_dec := std_logic_vector(to_unsigned(tfs_dec,Qn+1) + 5);
        end if;
        if s_int < 0 then
            fs_int <= 1-tfs_int;
        else
            fs_int <= tfs_int;
        end if;
        fs_dec = tfs_dec;
    end process;
end architecture beh;
