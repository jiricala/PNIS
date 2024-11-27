----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 22.11.2024 18:13:31
-- Design Name: 
-- Module Name: adder32b - Behavioral
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
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity adder32b is
    Port (
        A_32b : in  std_logic_vector(31 downto 0);
        B_32b : in  std_logic_vector(31 downto 0);
        S_32b : out std_logic_vector(31 downto 0);
        Cout  : out std_logic
    );
end adder32b;

architecture RTL of adder32b is

    component adder1b is
        Port ( 
            Cin  : in  std_logic;
            A    : in  std_logic;
            B    : in  std_logic;
            S    : out std_logic;
            Cout : out std_logic
        );
    end component;
    
    signal carry : std_logic_vector(32 downto 0);
begin
    
    Cout <= carry(32);
    
    carry(0) <= '0';
    
    adder_gen: 
    for i in 0 to 31 generate
        adder_i: adder1b 
                    port map ( 
                        Cin  => carry(i), 
                        A    => A_32b(i),
                        B    => B_32b(i),
                        S    => S_32b(i),
                        Cout => carry(i+1)
                    );
    end generate;
    
end RTL;
