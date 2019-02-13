LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.numeric_std.all;
USE ieee.std_logic_unsigned.all;

ENTITY unidad_control IS
    PORT (boot      : IN  STD_LOGIC;
          clk       : IN  STD_LOGIC;
          datard_m  : IN  STD_LOGIC_VECTOR(15 DOWNTO 0);
          op        : OUT STD_LOGIC_VECTOR(5 DOWNTO 0);
          wrd       : OUT STD_LOGIC;
          addr_a    : OUT STD_LOGIC_VECTOR(2 DOWNTO 0);
          addr_b    : OUT STD_LOGIC_VECTOR(2 DOWNTO 0);
          addr_d    : OUT STD_LOGIC_VECTOR(2 DOWNTO 0);
          immed     : OUT STD_LOGIC_VECTOR(15 DOWNTO 0);
          pc        : OUT STD_LOGIC_VECTOR(15 DOWNTO 0);
          ins_dad   : OUT STD_LOGIC;
          in_d      : OUT STD_LOGIC_VECTOR(1 DOWNTO 0);
          immed_x2  : OUT STD_LOGIC;
          wr_m      : OUT STD_LOGIC;
          word_byte : OUT STD_LOGIC;
			 reg_b :OUT STD_LOGIC;
			 z: IN STD_LOGIC;
			 valor_reg_a:IN STD_LOGIC_VECTOR(15 DOWNTO 0);
			 addr_io		: OUT std_logic_vector(7 downto 0);
			 wr_out		: OUT  std_logic; 
			 rd_in		: OUT  std_logic; --señal de control de a quin PC saltarem
			 
			 A_sys :OUT std_LOGIC;
			 sys_wrd:OUT std_LOGIC;
			 PCup: OUT STD_LOGIC_VECTOR(15 downto 0);
			 --interruptNow : OUT	 STD_LOGIC;
			 Enable_DisableInterrpt: OUT std_LOGIC;
			 PCrutinaInterrupt: IN STD_LOGIC_VECTOR (15 downto 0);
			 pcup_after_reti : IN STD_LOGIC_VECTOR(15 downto 0);
			 reti :OUT std_LOGIC;
			 inta :OUT std_LOGIC;
			 intr :IN std_LOGIC;
			 interruptNow :OUT std_LOGIC;
			 --div_zero :IN STD_LOGIC;
			 --aligned_error: IN STD_LOGIC;
			 --exceptionNotAligned :OUT STD_LOGIC;
			 --exception_div_zero: OUT STD_LOGIC;
			 --excpetion_ilegal_instr:OUT STD_LOGIC;
			 ExecutantseInterrupt : OUT STD_LOGIC;
			 interruptEnabled: IN STD_LOGIC);
END unidad_control;


ARCHITECTURE Structure OF unidad_control IS

    -- Aqui iria la declaracion de las entidades que vamos a usar
    -- Usaremos la palabra reservada COMPONENT ...
    -- Tambien crearemos los cables/buses (signals) necesarios para unir las entidades
    -- Aqui iria la definicion del program counter
	 
