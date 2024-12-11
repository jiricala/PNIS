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

entity multiplier32x32_extsim is
  Port ( 
    RST     : in  std_logic;
    CLK     : in  std_logic;
    EN_i    : in  std_logic;
    DIN1_i  : in  std_logic_vector(31 downto 0);
    DIN2_i  : in  std_logic_vector(31 downto 0);
    BUSY_o  : out std_logic;
    VALID_o : out std_logic;
    DOUT_o  : out std_logic_vector(63 downto 0);
    --- extension simulation outputs ---
    C_in_o    : out std_logic;
    SUM_IN1_o : out std_logic_vector(32 downto 0);
    SUM_IN2_o : out std_logic_vector(32 downto 0);
    SUM_OUT_o : out std_logic_vector(32 downto 0)
    
  );
end multiplier32x32_extsim;

architecture Behavioral of multiplier32x32_extsim is
    
    component adder33b is
        Port (
            C_i     : in  std_logic;
            A_33b_i : in  std_logic_vector(32 downto 0);
            B_33b_i : in  std_logic_vector(32 downto 0);
            S_33b_o : out std_logic_vector(32 downto 0);
            C_o     : out std_logic
        );
    end component;
    
    signal cntr  : unsigned(5 downto 0);
    signal busy  : std_logic;
    signal valid : std_logic;
    
    signal din1_reg  : std_logic_vector(31 downto 0);
    signal din2_sreg : std_logic_vector(31 downto 0);
    signal prod_sreg : std_logic_vector(63 downto 0);
    signal din1_mux  : std_logic_vector(31 downto 0);
    
    signal sum_in1 : std_logic_vector(32 downto 0);
    signal sum_in2 : std_logic_vector(32 downto 0);
    signal sum_out : std_logic_vector(32 downto 0);
    signal c_in    : std_logic;
    signal c_out   : std_logic;
    
begin
    
    --- 32BIT ADDER -----------------------------------------------------------
    adder:  adder33b
        port map (
            C_i     => c_in,
            A_33b_i => sum_in1,
            B_33b_i => sum_in2,
            S_33b_o => sum_out,
            C_o     => c_out
        );
    
    c_in <= cntr(5) AND din2_sreg(0);
    
    din1_mux <= NOT(din1_reg) when cntr(5) = '1' else din1_reg;
    sum_in1  <= din1_mux(31) & din1_mux when din2_sreg(0) = '1' else (others => '0');
    sum_in2  <= prod_sreg(63) & prod_sreg(63 downto 32);
    
    C_in_o    <= c_in;
    SUM_IN1_o <= sum_in1;
    SUM_IN2_o <= sum_in2;
    SUM_OUT_o <= sum_out;
    
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
