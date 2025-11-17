----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 11/05/2025 06:23:19 PM
-- Design Name: 
-- Module Name: condcheck - Behavioral
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

-- Condition checker selon le Tableau 1
-- Vérifie si l'instruction doit être exécutée selon Cond[3:0] et les Flags
entity condcheck is
    port(
        Cond   : in  STD_LOGIC_VECTOR(3 downto 0);  -- Bits 31:28 de l'instruction
        Flags  : in  STD_LOGIC_VECTOR(3 downto 0);  -- N, Z, C, V stockés
        CondEx : out STD_LOGIC                       -- 1 si instruction exécutée
    );
end condcheck;

architecture behavioral of condcheck is
    signal N, Z, C, V : STD_LOGIC;
begin
    -- Extraction des flags
    N <= Flags(3);  -- Negative
    Z <= Flags(2);  -- Zero
    C <= Flags(1);  -- Carry
    V <= Flags(0);  -- Overflow
    
    -- Logique de vérification selon Cond[3:0] (Tableau 1)
    process(Cond, N, Z, C, V)
    begin
        case Cond is
            when "0000" => CondEx <= Z;                    -- EQ: Equal
            when "0001" => CondEx <= not Z;                -- NE: Not equal
            when "0010" => CondEx <= C;                    -- CS/HS: Carry set
            when "0011" => CondEx <= not C;                -- CC/LO: Carry clear
            when "0100" => CondEx <= N;                    -- MI: Minus/Negative
            when "0101" => CondEx <= not N;                -- PL: Plus/Positive
            when "0110" => CondEx <= V;                    -- VS: Overflow set
            when "0111" => CondEx <= not V;                -- VC: Overflow clear
            when "1000" => CondEx <= C and (not Z);        -- HI: Unsigned higher
            when "1001" => CondEx <= (not C) or Z;         -- LS: Unsigned lower or same
            when "1010" => CondEx <= not (N xor V);        -- GE: Signed >= (N ? V avec barre)
            when "1011" => CondEx <= N xor V;              -- LT: Signed < (N ? V)
            when "1100" => CondEx <= (not Z) and (not (N xor V));  -- GT: Signed >
            when "1101" => CondEx <= Z or (N xor V);       -- LE: Signed <=
            when "1110" => CondEx <= '1';                  -- AL: Always
            when others => CondEx <= '1';                  -- Default: Always
        end case;
    end process;
    
end behavioral;
