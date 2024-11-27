----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 22.11.2024 18:13:31
-- Design Name: 
-- Module Name: adder1b - Behavioral
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

entity adder1b is
    Port ( 
        Cin  : in  std_logic;
        A    : in  std_logic;
        B    : in  std_logic;
        S    : out std_logic;
        Cout : out std_logic
    );
end adder1b;

architecture RTL of adder1b is
    signal and1 : std_logic; 
    signal and2 : std_logic; 
    signal xor1 : std_logic;
    signal xor2 : std_logic;
begin

    and1 <= A AND B;
    xor1 <= A XOR B;
    and2 <= Cin AND xor1;
    S    <= Cin XOR xor1;
    Cout <= and1 OR and2;
    
end RTL;
