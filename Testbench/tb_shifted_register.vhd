----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 11/11/2025 01:46:17 PM
-- Design Name: 
-- Module Name: tb_shifted_register - Behavioral
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

entity tb_shifted_register is
end tb_shifted_register;

architecture Behavioral of tb_shifted_register is
    
    -- Composant ARM 
    component ARM_TOP
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
    end component;
    
    -- Signaux
    signal clk       : STD_LOGIC := '0';
    signal reset     : STD_LOGIC := '0';
    signal PC        : STD_LOGIC_VECTOR(31 downto 0);
    signal Instr     : STD_LOGIC_VECTOR(31 downto 0);
    signal ALUResult : STD_LOGIC_VECTOR(31 downto 0);
    signal WriteData : STD_LOGIC_VECTOR(31 downto 0);
    signal Result    : STD_LOGIC_VECTOR(31 downto 0);
    signal Flags     : STD_LOGIC_VECTOR(3 downto 0);
    
    constant clk_period : time := 10 ns;
    
    -- Compteur de tests
    signal test_count : integer := 0;
    signal error_count : integer := 0;
    
begin
    -- Instance ARM
    dut: ARM_TOP
        port map(
            clk       => clk,
            reset     => reset,
            PC_out    => PC,
            Instr_out => Instr,
            ALUResult => ALUResult,
            WriteData => WriteData,
            Result    => Result,
            Flags_out => Flags
        );
    
    -- Horloge
    clk_process: process
    begin
        clk <= '0';
        wait for clk_period/2;
        clk <= '1';
        wait for clk_period/2;
    end process;
    
    -- Processus de stimulus
    stim_proc: process
    begin
        -- Reset initial
        reset <= '1';
        wait for 2 ns;
        reset <= '0';
        
        report "========================================" severity note;
        report "DÉBUT DES TESTS SHIFTED REGISTER" severity note;
        report "========================================" severity note;
        
        -- Attendre quelques cycles pour l'initialisation
        wait for 20 ns;
        
        -- ====================================================================
        -- Laisser le programme s'exécuter
        -- ====================================================================
        
        -- Attendre que toutes les instructions soient exécutées
        wait for 500 ns;
        
        -- ====================================================================
        -- RAPPORT FINAL
        -- ====================================================================
        report "========================================" severity note;
        report "FIN DES TESTS SHIFTED REGISTER" severity note;
        report "Vérifiez les waveforms pour valider les résultats" severity note;
        report "========================================" severity note;
        
        -- Afficher les dernières valeurs
        report "Dernières valeurs observées:" severity note;
        report "  PC = " & integer'image(to_integer(unsigned(PC))) severity note;
        report "  ALUResult = " & integer'image(to_integer(unsigned(ALUResult))) severity note;
        report "  Result = " & integer'image(to_integer(unsigned(Result))) severity note;
        report "  Flags = " & 
               integer'image(to_integer(unsigned'(0 => Flags(3)))) & 
               integer'image(to_integer(unsigned'(0 => Flags(2)))) & 
               integer'image(to_integer(unsigned'(0 => Flags(1)))) & 
               integer'image(to_integer(unsigned'(0 => Flags(0)))) 
               severity note;
        
        wait;
    end process;
    
    -- =========================================================================
    -- PROCESSUS DE MONITORING (Observer les changements)
    -- =========================================================================
    monitor_proc: process(clk)
        variable last_pc : STD_LOGIC_VECTOR(31 downto 0) := (others => '0');
    begin
        if rising_edge(clk) and reset = '0' then
            -- Afficher quand PC change (nouvelle instruction)
            if PC /= last_pc then
                report ">>> PC = " & integer'image(to_integer(unsigned(PC))) &
                       " | Instr = " & integer'image(to_integer(unsigned(Instr))) &
                       " | ALUResult = " & integer'image(to_integer(signed(ALUResult))) &
                       " | Result = " & integer'image(to_integer(signed(Result)))
                       severity note;
                last_pc := PC;
            end if;
        end if;
    end process;

end Behavioral;