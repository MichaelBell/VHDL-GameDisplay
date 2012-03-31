----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    21:00:21 01/17/2012 
-- Design Name: 
-- Module Name:    data_read - Behavioral 
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

-- Receiver using protocol:
-- Idle: data_clk LOW, data invalid
-- Start sending: data_clk goes high then low
-- Data: data is read on the next 10 transitions of data_clk from low to high
-- Clock rate must be at least 1KHz, otherwise we assume sender has gone idle
-- After data byte, you must have another start bit, but we don't have a stop bit.
entity data_read is
  Port ( CLK : in STD_LOGIC;
         data_clk : in STD_LOGIC;
         data : in std_logic;
         id : out unsigned(6 downto 0);
         x : out unsigned(9 downto 0);
         y : out unsigned(9 downto 0);
         sprite : out unsigned(7 downto 0);
         done : out std_logic
  );
end data_read;

architecture Behavioral of data_read is


begin
  process(CLK)
    variable state : std_logic_vector(1 downto 0);
    variable idx : unsigned(1 downto 0);
    variable count_clk : unsigned(15 downto 0);
    variable nextbit : unsigned(3 downto 0);
    variable value : unsigned(9 downto 0);
    variable debounce : unsigned(3 downto 0) := "0000";
  begin
    if rising_edge(CLK) then
      count_clk := count_clk + 1;
      if count_clk = "0000000000000000" then
        state := "00";
        idx := "00";
      else
        if state = "00" then
          -- Not receiving.  Looking for data_clk to go high.
          if data_clk = '1' then
            debounce := debounce + 1;
            if debounce = "0000" then
              count_clk := "0000000000000000";
              state := "01";
            end if;
          else
            debounce := "0000";
          end if;
        else
          if state = "01" then
            -- Start clock.  Wait for data_clk to go low again.
            if data_clk = '0' then
              debounce := debounce + 1;
              if debounce = "0000" then
                state := "10";
                count_clk := "0000000000000000";
                nextbit := "0000";
              end if;
            else
              debounce := "0000";
            end if;
          elsif state = "10" then
            -- Data bit on clk -> high transition.
            if data_clk = '1' then
              debounce := debounce + 1;
              if debounce = "0000" then
                state := "11";
                value(to_integer(nextbit)) := data;
                nextbit := nextbit + 1;
              end if;
            else
              debounce := "0000";
            end if;
          elsif state = "11" then
            if data_clk = '0' then
              debounce := debounce + 1;
              if debounce = "0000" then
                count_clk := "0000000000000000";
                if nextbit = "1010" then
                  state := "00";
                  if idx = "00" then
                    id <= value(6 downto 0);
                  elsif idx = "01" then
                    x <= value;
                  elsif idx = "10" then
                    y <= value;
                  else
                    sprite <= value(7 downto 0);
                  end if;
                  idx := idx + 1;
                else
                  state := "10";
                end if;
              end if;
            else
              debounce := "0000";
            end if;
          end if;
        end if;
      end if;

      if state = "00" and idx = "00" then
        done <= '1';
      else
        done <= '0';
      end if;
    end if;
  end process;
end Behavioral;

