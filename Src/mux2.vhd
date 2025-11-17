----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 10/09/2025 12:06:06 PM
-- Design Name: 
-- Module Name: mux2 - Behavioral
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

entity mux2 is
    Port (
        D0  : in  STD_LOGIC_VECTOR(31 downto 0);  -- RD2 (registre)
        D1  : in  STD_LOGIC_VECTOR(31 downto 0);  -- ExtImm (immédiat)
        sel : in  STD_LOGIC;                      -- ALUSrc (1 bit)
        Y   : out STD_LOGIC_VECTOR(31 downto 0)   -- SrcB pour ALU
    );
end mux2;

architecture Behavioral of mux2 is
begin
    process(D0, D1, sel)
    begin
        case sel is
            when '0' => Y <= D0;  -- RD2 (registre)
            when '1' => Y <= D1;  -- ExtImm (immédiat)
            when others => Y <= D0; -- valeur par défaut
        end case;
    end process;
end Behavioral;
