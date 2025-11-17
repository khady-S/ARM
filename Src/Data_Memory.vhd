----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 10/09/2025 11:33:37 AM
-- Design Name: 
-- Module Name: Data_Memory - Behavioral
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

entity Data_Memory is
    Port (
        -- Entrées
        CLK : in STD_LOGIC;                       -- Signal d'horloge
        MemWrite : in STD_LOGIC;                  -- Activation écriture (1 = écrire)
        A : in STD_LOGIC_VECTOR(31 downto 0);     -- Adresse mémoire
        WD : in STD_LOGIC_VECTOR(31 downto 0);    -- Donnée à écrire
        
        -- Sortie
        RD : out STD_LOGIC_VECTOR(31 downto 0)    -- Donnée lue
    );
end Data_Memory;

architecture Behavioral of Data_Memory is
    -- Déclaration de la mémoire : 64 cases de 32 bits
    type ramtype is array (0 to 63) of STD_LOGIC_VECTOR(31 downto 0);
    signal mem : ramtype := (others => (others => '0'));  -- Initialisation à zéro
    
begin

    -- Processus d'écriture synchrone
    process(CLK) 
    begin
        -- Sur front montant d'horloge
        if rising_edge(CLK) then
            -- Si écriture activée
            if MemWrite = '1' then 
            -- Écrire WD à l'adresse A (seuls 6 bits utilisés)
                mem(to_integer(unsigned(A(5 downto 0)))) <= WD;
            end if;
        end if;
    end process;

    -- Processus de lecture asynchrone

        -- Lire toujours la donnée à l'adresse A
        RD <= mem(to_integer(unsigned(A(5 downto 0))));

end Behavioral;