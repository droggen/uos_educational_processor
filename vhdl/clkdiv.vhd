library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity clkdiv is
	generic(N : integer);
	port (	clkin : in  STD_LOGIC;
				clkout : out STD_LOGIC
			);
end clkdiv;

architecture Behavioral of clkdiv is
	signal divider : STD_LOGIC_VECTOR(N-1 downto 0);
begin

	process(clkin)
	begin
			if rising_edge(clkin) then
				divider<=divider+1;
			end if;
   end process;
	
	clkout<=divider(N-1);

end Behavioral;