COMPONENT control_l IS
   PORT (ir     : IN  STD_LOGIC_VECTOR(15 DOWNTO 0);
			boot      : IN  STD_LOGIC;
          clk       : IN  STD_LOGIC;
          op     : OUT STD_LOGIC_VECTOR(5 DOWNTO 0);
          ldpc   : OUT STD_LOGIC;
          wrd    : OUT STD_LOGIC;
          addr_a : OUT STD_LOGIC_VECTOR(2 DOWNTO 0);
			 addr_b : OUT STD_LOGIC_VECTOR(2 DOWNTO 0);
          addr_d : OUT STD_LOGIC_VECTOR(2 DOWNTO 0);
          immed  : OUT STD_LOGIC_VECTOR(15 DOWNTO 0);
			 wr_m	  : OUT STD_LOGIC;
			 in_d	  : OUT STD_LOGIC_VECTOR(1 DOWNTO 0);
			 immed_x2:OUT STD_LOGIC;
			 word_byte:OUT STD_LOGIC;
			 reg_b :OUT STD_LOGIC;
			 control_pc : OUT STD_LOGIC_VECTOR(1 DOWNTO 0);
			 z: IN STD_LOGIC;
			  addr_io		: OUT std_logic_vector(7 downto 0);
			 wr_out		: OUT  std_logic; 
			 rd_in		: OUT  std_logic;
			 Enable_DisableInterrpt: OUT std_LOGIC;
			 interruptEnabled : IN STD_LOGIC;
			 interruptToDo : OUT	 STD_LOGIC;
			 A_sys :OUT std_LOGIC;
			 reti :OUT std_LOGIC;
			 --ilegal_instr: OUT STD_LOGIC;
			 --instructionMemWord :OUT STD_LOGIC;
			 getiid: OUT STD_LOGIC;
			 sys_wrd:OUT std_LOGIC);
	END COMPONENT;
	
	COMPONENT multi IS
    port(clk       : IN  STD_LOGIC;
         boot      : IN  STD_LOGIC;
         ldpc_l    : IN  STD_LOGIC;
         wrd_l     : IN  STD_LOGIC;
         wr_m_l    : IN  STD_LOGIC;
         w_b       : IN  STD_LOGIC;
         ldpc      : OUT STD_LOGIC;
         wrd       : OUT STD_LOGIC;
         wr_m      : OUT STD_LOGIC;
         ldir      : OUT STD_LOGIC;
         ins_dad   : OUT STD_LOGIC;
         word_byte : OUT STD_LOGIC;
			intr 		 :IN std_LOGIC;
			--div_zero :IN STD_LOGIC;
			--aligned_error: IN STD_LOGIC;
			interruptToDo : IN	 STD_LOGIC;
			--instructionMemWord :IN STD_LOGIC;
			--ilegal_instr: IN STD_LOGIC;
			--exceptionNotAligned :OUT STD_LOGIC;
			--exception_div_zero: OUT STD_LOGIC;
			--excpetion_ilegal_instr:OUT STD_LOGIC;
			reti : IN STD_LOGIC;
			EnabledInterrupt: IN STD_LOGIC;
			execInterrupt : OUT STD_LOGIC);
END COMPONENT;

signal ldpc_intern2, ldpc_intern, word_byte_intern, wr_m_intern, wrd_intern, 
			ldir_intern, reti_c, interruptNow_c, instructionMem_c, ilegal_instr_c,enabledInterrupt_c: STD_LOGIC;
signal ir_reg, ir, seguent_pc,immed_c, immed_c_shifted, pc_mod, seguent_pc_c: STD_LOGIC_VECTOR(15 downto 0);

	Signal pc_intern, pc_c: STD_LOGIC_VECTOR(15 downto 0);
	signal salt_relatiu_c : STD_LOGIC_VECTOR(7 downto 0);
	signal control_pc_c : STD_LOGIC_VECTOR(1 DOWNTO 0);
	signal acabat,intr_doit: std_LOGIC;
	signal interruptToDo_c, executantseInterrupt_c: STD_LOGIC;
	
