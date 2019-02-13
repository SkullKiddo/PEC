library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.numeric_std.all;
use IEEE.std_logic_unsigned.all;


entity keyboard_controller_stub is
    Port (clk        : in    STD_LOGIC;
          reset      : in    STD_LOGIC;
          ps2_clk    : inout STD_LOGIC;
          ps2_data   : inout STD_LOGIC;
          read_char  : out   STD_LOGIC_VECTOR (7 downto 0);
          clear_char : in   STD_LOGIC;
          data_ready : out   STD_LOGIC
			 );
end keyboard_controller_stub;

ARCHITECTURE Behavioral of keyboard_controller_stub is
signal actual: std_logic_vector(7 downto 0);
signal data_ready_c : std_LOGIC;
begin

--process (clear_char)
--variable vegada : integer := 0;
--begin
--	if vegada = 0 then 
--		read_char <= "00000000"; end if;
--	if vegada = 1 then 
--		read_char <= "00000001"; end if;
--	if vegada = 2 then 
--		read_char <= "00000010"; end if;
--		vegada := vegada +1;
--end process;		

data_ready <= '1';
--data_ready <= data_ready_c;
data_ready_c <= '0' when reset = '1' else not data_ready_c after 100ns;
read_char  <= "00000000" after 800ns, "00000001" after 2000ns, "00000010" after 9000ns;

 

end Behavioral;

