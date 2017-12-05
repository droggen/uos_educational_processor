-- Generates the CPU state sequence seq: ld1 (00), ld2 (01), exec (10)
-- Implementation with a D FF with synchronous reset and enable

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity cpusequencer is
	port(
		clk : in STD_LOGIC;
		rst : in STD_LOGIC;
		en : in STD_LOGIC;
		seq : out STD_LOGIC_VECTOR(1 downto 0)
		);
end cpusequencer;

architecture Behavioral of cpusequencer is
	signal s : STD_LOGIC_VECTOR(1 downto 0); 
begin

	process(clk,rst)
	begin
		if rising_edge(clk) then
			if rst='1' then
				s<="00";
			else 
				if en='1' then
					if s="10" then
						s <= "00";
					else
						s <= s+1;
					end if;
				end if;
			end if;
		end if;
	end process;

	seq <= s;

end Behavioral;

