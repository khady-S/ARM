----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 10/29/2025 08:07:58 PM
-- Design Name: 
-- Module Name: Alu_decoder - Behavioral
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

entity alu_decoder is
    Port ( 
        ALUOp      : in  STD_LOGIC;
        Funct      : in  STD_LOGIC_VECTOR(4 downto 0);
        ALUControl : out STD_LOGIC_VECTOR(1 downto 0);
        FlagW      : out STD_LOGIC_VECTOR(1 downto 0)
    );
end alu_decoder;

architecture Behavioral of alu_decoder is
begin
    process(ALUOp, Funct)
    begin
        -- Valeurs par défaut
        ALUControl <= "00";
        FlagW      <= "00";
        
        if ALUOp = '0' then
            -- ======================================================
            -- MÉMOIRE: LDR/STR utilisent ADD (ALUControl = 00)
            -- ======================================================
            ALUControl <= "00";  -- ADD pour calcul d'adresse
            FlagW      <= "00";  -- Pas de mise à jour des flags
            
        else
            -- ======================================================
            -- DATA PROCESSING: Décoder selon Funct[4:0]
            -- ======================================================
            case Funct(4 downto 1) is
                when "0100" =>
                    -- ADD (Funct[4:1] = 0100)
                    ALUControl <= "00";
                    FlagW      <= Funct(0) & Funct(0);  -- Flags si S=1
                    
                when "0010" =>
                    -- SUB (Funct[4:1] = 0010)
                    ALUControl <= "01";
                    FlagW      <= Funct(0) & Funct(0);  -- Flags si S=1
                    
                when "0000" =>
                    -- AND (Funct[4:1] = 0000)
                    ALUControl <= "10";
                    FlagW      <= Funct(0) & Funct(0);  -- Flags si S=1
                    
                when "1100" =>
                    -- ORR (Funct[4:1] = 1100)
                    ALUControl <= "11";
                    FlagW      <= Funct(0) & Funct(0);  -- Flags si S=1
                
                when "1010" =>
                    -- ============================================
                    -- CMP (Funct[4:1] = 1010) - NOUVEAU
                    -- ============================================
                    -- CMP fait une soustraction (Rn - Rm)
                    ALUControl <= "01";  -- Utilise SUB
                    -- CMP met TOUJOURS à jour les flags (pas besoin du bit S)
                    FlagW      <= "11";  -- Force mise à jour de tous les flags
                    
                when "1101" =>
                    -- MOV (Funct[4:1] = 1101)
                    -- MOV Rd, Rm => Rd = 0 + Rm (ADD avec Rn=R0)
                    ALUControl <= "00";  -- ADD
                    FlagW      <= Funct(0) & Funct(0);  -- Flags si S=1
                    
                when "1111" =>
                    -- MVN (Funct[4:1] = 1111)
                    -- MVN Rd, Rm => Rd = NOT Rm
                    -- En pratique, on peut implémenter avec: Rd = 0xFFFFFFFF XOR Rm
                    -- Ou utiliser une opération spéciale dans l'ALU
                    ALUControl <= "00";  -- Temporaire (à adapter selon votre ALU)
                    FlagW      <= Funct(0) & Funct(0);
                    
                when others =>
                    -- Instructions non supportées
                    ALUControl <= "00";
                    FlagW      <= "00";
            end case;
        end if;
    end process;

end Behavioral;

