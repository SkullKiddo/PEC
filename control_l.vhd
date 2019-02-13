LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.numeric_std.all;

ENTITY control_l IS
    PORT (ir     : IN  STD_LOGIC_VECTOR(15 DOWNTO 0);
			 clk	  : IN std_LOGIC;
			 boot	  : IN std_LOGIC;
          op     : OUT STD_LOGIC_VECTOR(5 DOWNTO 0); --Indica la operación que va a realizar la ALU. 
          ldpc   : OUT STD_LOGIC; --Esta señal a 1 indica que se puede incrementar el program counter (PC). Se mantendrá a 1 hasta quese ejecute una instrucción del tipo HALT, momento en el que permanecerá a 0 para detener elprocesador. 
          wrd    : OUT STD_LOGIC; --Permiso de escritura en el Banco de registros. 
          addr_a : OUT STD_LOGIC_VECTOR(2 DOWNTO 0); --Dirección del registro fuente del puerto A. 
			 addr_b : OUT STD_LOGIC_VECTOR(2 DOWNTO 0); --Dirección del registro fuente del puerto B.
          addr_d : OUT STD_LOGIC_VECTOR(2 DOWNTO 0); -- Dirección del registro destino
          immed  : OUT STD_LOGIC_VECTOR(15 DOWNTO 0); -- Valor inmediato con extensión de signo extraído de la instrucción
			 wr_m	  : OUT STD_LOGIC; -- Permiso de escritura en la memoria si es una instrucción ST o STB
			 in_d	  : OUT STD_LOGIC_VECTOR(1 DOWNTO 0); -- Esta señal a 1 indica que en el Banco de registros almacenaremos el valor procedente de la memoria y si vale 0 almacenaremos el valor procedente de la ALU.
			 immed_x2:OUT STD_LOGIC; --La señal que determina si hay que desplazar el inmediato o no. Debe valer 1 si se ejecuta una instrucción de acceso a word como son las instrucciones LD y ST.
			 word_byte:OUT STD_LOGIC;--La señal indica si el acceso a memoria es a nivel de byte o word. Sólo debe valer 1 cuando se esta ejecutando una instrucción LDB o STB
			 reg_b :OUT STD_LOGIC;
			 control_pc : OUT STD_LOGIC_VECTOR(1 DOWNTO 0);
			 z: IN STD_LOGIC;
			 addr_io		: OUT std_logic_vector(7 downto 0);
			 wr_out		: OUT  std_logic; 
			 rd_in		: OUT  std_logic;
			 InterruptEnabled : IN std_logic;
			 Enable_DisableInterrpt: OUT std_LOGIC;
			 InterruptToDo : OUT std_logic;
			 A_sys :OUT std_LOGIC;
			 ilegal_instr: OUT STD_LOGIC;
			 reti :OUT std_LOGIC;
			 getiid: OUT STD_LOGIC;
			 instructionMemWord :OUT STD_LOGIC;
			 sys_wrd:OUT std_LOGIC);
END control_l;


ARCHITECTURE Structure OF control_l IS

CONSTANT ARITMET : STD_LOGIC_VECTOR (3 DOWNTO 0) := "0000";
CONSTANT MOV : STD_LOGIC_VECTOR (3 DOWNTO 0) := "0101";
CONSTANT LD : STD_LOGIC_VECTOR (3 DOWNTO 0) := "0011";
CONSTANT ST : STD_LOGIC_VECTOR (3 DOWNTO 0) := "0100";
CONSTANT LDB : STD_LOGIC_VECTOR (3 DOWNTO 0) := "1101";
CONSTANT STB : STD_LOGIC_VECTOR (3 DOWNTO 0) := "1110";
CONSTANT SALTCOND : STD_LOGIC_VECTOR (3 DOWNTO 0) := "0110";
CONSTANT IO : STD_LOGIC_VECTOR (3 DOWNTO 0) := "0111";
CONSTANT COMP : STD_LOGIC_VECTOR (3 DOWNTO 0) := "0001";
CONSTANT MUL : STD_LOGIC_VECTOR (3 DOWNTO 0) := "1000";
CONSTANT JMPS : STD_LOGIC_VECTOR (3 DOWNTO 0) := "1010";

SIGNAL addra, addrb, addrd : std_LOGIC_VECTOR(2 DOWNTO 0);

BEGIN

