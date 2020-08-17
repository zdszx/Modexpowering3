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
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;
use IEEE.std_logic_unsigned.all;
use IEEE.math_real.all;

entity karatsuba is
    Generic( x_width : integer;
             y_width : integer);
    Port ( x : in STD_LOGIC_VECTOR (x_width-1 downto 0);
           y : in STD_LOGIC_VECTOR (y_width-1 downto 0);
           z : out STD_LOGIC_VECTOR (x_width +y_width -1 downto 0));
end karatsuba;

architecture Behavioral of karatsuba is

component karatsuba is
    Generic( x_width, y_width : natural);
    Port ( x : in STD_LOGIC_VECTOR (x_width-1 downto 0);
           y : in STD_LOGIC_VECTOR (y_width-1 downto 0);
           z : out STD_LOGIC_VECTOR (x_width +y_width -1 downto 0));
end component;

constant split : natural := integer(floor(real(x_width/2)));
signal high_x : std_logic_vector(x_width -1 downto split);
signal low_x : std_logic_vector(split -1 downto 0);
constant highx_l : integer := high_x'length;
constant lowx_l : integer := low_x'length;
signal low_y : std_logic_vector(y_width -1 downto 0);
constant bits : std_logic_vector(highx_l -lowx_l downto 0) := (others => '0');
signal sum_x : std_logic_vector(highx_l downto 0);
constant sumx_l : integer := sum_x'length;
signal z0 : std_logic_vector(lowx_l +y_width -1 downto 0);
signal z1 : std_logic_vector(sumx_l +y_width -1 downto 0);
constant bit : std_logic_vector(highx_l -lowx_l -1 downto 0) := (others => '0');
constant shift : std_logic_vector(split - 1 downto 0) := (others => '0');
signal zi : std_logic_vector(z'length downto 0);

begin

generate_recursion : if x_width > y_width generate
    high_x <= x(x'high downto split);
    low_x  <= x(split-1 downto 0);
    low_y  <= y;
    sum_x  <= ('0' & high_x) + (bits & low_x);
    recursive_inst0 : karatsuba Generic Map(lowx_l, y_width)
                                Port Map(low_x, low_y, z0);
    recursive_inst1 : karatsuba Generic Map(sumx_l, y_width)
                                Port Map(sum_x, low_y, z1);

    zi <= ((z1-z0) & shift) + (shift & bit & z0);
    z <= zi(z'length-1 downto 0);
end generate;

generate_end : if x_width <= y_width generate
    z <=  x * y;
end generate;

end Behavioral;
