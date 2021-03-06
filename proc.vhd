LIBRARY ieee;
USE ieee.std_logic_1164.all;

ENTITY proc IS
    PORT (clk			: IN  STD_LOGIC;
          boot			: IN  STD_LOGIC;
          datard_m	: IN  STD_LOGIC_VECTOR(15 DOWNTO 0);
          addr_m		: OUT STD_LOGIC_VECTOR(15 DOWNTO 0);
          data_wr		: OUT STD_LOGIC_VECTOR(15 DOWNTO 0);
          wr_m			: OUT STD_LOGIC;
          word_byte	: OUT STD_LOGIC;
			 addr_io		: OUT std_logic_vector(7 downto 0);
			 rd_io		: IN std_logic_vector(15 downto 0); 
			 wr_out		: OUT  std_logic; 
			 rd_in		: OUT  std_logic;
			 inta :OUT std_LOGIC;
			 interruptEnabled:OUT std_LOGIC;
			 intr :IN Std_LOGIC;
			 interruptNow: OUT STD_LOGIC;
			 aligned_error: IN STD_LOGIC);
			 
			 
END proc;

ARCHITECTURE Structure OF proc IS

COMPONENT datapath IS
    PORT (clk    : IN STD_LOGIC;
			boot : IN STd_LOGIC;
          op     : IN STD_LOGIC_VECTOR(5 DOWNTO 0);
          wrd    : IN STD_LOGIC;
          addr_a : IN STD_LOGIC_VECTOR(2 DOWNTO 0);
          addr_b : IN STD_LOGIC_VECTOR(2 DOWNTO 0);
          addr_d : IN STD_LOGIC_VECTOR(2 DOWNTO 0);
          immed  : IN STD_LOGIC_VECTOR(15 DOWNTO 0);
			 immed_x2:IN STD_LOGIC;
			 datard_m:IN STD_LOGIC_VECTOR(15 DOWNTO 0);
			 ins_dad: IN STD_LOGIC;
			 pc     : IN STD_LOGIC_VECTOR(15 DOWNTO 0);
			 in_d   : IN STD_LOGIC_VECTOR(1 DOWNTO 0);
			 addr_m : OUT STD_LOGIC_VECTOR(15 DOWNTO 0);
			 data_wr: OUT STD_LOGIC_VECTOR(15 DOWNTO 0);
			 reg_b :IN STD_LOGIC;
			 z: OUT STD_LOGIC;
			  rd_in		: IN  std_logic;
			 valor_reg_a:OUT STD_LOGIC_VECTOR(15 DOWNTO 0);
			 rd_io		: IN std_logic_vector(15 downto 0);
			 A_sys :IN std_LOGIC;
			 sys_wrd:IN std_LOGIC;
			 interruptEnabled:OUT std_LOGIC;
			 interruptNow : IN	 STD_LOGIC;
			 PCrutinaInterrupt : OUT STD_LOGIC_VECTOR(15 DOWNTO 0);
			 Enable_DisableInterrpt: IN std_LOGIC;
			 pcup_after_reti : OUT STD_LOGIC_VECTOR(15 downto 0);
			 reti :IN std_LOGIC;
			 div_zero :OUT STD_LOGIC;
			 ExecutantseInterrupt : IN STD_LOGIC;
			 exception_div_zero: IN STD_LOGIC;
			 excpetion_ilegal_instr:IN STD_LOGIC;
			 exception_NotAligned : IN STD_LOGIC;
			 pcup		: IN std_logic_vector(15 downto 0));
			 
			 
END COMPONENT;

COMPONENT unidad_control IS
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
			 rd_in		: OUT  std_logic;
			 A_sys :OUT std_LOGIC;
			 sys_wrd:OUT std_LOGIC;
			 PCup: OUT STD_LOGIC_VECTOR(15 downto 0);
			 PCrutinaInterrupt: IN STD_LOGIC_VECTOR(15 downto 0);
			 --interruptNow : OUT	 STD_LOGIC;
			 Enable_DisableInterrpt: OUT std_LOGIC;
			 pcup_after_reti : IN STD_LOGIC_VECTOR(15 downto 0);
			 reti :OUT std_LOGIC;
			 inta :OUT std_LOGIC;
			 intr :IN std_LOGIC;
			 interruptNow: OUT std_LOGIC;
			 div_zero :IN STD_LOGIC;
			 aligned_error: IN STD_LOGIC;
			 ExecutantseInterrupt : OUT STD_LOGIC;
			 exceptionNotAligned :OUT STD_LOGIC;
			 exception_div_zero: OUT STD_LOGIC;
			 excpetion_ilegal_instr:OUT STD_LOGIC;
			 interruptEnabled: IN STD_LOGIC);
