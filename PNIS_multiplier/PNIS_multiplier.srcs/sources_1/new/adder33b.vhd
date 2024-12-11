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

entity adder33b is
    Port (
        C_i     : in  std_logic;
        A_33b_i : in  std_logic_vector(32 downto 0);
        B_33b_i : in  std_logic_vector(32 downto 0);
        S_33b_o : out std_logic_vector(32 downto 0);
        C_o     : out std_logic
    );
end adder33b;

architecture RTL of adder33b is

    component adder1b is
        Port ( 
            C_i  : in  std_logic;
            A_i  : in  std_logic;
            B_i  : in  std_logic;
            S_o  : out std_logic;
            C_o  : out std_logic
        );
    end component;
    
    signal carry : std_logic_vector(33 downto 0);
begin
    
    C_o <= carry(33);
    
    carry(0) <= C_i;
    
    adder_gen: 
    for i in 0 to 32 generate
        adder_i: adder1b 
                    port map ( 
                        C_i  => carry(i), 
                        A_i  => A_33b_i(i),
                        B_i  => B_33b_i(i),
                        S_o  => S_33b_o(i),
                        C_o  => carry(i+1)
                    );
    end generate;
    
end RTL;
