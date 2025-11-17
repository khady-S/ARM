----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 10/29/2025 08:22:48 PM
-- Design Name: 
-- Module Name: Control_Unit - Behavioral
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

entity control_unit is
    Port ( 
        -- Ports pour les registres de flags (Exercice 1)
        clk        : in  STD_LOGIC;
        reset      : in  STD_LOGIC;
        ALUFlags   : in  STD_LOGIC_VECTOR(3 downto 0);
        
        -- Exercice 2
        Cond       : in  STD_LOGIC_VECTOR(3 downto 0);  -- Bits 31:28 de l'instruction
        
        -- Entrées venant de l'instruction
        Op         : in  STD_LOGIC_VECTOR(1 downto 0);   -- Bits 27:26
        Funct      : in  STD_LOGIC_VECTOR(5 downto 0);   -- Bits 25:20
        Funct11_7  : in  STD_LOGIC_VECTOR(4 downto 0);   --Bits 11:7 (Shift amount)
        Funct6_5   : in  STD_LOGIC_VECTOR(1 downto 0);   --Bits 6:5 (Shift type)
        
        -- Sorties vers le DataPath
        PCSrc      : out STD_LOGIC;
        MemtoReg   : out STD_LOGIC;
        MemWrite   : out STD_LOGIC;
        ALUSrc     : out STD_LOGIC;
        ImmSrc     : out STD_LOGIC_VECTOR(1 downto 0);
        RegWrite   : out STD_LOGIC;
        RegSrc     : out STD_LOGIC_VECTOR(1 downto 0);
        ALUControl : out STD_LOGIC_VECTOR(1 downto 0);
        ShiftEn    : out STD_LOGIC;  -- Active le shifter
        
        -- Flags stockés (Exercice 1)
        Flags      : out STD_LOGIC_VECTOR(3 downto 0)
    );
end control_unit;

architecture Structural of control_unit is
    -- =========================================================================
    -- DÉCLARATION DES COMPOSANTS
    -- =========================================================================
    
    component main_decoder
        Port ( 
            Op         : in  STD_LOGIC_VECTOR(1 downto 0);
            Funct5     : in  STD_LOGIC;
            Funct0     : in  STD_LOGIC;
            Funct      : in  STD_LOGIC_VECTOR(4 downto 1);
            Funct11_7  : in  STD_LOGIC_VECTOR(4 downto 0);  -- NOUVEAU
            Funct6_5   : in  STD_LOGIC_VECTOR(1 downto 0);  -- NOUVEAU
            Branch     : out STD_LOGIC;
            MemtoReg   : out STD_LOGIC;
            MemWrite   : out STD_LOGIC;
            ALUSrc     : out STD_LOGIC;
            ImmSrc     : out STD_LOGIC_VECTOR(1 downto 0);
            RegWrite   : out STD_LOGIC;
            RegSrc     : out STD_LOGIC_VECTOR(1 downto 0);
            ALUOp      : out STD_LOGIC;
            ShiftEn    : out STD_LOGIC  -- ? NOUVEAU
        );
    end component;
    
    component alu_decoder
        Port ( 
            ALUOp      : in  STD_LOGIC;
            Funct      : in  STD_LOGIC_VECTOR(4 downto 0);
            ALUControl : out STD_LOGIC_VECTOR(1 downto 0);
            FlagW      : out STD_LOGIC_VECTOR(1 downto 0)
        );
    end component;
    
    -- Composant flopr (Exercice 1)
    component flopr
        generic(width: integer := 32);
        port(
            clk   : in  STD_LOGIC;
            reset : in  STD_LOGIC;
            en    : in  STD_LOGIC;
            d     : in  STD_LOGIC_VECTOR(width-1 downto 0);
            q     : out STD_LOGIC_VECTOR(width-1 downto 0)
        );
    end component;
    
    -- Composant condcheck (Exercice 2)
    component condcheck
        port(
            Cond   : in  STD_LOGIC_VECTOR(3 downto 0);
            Flags  : in  STD_LOGIC_VECTOR(3 downto 0);
            CondEx : out STD_LOGIC
        );
    end component;
    
    -- =========================================================================
    -- SIGNAUX INTERNES
    -- =========================================================================
    signal ALUOp_internal    : STD_LOGIC;
    signal Branch_internal   : STD_LOGIC;
    signal FlagW_internal    : STD_LOGIC_VECTOR(1 downto 0);
    signal CondEx            : STD_LOGIC;
    signal FlagWrite         : STD_LOGIC_VECTOR(1 downto 0);
    signal Flags_internal    : STD_LOGIC_VECTOR(3 downto 0);
    signal RegWrite_internal : STD_LOGIC;
    signal MemWrite_internal : STD_LOGIC;
    
begin
    -- =========================================================================
    -- LOGIQUE DE CONTRÔLE CONDITIONNELLE
    -- =========================================================================
    
    -- PCSrc dépend du branch ET de la condition
    PCSrc <= Branch_internal and CondEx;
    
    -- RegWrite dépend aussi de CondEx (ne pas écrire si condition fausse)
    RegWrite <= RegWrite_internal and CondEx;
    
    -- MemWrite dépend aussi de CondEx
    MemWrite <= MemWrite_internal and CondEx;
    
    -- Enable pour l'écriture des flags: FlagW AND CondEx
    FlagWrite(1) <= FlagW_internal(1) and CondEx;
    FlagWrite(0) <= FlagW_internal(0) and CondEx;
    
    -- =========================================================================
    -- REGISTRES DE FLAGS
    -- =========================================================================
    
    -- Registres pour les flags [3:2] = N et Z (Exercice 1)
    flagreg1: flopr 
        generic map(width => 2)
        port map(
            clk   => clk,
            reset => reset,
            en    => FlagWrite(1),
            d     => ALUFlags(3 downto 2),
            q     => Flags_internal(3 downto 2)
        );
    
    -- Registres pour les flags [1:0] = C et V (Exercice 1)
    flagreg0: flopr 
        generic map(width => 2)
        port map(
            clk   => clk,
            reset => reset,
            en    => FlagWrite(0),
            d     => ALUFlags(1 downto 0),
            q     => Flags_internal(1 downto 0)
        );
    
    -- Sortie des flags
    Flags <= Flags_internal;
    
    -- =========================================================================
    -- VÉRIFICATION DE LA CONDITION
    -- =========================================================================
    cc: condcheck
        port map(
            Cond   => Cond,
            Flags  => Flags_internal,
            CondEx => CondEx
        );
    
    -- =========================================================================
    -- INSTANCIATION DU DÉCODEUR PRINCIPAL
    -- =========================================================================
    MainDec: main_decoder
        port map(
            Op         => Op,
            Funct5     => Funct(5),
            Funct0     => Funct(0),
            Funct      => Funct(4 downto 1),
            Funct11_7  => Funct11_7, 
            Funct6_5   => Funct6_5,    
            Branch     => Branch_internal,
            MemtoReg   => MemtoReg,
            MemWrite   => MemWrite_internal,
            ALUSrc     => ALUSrc,
            ImmSrc     => ImmSrc,
            RegWrite   => RegWrite_internal,
            RegSrc     => RegSrc,
            ALUOp      => ALUOp_internal,
            ShiftEn    => ShiftEn  
        );
    
    -- =========================================================================
    -- INSTANCIATION DU DÉCODEUR ALU
    -- =========================================================================
    ALUDec: alu_decoder
        port map(
            ALUOp      => ALUOp_internal,
            Funct      => Funct(4 downto 0),
            ALUControl => ALUControl,
            FlagW      => FlagW_internal
        );
    
end Structural;
    