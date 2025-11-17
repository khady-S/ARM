----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 11/10/2025 05:59:09 PM
-- Design Name: 
-- Module Name: tb_cmp - Behavioral
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

entity tb_cmp is
end tb_cmp;

architecture Behavioral of tb_cmp is
    -- Composant ARM 
    component arm
        port(
            clk      : in  STD_LOGIC;
            reset    : in  STD_LOGIC;
            PC       : out STD_LOGIC_VECTOR(31 downto 0);
            Instr    : out STD_LOGIC_VECTOR(31 downto 0);
            ALUResult: out STD_LOGIC_VECTOR(31 downto 0);
            WriteData: out STD_LOGIC_VECTOR(31 downto 0);
            ReadData : out STD_LOGIC_VECTOR(31 downto 0)
        );
    end component;
    
    -- Signaux
    signal clk       : STD_LOGIC := '0';
    signal reset     : STD_LOGIC := '0';
    signal PC        : STD_LOGIC_VECTOR(31 downto 0);
    signal Instr     : STD_LOGIC_VECTOR(31 downto 0);
    signal ALUResult : STD_LOGIC_VECTOR(31 downto 0);
    signal WriteData : STD_LOGIC_VECTOR(31 downto 0);
    signal ReadData  : STD_LOGIC_VECTOR(31 downto 0);
    
    constant clk_period : time := 10 ns;
    
begin
    -- Instance ARM
    dut: arm
        port map(
            clk       => clk,
            reset     => reset,
            PC        => PC,
            Instr     => Instr,
            ALUResult => ALUResult,
            WriteData => WriteData,
            ReadData  => ReadData
        );
    
    -- Horloge
    clk_process: process
    begin
        clk <= '0';
        wait for clk_period/2;
        clk <= '1';
        wait for clk_period/2;
    end process;
    
    -- Stimulus
    stim_proc: process
    begin
        -- Reset
        reset <= '1';
        wait for 2 ns;
        reset <= '0';
        
        -- Attendre l'exécution
        wait for 500 ns;
        
        -- Fin
        report "Test terminé";
        wait;
    end process;
    
end Behavioral;
