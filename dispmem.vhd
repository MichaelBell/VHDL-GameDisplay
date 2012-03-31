----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    22:07:06 12/02/2011 
-- Design Name: 
-- Module Name:    dispmem - Behavioral 
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

entity dispmem is
    Port ( row : in  unsigned (9 downto 0);
	         col : in  unsigned (9 downto 0);
           start_row : in  STD_LOGIC;
			     active : in std_logic;
           pixel : out  unsigned (7 downto 0);
           CLK : in  STD_LOGIC;
           sprite_id : in unsigned (6 downto 0);
           sprite_x : in unsigned (9 downto 0);
           sprite_y : in unsigned (9 downto 0);
           sprite_addr : in unsigned (7 downto 0);
           sprite_wen : in STD_LOGIC);
end dispmem;

architecture Behavioral of dispmem is
COMPONENT dispram
  PORT (
    clka : IN STD_LOGIC;
    ena : IN STD_LOGIC;
    wea : IN STD_LOGIC_VECTOR(0 DOWNTO 0);
    addra : IN STD_LOGIC_VECTOR(9 DOWNTO 0);
    dina : IN STD_LOGIC_VECTOR(7 DOWNTO 0);
    douta : OUT STD_LOGIC_VECTOR(7 DOWNTO 0)
  );
END COMPONENT;
COMPONENT sprite_data
  PORT (
    clka : IN STD_LOGIC;
    ena : IN STD_LOGIC;
    wea : IN STD_LOGIC_VECTOR(0 DOWNTO 0);
    addra : IN STD_LOGIC_VECTOR(11 DOWNTO 0);
    dina : IN STD_LOGIC_VECTOR(8 DOWNTO 0);
    douta : OUT STD_LOGIC_VECTOR(8 DOWNTO 0);
    clkb : IN STD_LOGIC;
    enb : IN STD_LOGIC;
    web : IN STD_LOGIC_VECTOR(0 DOWNTO 0);
    addrb : IN STD_LOGIC_VECTOR(11 DOWNTO 0);
    dinb : IN STD_LOGIC_VECTOR(8 DOWNTO 0);
    doutb : OUT STD_LOGIC_VECTOR(8 DOWNTO 0)
  );
END COMPONENT;
COMPONENT sprite_pos
  PORT (
    clka : IN STD_LOGIC;
    ena : IN STD_LOGIC;
    wea : IN STD_LOGIC_VECTOR(0 DOWNTO 0);
    addra : IN STD_LOGIC_VECTOR(6 DOWNTO 0);
    dina : IN STD_LOGIC_VECTOR(35 DOWNTO 0);
    douta : OUT STD_LOGIC_VECTOR(35 DOWNTO 0);
    clkb : IN STD_LOGIC;
    enb : IN STD_LOGIC;
    web : IN STD_LOGIC_VECTOR(0 DOWNTO 0);
    addrb : IN STD_LOGIC_VECTOR(6 DOWNTO 0);
    dinb : IN std_logic_vector(35 DOWNTO 0);
    doutb : OUT STD_LOGIC_VECTOR(35 DOWNTO 0)
  );
END COMPONENT;

  signal evenaddr : unsigned(9 downto 0);
  signal evenen : std_logic;
  signal evenwen : std_logic;
  signal evendin : std_logic_vector(7 downto 0);
  signal evendout : std_logic_vector(7 downto 0);
  signal oddaddr : unsigned(9 downto 0);
  signal odden : std_logic;
  signal oddwen : std_logic;
  signal odddin : std_logic_vector(7 downto 0);
  signal odddout : std_logic_vector(7 downto 0);
  
  -- Sprite data, i.e. the actual sprites themselves
  signal spriteden : std_logic;
  signal spriteaddr : unsigned(11 downto 0);
  signal spritedata : std_logic_vector(7 downto 0);
  signal spritealpha : std_logic;
  
  -- Sprite description, read side
  signal sdren : std_logic;
  signal sdrdata : std_logic_vector(35 downto 0);
  signal sdrposX : unsigned(9 downto 0);
  signal sdrposY : unsigned(9 downto 0);
  signal sdrheight : unsigned(5 downto 0);
  signal sdrwidth : unsigned(5 downto 0);
  signal sdrstartaddr : unsigned(11 downto 0);
  signal sdraddr : unsigned(6 downto 0);
  
  -- Sprite description, modify side
  signal sdmen : std_logic;
  signal sdmwen : std_logic;
  signal sdmrdata : std_logic_vector(35 downto 0);
  signal sdmrposX : unsigned(9 downto 0);
  signal sdmrposY : unsigned(9 downto 0);
  signal sdmrheight : unsigned(5 downto 0);
  signal sdmrwidth : unsigned(5 downto 0);
  signal sdmrstartaddr : unsigned(11 downto 0);
  signal sdmwdata : std_logic_vector(35 downto 0);
  signal sdmwposX : unsigned(9 downto 0);
  signal sdmwposY : unsigned(9 downto 0);
  signal sdmwheight : unsigned(5 downto 2);
  signal sdmwwidth : unsigned(5 downto 2);
  signal sdmwstartaddr : unsigned(11 downto 4);
  signal sdmaddr : unsigned(6 downto 0);  