--    	 with ir select op <= 
--		"00" when "0101---1--------", --MOVHI
--		"01" when "0101---0--------", --MOVI
--		"10" when others; --LD, ST, LDB, STB
--		
		
		op <=
			"000000" when ir (15 downto 12) = "0101" and ir(8) = '0' else
			"000001" when ir (15 downto 12) = "0101" and ir(8) = '1' else
			"000011" when ir (15 downto 12) = ARITMET and ir (5 downto 3) = "000" else --and
			"000100" when ir (15 downto 12) = ARITMET and ir (5 downto 3) = "001" else --or
			"000101" when ir (15 downto 12) = ARITMET and ir (5 downto 3) = "010" else --xor
			"000110" when ir (15 downto 12) = ARITMET and ir (5 downto 3) = "011" else --not
			"000111" when ir (15 downto 12) = ARITMET and ir (5 downto 3) = "100" else --add
			"001000" when ir (15 downto 12) = ARITMET and ir (5 downto 3) = "101" else --sub
			"001001" when ir (15 downto 12) = ARITMET and ir (5 downto 3) = "110" else --sha
			"001010" when ir (15 downto 12) = ARITMET and ir (5 downto 3) = "111" else --shl
			"001011" when ir (15 downto 12) = COMP and ir (5 downto 3) = "000" else --cmplt
			"001100" when ir (15 downto 12) = COMP and ir (5 downto 3) = "001" else --cmple
			"001101" when ir (15 downto 12) = COMP and ir (5 downto 3) = "011" else --cmpeq
			"001110" when ir (15 downto 12) = COMP and ir (5 downto 3) = "100" else --cmpltu
			"001111" when ir (15 downto 12) = COMP and ir (5 downto 3) = "101" else --cmpleu
			"010000" when ir (15 downto 12) = "0010" else --addi
			"010001" when ir (15 downto 12) = MUL and ir (5 downto 3) = "000" else --mul
			"010010" when ir (15 downto 12) = MUL and ir (5 downto 3) = "001" else --mulh
			"010011" when ir (15 downto 12) = MUL and ir (5 downto 3) = "010" else --mulhu
			"010100" when ir (15 downto 12) = MUL and ir (5 downto 3) = "100" else --div
			"010101" when ir (15 downto 12) = MUL and ir (5 downto 3) = "101" else --divu
			"010110" when ir (15 downto 12) = LD else --ld
			"010111" when ir (15 downto 12) = ST else --st
			"011000" when ir (15 downto 12) = LDB else --ldb
			"011001" when ir (15 downto 12) = STB else --stdb
			"011010" when ir (15 downto 12) = SALTCOND and ir(8 downto 8) = "0" else --BZ
			"011010" when ir (15 downto 12) = SALTCOND and ir(8 downto 8) = "1" else --BNZ
			"011011" when ir (15 downto 12) = JMPS and ir(2 downto 0) = "000" else --JZ
			"011100" when ir (15 downto 12) = JMPS and ir(2 downto 0) = "001" else --JNZ
			"011101" when ir (15 downto 12) = JMPS and ir(2 downto 0) = "011" else --JMP
			"011110" when ir (15 downto 12) = JMPS and ir(2 downto 0) = "000" else --JAL
			"100000" when ir (15 DOWNTO 12) = "1111" and ir (5 DOWNTO 0) = "101100" else --RDS
			"100001" when ir (15 DOWNTO 12) = "1111" and ir (5 DOWNTO 0) = "110000" else --WRS
			--"100010" when ir (15 DOWNTO 12) = "1111" and ir (5 DOWNTO 0) = "100000" else --EI -> S7(1) <= '1'
			--"100011" when ir (15 DOWNTO 12) = "1111" and ir (5 DOWNTO 0) = "100001" else --DI -> S7(1) <= '0'
			"100100" when ir (15 DOWNTO 12) = "1111" and ir (5 DOWNTO 0) = "100100"  --RETI
			else "011111"; --HALT
		
		 with ir select ldpc <= 
		'0' when "1111111111111111", --HALT
		'1' when others;
		
		with ir(15 DOWNTO 12) select addra <=
		ir(11 DOWNTO 9) when MOV, --MOVI MOVHI
		ir(8 DOWNTO 6) when others; --LD ST LDB STB IO
		
		with ir(15 DOWNTO 12) select addrb <=
		ir(2 DOWNTO 0) when ARITMET, --ariTMET
		ir(2 DOWNTO 0) when COMP, --compare
		ir(2 DOWNTO 0) when MUL, --mult
		ir(11 DOWNTO 9) when others; --MOVI MOVHI LD ST LDB STB
		
	
		addrd <=
		"111" when ir(15 downto 12) = "1111" and (ir (5 downto 0) = "100000" or ir (5 downto 0) = "100001") else
		ir(11 DOWNTO 9); --MOVI MOVHI LD ST LDB STB IO
		
