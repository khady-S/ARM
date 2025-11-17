----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 11/11/2025 01:05:23 PM
-- Design Name: 
-- Module Name: shifter_reg - Behavioral
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

entity shifter_reg is
    Port ( 
        Src       : in  STD_LOGIC_VECTOR(31 downto 0);  -- Valeur à décaler
        Shamt     : in  STD_LOGIC_VECTOR(4 downto 0);   -- Quantité de décalage (0-31)
        ShType    : in  STD_LOGIC_VECTOR(1 downto 0);   -- Type de décalage
        ShiftOut  : out STD_LOGIC_VECTOR(31 downto 0);  -- Résultat
        CarryOut  : out STD_LOGIC                        -- Carry out du shift
    );
end shifter_reg;

architecture Behavioral of shifter_reg is
    signal shift_amount : integer range 0 to 31;
begin
    
    shift_amount <= to_integer(unsigned(Shamt));
    
    process(Src, Shamt, ShType, shift_amount)
        variable temp_result : STD_LOGIC_VECTOR(31 downto 0);
        variable temp_carry  : STD_LOGIC;
    begin
        temp_result := Src;
        temp_carry := '0';
        
        case ShType is
            -- LSL: Logical Shift Left
            when "00" =>
                if shift_amount = 0 then
                    temp_result := Src;
                    temp_carry := '0';
                elsif shift_amount <= 32 then
                    temp_result := STD_LOGIC_VECTOR(shift_left(unsigned(Src), shift_amount));
                    -- Carry = dernier bit éjecté
                    if shift_amount <= 31 then
                        temp_carry := Src(32 - shift_amount);
                    else
                        temp_carry := '0';
                    end if;
                else
                    temp_result := (others => '0');
                    temp_carry := '0';
                end if;
                
            -- LSR: Logical Shift Right
            when "01" =>
                if shift_amount = 0 then
                    temp_result := Src;
                    temp_carry := '0';
                elsif shift_amount <= 32 then
                    temp_result := STD_LOGIC_VECTOR(shift_right(unsigned(Src), shift_amount));
                    -- Carry = dernier bit éjecté
                    temp_carry := Src(shift_amount - 1);
                else
                    temp_result := (others => '0');
                    temp_carry := '0';
                end if;
                
            -- ASR: Arithmetic Shift Right
            when "10" =>
                if shift_amount = 0 then
                    temp_result := Src;
                    temp_carry := '0';
                elsif shift_amount < 32 then
                    temp_result := STD_LOGIC_VECTOR(shift_right(signed(Src), shift_amount));
                    temp_carry := Src(shift_amount - 1);
                else
             -- Pour ASR >= 32, on remplit avec le bit de signe
                    if Src(31) = '1' then
                        temp_result := (others => '1');
                    else
                        temp_result := (others => '0');
                    end if;
                    temp_carry := Src(31);
                end if;
                
            -- ROR: Rotate Right
            when "11" =>
                if shift_amount = 0 then
                    temp_result := Src;
                    temp_carry := '0';
                else
            -- Rotation effectue un décalage circulaire
                    temp_result := STD_LOGIC_VECTOR(rotate_right(unsigned(Src), shift_amount));
                    temp_carry := temp_result(31);  -- MSB après rotation
                end if;
                
            when others =>
                temp_result := Src;
                temp_carry := '0';
        end case;
        
        ShiftOut <= temp_result;
        CarryOut <= temp_carry;
        
    end process;

end Behavioral;


