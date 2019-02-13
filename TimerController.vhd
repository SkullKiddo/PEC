LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.std_logic_arith.all;
USE ieee.std_logic_unsigned.all;

ENTITY timer IS
PORT (boot 					: IN 		STD_LOGIC;
		clk	 			: IN 		STD_LOGIC;
		inta					: IN		STD_LOGIC;
		interruptNow :IN STD_LOGIC;
		intr					: OUT		STD_LOGIC := '0');	
END timer;


ARCHITECTURE Structure OF timer IS

	SIGNAL interrupt	:	STD_LOGIC := '0';
	signal acaba_interr: STD_LOGIC;
	SIGNAL contador_ciclos			:	 STD_LOGIC_VECTOR(15 downto 0);
	SIGNAL contador_milisegundos	:	 STD_LOGIC_VECTOR(15 downto 0);
	
BEGIN

	PROCESS(clk)
	BEGIN
		IF RISING_EDGE(clk) THEN
			IF inta = '1' THEN
				acaba_interr <= '1';
			elsif acaba_interr = '1' then	
				interrupt <= '0';
			else acaba_interr <= '0';
			END IF;
			--timer
			IF contador_ciclos=0 THEN
				contador_ciclos<=x"C350"; -- tiempo de ciclo=20ns(50Mhz) 1ms=50000ciclos
				--contador_ciclos<=x"0005";
				IF contador_milisegundos = 0 THEN
					contador_milisegundos <= x"0032";
					interrupt <= '1';
				ELSIF contador_milisegundos > 0 THEN
					contador_milisegundos <= contador_milisegundos-1;
				END IF;
			ELSE
				contador_ciclos <= contador_ciclos-1;
			END IF;
			
			--boot
			IF boot = '1' THEN 
				contador_ciclos<=x"C350";
				contador_milisegundos <= x"0032";
			END IF;
		END IF;
	END PROCESS;
	 
	 intr <= interrupt;
END STRUCTURE;