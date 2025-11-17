----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 11/05/2025 10:28:33 PM
-- Design Name: 
-- Module Name: PC_register - Behavioral
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

-- Registre pour le Program Counter (PC)
-- Avec reset asynchrone
entity PC_register is
    Port (
        clk    : in  STD_LOGIC;                      -- Signal d'horloge
        reset  : in  STD_LOGIC;                      -- Reset asynchrone
        PC_in  : in  STD_LOGIC_VECTOR(31 downto 0);  -- PC' (nouvelle valeur)
        PC_out : out STD_LOGIC_VECTOR(31 downto 0)   -- PC (valeur actuelle)
    );
end PC_register;

architecture Behavioral of PC_register is
begin
    process(clk, reset)
    begin
        if reset = '1' then
            -- Reset asynchrone: PC à 0
            PC_out <= (others => '0');
        elsif rising_edge(clk) then
            -- Mise à jour du PC à chaque cycle d'horloge
            PC_out <= PC_in;
        end if;
    end process;
end Behavioral;