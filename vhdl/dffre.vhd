-- 8-bit register (D flip-flop) with synchronous enable and reset

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;


entity dffre is
	generic (N : integer);
	port(
		clk : in STD_LOGIC;
		en : in STD_LOGIC;
		rst: in STD_LOGIC;
		d : in STD_LOGIC_VECTOR(N-1 downto 0);
		q : out STD_LOGIC_VECTOR(N-1 downto 0)
		);
end dffre;

architecture Behavioral of dffre is
begin

	process(clk)
	begin
		if rising_edge(clk) then
			if rst='1' then
				q<=(others=>'0');
			else
				if en='1' then
					q<=d;
				end if;
			end if;
		end if;			
	end process;


end Behavioral;

