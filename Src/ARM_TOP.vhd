----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 11/12/2025 12:39:16 AM
-- Design Name: 
-- Module Name: ARM_TOP - Behavioral
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

entity ARM_TOP is
    Port ( 
        clk        : in  STD_LOGIC;
        reset      : in  STD_LOGIC;
        ALUResult  : out STD_LOGIC_VECTOR(31 downto 0);
        WriteData  : out STD_LOGIC_VECTOR(31 downto 0);
        Result     : out STD_LOGIC_VECTOR(31 downto 0);
        PC_out     : out STD_LOGIC_VECTOR(31 downto 0);
        Instr_out  : out STD_LOGIC_VECTOR(31 downto 0);
        Flags_out  : out STD_LOGIC_VECTOR(3 downto 0)
    );
end ARM_TOP;

architecture Structural of ARM_TOP is

    -- =========================================================================
    -- DÉCLARATION DES COMPOSANTS
    -- =========================================================================
    
    -- Control Unit
    component control_unit
        Port ( 
            clk        : in  STD_LOGIC;
            reset      : in  STD_LOGIC;
            ALUFlags   : in  STD_LOGIC_VECTOR(3 downto 0);
            Cond       : in  STD_LOGIC_VECTOR(3 downto 0);
            Op         : in  STD_LOGIC_VECTOR(1 downto 0);
            Funct      : in  STD_LOGIC_VECTOR(5 downto 0);
            Funct11_7  : in  STD_LOGIC_VECTOR(4 downto 0);
            Funct6_5   : in  STD_LOGIC_VECTOR(1 downto 0);
            PCSrc      : out STD_LOGIC;
            MemtoReg   : out STD_LOGIC;
            MemWrite   : out STD_LOGIC;
            ALUSrc     : out STD_LOGIC;
            ImmSrc     : out STD_LOGIC_VECTOR(1 downto 0);
            RegWrite   : out STD_LOGIC;
            RegSrc     : out STD_LOGIC_VECTOR(1 downto 0);
            ALUControl : out STD_LOGIC_VECTOR(1 downto 0);
            ShiftEn    : out STD_LOGIC;
            Flags      : out STD_LOGIC_VECTOR(3 downto 0)
        );
    end component;
    
    -- PC Register
    component PC_register
        Port (
            clk    : in  STD_LOGIC;
            reset  : in  STD_LOGIC;
            PC_in  : in  STD_LOGIC_VECTOR(31 downto 0);
            PC_out : out STD_LOGIC_VECTOR(31 downto 0)
        );
    end component;
    
    -- Instruction Memory
    component memoire_instruction
        Port (
            A  : in  STD_LOGIC_VECTOR(31 downto 0);
            RD : out STD_LOGIC_VECTOR(31 downto 0)
        );
    end component;
    
    -- Register File
    component Registre
        Port (
            CLK : in  STD_LOGIC;
            WE3 : in  STD_LOGIC;
            RA1 : in  STD_LOGIC_VECTOR(3 downto 0);
            RA2 : in  STD_LOGIC_VECTOR(3 downto 0);
            A3  : in  STD_LOGIC_VECTOR(3 downto 0);
            WD3 : in  STD_LOGIC_VECTOR(31 downto 0);
            R15 : in  STD_LOGIC_VECTOR(31 downto 0);
            RD1 : out STD_LOGIC_VECTOR(31 downto 0);
            RD2 : out STD_LOGIC_VECTOR(31 downto 0)
        );
    end component;
    
    -- Shifter (Barrel Shifter)
    component shifter_reg
        Port ( 
            Src       : in  STD_LOGIC_VECTOR(31 downto 0);
            Shamt     : in  STD_LOGIC_VECTOR(4 downto 0);
            ShType    : in  STD_LOGIC_VECTOR(1 downto 0);
            ShiftOut  : out STD_LOGIC_VECTOR(31 downto 0);
            CarryOut  : out STD_LOGIC
        );
    end component;
    
    -- Extend
    component Extend
        Port (
            Instr  : in  STD_LOGIC_VECTOR(23 downto 0);
            ImmSrc : in  STD_LOGIC_VECTOR(1 downto 0);
            ExtImm : out STD_LOGIC_VECTOR(31 downto 0)
        );
    end component;
    
    -- ALU
    component ALU
        Port (
            A          : in  STD_LOGIC_VECTOR(31 downto 0);
            B          : in  STD_LOGIC_VECTOR(31 downto 0);
            ALUControl : in  STD_LOGIC_VECTOR(1 downto 0);
            ALUResult  : out STD_LOGIC_VECTOR(31 downto 0);
            ALUFlags   : out STD_LOGIC_VECTOR(3 downto 0)
        );
    end component;
    
    -- Data Memory
    component Data_Memory
        Port (
            CLK      : in  STD_LOGIC;
            MemWrite : in  STD_LOGIC;
            A        : in  STD_LOGIC_VECTOR(31 downto 0);
            WD       : in  STD_LOGIC_VECTOR(31 downto 0);
            RD       : out STD_LOGIC_VECTOR(31 downto 0)
        );
    end component;
    
    -- MUX 2:1 32-bit
    component mux2
        Port (
            D0  : in  STD_LOGIC_VECTOR(31 downto 0);
            D1  : in  STD_LOGIC_VECTOR(31 downto 0);
            sel : in  STD_LOGIC;
            Y   : out STD_LOGIC_VECTOR(31 downto 0)
        );
    end component;
    
    -- MUX pour RegSrc
    component mux2_RegSrc
        Port (
            D0  : in  STD_LOGIC_VECTOR(3 downto 0);
            D1  : in  STD_LOGIC_VECTOR(3 downto 0);
            sel : in  STD_LOGIC;
            Y   : out STD_LOGIC_VECTOR(3 downto 0)
        );
    end component;
    
    -- Adder
    component adder
        Port (
            a   : in  STD_LOGIC_VECTOR(31 downto 0);
            b   : in  STD_LOGIC_VECTOR(31 downto 0);
            y   : out STD_LOGIC_VECTOR(31 downto 0)
        );
    end component;
    
    -- =========================================================================
    -- SIGNAUX INTERNES
    -- =========================================================================
    
    -- Program Counter
    signal PC_sig        : STD_LOGIC_VECTOR(31 downto 0);
    signal PCPlus4       : STD_LOGIC_VECTOR(31 downto 0);
    signal PCPlus8       : STD_LOGIC_VECTOR(31 downto 0);
    signal PCNext        : STD_LOGIC_VECTOR(31 downto 0);
    signal PCBranch      : STD_LOGIC_VECTOR(31 downto 0);
    
    -- Instruction
    signal Instr_sig     : STD_LOGIC_VECTOR(31 downto 0);
    
    -- Control Signals
    signal PCSrc         : STD_LOGIC;
    signal MemtoReg      : STD_LOGIC;
    signal MemWrite      : STD_LOGIC;
    signal ALUSrc        : STD_LOGIC;
    signal ImmSrc        : STD_LOGIC_VECTOR(1 downto 0);
    signal RegWrite      : STD_LOGIC;
    signal RegSrc        : STD_LOGIC_VECTOR(1 downto 0);
    signal ALUControl    : STD_LOGIC_VECTOR(1 downto 0);
    signal ShiftEn       : STD_LOGIC;  -- ? NOUVEAU
    signal Flags         : STD_LOGIC_VECTOR(3 downto 0);
    signal ALUFlags_sig  : STD_LOGIC_VECTOR(3 downto 0);
    
    -- Register File
    signal RA1           : STD_LOGIC_VECTOR(3 downto 0);
    signal RA2           : STD_LOGIC_VECTOR(3 downto 0);
    signal RD1           : STD_LOGIC_VECTOR(31 downto 0);
    signal RD2           : STD_LOGIC_VECTOR(31 downto 0);
    signal Result_sig    : STD_LOGIC_VECTOR(31 downto 0);
    
    -- Shifter Signals 
    signal Shamt5        : STD_LOGIC_VECTOR(4 downto 0);
    signal ShType        : STD_LOGIC_VECTOR(1 downto 0);
    signal ShiftedSrc    : STD_LOGIC_VECTOR(31 downto 0);
    signal ShiftCarry    : STD_LOGIC;
    signal SrcB_shifted  : STD_LOGIC_VECTOR(31 downto 0);
    
    -- ALU
    signal SrcA          : STD_LOGIC_VECTOR(31 downto 0);
    signal SrcB          : STD_LOGIC_VECTOR(31 downto 0);
    signal ALUResult_sig : STD_LOGIC_VECTOR(31 downto 0);
    
    -- Extend
    signal ExtImm        : STD_LOGIC_VECTOR(31 downto 0);
    
    -- Data Memory
    signal ReadData      : STD_LOGIC_VECTOR(31 downto 0);
    signal WriteData_sig : STD_LOGIC_VECTOR(31 downto 0);
    
