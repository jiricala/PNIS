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
use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity multiplier is
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
end multiplier;

architecture Behavioral of multiplier is
    
    component adder32b is
        Port (
            A_32b : in  std_logic_vector(31 downto 0);
            B_32b : in  std_logic_vector(31 downto 0);
            S_32b : out std_logic_vector(31 downto 0);
            Cout  : out std_logic
        );
    end component;
    
    signal cntr  : unsigned(5 downto 0);
    signal busy  : std_logic;
    signal valid : std_logic;
    
    signal din1_reg  : std_logic_vector(31 downto 0);
    signal din2_sreg : std_logic_vector(31 downto 0);
    signal prod_sreg : std_logic_vector(63 downto 0);
    
    signal sum_in1 : std_logic_vector(31 downto 0);
    signal sum_in2 : std_logic_vector(31 downto 0);
    signal sum_out : std_logic_vector(32 downto 0);
    
begin
    
    --- 32BIT ADDER -----------------------------------------------------------
    adder:  adder32b
        port map (
            A_32b => sum_in1,
            B_32b => sum_in2,
            S_32b => sum_out(31 downto 0),
            Cout  => sum_out(32)
        );
        
    sum_in1 <= din1_reg when din2_sreg(0) = '1' else (others => '0');
    sum_in2 <= prod_sreg(63 downto 32);
    
    --process(CLK)
    --    variable x1 : unsigned(32 downto 0);
    --    variable x2 : unsigned(32 downto 0);
    --    variable y  : unsigned(32 downto 0);
    --begin
    --    x1 := unsigned('0' & sum_in1);
    --    x2 := unsigned('0' & sum_in2);
    --    y  := x1 + x2;
    --    sum_out <= std_logic_vector(y);
    --end process;
    
    
    --- INPUT DATA REGISTERS & SHIFT REGISTERS --------------------------------
    process(CLK)
    begin
        if rising_edge(CLK) then
            if (RST = '1') then
                din1_reg  <= DIN1_i;
                din2_sreg <= DIN2_i;
                prod_sreg <= (others => '0');
            elsif (busy = '1') then
                din2_sreg <= '0' & din2_sreg(31 downto 1);      -- shift-register for data2 input
                prod_sreg <= sum_out & prod_sreg(31 downto 1);  -- half shift-register for adder results
            elsif (EN_i = '1') then
                din1_reg  <= DIN1_i;
                din2_sreg <= DIN2_i;
                prod_sreg <= (others => '0');
            end if;
        end if;
    end process;
    
    --- CONTROL SIGNALS --------------------------------------------------------
    process(CLK)
    begin
        if rising_edge(CLK) then
            if (RST = '1') then
                busy  <= '0';
                valid <= '0';
            elsif (cntr(5) = '1') then      -- if 32 cycles completed
                busy  <= '0';
                valid <= '1';
            elsif (EN_i = '1') then         -- if new multiplication initiated
                busy  <= '1';
                valid <= '0';
            end if;
            
            --- internal counter ---
            if (RST = '1' OR cntr(5) = '1') then
                cntr  <= (others => '0');
            elsif (EN_i = '1' OR busy = '1') then
                cntr <= cntr + 1;
            end if;
        end if;
    end process;
    
    --- OUTPUT SIGNALS --------------------------------------------------------
    BUSY_o  <= busy;
    VALID_o <= valid;
    DOUT_o  <= prod_sreg;
    
end Behavioral;
