LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.numeric_std.all;        --Esta libreria sera necesaria si usais conversiones TO_INTEGER
USE ieee.std_logic_unsigned.all;

ENTITY controladores_IO IS  
  PORT (boot   : IN  STD_LOGIC; 
		clk    : IN  std_logic;
		PS2_CLK: INout STD_LOGIC ;
		ps2_data   : inout STD_LOGIC;
		addr_io     : IN  std_logic_vector(7 downto 0); 
		wr_io  : in  std_logic_vector(15 downto 0); 
		rd_io  : out std_logic_vector(15 downto 0); 
		wr_out : in  std_logic; 
		rd_in  : in  std_logic; 
		led_verdes  : OUT STD_LOGIC_VECTOR(7 DOWNTO 0); 
		led_rojos   : OUT STD_LOGIC_VECTOR(7 DOWNTO 0);
      SW        	: in std_logic_vector(7 downto 0);
		sevenSeg 	: OUT std_LOGIC_VECTOR(15 DOWNTO 0);
		KEY		  	: IN std_LOGIC_VECTOR(3 DOWNTO 0);
		inta :IN std_LOGIC;
		intr : OUT STD_LOGIC;
		interruptEnabled: IN STD_LOGIC;
		interruptNow :IN STD_LOGIC);
	END controladores_IO; 
	
ARCHITECTURE Structure OF controladores_IO IS 

type lmeuarray is array (255 downto 0) of std_logic_vector(15 downto 0);
signal registres : lmeuarray;
signal botones, interruptores : std_LOGIC_VECTOR(15 DOWNTO 0);
signal read_keyboard, clear_keyboard : STD_LOGIC;
signal data_keyboard : STD_LOGIC_VECTOR (7 downto 0);

COMPONENT keyboard_controller is
    Port (clk        : in    STD_LOGIC;
          reset      : in    STD_LOGIC;
          ps2_clk    : inout STD_LOGIC;
          ps2_data   : inout STD_LOGIC;
          read_char  : out   STD_LOGIC_VECTOR (7 downto 0); --15
          clear_char : in    STD_LOGIC;
          data_ready : out   STD_LOGIC); --16
END COMPONENT keyboard_controller;

COMPONENT interrupt_controller IS
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
		interruptNow : IN STD_LOGIC;
		iid			: OUT		STD_LOGIC_VECTOR(15 DOWNTO 0));	
END COMPONENT;

COMPONENT switches_controller IS
		PORT (boot:	IN STD_LOGIC;
				clk:	IN STD_LOGIC;
				inta: IN STD_LOGIC;
				switches: IN STD_LOGIC_VECTOR (7 downto 0);
				intr: OUT STD_LOGIC;
				read_switches: OUT STD_LOGIC_VECTOR (7 downto 0));
END COMPONENT SWItches_controller;

COMPONENT timer IS
PORT (boot 					: IN 		STD_LOGIC;
		clk	 			: IN 		STD_LOGIC;
		inta					: IN		STD_LOGIC;
		interruptNow :IN STD_LOGIC;
		intr					: OUT		STD_LOGIC := '0');	
END COMPONENT timer;

COMPONENT keys_controller IS
		PORT (boot:	IN STD_LOGIC;
				clk:	IN STD_LOGIC;
				inta: IN STD_LOGIC;
				keys: IN STD_LOGIC_VECTOR (3 downto 0);
				intr: OUT STD_LOGIC;
				read_key: OUT STD_LOGIC_VECTOR (3 downto 0));
END COMPONENT keys_controller;

signal read_char_C : STD_LOGIC_VECTOR(7 downto 0);
signal data_ready_C, clear_char_c,intr_c : STD_LOGIC; 

signal timer_intr, ps2_intr, switch_intr, key_intr: STD_LOGIC;
signal timer_inta, ps2_inta_c, switch_inta, key_inta: STD_LOGIC;


signal readed_switches	:	STD_LOGIC_VECTOR(7 DOWNTO 0);
signal readed_key		:	STD_LOGIC_VECTOR(3 DOWNTO 0);
signal contador_ciclos : STD_LOGIC_VECTOR(15 downto 0):=x"0000";
signal iid_c : STD_LOGIC_VECTOR(15 downto 0);
signal contador_milisegundos : STD_LOGIC_VECTOR(15 downto 0):=x"0000";
signal hihainterrupt: STD_LOGIC;

