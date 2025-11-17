----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 11/05/2025 05:49:07 PM
-- Design Name: 
-- Module Name: flopr - Behavioral
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

-- Registre avec enable et reset asynchrone
-- Utilisé pour stocker les flags (N, Z, C, V)
entity flopr is
    generic(width: integer := 32);
    port(
        clk   : in  STD_LOGIC;
        reset : in  STD_LOGIC;
        en    : in  STD_LOGIC;
        d     : in  STD_LOGIC_VECTOR(width-1 downto 0);
        q     : out STD_LOGIC_VECTOR(width-1 downto 0)
    );
end flopr;

architecture Structural of flopr is
begin
    process(clk, reset)
    begin
        if reset = '1' then
            -- Reset asynchrone: tout à 0
            q <= (others => '0');
        elsif rising_edge(clk) then
            if en = '1' then
                -- Écriture seulement si enable = '1'
                q <= d;
            end if;
        end if;
    end process;
end Structural;
