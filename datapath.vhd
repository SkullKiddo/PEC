LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.numeric_std.all;
USE ieee.std_logic_arith.all;
USE IEEE.std_logic_unsigned.all;


ENTITY datapath IS
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
			 valor_reg_a:OUT STD_LOGIC_VECTOR(15 DOWNTO 0);
			 rd_in		: IN  std_logic;
			 rd_io		: IN std_logic_vector(15 downto 0);
			  A_sys :IN std_LOGIC;
			 sys_wrd:IN std_LOGIC;
			 interruptEnabled:OUT std_LOGIC;
			 interruptNow : IN	 STD_LOGIC;
			 Enable_DisableInterrpt: IN std_LOGIC;
			 PCrutinaInterrupt : OUT STD_LOGIC_VECTOR(15 DOWNTO 0);
			 pcup_after_reti : OUT STD_LOGIC_VECTOR(15 downto 0);
			 reti :IN std_LOGIC;
			 ExecutantseInterrupt : IN STD_LOGIC;
			 
			 exception_div_zero: IN STD_LOGIC;
			 excpetion_ilegal_instr:IN STD_LOGIC;
			 exception_NotAligned : IN STD_LOGIC;
			 
			 div_zero :OUT STD_LOGIC;
			 pcup		: IN std_logic_vector(15 downto 0));
			 
			 
END datapath;


ARCHITECTURE Structure OF datapath IS


COMPONENT regfile IS
    PORT (clk    : IN  STD_LOGIC;
          wrd    : IN  STD_LOGIC;
          d      : IN  STD_LOGIC_VECTOR(15 DOWNTO 0);
          addr_a : IN  STD_LOGIC_VECTOR(2 DOWNTO 0);
			 addr_b : IN  STD_LOGIC_VECTOR(2 DOWNTO 0);
          addr_d : IN  STD_LOGIC_VECTOR(2 DOWNTO 0);
          a      : OUT STD_LOGIC_VECTOR(15 DOWNTO 0);
          b      : OUT STD_LOGIC_VECTOR(15 DOWNTO 0));
	END COMPONENT;
	
COMPONENT alu IS
    PORT (x  : IN  STD_LOGIC_VECTOR(15 DOWNTO 0);
          y  : IN  STD_LOGIC_VECTOR(15 DOWNTO 0);
          op : IN  STD_LOGIC_VECTOR(5 DOWNTO 0);
          w  : OUT STD_LOGIC_VECTOR(15 DOWNTO 0);
			 div_zero :OUT STD_LOGIC;
			 z: OUT STD_LOGIC);
	END COMPONENT;

COMPONENT sysreg IS
    PORT (clk    : IN  STD_LOGIC;
			 boot    : IN STD_LOGIC;
          wrd    : IN  STD_LOGIC;
          d      : IN  STD_LOGIC_VECTOR(15 DOWNTO 0);
          addr_a : IN  STD_LOGIC_VECTOR(2 DOWNTO 0);
          addr_d : IN  STD_LOGIC_VECTOR(2 DOWNTO 0);
          a      : OUT STD_LOGIC_VECTOR(15 DOWNTO 0);
			 PCrutinaInterrupt : OUT STD_LOGIC_VECTOR(15 DOWNTO 0);
			 interruptNow : IN	 STD_LOGIC;
			 pcup    : IN  STD_LOGIC_VECTOR(15 DOWNTO 0);
			 Enable_DisableInterrpt: IN std_LOGIC;
			 pcup_after_reti : OUT STD_LOGIC_VECTOR(15 downto 0);
			 reti :IN std_LOGIC;
			  ExecutantseInterrupt : IN STD_LOGIC;
			   addr_m : IN STD_LOGIC_VECTOR(15 DOWNTO 0);
			  exception_div_zero: IN STD_LOGIC;
			 excpetion_ilegal_instr:IN STD_LOGIC;
			 exception_NotAligned : IN STD_LOGIC;
			 interruptBitEnabled : OUT std_LOGIC);
END COMPONENT;

signal d_intern, w_d,a_x,y_imm, y_val, shifted_immed, b_c, valor_d, A_c, a_sys_c, addr_m_c  :std_LOGIC_VECTOR(15 downto 0); 
    -- Aqui iria la declaracion de las entidades que vamos a usar
    -- Usaremos la palabra reservada COMPONENT ...
    -- Tambien crearemos los cables/buses (signals) necesarios para unir las entidades
--signal valor_reg_a_c : STD_LOGIC_VECTOR (15 downto 0);
BEGIN
	
	valor_reg_a <= a_x;
	addr_m <= addr_m_c;
	with ins_dad select addr_m_c<= 
		w_d when '0',
		pc when others;
	
	with rd_in select valor_d <=
		d_intern when '0',
		rd_io when others;
	
	with in_d select d_intern <=
		w_d when "00",
		--std_lOGIC_VECTOR(unsigned(pc) + unsigned("0000000000000010")) when "10",
				pc + 2 when "10",

		datard_m when others;
	
	shifted_immed(15 downto 1) <= immed(14 downto 0);
	shifted_immed(0) <= '0';
	
	with immed_x2 select  y_imm <=
		immed when '0',
		shifted_immed when others;
	
	with reg_b select y_val <=
		y_imm when '0',
		b_c when others;
	
	with A_sys select A_c <=
		a_x when '0',
		a_sys_c when others;
	
	data_wr <= b_c;
   BancReg : regfile Port Map (clk=>clk,	wrd => wrd,	d=>valor_d,	addr_a=>addr_a,	addr_b=>addr_b,
										addr_d=>addr_d,	a=>a_x,	b=>b_c);
	ralu: alu Port Map (x=>A_c,y=>y_val,op=>op,w=>w_d, z=>z, div_zero => div_zero);
    -- En los esquemas de la documentacion a la instancia del banco de registros le hemos llamado reg0 y a la de la alu le hemos llamado alu0
	REG_SYS: sysreg Port Map (clk=>clk,	wrd => sys_wrd,	d=>d_intern,	addr_a=>addr_a, interruptNow=>interruptNow,
										addr_d=>addr_d,	a=>a_sys_c , InterruptBitEnabled => interruptEnabled, pcup => pcup,
										PCrutinaInterrupt=> PCrutinaInterrupt, boot => boot, enable_DisableInterrpt => enable_DisableInterrpt,
										reti => reti, pcup_after_reti => pcup_after_reti, executantseInterrupt => executantseInterrupt, 
										exception_NotAligned => exception_NotAligned, addr_m => addr_m_c,
										exception_div_zero => exception_div_zero, excpetion_ilegal_instr => excpetion_ilegal_instr);

END Structure;