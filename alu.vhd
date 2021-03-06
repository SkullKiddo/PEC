LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.numeric_std.all;
--USE IEEE.std_logic_unsigned.all;
USE IEEE.std_logic_signed.all;
--use ieee.STD_LOGIC_ARITH.all;



ENTITY alu IS
    PORT (x  : IN  STD_LOGIC_VECTOR(15 DOWNTO 0);
          y  : IN  STD_LOGIC_VECTOR(15 DOWNTO 0);
          op : IN  STD_LOGIC_VECTOR(5 downto 0);
          w  : OUT STD_LOGIC_VECTOR(15 DOWNTO 0);
			 div_zero :OUT STD_LOGIC;
			 z: OUT STD_LOGIC);
END alu;


ARCHITECTURE Structure OF alu IS

signal conv, cmplt,cmple,cmpeq,cmpltu,cmpleu , mul, sha_c: STD_LOGIC_VECTOR(15 downto 0);
signal Smul, Umul: STD_LOGIC_VECTOR(31 downto 0); --resultat de multiplicar unsigned

BEGIN

	 conv(7 downto 0) <= x(7 downto 0);
	 conv(15 downto 8) <= y(7 downto 0);
	 with y(15 downto 15) select sha_c <=
		to_stdlogicvector(to_bitvector(x) sla to_integer(signed(y))) when "1",
		std_logic_vector(unsigned(x) sll to_integer(signed(y))) when others;
	 
	cmplt <= "0000000000000001" when signed(x) < signed(y) else "0000000000000000";	
	cmple <= "0000000000000001" when signed(x) <= signed(y) else "0000000000000000";	
	cmpeq <= "0000000000000001" when signed(x) = signed(y) else	"0000000000000000";	
	cmpltu <= "0000000000000001" when unsigned(x) < unsigned(y) else "0000000000000000";
	cmpleu <= "0000000000000001" when unsigned(x) <= unsigned(y) else "0000000000000000";	 
	--mul <= std_logic_vector( signed(x) * signed(y) ); --MUL
	with op select w <= 
	   y when "000000",
		conv when "000001",
		x and y when "000011",
		x or y when "000100",
		x xor y when "000101",
		not x when "000110",
		STD_LOGIC_VECTOR(signed(x) + signed(y)) when "000111",
		STD_LOGIC_VECTOR(signed(x) - signed(y)) when "001000",
		sha_c when "001001", --sha
		std_logic_vector(unsigned(x) sll to_integer(signed(y))) when "001010", -- SHL
		--"01001" when "0000------110---", --SHA
		--"01010" when "0000------111---", --SHL
		cmplt when "001011",--CMPLT
		cmple when "001100", --CMPLE
		cmpeq when "001101",--CMPEQ
		cmpltu when "001110",--CMPLTU
		cmpleu when "001111", --CMPLEU "01111"
		STD_LOGIC_VECTOR(signed(x)+signed(y)) when "010000", --ADDI
		Smul(15 DOWNTO 0) when "010001", --MUL
		Smul(31 DOWNTO 16) when "010010", --MULH
		Umul (31 DOWNTO 16)when "010011", --MULHU
		STD_LOGIC_VECTOR(signed(x)/signed(y)) when "010100", --DIV
		STD_LOGIC_VECTOR(unsigned(x)/unsigned(y)) when "010101", --DIVU
		STD_LOGIC_VECTOR(signed(x) + signed(y)) when "010110", 
		STD_LOGIC_VECTOR(signed(x) + signed(y)) when	"010111", 
		STD_LOGIC_VECTOR(signed(x) + signed(y)) when "011000", 
		STD_LOGIC_VECTOR(signed(x) + signed(y)) when "011001",
		x when "100000",
		x when "100001",
		x when others;
		
		
		--"10110" when ir (15 downto 12) = LD else --ld
			--"10111" when ir (15 downto 12) = ST else --st
			--"11000" when ir (15 downto 12) = LDB else --ldb
			--"11001" when ir (15 downto 12) = STB else --stdb
		Smul <= std_logic_vector(signed(x)*signed(y));
		Umul <= std_logic_vector(unsigned(x)*unsigned(y));
		
		div_zero <=
			'1' when (op = "010100" or op = "010101") and y = "0000000000000000" else '0';
		
		with y select z <=
			'1' when "0000000000000000",
			'0' when others;
END Structure;