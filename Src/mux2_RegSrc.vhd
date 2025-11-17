----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 10/09/2025 12:54:56 PM
-- Design Name: 
-- Module Name: mux2_RegSrc - Behavioral
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

entity mux2_RegSrc is
    port(
        D0, D1 : in STD_LOGIC_VECTOR(3 downto 0);
        sel    : in STD_LOGIC;
        Y      : out STD_LOGIC_VECTOR(3 downto 0)
    );
end mux2_RegSrc;

architecture Behavioral of mux2_RegSrc is
begin
    Y <= D0 when sel = '0' else D1;
end Behavioral;
