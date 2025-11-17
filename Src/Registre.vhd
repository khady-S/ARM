----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 10/09/2025 10:47:42 AM
-- Design Name: 
-- Module Name: Registre - Behavioral
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

entity Registre is
    Port (
        -- Entrées
        CLK : in STD_LOGIC;                       -- Signal d'horloge
        WE3 : in STD_LOGIC;
        RA1 : in STD_LOGIC_VECTOR(3 downto 0);    -- Adresse lecture registre 1
        RA2 : in STD_LOGIC_VECTOR(3 downto 0);    -- Adresse lecture registre 2
        A3 : in STD_LOGIC_VECTOR(3 downto 0);     -- Adresse écriture registre
        WD3 : in STD_LOGIC_VECTOR(31 downto 0);   -- Donnée à écrire
        R15 : in STD_LOGIC_VECTOR(31 downto 0);   -- Valeur spéciale pour R15
        
        -- Sorties
        RD1 : out STD_LOGIC_VECTOR(31 downto 0);  -- Donnée lue registre 1
        RD2 : out STD_LOGIC_VECTOR(31 downto 0)   -- Donnée lue registre 2
    );
end Registre;

architecture Behavioral of Registre is
    -- Déclaration des 16 registres de 32 bits
    type ramtype is array (0 to 15) of STD_LOGIC_VECTOR(31 downto 0);
    signal mem : ramtype := (others => (others => '0'));  -- Initialisation à zéro
    
begin

    -- Processus d'écriture synchrone
    process(CLK) 
    begin
        -- Sur front montant d'horloge
        if rising_edge(CLK) then
            -- Si écriture activée
            if WE3 = '1' then 
                -- Écrire WD3 dans le registre A3
                mem(to_integer(unsigned(A3))) <= WD3;
            end if;
        end if;
    end process;

    -- Processus de lecture asynchrone
        -- Lecture registre 1
    RD1 <= mem(to_integer(unsigned(RA1)));
    -- Lecture registre 2
    RD2 <= mem(to_integer(unsigned(RA2)));

end Behavioral;
