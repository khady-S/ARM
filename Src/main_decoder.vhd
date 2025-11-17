----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 10/27/2025 11:15:17 AM
-- Design Name: 
-- Module Name: main_decoder - Behavioral
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

entity main_decoder is
    Port ( 
        Op       : in  STD_LOGIC_VECTOR(1 downto 0);
        Funct5   : in  STD_LOGIC;
        Funct0   : in  STD_LOGIC;
        Funct    : in  STD_LOGIC_VECTOR(4 downto 1); -- pour détecter CMP et MOV
        Funct11_7: in  STD_LOGIC_VECTOR(4 downto 0); -- shift amount
        Funct6_5 : in  STD_LOGIC_VECTOR(1 downto 0); -- shift type
        Branch   : out STD_LOGIC;
        MemtoReg : out STD_LOGIC;
        MemWrite : out STD_LOGIC;
        ALUSrc   : out STD_LOGIC;
        ImmSrc   : out STD_LOGIC_VECTOR(1 downto 0);
        RegWrite : out STD_LOGIC;
        RegSrc   : out STD_LOGIC_VECTOR(1 downto 0);
        ALUOp    : out STD_LOGIC;
        ShiftEn  : out STD_LOGIC  -- Active le shifter
    );
end main_decoder;

architecture Behavioral of main_decoder is
begin
    process(Op, Funct5, Funct0, Funct, Funct11_7, Funct6_5)
        variable has_shift : STD_LOGIC;
    begin
        -- Valeurs par défaut
        Branch   <= '0';
        MemtoReg <= '0';
        MemWrite <= '0';
        ALUSrc   <= '0';
        ImmSrc   <= "00";
        RegWrite <= '0';
        RegSrc   <= "00";
        ALUOp    <= '0';
        ShiftEn  <= '0';  -- Par défaut, pas de shift
        
        case Op is
            when "00" => -- Data Processing
                ALUOp    <= '1';
                MemtoReg <= '0';
                MemWrite <= '0';
                Branch   <= '0';
                
                -- Détecte CMP 
                if Funct = "1010" then
                    RegWrite <= '0';  -- CMP n'écrit pas
                else
                    RegWrite <= '1';  -- Autres instructions écrivent
                end if;
                
                if Funct5 = '0' then
                    -- ==========================================
                    -- DP Reg: registre comme 2e opérande
                    -- ==========================================
                    ALUSrc <= '0';
                    ImmSrc <= "00";
                    
                    --GESTION DE MOV AVEC REGISTRE: MOV Rd, Rm
                    -- Pour MOV, on veut: Rd = Rm (pas Rd = Rn + Rm)
                    -- Solution: Forcer Rn = R0 (qui vaut 0)
                    if Funct = "1101" then
                        -- MOV: Forcer la lecture de R0 comme premier opérande
                        RegSrc <= "01";  -- RA1 pointe vers R0 au lieu de Rn
                    else
                        RegSrc <= "00";  -- Normal
                    end if;
                    
                    -- Détection du shifted register
                    if (Funct11_7 /= "00000") or (Funct6_5 /= "00") then
                        has_shift := '1';
                    else
                        has_shift := '0';
                    end if;
                    
                    ShiftEn <= has_shift;
                    
                else
                    -- ==========================================
                    -- DP Imm: immédiat comme 2e opérande
                    -- ==========================================
                    ALUSrc  <= '1';
                    ImmSrc  <= "00";
                    ShiftEn <= '0';  -- Pas de shift avec immediate
                    
                    --GESTION DE MOV AVEC IMMÉDIAT: MOV Rd, #imm
                    -- Pour MOV, on veut: Rd = #imm (pas Rd = Rn + #imm)
                    -- Solution: Forcer Rn = R0 (qui vaut 0)
                    if Funct = "1101" then
                        -- MOV: Forcer la lecture de R0 comme premier opérande
                        RegSrc <= "01";  -- RA1 pointe vers R0 au lieu de Rn
                    else
                        RegSrc <= "00";  -- Normal
                    end if;
                end if;
                
            when "01" => -- Memory (LDR/STR)
                ALUSrc  <= '1';
                ImmSrc  <= "01";
                ALUOp   <= '0';
                Branch  <= '0';
                ShiftEn <= '0';  -- Pas de shift pour LDR/STR
                
                if Funct0 = '0' then
                    -- STR: Store Register
                    MemWrite <= '1';
                    RegWrite <= '0';
                    RegSrc   <= "10";
                    MemtoReg <= '0';
                else
                    -- LDR: Load Register
                    MemWrite <= '0';
                    RegWrite <= '1';
                    MemtoReg <= '1';
                    RegSrc   <= "00";
                end if;
                
            when "10" => -- Branch
                Branch   <= '1';
                ALUSrc   <= '1';
                ImmSrc   <= "10";
                ALUOp    <= '0';
                RegWrite <= '0';
                MemWrite <= '0';
                RegSrc   <= "01";  -- RA1 = R15 (PC)
                ShiftEn  <= '0';   -- Pas de shift pour branch
                
            when others =>
                -- Valeurs par défaut déjà définies
                ShiftEn <= '0';
        end case;
    end process;

end Behavioral;