LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.std_logic_arith.all;
USE ieee.std_logic_unsigned.all;

ENTITY interrupt_controller IS
PORT (boot 			: IN 		STD_LOGIC;
		CLK	 	: IN 		STD_LOGIC;
		inta			: IN		STD_LOGIC;
		key_intr		: IN		STD_LOGIC;
		ps2_intr		: IN		STD_LOGIC;
		switch_intr	: IN		STD_LOGIC;
		timer_intr	: IN		STD_LOGIC;
		intr			: OUT		STD_LOGIC := '0';
		key_inta		: OUT		STD_LOGIC := '0';
		ps2_inta		: OUT		STD_LOGIC := '0';
		switch_inta	: OUT 	STD_LOGIC := '0';
		timer_inta	: OUT		STD_LOGIC := '0';
		interruptEnabled: IN STD_LOGIC;
		interruptNow :IN STD_LOGIC;
		iid			: OUT		STD_LOGIC_VECTOR(15 DOWNTO 0));	
END interrupt_controller;

ARCHITECTURE Structure OF interrupt_controller IS
	
	SIGNAL interrupt,interrupt2,interrupt3,interrupt4,interrupt5,interrupt6,interrupt7,interrupt8		: STD_LOGIC := '0';
	SIGNAL current_int 	: STD_LOGIC_VECTOR(15 DOWNTO 0);
	
BEGIN

	
	current_int <= 	"0000000000000000" WHEN timer_intr = '1' 	ELSE --timer
							"0000000000000001" WHEN key_intr = '1'		ELSE --pulsadores
							"0000000000000010" WHEN switch_intr = '1' ELSE --switches
							"0000000000000011" WHEN ps2_intr = '1' ; -- teclado ps2
							
	interrupt	<=		'1' WHEN 	(timer_intr = '1' 	OR 
											key_intr = '1' 	OR
											switch_intr = '1'	OR
											ps2_intr = '1')	
											AND boot = '0'  ELSE '0';
											
	--timer_inta <= 	'1' WHEN (inta = '1' AND interrupt = '1' AND current_int = "0000000000000000") AND boot = '0' ELSE
	--				'0';
							
	--key_inta <= 	'1' WHEN (inta = '1' AND interrupt = '1' AND current_int = "0000000000000001") AND boot = '0' ELSE
		--			'0';
					
	
	--switch_inta <= '1' WHEN (inta = '1' AND interrupt = '1' AND current_int = "0000000000000010") AND boot = '0' ELSE
	--			'0';
						
						
	--ps2_inta <= '1' WHEN (inta = '1' AND interrupt = '1' AND current_int = "0000000000000011") AND boot = '0' ELSE
	--				'0';


	
	PROCESS(clk)
	BEGIN
		IF RISING_EDGE(clk) THEN
			intr <= interrupt;
--			interrupt <= interrupt2;
--			interrupt2 <= interrupt3;
--			interrupt3 <= interrupt4;
--			interrupt4 <= interrupt5;
--			interrupt5 <= interrupt6;
--			interrupt6 <= interrupt7;
--			interrupt7 <= interrupt8;
			iid  <= current_int;
			IF (inta = '1' AND interrupt = '1') THEN
				IF current_int = "0000000000000001" THEN
					key_inta <= '1';
					ps2_inta <= '0';
					switch_inta <= '0';
					timer_inta <= 	'0';
				ELSIF current_int = "0000000000000011" THEN
					key_inta <= '0';
					ps2_inta <= '1';
					switch_inta <= '0';
					timer_inta <= 	'0';
				ELSIF current_int = "0000000000000010" THEN
					key_inta <= '0';
					ps2_inta <= '0';
					switch_inta <= '1';
					timer_inta <= 	'0';
				ELSIF current_int = "0000000000000000" THEN
					key_inta <= '0';
					ps2_inta <= '0';
					switch_inta <= '0';
					timer_inta <= 	'1';
				END IF;
			ELSE 
				key_inta <= '0';
				ps2_inta <= '0';
				switch_inta <= '0';
				timer_inta <= 	'0';
			END IF;
		END IF;
	END PROCESS;
	
END Structure;