library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
USE ieee.numeric_std.all;


entity vga_controller_stub is
    port(clk_50mhz      : in  std_logic; -- system clock signal
         reset          : in  std_logic; -- system reset
         blank_out      : out std_logic; -- vga control signal
         csync_out      : out std_logic; -- vga control signal
         red_out        : out std_logic_vector(7 downto 0); -- vga red pixel value
         green_out      : out std_logic_vector(7 downto 0); -- vga green pixel value
         blue_out       : out std_logic_vector(7 downto 0); -- vga blue pixel value
         horiz_sync_out : out std_logic; -- vga control signal
         vert_sync_out  : out std_logic; -- vga control signal
         --
         addr_vga          : in std_logic_vector(12 downto 0);
         we                : in std_logic;
         wr_data           : in std_logic_vector(15 downto 0);
         rd_data           : out std_logic_vector(15 downto 0);
         byte_m            : in std_logic);             -- simplemente lo ignoramos, este controlador no lo tiene implementado
end vga_controller_stub;

architecture structure of vga_controller_stub is

begin
blank_out <= '1';
         csync_out <= '1';
         red_out <= "11111111";
         green_out <= "11111111";
         blue_out <= "11111111";
         horiz_sync_out <= '1';
         vert_sync_out <= '1';
			rd_data <= "1111111111111111";
		
end structure;