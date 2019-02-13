LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE IEEE.std_logic_arith.all;
USE ieee.std_logic_unsigned.all;
USE ieee.numeric_std.ALL;

ENTITY MemoryController IS
		PORT(addr:		IN 		STD_LOGIC_VECTOR(15 downto 0);
		wr_data:	IN		STD_LOGIC_VECTOR(15 downto 0);
		rd_data:	OUT		STD_LOGIC_VECTOR(15 downto 0);
		we:			IN		STD_LOGIC;
		byte_m:		IN		STD_LOGIC;
		CLOCK50:	IN		STD_LOGIC;
		SRAM_ADDR:	OUT		STD_LOGIC_VECTOR(17 downto 0);--17 DE1 19 DE2
		SRAM_DQ:	INOUT	STD_LOGIC_VECTOR(15 downto 0);

		SRAM_UB_N:	OUT		STD_LOGIC;
		SRAM_LB_N:	OUT		STD_LOGIC;
		SRAM_CE_N:	OUT		STD_LOGIC := '1';
		SRAM_OE_N:	OUT		STD_LOGIC := '1';
		SRAM_WE_N:	OUT		STD_LOGIC := '1';
		aligned_error: OUT STD_LOGIC;
		vga_addr : OUT std_logic_vector(12 downto 0);
		vga_we : OUT std_logic;
		vga_wr_data : OUT std_logic_vector(15 downto 0);
		vga_rd_data : IN std_logic_vector(15 downto 0);
		vga_byte_m : OUT std_logic);
END MemoryController;

ARCHITECTURE Structure of MemoryController IS 

COMPONENT SRAMController IS
	PORT(clk:		IN 		STD_LOGIC;
		dataToWrite:IN 		STD_LOGIC_VECTOR (15 downto 0);
		WR:			IN 		STD_LOGIC;
		byte_m:		IN 		STD_LOGIC := '0';
		address:	IN 		STD_LOGIC_VECTOR (15 downto 0) := "0000000000000000";
		SRAM_DQ:	INOUT	STD_LOGIC_VECTOR(15 downto 0);
		SRAM_ADDR:	OUT		STD_LOGIC_VECTOR(17 downto 0); --17 para DE1, 19 para DE2;
		SRAM_UB_N:	OUT		STD_LOGIC;
		SRAM_LB_N:	OUT		STD_LOGIC;
		SRAM_CE_N:	OUT		STD_LOGIC := '1';
		SRAM_OE_N:	OUT		STD_LOGIC := '1';
		SRAM_WE_N:	OUT		STD_LOGIC := '1';
		aligned_error: OUT STD_LOGIC;
		dataReaded:	OUT		STD_LOGIC_VECTOR (15 downto 0));
		
END COMPONENT;

signal wr_c, wrSdram: std_LOGIC;
signal limit_sup,limit_inf: std_LOGIC_VECTOR(15 downto 0);
signal mult: std_LOGIC;
signal readedSram :std_LOGIC_VECTOR(15 downto 0);
--signal proba: std_LOGIC_VECTOR(15 downto 0);
BEGIN

limit_sup <= "1100000000000000";
limit_inf <= "1101000000000000";

--proba <= "1111111111111111";
with mult select wr_c <=
	we when '1',
	'0' when others;

	
with addr < limit_sup or addr > limit_inf select mult <=
	'1' when true,
	'0' when false;

vga_addr <= addr(12 downto 0);

vga_we <= '1' when (addr >= X"A000" and addr < X"C000" ) and (we = '1') else '0';

rd_data <= vga_rd_data when addr >= X"A000" and addr < X"C000" else readedSram;	

vga_wr_data <= wr_data;

vga_byte_m <= byte_m;

wrSdram <= '0' when (addr >= X"A000") and (addr < X"C000") else wr_c; 
	
SRAM: SRAMController PORT MAP (clk=> CLOCK50, dataToWrite => wr_data, WR=> wrSdram, 
	byte_m =>byte_m, address => addr, SRAM_DQ => SRAM_DQ, SRAM_ADDR => SRAM_ADDR,
	SRAM_UB_N => SRAM_UB_N, SRAM_LB_N => SRAM_LB_N, SRAM_CE_N => SRAM_CE_N,
	SRAM_OE_N => SRAM_OE_N, SRAM_WE_N => SRAM_WE_N, dataReaded => readedSram, aligned_error => aligned_error);

END Structure;