END COMPONENT;

signal wrd_c, immed_x2_c, ins_dad_c, executantseInterrupt_c, div_zero_c, exceptionNotAligned_c,
		exception_div_zero_c, excpetion_ilegal_instr_c : STD_LOGIC;
signal immed_c,pc_c,valor_reg_a_c, pcup_c, addr_m_c, PCrutinaInterrupt_c , pcup_after_reti_c : STD_LOGIC_VECTOR(15 DOWNTO 0);
signal in_d_c : STD_LOGIC_VECTOR(1 DOWNTO 0);
signal op_c: STD_LOGIC_VECTOR(5 DOWNTO 0);
signal addr_a_c, addr_b_c, addr_d_c : STD_LOGIC_VECTOR(2 DOWNTO 0);
signal reg_b_c ,z_c, rd_in_c, A_sys_c, sys_wrd_c, interruptEnabled_c,interruptNow_c, enable_DisableInterrpt_c, reti_c: std_LOGIC;
BEGIN

datapath1: 
		datapath PORT MAP
		(clk => clk,boot => boot,				op => op_c,   				wrd   => wrd_c,
       addr_a => addr_a_c, 	addr_b => addr_b_c,		addr_d => addr_d_c,
       immed => immed_c, 		immed_x2 => immed_x2_c,	datard_m => datard_m,
		 ins_dad => ins_dad_c,	
		 pc => pc_c, 				
		 in_d => in_d_c, 
		 addr_m => addr_m_c,		data_wr => data_wr, reg_b => reg_b_c, z=>z_c, 
		 valor_reg_a=> valor_reg_a_c, rd_io => rd_io, rd_in => rd_in_c,
		 A_sys => A_sys_c, 
		 sys_wrd => sys_wrd_c, pcup=> pcup_c, interruptEnabled=> interruptEnabled_c, interruptNow => interruptNow_c,
		 PCrutinaInterrupt => PCRutinaInterrupt_c, enable_DisableInterrpt => enable_DisableInterrpt_c,
		 pcup_after_reti => pcup_after_reti_c, reti => reti_c, executantseInterrupt => executantseInterrupt_c,
		 div_zero => div_zero_c, exception_div_zero => exception_div_zero_c, exception_NotAligned => exceptionNotAligned_c, 
		 excpetion_ilegal_instr => excpetion_ilegal_instr_c);
		 
		 rd_in <= rd_in_c;
unidad_control1: 
		unidad_control PORT MAP
		(boot => boot,	     	 	clk => clk,					datard_m => datard_m,
       op => op_c,				wrd => wrd_c,				addr_a => addr_a_c,
       addr_b => addr_b_c,		addr_d => addr_d_c,		immed => immed_c,
       pc => pc_c,				ins_dad => ins_dad_c,	in_d => in_d_c,
       immed_x2 => immed_x2_c,wr_m => wr_m,				word_byte => word_byte, reg_b => reg_b_c, z=> z_c, valor_reg_a=> valor_reg_a_c,
		 addr_io => addr_io, wr_out => wr_out, rd_in => rd_in_c, A_sys => A_sys_c , sys_wrd => sys_wrd_c, pcup => pcup_c,interruptEnabled =>interruptEnabled_c, 
		 inta => inta,PCrutinaInterrupt => PCrutinaInterrupt_c, 
		 enable_DisableInterrpt => enable_DisableInterrpt_c, pcup_after_reti => pcup_after_reti_c,
		 reti => reti_c,
		 interruptNow => interruptNow_c, --inta=> inta,
		 intr=>intr, executantseInterrupt => executantseInterrupt_c, div_zero => div_zero_c, aligned_error => aligned_error,
		 exceptionNotAligned => exceptionNotAligned_c, exception_div_zero=> exception_div_zero_c,
		 excpetion_ilegal_instr => excpetion_ilegal_instr_c);
		addr_m <=
	PCrutinaInterrupt_c when interruptNow_c = '1' 
	else addr_m_c;
	interruptEnabled <= interruptEnabled_c;
	interruptNow<= interruptNow_c;
END Structure;
