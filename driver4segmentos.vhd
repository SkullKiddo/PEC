LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE IEEE.std_logic_arith.all;
USE ieee.std_logic_unsigned.all;

ENTITY driver4displays IS
	PORT(
	numeros : IN STD_LOGIC_VECTOR(15 DOWNTO 0);
	HEX0 : OUT std_logic_vector(6 downto 0);
	HEX1 : OUT std_logic_vector(6 downto 0);
	HEX2 : OUT std_logic_vector(6 downto 0);
	HEX3 : OUT std_logic_vector(6 downto 0));
END driver4displays;

ARCHITECTURE Structure OF driver4displays IS

COMPONENT driver7Segmentos IS
	PORT( codigoCaracter : IN STD_LOGIC_VECTOR(3 DOWNTO 0);
	bitsCaracter : OUT STD_LOGIC_VECTOR(6 DOWNTO 0));
END COMPONENT;
BEGIN
Driver0: driver7Segmentos PORT MAP (codigoCaracter =>numeros(3 DOWNTO 0),	bitsCaracter => HEX0);
Driver1: driver7Segmentos PORT MAP (codigoCaracter =>numeros(7 DOWNTO 4),	bitsCaracter => HEX1);
Driver2: driver7Segmentos PORT MAP (codigoCaracter =>numeros(11 DOWNTO 8),	bitsCaracter => HEX2);
Driver3: driver7Segmentos PORT MAP (codigoCaracter =>numeros(15 DOWNTO 12),	bitsCaracter => HEX3);
END Structure;