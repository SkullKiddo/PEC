LIBRARY ieee;
USE ieee.STD_LOGIC_1164.all;
--USE IEEE.STD_LOGIC_arith.all;
--USE ieee.STD_LOGIC_unsigned.all;
USE ieee.numeric_std.ALL;



ENTITY SRAMController IS
	PORT(clk:		IN 		STD_LOGIC;
		SRAM_ADDR:	OUT		STD_LOGIC_VECTOR(17 downto 0); --17 para DE1, 19 para DE2;
		SRAM_DQ:	INOUT	STD_LOGIC_VECTOR(15 downto 0);
		SRAM_UB_N:	OUT		STD_LOGIC;
		SRAM_LB_N:	OUT		STD_LOGIC;
		SRAM_CE_N:	OUT		STD_LOGIC := '1';
		SRAM_OE_N:	OUT		STD_LOGIC := '1';
		SRAM_WE_N:	OUT		STD_LOGIC := '1';
		
		address:	IN 		STD_LOGIC_VECTOR (15 downto 0) := "0000000000000000";
		dataReaded:	OUT		STD_LOGIC_VECTOR (15 downto 0);
		dataToWrite:IN 		STD_LOGIC_VECTOR (15 downto 0);
		WR:			IN 		STD_LOGIC;
		aligned_error: OUT STD_LOGIC;
		byte_m:		IN 		STD_LOGIC := '0');
END SRAMController;

ARCHITECTURE Structure of SRAMController IS 

type state_type is(RD0,WR0,WR1);
	
	SIGNAL estat : state_type := RD0;
	signal dataHigh : std_logic_vector (7 downto 0);
	signal dataLow : std_logic_vector (7 downto 0);
	signal SignExtension : std_logic_vector (7 downto 0);
	
	
begin
	
	
	process(clk,WR)
		variable cont : integer := 0;
		variable escritura : integer:= 0;
		variable contat: integer:=0;
		begin
			if rising_edge(clk) then
				aligned_error <= '0';
				if WR = '1' and contat = 0 then 
					 escritura := 1;
					 contat := 1;
				elsif WR = '0' then  escritura := 0;
				end if;
				if escritura = 0 then 
					estat <= RD0;
					if byte_m = '0' and address(0) = '1' then aligned_error <= '1';
					end if;
				else 
					if byte_m = '0' and address(0) = '1' then aligned_error <= '1';
					elsif estat = RD0 then estat <= WR0;
					elsif estat = WR0 then estat <= WR1;
					else estat <= RD0;
							escritura := 0;
					end if;
				end if;
				cont := cont +1;
				if cont = 16 then cont := 0; contat := 0;
				end if;
			end if;
	end process;
	
	SRAM_ADDR <= "000" & address (15 DOWNTO 1);
	
	--SRAM_DQ <= "ZZZZZZZZZZZZZZZZ";

	 SRAM_DQ <= "ZZZZZZZZZZZZZZZZ" when estat = RD0 else
					dataToWrite(7 DOWNTO 0) & "00000000" WHEN estat = WR0 and address(0) = '1' and byte_m = '1' ELSE
					"00000000" & dataToWrite(7 DOWNTO 0) WHEN estat = WR0 and address(0) = '0' and byte_m = '1' ELSE
					 dataToWrite(7 DOWNTO 0) & "00000000" WHEN estat = WR1 and address(0) = '1' and byte_m = '1' ELSE
					 "00000000" & dataToWrite(7 DOWNTO 0) WHEN estat = WR1 and address(0) = '0' and byte_m = '1' ELSE
					 dataToWrite WHEN estat = WR0 ELSE
					 dataToWrite WHEN estat = WR1 ELSE
					 "ZZZZZZZZZZZZZZZZ";
		
	
	
	SRAM_UB_N <= 
					'0' when estat = RD0 else
					
					'1' when estat = WR0 and address(0) = '0' and byte_m = '1' else
					'0' when estat = WR0 and address(0) = '1' and  byte_m = '1' else
					
					'1' when estat = WR1 and address(0) = '0' and byte_m = '1' else
					'0' when estat = WR1 and address(0) = '1' and byte_m = '1' else
					'0';
			
	SRAM_LB_N <= 
	
					'0' when estat = RD0 else
					
					'0' when estat = WR0 and address(0) = '0' and byte_m = '1' else
					'1' when estat = WR0 and address(0) = '1' and byte_m = '1' else
					
					'0' when estat = WR1 and address(0) = '0' and byte_m = '1' else
					'1' when estat = WR1 and address(0) = '1' and byte_m = '1' else
					'0';
					
			
	--	with estat select SRAM_CE_N <= 
	
		--			'0' when RD0, -- !CE = 0
					
			--		'0' when WR0, -- !CE = 0
				--	'0' when WR1, -- !CE = 0
	SRAM_CE_N <= '0';
	SRAM_OE_N <= '0';			
			
	--with estat select  SRAM_OE_N <= 
	
		--			'0' when RD0, -- !OE = 0
					
			--		'1' when WR0, -- !OE = X
				--	'1' when WR1, -- !OE = 1
	

					
	with estat select SRAM_WE_N <= 
	
					'1' when RD0, -- !WE = 1
					
					'0' when WR0, -- !WE = 0
					'1' when WR1; -- !WE = 0
					
	
	dataReaded <= dataHigh & dataLow;
	dataLow <= SRAM_DQ(15 DOWNTO 8) when byte_m = '1' and address(0) = '1' else SRAM_DQ(7 DOWNTO 0);
	dataHigh <= SRAM_DQ(15 DOWNTO 8) when byte_m = '0' else SignExtension;
	SignExtension <= (others => dataLow(7));
	
	
	
--	dataReaded <= 
--					std_logic_vector(resize(signed(SRAM_DQ(7 DOWNTO 0)),dataReaded'length))  when estat = RD0 and byte_m = '1' and address(0) = '0' else
--					std_logic_vector(resize(signed(SRAM_DQ(15 DOWNTO 8)),dataReaded'length)) when estat = RD0 and byte_m = '1' and address(0) = '1';-- else
--					SRAM_DQ when estat = RD0;
	
	

	
END Structure;