begin
  
evenram : dispram
  PORT MAP (
    clka => CLK,
    ena => evenen,
    wea(0) => evenwen,
    addra => std_logic_vector(evenaddr),
    dina => evendin,
    douta => evendout
  );
oddram : dispram
  PORT MAP (
    clka => CLK,
    ena => odden,
    wea(0) => oddwen,
    addra => std_logic_vector(oddaddr),
    dina => odddin,
    douta => odddout
  );
  
sprites : sprite_data
  PORT MAP (
    clka => CLK,
    ena => spriteden,
    wea => "0",
    addra => std_logic_vector(spriteaddr),
    dina => "000000000",
    douta(7 downto 0) => spritedata,
	  douta(8) => spritealpha,
    clkb => CLK,
    enb => '0',
    web => "0",
    addrb => "000000000000",
    dinb => "000000000",
    doutb => open
  );
  
sdesc : sprite_pos
  PORT MAP (
    clka => CLK,
    ena => sdren,
    wea => "0",
    addra => std_logic_vector(sdraddr),
    dina => "000000000000000000000000000000000000",
    douta => sdrdata,
    clkb => CLK,
    enb => sdmen,
    web(0) => sdmwen,
    addrb => std_logic_vector(sdmaddr),
	  dinb => sdmwdata,
    doutb => sdmrdata
  );
--	Inst_ball: ball PORT MAP(
--		CLK => CLK,
--		desc_addr => sdmaddr,
--		desc_en => sdmen,
--		desc_wen => sdmwen,
--		desc_x_in => sdmrposX,
--		desc_y_in => sdmrposY,
--		desc_x => sdmwposX,
--		desc_y => sdmwposY
--	);  
  
  sdmaddr <= sprite_id;
  sdmwposX <= sprite_x;
  sdmwposY <= sprite_y;
  sdmwstartaddr <= sprite_addr;
  sdmwen <= sprite_wen;
  sdmen <= '1';
  
  sdrposX <= unsigned(sdrdata(35 downto 26));
  sdrposY <= unsigned(sdrdata(25 downto 16));
  sdrwidth(5 downto 2) <= unsigned(sdrdata(15 downto 12));
  sdrheight(5 downto 2) <= unsigned(sdrdata(11 downto 8));
  sdrstartaddr(11 downto 4) <= unsigned(sdrdata(7 downto 0));
  sdmwdata(35 downto 26) <= std_logic_vector(sdmwposX);
  sdmwdata(25 downto 16) <= std_logic_vector(sdmwposY);
  sdmwdata(15 downto 12) <= std_logic_vector(sdmwwidth(5 downto 2));
  sdmwdata(11 downto 8) <= std_logic_vector(sdmwheight(5 downto 2));
  sdmwdata(7 downto 0) <= std_logic_vector(sdmwstartaddr(11 downto 4));
  sdmrposX <= unsigned(sdmrdata(35 downto 26));
  sdmrposY <= unsigned(sdmrdata(25 downto 16));
  sdmrwidth(5 downto 2) <= unsigned(sdmrdata(15 downto 12));
  sdmrheight(5 downto 2) <= unsigned(sdmrdata(11 downto 8));
  sdmrstartaddr(11 downto 4) <= unsigned(sdmrdata(7 downto 0));
  
  sdrwidth(1 downto 0) <= "00";
  sdrheight(1 downto 0) <= "00";
  sdrstartaddr(3 downto 0) <= "0000";
  sdmrwidth(1 downto 0) <= "00";
  sdmrheight(1 downto 0) <= "00";
  sdmrstartaddr(3 downto 0) <= "0000";

process(CLK)
  
  variable wraddr : unsigned(9 downto 0);
  variable wren : std_logic;
  variable wrdata : std_logic_vector(7 downto 0);

   variable next_row : unsigned(9 downto 0);
	variable stage : unsigned(3 downto 0) := "0000";
	variable local_addr : unsigned(9 downto 0);
	
	variable sdren_tmp : std_logic;
	variable spriteden_tmp : std_logic;
	
	variable sprite_row : unsigned(9 downto 0);
	variable sprite_offset : unsigned(9 downto 0);
	
