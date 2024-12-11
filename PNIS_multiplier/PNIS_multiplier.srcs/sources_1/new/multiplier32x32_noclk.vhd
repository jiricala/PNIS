----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 20.11.2024 14:08:46
-- Design Name: 
-- Module Name: multiplier - Behavioral
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
-- use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity multiplier32x32_noclk is
  Port ( 
    DIN1_i  : in  std_logic_vector(31 downto 0);
    DIN2_i  : in  std_logic_vector(31 downto 0);
    DOUT_o  : out std_logic_vector(63 downto 0)
  );
end multiplier32x32_noclk;

architecture Behavioral of multiplier32x32_noclk is
    
    component adder33b is
        Port (
            C_i     : in  std_logic;
            A_33b_i : in  std_logic_vector(32 downto 0);
            B_33b_i : in  std_logic_vector(32 downto 0);
            S_33b_o : out std_logic_vector(32 downto 0);
            C_o     : out std_logic
        );
    end component;
    
    type arr_std_32x33b is array(0 to 31) of std_logic_vector(32 downto 0);
    
    signal rca_in1  : arr_std_32x33b;
    signal rca_in2  : arr_std_32x33b;
    signal rca_out  : arr_std_32x33b;
    signal c_in     : std_logic_vector(0 to 31);
    signal c_out    : std_logic_vector(0 to 31);
    
    signal data_out : std_logic_vector(63 downto 0);
    
begin
    
    --- ADDERS ---
    adders_gen: for i in 0 to 31 generate
        adder_i:  adder33b
            port map (
                C_i     => c_in(i),
                A_33b_i => rca_in1(i),
                B_33b_i => rca_in2(i),
                S_33b_o => rca_out(i),
                C_o     => c_out(i)         -- unused
            );
    end generate;
    
    --- WIRING FOR ADDERS ---
    wiring_gen: for i in 0 to 30 generate
        rca_in1(i)   <= DIN1_i(31) & DIN1_i when (DIN2_i(i) = '1') else (others => '0');
        rca_in2(i+1) <= rca_out(i)(32) & rca_out(i)(32 downto 1);
        c_in(i) <= '0';
        data_out(i) <= rca_out(i)(0);
    end generate;
    
    --- INITIAL ADDITION INPUT2 ---
    rca_in2(0) <= (others => '0');
    
    --- LAST ADDITION INPUT1 LOGIC ---
    rca_in1(31) <= NOT(DIN1_i(31) & DIN1_i) when (DIN2_i(31) = '1') else (others => '0');   -- invertion for 2's complement
    c_in(31) <= DIN2_i(31);                                                                 -- add +1 for 2's complement
    
    --- OUTPUT ---
    data_out(63 downto 31) <= rca_out(31);
    DOUT_o <= data_out;
    
end Behavioral;