BEGIN

    -- Aqui iria la declaracion del "mapeo" (PORT MAP) de los nombres de las entradas/salidas de los componentes
    -- En los esquemas de la documentacion a la instancia de la logica de control le hemos llamado c0
    -- Aqui iria la definicion del comportamiento de la unidad de control y la gestion del PC
	process(clk,boot)
	
	variable trobat : Integer := 0;
	variable systemcicle : Integer;
		begin
		if boot = '1' then
		acabat <= '1';
		intr_doit <= '0';
		systemcicle := 0;
		executantseInterrupt_c <= '0';
			pc_intern <= "1100000000000000" ; --PC = 0xC000 - 2 C = "1100000000000000" C-2 = "1011111111111110"
		elsif rising_edge(clk) then
			if systemcicle = 1 then	pc_intern <= PCrutinaInterrupt; systemcicle := 0; executantseInterrupt_c<='1'; 
			elsif ldpc_intern2 = '1' and trobat = 0 then
				--pc_intern <= pc_intern + 2;
				pc_intern <= pc_intern;
			elsif ldpc_intern2 = '0' and trobat = 0 and reti_c = '1' then pc_intern <= pcup_after_reti; executantseInterrupt_c <= '0'; intr_doit <= '0';
			elsif ldpc_intern2 = '0' and trobat = 0 and (intr = '0' or (intr = '1' and intr_doit = '1' )) then pc_intern <= pc_mod;
			elsif ldpc_intern2 = '0' and trobat = 0 and intr = '1' and intr_doit = '0' then systemcicle := 1; 
			intr_doit <= '1';
			--pc_intern <= pc_mod;
			--elsif executantseInterrupt_c = '1' then pc_inter
			end if;
			if ldpc_intern = '0' then trobat := 1; acabat <= '1'; --halt
			end if;
		end if;
	end process;
	--pc <= pc_intern;
	pc <= pcup_after_reti when reti_c = '1' else pc_c;
	with acabat select pc_c <=
		pc_mod when '0',
		pc_intern when others;
	--pc <= pc_mod;
	seguent_pc <=
		PCrutinaInterrupt when interruptEnabled = '1' and interruptToDo_c = '1' and executantseInterrupt_c = '0'
		else pc_c ;

	with control_pc_c select pc_mod <=
		pc_intern +2 when "00",
		immed_c_shifted + pc_intern + 2	when "01",
		valor_reg_a when "10", --adreça absoluta de jmp o de jal provinent de BR
		pc_intern when others;
	Pcup <= pc_mod;	
	executantseInterrupt <= executantseInterrupt_c;
	--with control_pc_c select pc <=
		--pc_intern +2 when "00",
		--immed_c_shifted + pc_intern + 2	when "01",
		--valor_reg_a when "10", --adreÃ§a absoluta de jmp o de jal provinent de BR
		--pc_intern when others;
	interruptNow <= interruptNow_c;
		
	process(clk)
		begin
		if rising_edge(clk) then
			if ldir_intern='1' then
				ir<= datard_m;
			end if;	
		end if;
	end process;	
	immed_c_shifted(15 DOWNTO 1) <= immed_c(14 downto 0);
	immed_c_shifted(0 DOWNTO 0) <= "0";
--	process(clk)
--		begin
--		if rising_edge(clk) then
--			ir_reg<= ir;
--		end if;
--	end process;
--	
--	with ldir_intern select ir(15 downto 0)<=
--		datard_m(15 downto 0) when '1',
--		ir_reg(15 downto 0) when others;
--		
--
--	with boot select ir(15 downto 0)<=
--		ir(15 downto 0) when '1',
--		"0000000000000000" when others;
	immed <= immed_c;
	control1:
		control_l PORT MAP 
		(clk => clk, boot => boot, ir=>ir,					op=>op,					ldpc=>ldpc_intern,
		wrd=>wrd_intern,				addr_a=>addr_a,		addr_b=>addr_b,	addr_d=>addr_d,
		immed=>immed_c, 					wr_m=>wr_m_intern,	in_d=> in_d,
		immed_x2=>immed_x2, 			word_byte=> word_byte_intern, reg_b => reg_b,  
		control_pc => control_pc_c, z=> z, addr_io => addr_io, wr_out => wr_out, rd_in => rd_in,
		A_sys => A_sys, sys_wrd => sys_wrd, interruptEnabled => interruptEnabled,
		interruptToDo => interruptToDo_c, Enable_DisableInterrpt => enabledInterrupt_c, reti => reti_c,
		getiid => inta, instructionMemWord => instructionMem_c,ilegal_instr => ilegal_instr_c);
	Enable_DisableInterrpt <= enabledInterrupt_c;
	multi1: 
		multi PORT MAP
		(clk=>clk, 						boot=> boot, 			ldpc_l=>ldpc_intern,
		wrd_l=>wrd_intern,			wr_m_l=>wr_m_intern,	w_b=>word_byte_intern,
		ldpc=>ldpc_intern2,			wrd=>wrd,				wr_m=>wr_m,
		ldir=>ldir_intern ,			ins_dad=>ins_dad,			word_byte=>word_byte,
		interruptToDo => interruptToDo_c, execInterrupt => interruptNow_c, intr => intr, div_zero => div_zero,
		aligned_error => aligned_error, instructionMemWord => instructionMem_c, ilegal_instr => ilegal_instr_c,
		reti => reti_c, exception_div_zero => exception_div_zero,enabledInterrupt=> enabledInterrupt_c);
	
END Structure;