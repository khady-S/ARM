----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 11/06/2025 02:45:58 PM
-- Design Name: 
-- Module Name: ARM_tb - Behavioral
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

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity ARM_tb is
--  Port ( );
end ARM_tb;

architecture Behavioral of ARM_tb is
    
    
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
    
    -- =========================================================================
    -- SIGNAUX DU TESTBENCH
    -- =========================================================================
    
    -- Signaux d'entrée
    signal clk   : STD_LOGIC := '0';
    signal reset : STD_LOGIC := '1';  -- Commence à 1 pour le reset initial
    
    -- Signaux de sortie pour observation
    signal ALUResult_tb  : STD_LOGIC_VECTOR(31 downto 0);
    signal WriteData_tb  : STD_LOGIC_VECTOR(31 downto 0);
    signal Result_tb     : STD_LOGIC_VECTOR(31 downto 0);
    signal PC_tb         : STD_LOGIC_VECTOR(31 downto 0);
    signal Instr_tb      : STD_LOGIC_VECTOR(31 downto 0);
    signal Flags_tb      : STD_LOGIC_VECTOR(3 downto 0);
    
    -- Constante de timing
    constant CLK_PERIOD : time := 10 ns;  -- Période d'horloge de 10 ns
    
begin
    
    -- =========================================================================
    -- INSTANCIATION DE L'ARM SOUS TEST (DUT)
    -- =========================================================================
    DUT: ARM_TOP
        port map(
            clk       => clk,
            reset     => reset,
            ALUResult => ALUResult_tb,
            WriteData => WriteData_tb,
            Result    => Result_tb,
            PC_out    => PC_tb,
            Instr_out => Instr_tb,
            Flags_out => Flags_tb
        );
    
    -- =========================================================================
    -- GÉNÉRATION DE L'HORLOGE
    -- Période: 10 ns
    -- Fréquence: 100 MHz
    -- =========================================================================
    clk_process: process
    begin
        clk <= '0';
        wait for CLK_PERIOD/2;  -- 5 ns
        clk <= '1';
        wait for CLK_PERIOD/2;  -- 5 ns
    end process;
    
    -- =========================================================================
    -- GESTION DU RESET
    -- Reset à 1 pendant les 2 premières nanosecondes
    -- =========================================================================
    reset_process: process
    begin
        reset <= '1';           -- Reset actif au démarrage
        wait for 2 ns;          -- Pendant 2 ns
        reset <= '0';           -- Désactive le reset
        wait;                   -- Attend indéfiniment
    end process;
    
    -- =========================================================================
    -- PROCESSUS DE SIMULATION
    -- =========================================================================
    stim_process: process
    begin
        -- Attendre que le reset soit terminé
        wait for 2 ns;
        
      
        wait for 500 ns;
        
        -- Message de fin de simulation
        report "=== SIMULATION TERMINÉE ===" severity note;
        report "Vérifiez les waveforms pour valider les résultats" severity note;
        report "Comparez ALUResult et WriteData avec le fichier de test" severity note;
        
        -- Fin de la simulation
        wait;
    end process;

end Behavioral;
