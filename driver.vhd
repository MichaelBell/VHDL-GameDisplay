----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    22:24:58 09/16/2010 
-- Design Name: 
-- Module Name:    driver - Behavioral 
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

entity driver is
    Port ( CLK : in  STD_LOGIC;
           VS : out  STD_LOGIC;
           HS : out  STD_LOGIC;
					 Active : out STD_LOGIC;
					 ActiveIn2 : out std_logic;
           CountX : out  unsigned (9 downto 0);
           CountY : out  unsigned (9 downto 0));
end driver;

architecture Behavioral of driver is

  signal intCX : unsigned (10 downto 0) := "00000000000";
	signal intCY : unsigned (9 downto 0) := "0000000000";

begin

process (CLK)
  variable countx_tmp : unsigned(10 downto 0);
begin
  if rising_edge(CLK) then
	  if intCX = 1344 then
	    intCX <= "00000000000";
			if intCY = 806 then
			  intCY <= "0000000000";
			else
			  intCY <= intCY + 1;
			end if;
		else
		  intCX <= intCX + 1;
		end if;
		
		if intCX < 144 then
		  HS <= '0';
		else
		  HS <= '1';
		end if;
		
		if intCY < 6 then
		  VS <= '0';
		else
		  VS <= '1';
		end if;
		
		if intCY >= 35 and intCY < 803 then
		   CountY <= intCY - 35;
			if intCX >= 310 and intCX < 1334 then
				countx_tmp := intCX - 310;
				CountX <= countx_tmp(9 downto 0);
				ActiveIn2 <= '1';
			end if;
			if intCX >= 312 and intCX < 1336 then
				Active <= '1';
			else
				Active <= '0';
			end if;
		else
			CountY <= "1011111111";
			Active <= '0';
		end if;
  end if;
end process;
end Behavioral;
