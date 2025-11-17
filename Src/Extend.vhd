----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 10/09/2025 11:01:02 AM
--  Name: Khady Sylla
-- Module Name: Extend - Behavioral
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

entity Extend is
    Port (
    -- ENTREES --
        
        Instr : in STD_LOGIC_VECTOR(23 downto 0);  -- Les 24 bits de poids faible de l'instruction
        ImmSrc : in STD_LOGIC_VECTOR(1 downto 0); -- Signal de contrôle pour sélectionner le type d'extension
                  
                  -- SORTIE --                                  -- "00" = Imm8, "01" = Imm12, "10" = Imm24
        ExtImm : out STD_LOGIC_VECTOR(31 downto 0) -- Immédiat étendu sur 32 bits
    );
end Extend;

architecture Behavioral of Extend is
begin
    process(all)
    begin
    -- Processus combinatoire sensible à tous les signaux d'entrée
        case ImmSrc is
            when "00" => 
                ExtImm <= X"000000" & Instr(7 downto 0);    -- Imm8
            when "01" => 
                ExtImm <= X"00000" & Instr(11 downto 0);    -- Imm12
            when "10" => 
                ExtImm <= X"00" & Instr(23 downto 0)  ;        -- Imm24 (décalé de 2)
            when others => 
            -- Sortie mise à 0 pour éviter les états indéterminés
                ExtImm <= (others => '0');                  -- Valeur par défaut
        end case;
    end process;
end Behavioral;