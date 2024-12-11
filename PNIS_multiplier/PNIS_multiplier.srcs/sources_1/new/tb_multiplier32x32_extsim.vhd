
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

entity tb_multiplier32x32_extsim is
--  Port ( );
end tb_multiplier32x32_extsim;

architecture Behavioral of tb_multiplier32x32_extsim is
    component multiplier32x32 is
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
    signal busy   : std_logic;
    signal valid  : std_logic;
    signal dout   : std_logic_vector(63 downto 0);
    
    signal din1_reg : std_logic_vector(31 downto 0) := (others => '0');
    signal din2_reg : std_logic_vector(31 downto 0) := (others => '0');
    
    signal RESULT_CHECK : boolean := false;
    
begin

    uut: multiplier32x32
      Port map ( 
        RST     => reset,
        CLK     => sysclk,
        EN_i    => en,
        DIN1_i  => din1,
        DIN2_i  => din2,
        BUSY_o  => busy,
        VALID_o => valid,
        DOUT_o  => dout
      );
      
    reset <= '0' after 23ns;
    sysclk <= not(sysclk) after 5ns;
    
    process
        variable cnt1 : unsigned(31 downto 0) := x"4000_0000"; -- (others => '0');
    begin
        wait for 90ns;
        if (busy = '0') then
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
        if (busy = '0') then
            i := i + 1;
            cnt2 := cnt2 + i;
            din2 <= std_logic_vector(cnt2);
        end if;
        
    end process;

    process(busy)
    begin
        if rising_edge(busy) then
            din1_reg <= din1;
            din2_reg <= din2;
        end if;
    end process;
    
    process(valid)
    begin
        if (valid = '1') then
            if (dout = std_logic_vector(signed(din1_reg) * signed(din2_reg))) then
                RESULT_CHECK <= true;
            else
                RESULT_CHECK <= false;
            end if;
        else
            RESULT_CHECK <= RESULT_CHECK;
        end if;
    end process;
    
end Behavioral;
