----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 10/09/2025 12:17:54 PM
-- Design Name: 
-- Module Name: ALU - Behavioral
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
use IEEE.NUMERIC_STD.ALL;

entity ALU is
  Port (
    A            : in  STD_LOGIC_VECTOR(31 downto 0);
    B            : in  STD_LOGIC_VECTOR(31 downto 0);
    ALUControl   : in  STD_LOGIC_VECTOR(1 downto 0);
    ALUResult    : out STD_LOGIC_VECTOR(31 downto 0);
    ALUFlags     : out STD_LOGIC_VECTOR(3 downto 0)
  );
end ALU;

architecture Structural of ALU is
  -- Déclaration des signaux internes
  signal add, andd, orr, result_int : STD_LOGIC_VECTOR(31 downto 0);
  signal C, OV : STD_LOGIC;
  signal carry_in : STD_LOGIC;
  
  -- Déclaration des composants
  component adder_alu
    port (
      a    : in  STD_LOGIC_VECTOR(31 downto 0);
      b    : in  STD_LOGIC_VECTOR(31 downto 0);
      cin  : in  STD_LOGIC;
      s    : out STD_LOGIC_VECTOR(31 downto 0);
      cout : out STD_LOGIC;
      ov   : out STD_LOGIC;
      sel  : in  STD_LOGIC
    );
  end component;
  
  component and_logic
    port (
      A : in  STD_LOGIC_VECTOR(31 downto 0);
      B : in  STD_LOGIC_VECTOR(31 downto 0);
      Y : out STD_LOGIC_VECTOR(31 downto 0)
    );
  end component;
  
  component or_logic
    port (
      A : in  STD_LOGIC_VECTOR(31 downto 0);
      B : in  STD_LOGIC_VECTOR(31 downto 0);
      Y : out STD_LOGIC_VECTOR(31 downto 0)
    );
  end component;
  
  component mux4
    port (
      D0  : in  STD_LOGIC_VECTOR(31 downto 0);
      D1  : in  STD_LOGIC_VECTOR(31 downto 0);
      D2  : in  STD_LOGIC_VECTOR(31 downto 0);
      D3  : in  STD_LOGIC_VECTOR(31 downto 0);
      sel : in  STD_LOGIC_VECTOR(1 downto 0);
      Y   : out STD_LOGIC_VECTOR(31 downto 0)
    );
  end component;

begin

  -- Instanciation de l'additionneur
  ADDER_INST: adder_alu
  port map (
      a    => A,
      b    => B,
      cin  => carry_in,
      s    => add,
      cout => C,
      ov   => OV,
      sel  => carry_in
    );

  -- Instanciation de la porte AND
  U_and: and_logic
    PORT MAP (
      A => A,
      B => B,
      Y => andd
    );

  -- Instanciation de la porte OR
  U_or: or_logic
    PORT MAP (
      A => A,
      B => B,
      Y => orr
    );
    
  -- Instanciation du multiplexeur
  U_mux2: mux4
    PORT MAP (
      D0  => add,   -- Operation "000" = ADD
      D1  => add,   -- Operation "001" = SUB
      D2  => andd,  -- Operation "010" = AND
      D3  => orr,   -- Operation "011" = OR
      sel => ALUControl(1 downto 0),
      Y   => result_int
    );
    
  -- Contrôle du carry_in (1 pour SUB, 0 pour ADD)
  carry_in <= ALUControl(0) ;

  -- Sortie du résultat
  ALUResult <= result_int;

  -- Gestion des flags
  ALUFlags(3) <= result_int(31);  -- N (Negative)
  ALUFlags(2) <= '1' when result_int = x"00000000" else '0';  -- Z (Zero)
  ALUFlags(1) <= C when ALUControl(1) = '0' else '0';  -- C (Carry) - seulement pour ADD/SUB
  ALUFlags(0) <= OV when ALUControl(1) = '0' else '0';  -- V (Overflow) - seulement pour ADD/SUB

end Structural;