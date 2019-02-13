library ieee;
USE ieee.std_logic_1164.all;

entity multi is
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
			intr		 : IN STD_LOGIC;
			interruptToDo : IN	 STD_LOGIC;
			aligned_error: IN STD_LOGIC;
			instructionMemWord :IN STD_LOGIC;
			div_zero :IN STD_LOGIC;
			ilegal_instr : IN STD_LOGIC;
			exceptionNotAligned :OUT STD_LOGIC;
			exception_div_zero: OUT STD_LOGIC;
			excpetion_ilegal_instr:OUT STD_LOGIC;
			reti : IN STD_LOGIC;
			EnabledInterrupt: IN STD_LOGIC;
			execInterrupt : OUT STD_LOGIC);
end entity;

architecture Structure of multi is

    -- Aqui iria la declaracion de las los estados de la maquina de estados

type state_type is(fetch,exec,system);
signal estat: state_type;
signal exception, exception_div_zero_c, excpetion_ilegal_inst_c, exceptionNotAligned_c : STD_LOGIC;
shared variable systemfet,exception_recibed, exception_recibed2 :INTEGER;
begin 

exceptionNotAligned_c <= '1' when aligned_error = '1' and (estat = fetch or instructionMemWord = '1' ) else '0';
exception_div_zero_c <= div_zero;
excpetion_ilegal_inst_c <= ilegal_instr;

exception <= '1' when ilegal_instr = '1' or div_zero = '1' else '0';-- or (aligned_error = '1' and (estat = fetch or instructionMemWord = '1' )) else '0';

	 
    estado:process(clk,boot,exception) 
		begin
			if rising_edge(exception)then exception_recibed := 1;
			end if;
			if exception_recibed2 = 1 then exception_recibed := 0;
			end if;
			if boot = '1' then
				estat <= fetch;
				execInterrupt <= '0';
				exception_recibed := 0;
				exception_recibed2 := 0;
				exceptionNotAligned <= '0';
					exception_div_zero <= '0';
					excpetion_ilegal_instr <= '0';
				systemfet := 0;
			elsif rising_edge(clk) then
				if estat = fetch then estat <= exec;
				elsif estat = exec and intr = '1' and systemfet = 0  and EnabledInterrupt = '1' then
					estat <= system;
					execInterrupt <= '1';

					systemfet := 1;
				elsif estat = fetch and exception_recibed = 1 and systemfet = 0 then
					exception_recibed2 := 1;
					exceptionNotAligned <= exceptionNotAligned_c;
					exception_div_zero <= exception_div_zero_c;
					excpetion_ilegal_instr <= excpetion_ilegal_inst_c;
					estat <= system;
					systemfet := 1;
				else estat <= fetch; execInterrupt <= '0'; exception_recibed2:= 0; --<= exceptionNotAligned <= '0', exce
				end if;
				if reti = '1' then systemfet:= 0;
				end if;
			end if;	
	end process;
	
		with estat select wrd <=
		'0' when fetch,
		--'' when system,
		wrd_l when others;
	
	with estat select wr_m <=
		'0' when fetch,
		'0' when system,
		wr_m_l when others;
		
	with estat select word_byte <=
		'0' when fetch,
		'0' when system,
		w_b when others;
		
	with estat select ldpc <=
		'0' when exec,
		'0' when system,
		ldpc_l when others;
	
	ldir <= '1' when estat = fetch else '0';
	ins_dad <= '1' when estat = fetch else '0';
end Structure;
