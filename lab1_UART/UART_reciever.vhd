----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    23:13:47 03/20/2019 
-- Design Name: 
-- Module Name:    UART_reciever - Behavioral 
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
use IEEE.NUMERIC_STD.ALL;


-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity UART_reciever is

generic(
			data_bit : integer := 8;
			tick : integer := 16
			);
port(
		clk, reset : in std_logic;
		rx : in std_logic;
		s_tick : in std_logic;
		rx_done : out std_logic;
		data_out : out std_logic_vector(7 downto 0)
		);
		
end UART_reciever;

architecture Behavioral of UART_reciever is

type state_type is (idle, start, data, stop); --stanja FSM
signal state_reg, state_next : state_type;
signal s_reg, s_next : unsigned(3 downto 0);
signal n_reg, n_next : unsigned(2 downto 0);
signal b_reg, b_next : std_logic_vector(7 downto 0);

begin

	process(clk, reset)
	begin
		if(reset = '1') then
			state_reg <= idle;
			s_reg <= "0000";
			n_reg <= "000";
			b_reg <= "00000000";
		elsif(clk'event and clk = '1') then
			state_reg <= state_next;
			s_reg <= s_next;
			n_reg <= n_next;
			b_reg <= b_next;
		end if;
	end process;
	
	process(state_reg, s_reg, n_reg, b_reg, s_tick, rx)
	begin
		state_next <= state_reg;
		s_next <= s_reg;
		n_next <= n_reg;
		b_next <= b_reg;
		rx_done <= '0';
		
		case state_reg is
			
			when idle =>
				if(rx = '0') then
					state_next <= start;
					s_next <= "0000";
				end if;
			
			when start =>
				if(s_tick = '1') then
					if(s_reg = 7) then
						state_next <= data;
						s_next <= "0000";
						n_next <= "000";
					else
						s_next <= s_reg + 1;
					end if;
				end if;
			
			when data =>
				if(s_tick = '1') then
					if s_reg = 15 then
						s_next <= "0000";
						b_next <= rx & b_reg(7 downto 1);
						if (n_reg = (data_bit-1)) then
							state_next <= stop;
						else
							n_next <= n_reg + 1;
						end if;
					else
						s_next <= s_reg + 1;
					end if;
				end if;
				
			when stop =>
				if(s_tick = '1') then
					if s_reg = (tick - 1) then
						state_next <= idle;
						rx_done <= '1';
					else
						s_next <= s_reg + 1;
					end if;
				end if;
		end case;
	end process;	
data_out <= b_reg;

end Behavioral;

