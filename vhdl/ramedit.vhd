-- RAM editor
-- 

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity ramedit is
	generic(N : integer);
	port(
			clk : in STD_LOGIC;
			rst : in STD_LOGIC;
			btnU : in STD_LOGIC;
			btnD : in STD_LOGIC;
			btnL : in STD_LOGIC;
			btnR : in STD_LOGIC;
			din : in STD_LOGIC_VECTOR(15 downto 0);
			we : out STD_LOGIC;
			address : out STD_LOGIC_VECTOR(N-1 downto 0);
			data : out STD_LOGIC_VECTOR(7 downto 0)
		);
end ramedit;

architecture Behavioral of ramedit is
	-- Register with the address we currently wish to edit
	signal address_edit : STD_LOGIC_VECTOR(N-1 downto 0);
begin
	process(clk,rst)
	begin
		if rising_edge(clk) then
			if rst='1' then
				address_edit<=(others=>'0');
			else
				if btnU='1' and btnD='0' then
					address_edit <= address_edit+1;
				elsif btnU='0' and btnD='1' then
					address_edit <= address_edit-1;
				elsif btnL='1' then
					address_edit <= din(8+N-1 downto 8);
				end if;
			end if;		
		end if;
	end process;
	
	we <= btnR;	
	address <= address_edit;
	data <= din(7 downto 0);
	
end Behavioral;

