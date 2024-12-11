----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 20.11.2024 21:32:31
-- Design Name: 
-- Module Name: tb_multiplier - Behavioral
-- Project Name: 
-- Target Devices: 
-- Tool Versions: 
-- Description: 
-- 
-- Dependencies: 
-- 
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
-- 
----------------------------------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity tb_multiplier_comb is
--  Port ( );
end tb_multiplier_comb;

architecture Behavioral of tb_multiplier_comb is
    component multiplier32x32_extsim is
      Port ( 
        RST     : in  std_logic;
        CLK     : in  std_logic;
        EN_i    : in  std_logic;
        DIN1_i  : in  std_logic_vector(31 downto 0);
        DIN2_i  : in  std_logic_vector(31 downto 0);
        BUSY_o  : out std_logic;
        VALID_o : out std_logic;
        DOUT_o  : out std_logic_vector(63 downto 0);
        --- extension simulation outputs ---
        SUM_CIN_o : out std_logic;
        SUM_IN1_o : out std_logic_vector(32 downto 0);
        SUM_IN2_o : out std_logic_vector(32 downto 0);
        SUM_OUT_o : out std_logic_vector(32 downto 0)
      );
    end component;
    
    component multiplier is
      Port ( 
        RST     : in  std_logic;
        CLK     : in  std_logic;
        EN_i    : in  std_logic;
        DIN1_i  : in  std_logic_vector(31 downto 0);
        DIN2_i  : in  std_logic_vector(31 downto 0);
        BUSY_o  : out std_logic;
        VALID_o : out std_logic;
        DOUT_o  : out std_logic_vector(63 downto 0)
      );
    end component;
    
    signal reset  : std_logic := '1';
    signal sysclk : std_logic := '1';
    signal en     : std_logic := '0';
    signal din1   : std_logic_vector(31 downto 0) := (others => '0');
    signal din2   : std_logic_vector(31 downto 0) := (others => '0');
    signal uut1_busy  : std_logic;
    signal uut2_busy  : std_logic;
    signal uut1_valid : std_logic;
    signal uut2_valid : std_logic;
    signal uut1_dout  : std_logic_vector(63 downto 0);
    signal uut2_dout  : std_logic_vector(63 downto 0);
    
    signal sum_cin : std_logic;
    signal sum_in1 : std_logic_vector(32 downto 0);
    signal sum_in2 : std_logic_vector(32 downto 0);
    signal sum_out : std_logic_vector(32 downto 0);
    signal sum_reg : std_logic_vector(32 downto 0);
    signal sum_ref : std_logic_vector(33 downto 0);
    
    signal din1_reg : std_logic_vector(31 downto 0) := (others => '0');
    signal din2_reg : std_logic_vector(31 downto 0) := (others => '0');
    
    signal RESULT_CHECK : boolean := false;
    signal ADDER_CHECK  : boolean := false;
    signal BUSY_CHECK   : boolean := false;
    signal VALID_CHECK  : boolean := false;
    signal DOUT_CHECK   : boolean := false;
    
begin

    uut1: multiplier32x32_extsim
      Port map ( 
        RST     => reset,
        CLK     => sysclk,
        EN_i    => en,
        DIN1_i  => din1,
        DIN2_i  => din2,
        BUSY_o  => uut1_busy,
        VALID_o => uut1_valid,
        DOUT_o  => uut1_dout,
        SUM_CIN_o => sum_cin,
        SUM_IN1_o => sum_in1,
        SUM_IN2_o => sum_in2,
        SUM_OUT_o => sum_out
      );
    
    uut2: multiplier
      Port map ( 
        RST     => reset,
        CLK     => sysclk,
        EN_i    => en,
        DIN1_i  => din1,
        DIN2_i  => din2,
        BUSY_o  => uut2_busy,
        VALID_o => uut2_valid,
        DOUT_o  => uut2_dout
      );
        
    reset <= '0' after 23ns;
    sysclk <= not(sysclk) after 5ns;
    
    process
        variable cnt1 : unsigned(31 downto 0) := x"4000_0000"; -- (others => '0');
    begin
        wait for 40ns;
        if (uut1_busy = '0') then
            cnt1 := cnt1 + x"1AAA_AAAA";
            din1 <= std_logic_vector(cnt1);
            en <= '1';
        end if;
        wait for 50ns;
        en <= '0';
    end process;
    
    process
        variable i : unsigned(31 downto 0) := x"1000_0000"; --(others => '0');
        variable cnt2 : unsigned(31 downto 0) := (others => '0');
    begin
        wait for 1300ns;
        if (uut1_busy = '0') then
            i := i + 1;
            cnt2 := cnt2 + i;
            din2 <= std_logic_vector(cnt2);
        end if;
        
    end process;

    process(uut1_busy)
    begin
        if rising_edge(uut1_busy) then
            din1_reg <= din1;
            din2_reg <= din2;
        end if;
    end process;
    
    process(uut1_valid)
    begin
        if (uut1_valid = '1') then
            if (uut1_dout = std_logic_vector(signed(din1_reg) * signed(din2_reg))) then
                RESULT_CHECK <= true;
            else
                RESULT_CHECK <= false;
            end if;
        else
            RESULT_CHECK <= RESULT_CHECK;
        end if;
    end process;
    
    
    BUSY_CHECK  <= true when uut1_busy = uut2_busy else false;
    VALID_CHECK <= true when uut1_valid = uut2_valid else false;
    DOUT_CHECK  <= true when uut1_dout = uut2_dout else false;
    
    sum_ref <= std_logic_vector(signed(sum_in1) + signed(sum_in2) + signed(std_logic_vector'(x"0000_000" & b"000" & sum_cin)));
    ADDER_CHECK <= true when (sum_out = sum_ref(32 downto 0)) else false;
    
end Behavioral;
