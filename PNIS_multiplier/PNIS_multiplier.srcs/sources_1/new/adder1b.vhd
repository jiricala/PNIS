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
        C_i : in  std_logic;
        A_i : in  std_logic;
        B_i : in  std_logic;
        S_o : out std_logic;
        C_o : out std_logic
    );
end adder1b;

architecture RTL of adder1b is
    signal and1 : std_logic; 
    signal and2 : std_logic; 
    signal xor1 : std_logic;
    signal xor2 : std_logic;
begin

    and1 <= A_i AND B_i;
    xor1 <= A_i XOR B_i;
    and2 <= C_i AND xor1;
    S_o  <= C_i XOR xor1;
    C_o  <= and1 OR and2;
    
end RTL;
