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

entity tb_multiplier is
--  Port ( );
end tb_multiplier;

architecture Behavioral of tb_multiplier is
    component multiplier is
      Port ( 
        DIN1_i  : in  std_logic_vector(31 downto 0);
        DIN2_i  : in  std_logic_vector(31 downto 0);
        DOUT_o  : out std_logic_vector(63 downto 0)
      );
    end component;
    
    signal din1  : std_logic_vector(31 downto 0) := (others => '0');
    signal din2  : std_logic_vector(31 downto 0) := (others => '0');
    signal dout  : std_logic_vector(63 downto 0);
    
    signal dout_calc : std_logic_vector(63 downto 0);
    
    signal RESULT_CHECK : boolean := false;
    
begin

    uut: multiplier
      Port map ( 
        DIN1_i  => din1,
        DIN2_i  => din2,
        DOUT_o  => dout
      );
    
    process
        variable cnt1 : unsigned(31 downto 0) := x"4000_0000"; -- (others => '0');
        variable i : unsigned(31 downto 0) := x"1000_0000"; --(others => '0');
        variable cnt2 : unsigned(31 downto 0) := (others => '0');
    begin
        cnt1 := cnt1 + x"1AAA_AAAA";
        din1 <= std_logic_vector(cnt1);
        i := i + 1;
        cnt2 := cnt2 + i;
        din2 <= std_logic_vector(cnt2);
        wait for 100ns;
    end process;
    
    dout_calc <= std_logic_vector(signed(din1) * signed(din2));
    
    RESULT_CHECK <= true when (dout = dout_calc) else false;
    
end Behavioral;
