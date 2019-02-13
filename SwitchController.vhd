LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.numeric_std.all;        --Esta libreria sera necesaria si usais conversiones TO_INTEGER
USE ieee.std_logic_unsigned.all;

ENTITY switches_controller IS
		PORT (boot:	IN STD_LOGIC;
				clk:	IN STD_LOGIC;
				inta: IN STD_LOGIC;
				switches: IN STD_LOGIC_VECTOR (7 downto 0);
				intr: OUT STD_LOGIC;
				read_switches: OUT STD_LOGIC_VECTOR (7 downto 0));
END ENTITY;

ARCHITECTURE Structure OF switches_controller IS
SIGNAL last				:	STD_LOGIC_VECTOR(7 DOWNTO 0); --valor de switches en el ciclo anterior
	SIGNAL changed			:	STD_LOGIC := '0'; --indica si ha habido algun cambio mientras se estaba atendiendo otra interrupcion
	
	SIGNAL value_int		:  STD_LOGIC_VECTOR(7 DOWNTO 0); --valor de switches de la interrupcion actual
	SIGNAL interrupt		:	STD_LOGIC := '0'; --indica si se esta atendiendo una interrupcion
	
BEGIN

	PROCESS(clk)
	BEGIN
		IF RISING_EDGE(clk) THEN
			IF boot = '1' THEN
				interrupt <= '0';
				changed 	 <= '0';
			ELSIF((last /= switches AND interrupt = '0') 
					OR (changed = '1' AND interrupt = '0')) THEN --si ve un cambio en el valor de switches o hay el flag de changed activado, genera una interrupcion
				interrupt <= '1';
				value_int <= switches;
				changed <= '0';
			ELSIF (last /= switches) THEN
				changed <= '1';
			END IF;	
			
			IF (inta = '1') THEN --si recibe un acknowledge, termina la interrupion
				interrupt <= '0';
			END IF;
			
			last <= switches;
		END IF;
	END PROCESS;
	 
	 intr <= interrupt;
	 read_switches <= value_int;
END STRUCTURE;