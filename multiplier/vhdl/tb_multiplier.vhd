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
    
    signal cnt1     : unsigned(31 downto 0) := (others => '0');
    signal cnt2     : unsigned(31 downto 0) := (others => '0');
    signal din1_reg : std_logic_vector(31 downto 0) := (others => '0');
    signal din2_reg : std_logic_vector(31 downto 0) := (others => '0');
    
    signal RESULT_CHECK : boolean := false;
    
begin

    uut: multiplier
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
    begin
        wait for 90ns;
        if (busy = '0') then
            cnt1 <= cnt1 + 1;
            din1 <= std_logic_vector(cnt1);
            din2 <= std_logic_vector(cnt2);
            en <= '1';
        end if;
        wait for 50ns;
        en <= '0';
    end process;
    
    process
        variable i : unsigned(31 downto 0) := (others => '0');
    begin
        wait for 1300ns;
        if (busy = '0') then
            i := i + 1;
            cnt2 <= cnt2 + i;
        end if;
    end process;

    process(busy)
    begin
        if rising_edge(busy) then
            din1_reg <= din1;
            din2_reg <= din2;
        end if;
    end process;
    
    RESULT_CHECK <= true when (dout = std_logic_vector(signed(din1_reg) * signed(din2_reg)) OR valid = '0' ) else false;

    
end Behavioral;
