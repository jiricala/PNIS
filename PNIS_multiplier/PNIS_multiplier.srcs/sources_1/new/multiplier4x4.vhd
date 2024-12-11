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

entity multiplier4x4 is
  Port ( 
    RST     : in  std_logic;
    CLK     : in  std_logic;
    EN_i    : in  std_logic;
    DIN1_i  : in  std_logic_vector(3 downto 0);
    DIN2_i  : in  std_logic_vector(3 downto 0);
    BUSY_o  : out std_logic;
    VALID_o : out std_logic;
    DOUT_o  : out std_logic_vector(7 downto 0)
    
  );
end multiplier4x4;

architecture Behavioral of multiplier4x4 is
    
    component adder5b is
        Port (
            C_i    : in  std_logic;
            A_5b_i : in  std_logic_vector(4 downto 0);
            B_5b_i : in  std_logic_vector(4 downto 0);
            S_5b_o : out std_logic_vector(4 downto 0);
            C_o    : out std_logic
        );
    end component;
    
    signal cntr  : unsigned(2 downto 0);
    signal busy  : std_logic;
    signal valid : std_logic;
    
    signal din1_mux  : std_logic_vector(3 downto 0);
    
    signal din1_reg  : std_logic_vector(3 downto 0);
    signal din2_sreg : std_logic_vector(3 downto 0);
    signal prod_sreg : std_logic_vector(7 downto 0);
    
    
    signal c_in    : std_logic;
    signal sum_in1 : std_logic_vector(4 downto 0);
    signal sum_in2 : std_logic_vector(4 downto 0);
    signal sum_out : std_logic_vector(4 downto 0);
    
begin
    
    --- 32BIT ADDER -----------------------------------------------------------
    adder: adder5b
        port map (
            C_i    => c_in,
            A_5b_i => sum_in1,
            B_5b_i => sum_in2,
            S_5b_o => sum_out,
            C_o    => open
        );
    
    c_in <= cntr(2) AND din2_sreg(0);
    
    din1_mux <= NOT(din1_reg) when cntr(2) = '1' else din1_reg;
    sum_in1  <= din1_mux(3) & din1_mux when din2_sreg(0) = '1' else (others => '0');
    sum_in2  <= prod_sreg(7) & prod_sreg(7 downto 4);
    
    --- INPUT DATA REGISTERS & SHIFT REGISTERS --------------------------------
    process(CLK)
    begin
        if rising_edge(CLK) then
            if (RST = '1') then
                din1_reg  <= DIN1_i;
                din2_sreg <= DIN2_i;
                prod_sreg <= (others => '0');
            elsif (busy = '1') then
                din2_sreg <= '0' & din2_sreg(3 downto 1);      -- shift-register for data2 input
                prod_sreg <= sum_out & prod_sreg(3 downto 1);  -- half shift-register for adder results
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
            elsif (cntr(2) = '1') then      -- if 4 cycles completed
                busy  <= '0';
                valid <= '1';
            elsif (EN_i = '1') then         -- if new multiplication initiated
                busy  <= '1';
                valid <= '0';
            end if;
            
            --- internal counter ---
            if (RST = '1' OR cntr(2) = '1') then
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
