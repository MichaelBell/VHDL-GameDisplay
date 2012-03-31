----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    21:53:21 09/16/2010 
-- Design Name: 
-- Module Name:    vga - Behavioral 
-- Project Name: 
-- Target Devices: 
-- Tool versions: 
-- Description: 
--
-- Dependencies: 
--
-- Revision: 
-- Revision 0.01 - File Created
-- Additional Comments: 
--
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity vga is
    Port ( CLKIN : in  STD_LOGIC;
           VS : out  STD_LOGIC;
           HS : out  STD_LOGIC;
           data_clk : in STD_LOGIC;
           data : in STD_LOGIC;
           OutRed : out  unsigned(2 downto 0);
           OutGreen : out  unsigned(2 downto 0);
           OutBlue : out  unsigned(2 downto 1));
end vga;

architecture Behavioral of vga is

component driver is
    Port ( CLK : in  STD_LOGIC;
           VS : out  STD_LOGIC;
           HS : out  STD_LOGIC;
				Active : out STD_LOGIC;
				ActiveIn2 : out STD_LOGIC;
           CountX : out  unsigned (9 downto 0);
           CountY : out  unsigned (9 downto 0));
end component;
	COMPONENT dispmem
	PORT(
		row : IN unsigned(9 downto 0);
		col : IN unsigned(9 downto 0);
		start_row : IN std_logic;
		active : in std_logic;
		CLK : IN std_logic;          
		pixel : OUT unsigned(7 downto 0);
    sprite_id : IN unsigned(6 downto 0);
    sprite_x : IN unsigned(9 downto 0);
    sprite_y : IN unsigned(9 downto 0);
    sprite_addr : IN unsigned (7 downto 0);
    sprite_wen : IN std_logic
		);
	END COMPONENT;

	COMPONENT dcm1
	PORT(
		CLKIN_IN : IN std_logic;          
		CLKIN_IBUFG_OUT : OUT std_logic;
		CLKFX_OUT : OUT std_logic;
		CLK0_OUT : OUT std_logic
		);
	END COMPONENT;
  
	COMPONENT data_read
	PORT(
		CLK : IN std_logic;
		data_clk : IN std_logic;
		data : IN std_logic;          
		id : OUT unsigned(6 downto 0);
		x : OUT unsigned(9 downto 0);
		y : OUT unsigned(9 downto 0);
		sprite : OUT unsigned(7 downto 0);
    done : OUT std_logic
		);
	END COMPONENT;  

  signal CLK : std_logic;
  signal VSint : std_logic;
  signal HSint : std_logic;
  signal active : std_logic;
  signal activein2 : std_logic;
  signal start_row : std_logic;
  signal pixel : unsigned(7 downto 0);
	signal countX : unsigned(9 downto 0);
	signal countY : unsigned(9 downto 0);
  signal spriteX : unsigned(9 downto 0);
  signal spriteY : unsigned(9 downto 0);
  signal spriteID : unsigned(6 downto 0);
  signal spriteAddr : unsigned(7 downto 0);
  signal spriteWen : std_logic;
	
begin

  gen: driver port map (CLK, VSint, HSint, active, activein2, countx, county);
	Inst_dcm1: dcm1 PORT MAP(
		CLKIN_IN => CLKIN,
		CLKFX_OUT => CLK
	);
	Inst_dispmem: dispmem PORT MAP(
		row => countY,
		col => countX,
		start_row => start_row,
		active => activein2,
		pixel => pixel,
		CLK => CLK,
    sprite_x => spriteX,
    sprite_y => spriteY,
    sprite_id => spriteID,
    sprite_addr => spriteAddr,
    sprite_wen => spriteWen
	);	
	VS <= VSint;
	HS <= HSint;
  
	Inst_data_read: data_read PORT MAP(
		CLK => CLK,
		data_clk => data_clk,
		data => data,
		id => spriteID,
		x => spriteX,
		y => spriteY,
		sprite => spriteAddr,
    done => spriteWen
	);  

process(CLK)

  
  variable pixel_out : unsigned(7 downto 0);
  variable last_hs : std_logic := '0';
  
begin
  if rising_edge(CLK)	then	  
	   if active = '1' then
         pixel_out := pixel;
	   else
		   pixel_out := "00000000";
	   end if;
	  OutRed <= pixel_out(7 downto 5);
	  OutGreen <= pixel_out(4 downto 2);
	  OutBlue <= pixel_out(1 downto 0);
	   if last_hs = '1' and HSint = '0' then
			start_row <= '1';
		else
			start_row <= '0';
		end if;
	   last_hs := HSint;
  end if;
end process;

end Behavioral;
