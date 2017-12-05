

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity edgedetect is
	port(
		clk : in STD_LOGIC;
		din : in STD_LOGIC;
		dout : out STD_LOGIC
		);
end edgedetect;

architecture Behavioral of edgedetect is
	signal last : STD_LOGIC;
begin

	process(clk) 
	begin
		if rising_edge(clk) then
			last <= din;
		end if;
	end process;

	dout <= din and not last;

end Behavioral;

