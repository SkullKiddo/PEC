LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.std_logic_arith.all;
USE ieee.std_logic_unsigned.all;

ENTITY sisa IS
    PORT (CLOCK_50  : IN    STD_LOGIC;
          SRAM_ADDR : OUT   std_logic_vector(17 downto 0);
          SRAM_DQ   : INOUT std_logic_vector(15 downto 0);
          SRAM_UB_N : OUT   std_logic;
          SRAM_LB_N : OUT   std_logic;
          SRAM_CE_N : OUT   std_logic := '1';
          SRAM_OE_N : OUT   std_logic := '1';
          SRAM_WE_N : OUT   std_logic := '1';
          SW        : IN std_logic_vector(9 downto 0);
			 
			 LEDG 	  : OUT std_logic_vector(7 downto 0);
			 LEDR		  : OUT std_logic_vector(7 downto 0);
			 HEX0 : OUT STD_LOGIC_VECTOR(6 DOWNTO 0);
			 HEX1 : OUT STD_LOGIC_VECTOR(6 DOWNTO 0);
			 HEX2 : OUT STD_LOGIC_VECTOR(6 DOWNTO 0);
			 HEX3 : OUT STD_LOGIC_VECTOR(6 DOWNTO 0);
			 KEY		  : IN std_LOGIC_VECTOR(3 DOWNTO 0);
			 PS2_CLK : INOUT std_LOGIC;
			 PS2_DAT : INOUT std_LOGIC;
			 VGA_HS		: OUT 	STD_LOGIC;
			 VGA_VS		: OUT 	STD_LOGIC;
			 VGA_R		: OUT		STD_LOGIC_VECTOR(3 DOWNTO 0);
			 VGA_G		: OUT		STD_LOGIC_VECTOR(3 DOWNTO 0);
			 VGA_B		: OUT		STD_LOGIC_VECTOR(3 DOWNTO 0));
END sisa;

ARCHITECTURE Structure OF sisa IS

COMPONENT MemoryController IS
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
END COMPONENT;

COMPONENT proc IS
    PORT (clk       : IN  STD_LOGIC;
          boot      : IN  STD_LOGIC;
          datard_m  : IN  STD_LOGIC_VECTOR(15 DOWNTO 0);
          addr_m    : OUT STD_LOGIC_VECTOR(15 DOWNTO 0);
          data_wr   : OUT STD_LOGIC_VECTOR(15 DOWNTO 0);
          wr_m      : OUT STD_LOGIC;
          word_byte : OUT STD_LOGIC;
			 addr_io     : OUT  std_logic_vector(7 downto 0); 
			 wr_OUT : OUT std_LOGIC;
			 rd_IN : OUT std_LOGIC;
			 rd_io : IN std_logic_vector(15 downto 0);
			 inta :OUT std_LOGIC;
			 intr : IN STD_LOGIC;
			 interruptEnabled:OUT STD_LOGIC;
			 interruptNow:OUT STD_LOGIC;
			 aligned_error: IN STD_LOGIC);
END COMPONENT;

COMPONENT controladores_IO IS  
  PORT (boot   : IN  STD_LOGIC; 
		clk    : IN  std_logic;
		PS2_CLK: INOUT STD_LOGIC ;
		ps2_data   : INOUT STD_LOGIC;
		addr_io     : IN  std_logic_vector(7 downto 0); 
		wr_io  : IN  std_logic_vector(15 downto 0); 
		rd_io  : OUT std_logic_vector(15 downto 0); 
		wr_OUT : IN  std_logic; 
		rd_IN  : IN  std_logic; 
		led_verdes  : OUT STD_LOGIC_VECTOR(7 DOWNTO 0); 
		led_rojos   : OUT STD_LOGIC_VECTOR(7 DOWNTO 0);
      SW        : IN std_logic_vector(7 downto 0);
		sevenSeg 	: OUT std_LOGIC_VECTOR(15 DOWNTO 0);
		KEY		   : IN std_LOGIC_VECTOR(3 DOWNTO 0);
		INTerruptEnabled: IN STD_LOGIC;
		inta :IN std_LOGIC;
		intr : OUT STD_LOGIC;
		interruptNow:IN STD_LOGIC);
	END COMPONENT controladores_IO; 
	
COMPONENT driver4displays IS
  PORT (numeros : IN STD_LOGIC_VECTOR(15 DOWNTO 0);
	HEX0 : OUT std_logic_vector(6 downto 0);
	HEX1 : OUT std_logic_vector(6 downto 0);
	HEX2 : OUT std_logic_vector(6 downto 0);
	HEX3 : OUT std_logic_vector(6 downto 0));
END COMPONENT driver4displays; 

