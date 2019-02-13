LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.numeric_std.all;        --Esta libreria sera necesaria si usais conversiones TO_INTEGER
USE ieee.std_logic_unsigned.all; --Esta libreria sera necesaria si usais conversiones CONV_INTEGER

ENTITY sysreg IS
    PORT (clk    : IN  STD_LOGIC;
			 boot : IN STD_LOGIC;
          wrd    : IN  STD_LOGIC;
          d      : IN  STD_LOGIC_VECTOR(15 DOWNTO 0);
          addr_a : IN  STD_LOGIC_VECTOR(2 DOWNTO 0);
          addr_d : IN  STD_LOGIC_VECTOR(2 DOWNTO 0);
          a      : OUT STD_LOGIC_VECTOR(15 DOWNTO 0);
			 interruptNow : IN	 STD_LOGIC;
			 exception_div_zero: IN STD_LOGIC;
			 excpetion_ilegal_instr:IN STD_LOGIC;
			 exception_NotAligned : IN STD_LOGIC;
			 pcup: IN	STD_LOGIC_VECTOR(15 DOWNTO 0);
			 pcup_after_reti : OUT STD_LOGIC_VECTOR(15 downto 0);
			 reti :IN std_LOGIC;
			 PCrutinaInterrupt : OUT std_LOGIC_VECTOR(15 DOWNTO 0);
			 Enable_DisableInterrpt: IN std_LOGIC;
			 addr_m : IN STD_LOGIC_VECTOR(15 DOWNTO 0);
			 ExecutantseInterrupt : IN STD_LOGIC;
			 interruptBitEnabled: OUT STd_LOGIC);
END sysreg;


ARCHITECTURE Structure OF sysreg IS
	type arraysys is array (7 downto 0) of std_logic_vector(15 downto 0);
	signal sys_registres : arraysys;
	signal retidoit :STD_LOGIC;
BEGIN

	
	process(clk)
		
		begin
		if boot = '1' then
			sys_registres(7) <= "0000000000000000";
			sys_registres(5) <= "1111000000000000";
			sys_registres(6) <= "0000000000000000";
			sys_registres(3) <= "0000000000000000";
			sys_registres(2) <= "0000000000000000";
			retidoit <= '1';
		elsif rising_edge(clk) and reti = '1' then
			sys_registres(7) <= sys_registres(0);
			sys_registres(2) <= "0000000000000000";
			
		elsif rising_edge(clk) and wrd = '1' then 
				sys_registres(conv_integer(addr_d)) <= d;
		elsif rising_edge(clk) and interruptNow = '1' then
				sys_registres(0) <= sys_registres(7);
				sys_registres(1) <= pcup;
				sys_registres(2) <= "0000000000001111";
				sys_registres(7)(1) <= '0';
				--sys_registres(7) <= "0000000000000000";
		
		elsif rising_edge(clk) and ExecutantseInterrupt = '0' then
				sys_registres(7)(1) <= enable_DisableInterrpt;
		elsif rising_edge(clk) and ExecutantseInterrupt = '1' then 
				sys_registres(7)(1) <= '0';
		end if;
		--Exceptions
		if rising_edge(clk) then
			if exception_NotAligned = '1' then 
				sys_registres(3) <= addr_m;
				sys_registres(2) <= "0000000000000001";
			elsif exception_div_zero = '1' then 
				sys_registres(2) <= "0000000000000100";
			elsif excpetion_ilegal_instr = '1' then
				sys_registres(2) <= "0000000000000000";
			end if;
		end if;
	end process;
		pcup_after_reti <= sys_registres(1);
		a <= sys_registres(conv_integer(addr_a));
		interruptBitEnabled <= sys_registres(7)(1);
		PCrutinaInterrupt <= sys_registres(5);
	-- Aqui iria la definicion del comportamiento del banco de registros
    -- Os puede ser util usar la funcion "conv_integer" o "to_integer"
    -- Una buena (y limpia) implementacion no deberia ocupar m�s de 7 o 8 lineas
	
		
END Structure;