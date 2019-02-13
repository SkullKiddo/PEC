library ieee;
   use ieee.std_logic_1164.all;


entity test_sisa is
end test_sisa;

architecture comportament of test_sisa is
   component async_64Kx16 is
		generic
			(ADDR_BITS		: integer := 16;
			DATA_BITS		: integer := 16;
			depth 			: integer := 65536;
			
			TimingInfo		: BOOLEAN := TRUE;
			TimingChecks	: std_logic := '1'
			);
		Port (
			CE_b    : IN Std_Logic;	                                                -- Chip Enable CE#
			WE_b  	: IN Std_Logic;	                                                -- Write Enable WE#
			OE_b  	: IN Std_Logic;                                                 -- Output Enable OE#
			BHE_b	: IN std_logic;                                                 -- Byte Enable High BHE#
			BLE_b   : IN std_logic;                                                 -- Byte Enable Low BLE#
			A 		: IN Std_Logic_Vector(addr_bits-1 downto 0);                    -- Address Inputs A
			DQ		: INOUT Std_Logic_Vector(DATA_BITS-1 downto 0):=(others=>'Z');   -- Read/Write Data IO
			boot    : in std_logic
			); 
   end component;
   
   component sisa IS
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
   end component;

   
   -- Registres (entrades) i cables
   signal clk           : std_logic := '0';
   signal reset_ram    	: std_logic := '0';
   signal reset_proc    : std_logic := '0';

   signal addr_SoC      : std_logic_vector(17 downto 0);
   signal addr_mem      : std_logic_vector(15 downto 0);
   signal data_mem      : std_logic_vector(15 downto 0);

   signal ub_m           : std_logic;
   signal lb_m           : std_logic;
   signal ce_m           : std_logic;
   signal oe_m           : std_logic;
   signal we_m           : std_logic;
   signal ce_m2           : std_logic;

   signal interruptores      : std_logic_vector(9 downto 0);
   signal botones : STD_LOGIC_VECTOR(3 DOWNTO 0);
   signal displ0, displ1, displ2, displ3 : STD_LOGIC_VECTOR (6 DOWNTO 0);
   
   signal VGA_HS		: STD_LOGIC;
   signal VGA_VS		: STD_LOGIC;
   signal VGA_R		: STD_LOGIC_VECTOR(3 DOWNTO 0);
   signal VGA_G		: STD_LOGIC_VECTOR(3 DOWNTO 0);
   signal VGA_B		: STD_LOGIC_VECTOR(3 DOWNTO 0);
   
   --type Numero is(uno, dos, tres, cuatro, cienco, seis, siete, ocho, nueve, A, B, C, D, E, F);
   -- signal num0, num1, num2, num3 : Numero;
   

	
begin
   
   ce_m2 <= '1', ce_m after 100ns;
   -- Instanciacions de moduls
   SoC : sisa
      port map (
         CLOCK_50   => clk,
         SW        => interruptores,

         SRAM_ADDR  => addr_SoC,
         SRAM_DQ    => data_mem,
			SRAM_UB_N 	=> ub_m,
			SRAM_LB_N 	=> lb_m,
			SRAM_CE_N 	=> ce_m,
			SRAM_OE_N 	=> oe_m,
			SRAM_WE_N 	=> we_m,
			--LEDG
			--LEDR
			--HEX0
			--HEX1
			--HEX2
			--HEX3
			KEY => botones,
			VGA_HS => VGA_HS,
			 VGA_VS	=> VGA_VS,
			 VGA_R	=> VGA_R,
			 VGA_G	=> VGA_G,
			 VGA_B => VGA_B
			
      );

   mem0 : async_64Kx16
      port map (
				A 	 => addr_mem,
				DQ  => data_mem,
				
				--CE_b => ce_m,
				CE_b => ce_m2,
				OE_b => oe_m,
				WE_b => we_m,
				BLE_b => lb_m,
				BHE_b => ub_m,

				boot     => reset_ram
      );
	  

		addr_mem (15 downto 0) <= addr_SOC (15 downto 0);
		interruptores(9) <= reset_proc;
		
   -- Descripcio del comportament
   interruptores(7 DOWNTO 0) <= "00000000";
	clk <= not clk after 10 ns;
	
	reset_ram <= '1' after 15 ns, '0' after 50 ns;    -- reseteamos la RAm en el primer ciclo
	reset_proc <= '1' after 25 ns, '0' after 320 ns;  -- reseteamos el procesador en el segundo ciclo
	botones <= "0010" after 5000 ns;
  interruptores(8 downto 0) <= "000000001" after 5000 ns;
	
end comportament;