BEGIN 
	
--		registre 7 BUTONS
--		registre 8 SWITCHES
--		registre 9 CONTROLADOR 7segs ENCES
--		registre 10 VALOR 7segs
--		registre 15 CHAR LLEGIT DEL TECLAT
--		registre 16 CHAR TECLAT READY // CHAR TECLAT CLEAR
--		registre 20 cicles
--		registre 21 milis

process(clk)
begin
if rising_edge(clk) then
	if contador_ciclos=0 then
		contador_ciclos<=x"C350"; -- tiempo de ciclo=20ns(50Mhz) 1ms=50000ciclos
		if contador_milisegundos>0 then
				contador_milisegundos <= contador_milisegundos-1;
		end if;
	else
		contador_ciclos <= contador_ciclos-1;
	end if;
end if;
end process; 

process(clk)
		begin
		if boot = '1' then
			registres(16) <= "0000000000000000";
			registres(6) <= "1111111111111111";
		elsif rising_edge(clk) then
			clear_char_c <= '0';
			if wr_out = '1' then 
				if addr_io = "00010000" or ps2_inta_c = '1' then
					clear_char_c <= '1';
					--posar inta
				else registres(conv_integer(addr_io)) <= wr_io;
				end if;
			end if;
			registres(7) <= botones;
			registres(8) <= interruptores;
			--registres(10) <=  registres(15);
			registres(15)(15 downto 8) <= (others => read_char_C(7));
			registres(15)(7 downto 0) <= read_char_C;
			registres(16) <= (others => data_ready_C);
			--registres(20) <= contador_ciclos;
			--registres(21) <= contador_milisegundos;
			
			--timer per snake
			if rising_edge(clk) then
			if registres(20)=0 then
				registres(20)<=x"C350"; -- tiempo de ciclo=20ns(50Mhz) 1ms=50000ciclos
				if registres(21)>0 then
					registres(21) <= registres(21)-1;
			end if;
else
registres(20) <= registres(20)-1;
end if;
end if;
end if;
end process;
	

		rd_io <= iid_c when inta = '1' else registres(conv_integer(addr_io));
		sevenSeg(3 DOWNTO 0) <= registres(10)(3 DOWNTO 0) when registres(9)(0) = '1' else "1111";
		sevenSeg(7 DOWNTO 4) <= registres(10)(7 DOWNTO 4) when registres(9)(1) = '1' else "1111";
		sevenSeg(11 DOWNTO 8) <= registres(10)(11 DOWNTO 8) when registres(9)(2) = '1' else "1111";
		sevenSeg(15 DOWNTO 12) <= registres(10)(15 DOWNTO 12) when registres(9)(3) = '1' else "1111";


led_verdes <= registres(5)(7 DOWNTO 0);
led_rojos <= registres(6)(7 DOWNTO 0);
botones(3 DOWNTO 0) <= KEY;
botones(15 DOWNTO 4) <= (others => KEY(3));
interruptores(7 DOWNTO 0) <= SW;
interruptores(15 DOWNTO 8) <= (others => SW(7));

Keyboard : KEYboard_controller PORT MAP (clk => clk, reset => boot,
          ps2_clk => PS2_CLK,
          ps2_data => PS2_DATA,
          read_char => read_char_C,
          data_ready => data_ready_C,
		  clear_char => clear_char_c); --16	

controllerInterrupts: interrupt_controller PORT MAP (boot => boot, clk => clk, inta => inta,key_intr => key_intr,ps2_intr => data_ready_C, 
							switch_intr => switch_intr,timer_intr => timer_intr, intr => intr_c, key_inta => key_inta, ps2_inta => ps2_inta_c,
							switch_inta => switch_inta, timer_inta => timer_inta, iid => iid_c, interruptEnabled => interruptEnabled,
							interruptNow => interruptNow);

controllerKey: Keys_controller 	PORT MAP(boot => boot, clk => clk,	inta => key_inta,
				keys => KEY, intr => key_intr, read_key => readed_key);
				
controllerSwitch: switches_controller 	PORT MAP(boot => boot, clk => clk,	inta => switch_inta,
				switches => SW, intr => switch_intr, read_switches => readed_switches);
		
controllerTimer: timer 	PORT MAP(boot => boot, clk => clk,	inta => timer_inta,
				intr => timer_intr, interruptNow => interruptNow);

intr <= intr_c;
END Structure;