begin
   if rising_edge(CLK) then
		if row = 767 then
			next_row := "0000000000";
		else
			next_row := row  + 1;
		end if;
	  
  if sprite_addr < 32 then
  	sdmwwidth <= "0100";
  	sdmwheight <= "0100";
  else
    sdmwwidth <= "0010";
    sdmwheight <= "0010";
  end if;
  
	  sdren_tmp := '0';
	  spriteden_tmp := '0';
	  
		if stage = "0000" then
			-- Not writing, look for start_row
			wren := '0';
			wrdata := "00000000";
			wraddr := "0000000000";
			if start_row = '1' then
				stage := "0001";
				local_addr := "0000000000";
			end if;
		elsif stage = "0001" then
			-- Write left border
			wren := '1';
			wraddr := local_addr;
			wrdata := "11111111";
			local_addr := local_addr + 1;
			if local_addr = 6 then
				if next_row < 6 or next_row >= 762 then
					stage := "0010";
				else
					stage := "0011";
					local_addr := "1111111010";
				end if;
			end if;
		elsif stage = "0010" then
			-- Write middle
			wren := '1';
			wraddr := local_addr;
			wrdata := "11111111";
			local_addr := local_addr + 1;
			if local_addr = 1018 then
				stage := "0011";
			end if;			
		elsif stage = "0011" then
			-- Write right border
			wren := '1';
			wraddr := local_addr;
			wrdata := "11111111";
			local_addr := local_addr + 1;
			if local_addr = 0 then
				stage := "0100";
				sdraddr <= "0000000";
				sdren_tmp := '1';
			end if;
		elsif stage = "0100" then
			wren := '0';
			wraddr := local_addr;
			wrdata := "00000000";
			sdren_tmp := '1';		
			stage := "0101";
		elsif stage = "0101" then
			-- Check sprite position
			wren := '0';
			wraddr := local_addr;
			wrdata := "00000000";
			if next_row >= sdrposY and next_row < sdrposY + sdrheight then
				stage := "0110";
				sdren_tmp := '1';
			else
				-- Move to next sprite.
				if sdraddr = "1111111" then
					stage := "0000";
				else
					sdren_tmp := '1';
					sdraddr <= sdraddr + 1;
					stage := "0100";
				end if;
			end if;
		elsif stage = "0110" then
			wren := '0';
			wraddr := local_addr;
			wrdata := "00000000";
			local_addr := sdrposX;
			sdren_tmp := '1';
			sprite_row := (next_row - sdrposY);
			sprite_offset := sprite_row(5 downto 0) * sdrwidth(5 downto 2);
			stage := "0111";
    elsif stage = "0111" then
			sdren_tmp := '1';
			spriteden_tmp := '1';
			spriteaddr <= (sdrstartaddr(11 downto 2) + sprite_offset) & "00";		
      stage := "1000";
		elsif stage = "1000" then
			wren := '0';
			wraddr := local_addr;
			wrdata := "00000000";
			spriteaddr <= spriteaddr + 1;
			sdren_tmp := '1';
			spriteden_tmp := '1';
			stage := "1001";
		else
			wren := spritealpha;
			wraddr := local_addr;
			wrdata := spritedata;
			local_addr := local_addr + 1;
			spriteaddr <= spriteaddr + 1;
			sdren_tmp := '1';
			spriteden_tmp := '1';
			if local_addr = sdrposX + sdrwidth then
				if sdraddr = "1111111" then
					stage := "0000";
				else
					sdren_tmp := '1';
					sdraddr <= sdraddr + 1;
					stage := "0100";
				end if;
			end if;
		end if;
		
		sdren <= sdren_tmp;
		spriteden <= spriteden_tmp;

		if row(0) = '0' then
			pixel <= unsigned(evendout);
			evenen <= active;
			evenwen <= '1';
			evenaddr <= col;
			evendin <= "00000000";
			odden <= wren;
			oddwen <= wren;
			oddaddr <= wraddr;
			odddin <= wrdata;
		else
			pixel <= unsigned(odddout);
			odden <= active;
			oddwen <= '1';
			oddaddr <= col;
			odddin <= "00000000";
			evenen <= wren;
			evenwen <= wren;
			evenaddr <= wraddr;
			evendin <= wrdata;
		end if;
	end if;
end process;
end Behavioral;