--		with ir select wrd <= 	--permis escritura br
--		'0' when "1111111111111111",
--		'0' when "0100------------",
--		'0' when "1110------------",
--		'1' when others;

		wrd <=
			'1' when 	ir(15 DOWNTO 12) = ARITMET or
							ir(15 DOWNTO 12) = LD or
							ir(15 DOWNTO 12) = LDB or
							ir(15 DOWNTO 12) = MOV or
							ir(15 DOWNTO 12) = COMP or
							ir(15 DOWNTO 12) = MUL or
							ir(15 DOWNTO 12) = "0010" or
							(ir(15 DOWNTO 12) = IO and ir(8 downto 8) = "0") or
							(ir(15 DOWNTO 12) = JMPS and ir(2 DOWNTO 0) = "100")
							or (ir(15 downto 12) = "1111" and (ir(5 downto 0)= "101100" or ir(8 downto 0) = "000101000"))
			else '0';	
		
		with ir(15 DOWNTO 12) select immed_x2<=
			'1' when LD,
			'1' when ST,
			'1' when SALTCOND,
			'0' when others;
		with ir(15 DOWNTO 12) select word_byte<=
			'1' when LDB,
			'1' when STB,
			'0' when others;
		
		with ir(15 DOWNTO 12) select wr_m <=
			'1' when ST,
			'1' when STB,
			'0' when others;
			
		
		in_d <=
			"01" when ir(15 DOWNTO 12)=LD else
			"01" when ir(15 DOWNTO 12)=LDB else
			"10" when ir(15 DOWNTO 12)=JMPS and ir(2 DOWNTO 0) = "100" else
			"00" ;
		
		with ir(15 DOWNTO 12) SELECT immed <=
		std_logic_vector(resize(signed(ir(7 DOWNTO 0)), immed'length)) when MOV,
		std_logic_vector(resize(signed(ir(7 DOWNTO 0)), immed'length)) when SALTCOND,
		std_logic_vector(resize(signed(ir(7 DOWNTO 0)), immed'length)) when IO,
		std_logic_vector(resize(signed(ir(5 DOWNTO 0)), immed'length)) when others;
		
		with ir(15 DOWNTO 12) select reg_b <=
			'1' when ARITMET,
			'1' when MUL,
			'1' when COMP,
			'1' when SALTCOND,
			'1' when JMPS,
			'0' when others;
			
	--control_pc : OUT STD_LOGIC_VECTOR(1 DOWNTO 0);
		--	 salt_relatiu: OUT STD_LOGIC_VECTOR(7 DOWNTO 0);
			-- z: IN STD_LOGIC););
		
		 	
		control_pc <= --SALTS
		"01" when ir(15 DOWNTO 12) = SALTCOND and ((ir(8 DOWNTO 8) = "0" and z = '1') or (ir(8 DOWNTO 8) = "1" and z = '0')) else
		"10" when ir(15 DOWNTO 12) = 	JMPS and ((ir(2 DOWNTO 0) = "011") or (ir(2 DOWNTO 0) = "000" and z = '1') or 
															(ir(2 DOWNTO 0) = "001" and z = '0') or ir(2 DOWNTO 0) = "100")else
		"11" when ir(15 DOWNTO 0) = "1111111111111111" else
		"00";
		
		addr_io <= ir(7 DOWNTO 0);
		wr_out <= '1' when ir(15 downto 12) = IO and ir(8 downto 8) = "1" else '0';
		rd_in <= '1' when (ir(15 downto 12) = IO and ir(8 downto 8) = "0") or (ir(15 downto 12)= "1111" 
								and ir(8 downto 0) = "000101000") else '0';
		addr_a <= addra;
		addr_b <= addrb;
		addr_d <= addrd;
		
		process (clk)
			begin
			if boot = '1' then Enable_DisableInterrpt <= '0';
			elsif rising_edge(clk) then
				if ir(15 downto 12) = "1111" and ir(5 downto 0) = "100000" then 
					ENable_DisableInterrpt <= '1';
				elsif ir(15 downto 12) = "1111" and ir (5 downto 0) = "100001" then
					Enable_DisableInterrpt <= '0';
				end if;
			end if;
		end process;
				--interrupts
		A_sys <= --llegir de reg de systema
			'1' when ir (15 DOWNTO 12) = "1111" and ir (5 downto 0) = "101100"
			else '0';
			
		sys_wrd <= --escriure a reg de systema
			'1' when ir (15 DOWNTO 12) = "1111" and ir (5 downto 0) = "110000"
			else '0';
			
		interruptToDo <= 
			'1' when interruptEnabled = '1' and ir (15 downto 12) = "1111" and ir (5 DOWNTO 0) = "101000"
			else '0';
		reti <= 
			'1' when ir(15 downto 0) = "1111000000100100" else '0';
		getiid <= '1' when ir(15 downto 12) = "1111" and  ir( 8 downto 0) = "000101000" else '0';
		--inta <= 
		--excep0 <= --ilegal instruction
		---excep1 <= --address impar
		
		instructionMemWord <= '1' when ir(15 DOWNTO 12)=LD or ir(15 DOWNTO 12)=ST else '0';
		--excep4 <= --division por cero 
		--excep15<= --interrupts
		ilegal_instr <= '1' when (ir(15 downto 12) = COMP and 
										(ir(5 downto 3) = "011" or ir(5 downto 3) = "110" or ir(5 downto 3) = "111")) or
										(ir(15 downto 12) = MUL and 
										(ir(5 downto 3) = "011" or ir(5 downto 3) = "110" or ir(5 downto 3) = "111")) else '0';
END Structure;