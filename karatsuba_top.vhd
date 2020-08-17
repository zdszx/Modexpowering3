----------------------------------------------------------------------------------
-- Company: 
-- Engineer:
-- FEKETE, Balazs Valer, fbv81bp@gmail.com, fbv81bp@outlook.hu
-- Create Date: 01.04.2020 06:41:46
-- Design Name: Karatsuba multiplier
-- Module Name: karatsuba_top - Behavioral
-- Project Name: 
-- Target Devices: Any
-- Tool Versions: 
-- Description: 
-- 
-- Dependencies: 
-- 
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
-- ALL RIGHTS RESERVED!
----------------------------------------------------------------------------------


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity karatsuba_top is
    Port ( x : in STD_LOGIC_VECTOR (31 downto 0);
           y : in STD_LOGIC_VECTOR (31 downto 0);
           z : out STD_LOGIC_VECTOR (63 downto 0));
end karatsuba_top;

architecture Behavioral of karatsuba_top is

component karatsuba is
    Generic( x_width, y_width : natural);
    Port ( x : in STD_LOGIC_VECTOR (x_width-1 downto 0);
           y : in STD_LOGIC_VECTOR (y_width-1 downto 0);
           z : out STD_LOGIC_VECTOR (x_width+y_width-1 downto 0));
end component;

begin

top_inst : karatsuba Generic Map(32, 32)
                     Port Map(x, y, z);

end Behavioral;