COMPONENT vga_controller_stub IS
	port(clk_50mhz      : IN  std_logic; -- system clock signal
         reset          : IN  std_logic; -- system reset
         --blank_OUT      : OUT std_logic; -- vga control signal
         --csync_OUT      : OUT std_logic; -- vga control signal
         red_OUT        : OUT std_logic_vector(7 downto 0); -- vga red pixel value
         green_OUT      : OUT std_logic_vector(7 downto 0); -- vga green pixel value
         blue_OUT       : OUT std_logic_vector(7 downto 0); -- vga blue pixel value
         horiz_sync_OUT : OUT std_logic; -- vga control signal
         vert_sync_OUT  : OUT std_logic; -- vga control signal
         --
         addr_vga          : IN std_logic_vector(12 downto 0);
         we                : IN std_logic;
         wr_data           : IN std_logic_vector(15 downto 0);
         rd_data           : OUT std_logic_vector(15 downto 0);
         byte_m            : IN std_logic);
         --vga_cursor        : IN std_logic_vector(15 downto 0);  -- simplemente lo ignoramos, este controlador no lo tiene implementado
         --vga_cursor_enable : IN std_logic);                     -- simplemente lo ignoramos, este controlador no lo tiene implementado
end COMPONENT vga_controller_stub;

signal addr_c, data_wr_c, datard_m_c, rd_data_c, wr_io_c, rd_io_c: STD_LOGIC_VECTOR(15 DOWNTO 0);
signal addr_io_c : STD_LOGIC_VECTOR(7 DOWNTO 0);
signal we_c,word_byte_c, wr_OUT_c, rd_IN_c, vga_we_c, vga_byte_m_c : STD_LOGIC;
signal clk_proc: STD_LOGIC;
signal ledsverdes :std_logic_vector(7 downto 0);
signal ledsrojos :std_logic_vector(7 downto 0);
signal vga_B_c, vga_G_c, vga_r_c :std_logic_vector(7 downto 0);
signal vga_addr_c: std_LOGIC_VECTOR(12 downto 0);
Signal hexas, vga_wr_data_c, vga_rd_data_c: STD_LOGIC_VECTOR(15 DOWNTO 0);

signal inta_c, intr_c, interruptEnabled_c, interruptNow_c, aligned_error_c : STD_LOGIC;

BEGIN

process (CLOCK_50)
	variable cont: INTEGER := 0;
	begIN
	  --dwerf
		if SW(9) = '1' then clk_proc <= '0';
		elsif risINg_edge(CLOCK_50) then
			cont := cont +1;
			if cont = 4 then clk_proc <= not clk_proc;
									cont := 0;
			end if;
		--else clk_proc <= '0';
		end if;
end process;


proc1: proc PORT MAP (clk => clk_proc, boot=>SW(9), datard_m =>rd_data_c, addr_m =>addr_c,
						data_wr => data_wr_c, wr_m => we_c, word_byte => word_byte_c, rd_io => rd_io_c, 
						wr_OUT => wr_OUT_c, rd_IN  => rd_IN_c, addr_io => addr_io_c, inta=> inta_c, intr => intr_c,
					interruptEnabled => interruptEnabled_c,interruptNow=>interruptNow_c, aligned_error => aligned_error_c	); 

MemControl: MemoryController PORT MAP (addr => addr_c , wr_data => data_wr_c, rd_data => rd_data_c, we => we_c,
										byte_m => word_byte_c, 
										CLOCK50 => CLOCK_50, 
										SRAM_ADDR => SRAM_ADDR, 
										SRAM_DQ => SRAM_DQ, 
										SRAM_UB_N => SRAM_UB_N,
										SRAM_LB_N => SRAM_LB_N,
										SRAM_CE_N => SRAM_CE_N,
										SRAM_OE_N => SRAM_OE_N,
										SRAM_WE_N => SRAM_WE_N,
										vga_addr => vga_addr_c,
										vga_we => vga_we_c,
										vga_wr_data =>vga_wr_data_c,
										vga_rd_data =>vga_rd_data_c,
										vga_byte_m =>vga_byte_m_c, aligned_error => aligned_error_c);
										
ControlINOUT: CONtroladores_IO PORT map(boot => SW(9),	clk => CLOCK_50,	addr_io => addr_io_c, 
													wr_io => data_wr_c,	rd_io => rd_io_c ,
													wr_OUT => wr_OUT_c, rd_IN  => rd_IN_c, led_verdes  => LEDG , 
													led_rojos   => LEDR,SW =>SW( 7 downto 0), KEY => KEY,sevenSeg => hexas, PS2_CLK=> PS2_CLK, 
													PS2_DATA => PS2_DAT, inta => inta_c, 
												  intr => intr_c,
												  interruptNow => interruptNow_c,
												  interruptEnabled=> interruptEnabled_c); 
		

						
SetSeg: Driver4displays PORT MAP(numeros => hexas,	HEX0 => HEX0, HEX1 => HEX1, HEX2 => HEX2, HEX3 => HEX3);

vga: vga_controller_stub PORT MAP(clk_50mhz => CLOCK_50,
         reset => SW(9),
         red_OUT => vga_r_c, -- vga red pixel value
         green_OUT => vga_g_c, -- vga green pixel value
         blue_OUT => vga_b_c, -- vga blue pixel value
         horiz_sync_OUT => vga_HS, -- vga control signal
         vert_sync_OUT  => vga_vs, -- vga control signal
         addr_vga  => vga_addr_c,
         we   => vga_we_c,
         wr_data => vga_wr_data_c,
         rd_data => vga_rd_data_c,
         byte_m => vga_byte_m_c);
			
vga_B <= vga_B_c(3 downto 0);
vga_r <= vga_r_c(3 downto 0);
vga_g <= vga_g_c(3 downto 0);

END Structure;