begin

    -- =========================================================================
    -- CONTROL UNIT
    -- =========================================================================
    ctrl: control_unit
        port map(
            clk        => clk,
            reset      => reset,
            ALUFlags   => ALUFlags_sig,
            Cond       => Instr_sig(31 downto 28),
            Op         => Instr_sig(27 downto 26),
            Funct      => Instr_sig(25 downto 20),
            Funct11_7  => Instr_sig(11 downto 7),   --NOUVEAU
            Funct6_5   => Instr_sig(6 downto 5),    --NOUVEAU
            PCSrc      => PCSrc,
            MemtoReg   => MemtoReg,
            MemWrite   => MemWrite,
            ALUSrc     => ALUSrc,
            ImmSrc     => ImmSrc,
            RegWrite   => RegWrite,
            RegSrc     => RegSrc,
            ALUControl => ALUControl,
            ShiftEn    => ShiftEn,                  --NOUVEAU
            Flags      => Flags
        );
    
    -- =========================================================================
    -- PROGRAM COUNTER
    -- =========================================================================
    pc_reg: PC_register
        port map(
            clk    => clk,
            reset  => reset,
            PC_in  => PCNext,
            PC_out => PC_sig
        );
    
    -- PC + 4
    pc_adder1: adder
        port map(
            a => PC_sig,
            b => x"00000004",
            y => PCPlus4
        );
    
    -- PC + 8 (pour R15)
    pc_adder2: adder
        port map(
            a => PCPlus4,
            b => x"00000004",
            y => PCPlus8
        );
    
    -- Branch adder
    branch_adder: adder
        port map(
            a => PCPlus4,
            b => ExtImm,
            y => PCBranch
        );
    
    -- MUX pour PCNext
    pc_mux: mux2
        port map(
            D0  => PCPlus4,
            D1  => PCBranch,
            sel => PCSrc,
            Y   => PCNext
        );
    
    -- =========================================================================
    -- INSTRUCTION MEMORY
    -- =========================================================================
    imem: memoire_instruction
        port map(
            A  => PC_sig,
            RD => Instr_sig
        );
    
    -- =========================================================================
    -- EXTRACTION DES BITS DE SHIFT (? NOUVEAU)
    -- =========================================================================
    Shamt5 <= Instr_sig(11 downto 7);  -- Shift amount
    ShType <= Instr_sig(6 downto 5);   -- Shift type
    
    -- =========================================================================
    -- REGISTER FILE
    -- =========================================================================
    
    -- MUX pour RA1
    ra1_mux: mux2_RegSrc
        port map(
            D0  => Instr_sig(19 downto 16),  -- Rn
            D1  => "1111",                    -- R15
            sel => RegSrc(0),
            Y   => RA1
        );
    
    -- MUX pour RA2
    ra2_mux: mux2_RegSrc
        port map(
            D0  => Instr_sig(3 downto 0),     -- Rm
            D1  => Instr_sig(15 downto 12),   -- Rd
            sel => RegSrc(1),
            Y   => RA2
        );
    
    -- Register File
    rf: Registre
        port map(
            CLK => clk,
            WE3 => RegWrite,
            RA1 => RA1,
            RA2 => RA2,
            A3  => Instr_sig(15 downto 12),  -- Rd
            WD3 => Result_sig,
            R15 => PCPlus8,
            RD1 => RD1,
            RD2 => RD2
        );
    
    -- =========================================================================
    -- BARREL SHIFTER 
    -- =========================================================================
    barrel_shifter: shifter_reg
        port map(
            Src      => RD2,
            Shamt    => Shamt5,
            ShType   => ShType,
            ShiftOut => ShiftedSrc,
            CarryOut => ShiftCarry
        );
    
    -- MUX pour activer/désactiver le shifter 
    SrcB_shifted <= ShiftedSrc when ShiftEn = '1' else RD2;
    
    -- =========================================================================
    -- EXTEND
    -- =========================================================================
    ext: Extend
        port map(
            Instr  => Instr_sig(23 downto 0),
            ImmSrc => ImmSrc,
            ExtImm => ExtImm
        );
    
    -- =========================================================================
    -- ALU
    -- =========================================================================
    
    -- SrcA toujours depuis RD1
    SrcA <= RD1;
    
    -- MUX ALUSrc ( MODIFIÉ pour utiliser SrcB_shifted)
    alu_src_mux: mux2
        port map(
            D0  => SrcB_shifted,  -- Utilise la sortie shifter ou RD2
            D1  => ExtImm,
            sel => ALUSrc,
            Y   => SrcB
        );
    
    -- ALU
    alu_unit: ALU
        port map(
            A          => SrcA,
            B          => SrcB,
            ALUControl => ALUControl,
            ALUResult  => ALUResult_sig,
            ALUFlags   => ALUFlags_sig
        );
    
    -- =========================================================================
    -- DATA MEMORY
    -- =========================================================================
    WriteData_sig <= RD2;
    
    dmem: Data_Memory
        port map(
            CLK      => clk,
            MemWrite => MemWrite,
            A        => ALUResult_sig,
            WD       => WriteData_sig,
            RD       => ReadData
        );
    
    -- MUX MemtoReg
    result_mux: mux2
        port map(
            D0  => ALUResult_sig,
            D1  => ReadData,
            sel => MemtoReg,
            Y   => Result_sig
        );
    
    -- =========================================================================
    -- SORTIES
    -- =========================================================================
    PC_out    <= PC_sig;
    Instr_out <= Instr_sig;
    ALUResult <= ALUResult_sig;
    WriteData <= WriteData_sig;
    Result    <= Result_sig;
    Flags_out <= Flags;

end Structural;