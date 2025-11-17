----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 10/30/2025 03:46:04 PM
-- Design Name: 
-- Module Name: mux4 - Behavioral
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

entity mux4 is
    Port (
        D0  : in  STD_LOGIC_VECTOR(31 downto 0);  -- Entrée 0
        D1  : in  STD_LOGIC_VECTOR(31 downto 0);  -- Entrée 1
        D2  : in  STD_LOGIC_VECTOR(31 downto 0);  -- Entrée 2
        D3  : in  STD_LOGIC_VECTOR(31 downto 0);  -- Entrée 3
        sel : in  STD_LOGIC_VECTOR(1 downto 0);   -- Sélection (2 bits)
        Y   : out STD_LOGIC_VECTOR(31 downto 0)   -- Sortie
    );
end mux4;

architecture Behavioral of mux4 is
begin
    process(D0, D1, D2, D3, sel)
    begin
        case sel is
            when "00"   => Y <= D0;  -- Sélectionne D0
            when "01"   => Y <= D1;  -- Sélectionne D1
            when "10"   => Y <= D2;  -- Sélectionne D2
            when "11"   => Y <= D3;  -- Sélectionne D3
            when others => Y <= D0;  -- Valeur par défaut
        end case;
    end process;
end Behavioral;