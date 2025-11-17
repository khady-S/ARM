----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 10/09/2025 12:53:37 PM
-- Design Name: 
-- Module Name: DataPath - Behavioral
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
use STD.TEXTIO.ALL;
use IEEE.STD_LOGIC_TEXTIO.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity Datapath is
--  Port ( );
end Datapath;

architecture Behavioral of Datapath is
    
   
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
    -- Signaux pour les valeurs attendues
    signal ExpectedALUResult : STD_LOGIC_VECTOR(31 downto 0);
    signal ExpectedData      : STD_LOGIC_VECTOR(31 downto 0);
    
    -- Constante de timing
    constant CLK_PERIOD : time := 10 ns;  -- Période d'horloge de 10 ns
    
    -- fichier de test
    constant TEST_FILE_PATH : string := "C:/Architecture/Labo_4/labo_4/ExpectedData.txt";
    
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
    -- PROCESSUS DE LECTURE DU FICHIER DE TEST
    -- =========================================================================
    read_test_file: process
        file test_file : text;
        variable file_line : line;
        variable char : character;
        variable good_read : boolean;
        variable temp_alu : STD_LOGIC_VECTOR(31 downto 0);
        variable temp_data : STD_LOGIC_VECTOR(31 downto 0);
    begin
        -- Attendre la fin du reset
        wait until reset = '0';
        wait until rising_edge(clk);
        
        -- Ouvrir le fichier
        file_open(test_file, TEST_FILE_PATH, read_mode);
        
        -- Lire ligne par ligne
        while not endfile(test_file) loop
            readline(test_file, file_line);
            
            -- Lire ALUResult (32 bits en binaire)
            read(file_line, temp_alu, good_read);
            
            if good_read then
                ExpectedALUResult <= temp_alu;
                
                -- Lire le caractère '_' (séparateur)
                read(file_line, char);
                
                -- Lire WriteData (32 bits en binaire)
                read(file_line, temp_data, good_read);
                
                if good_read then
                    ExpectedData <= temp_data;
                end if;
            end if;
            
            -- Attendre le prochain cycle d'horloge
            wait until rising_edge(clk);
        end loop;
        
        -- Fermer le fichier
        file_close(test_file);
        
        report "=== LECTURE DU FICHIER DE TEST TERMINÉE ===" severity note;
        wait;
    end process;
    
    -- =========================================================================
    -- PROCESSUS DE VÉRIFICATION
    -- =========================================================================
    verify_process: process(clk)
        variable error_count : integer := 0;
    begin
        if rising_edge(clk) and reset = '0' then
            -- Attendre un peu après le reset pour commencer la vérification
            if PC_tb /= x"00000000" then
                -- Vérifier ALUResult
                if ALUResult_tb /= ExpectedALUResult then
                    report "ERREUR: ALUResult incorrect!" & 
                           " Attendu: " & to_hstring(ExpectedALUResult) &
                           " Obtenu: " & to_hstring(ALUResult_tb) &
                           " PC: " & to_hstring(PC_tb)
                           severity warning;
                    error_count := error_count + 1;
                end if;
                
                -- Vérifier WriteData
                if WriteData_tb /= ExpectedData then
                    report "ERREUR: WriteData incorrect!" & 
                           " Attendu: " & to_hstring(ExpectedData) &
                           " Obtenu: " & to_hstring(WriteData_tb) &
                           " PC: " & to_hstring(PC_tb)
                           severity warning;
                    error_count := error_count + 1;
                end if;
            end if;
        end if;
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
        report "Vérifiez les waveforms pour les détails" severity note;
        
        wait;
    end process;

end Behavioral;