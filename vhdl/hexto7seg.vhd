library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use IEEE.std_logic_unsigned.ALL;

entity hexto7seg is
	port(	
		clk: in std_logic;
		d7: in std_logic_vector(3 downto 0);
		d6: in std_logic_vector(3 downto 0);
		d5: in std_logic_vector(3 downto 0);
		d4: in std_logic_vector(3 downto 0);
		d3: in std_logic_vector(3 downto 0);
		d2: in std_logic_vector(3 downto 0);
		d1: in std_logic_vector(3 downto 0);
		d0: in std_logic_vector(3 downto 0);
		blink: in std_logic_vector(7 downto 0);
		q: out std_logic_vector(6 downto 0);
		active : out std_logic_vector(7 downto 0)
		);
end hexto7seg;

architecture Behavioral of hexto7seg is
	signal a: std_logic;
	signal b: std_logic;
	signal c: std_logic;
	signal d: std_logic;
	signal qt: std_logic_vector(6 downto 0);
	signal ctr: std_logic_vector(2 downto 0);
	signal divider: std_logic_vector(25 downto 0);
begin



	p1: process(clk)
   begin
			if rising_edge(clk) then
				divider<=divider+1;
			end if;
   end process;
	p2: process(clk)
   begin
			if rising_edge(clk) then
				if  divider(9 downto 0)="0000000000"  then 
					ctr<=ctr+1;
				end if;
			end if;
   end process;

	-- input mux
	with ctr select
	a <= 	d0(3) when "000",
			d1(3) when "001",
			d2(3) when "010",
			d3(3) when "011",
			d4(3) when "100",
			d5(3) when "101",
			d6(3) when "110",
			d7(3) when others;
	with ctr select
	b <= 	d0(2) when "000",
			d1(2) when "001",
			d2(2) when "010",
			d3(2) when "011",
			d4(2) when "100",
			d5(2) when "101",
			d6(2) when "110",
			d7(2) when others;
	with ctr select
	c <= 	d0(1) when "000",
			d1(1) when "001",
			d2(1) when "010",
			d3(1) when "011",
			d4(1) when "100",
			d5(1) when "101",
			d6(1) when "110",
			d7(1) when others;
	with ctr select
	d <= 	d0(0) when "000",
			d1(0) when "001",
			d2(0) when "010",
			d3(0) when "011",
			d4(0) when "100",
			d5(0) when "101",
			d6(0) when "110",
			d7(0) when others;

	-- Output mux
	with ctr select
	active <= 	"11111110" when "000",
					"11111101" when "001",
					"11111011" when "010",
					"11110111" when "011",
					"11101111" when "100",
					"11011111" when "101",
					"10111111" when "110",
					"01111111" when others;

	-- Blinking
	q(0) <= (blink(to_integer(unsigned(ctr))) and divider(25)) or qt(0);
	q(1) <= (blink(to_integer(unsigned(ctr))) and divider(25)) or qt(1);
	q(2) <= (blink(to_integer(unsigned(ctr))) and divider(25)) or qt(2);
	q(3) <= (blink(to_integer(unsigned(ctr))) and divider(25)) or qt(3);
	q(4) <= (blink(to_integer(unsigned(ctr))) and divider(25)) or qt(4);
	q(5) <= (blink(to_integer(unsigned(ctr))) and divider(25)) or qt(5);
	q(6) <= (blink(to_integer(unsigned(ctr))) and divider(25)) or qt(6);



	qt(0) <= not ( (not a and not b and not c and not d )
				or (not a and not b and c and not d)
				or (not a and not b and c and d)
				or (not a and b and not c and d)
				or (not a and b and c and not d)
				or (not a and b and c and d)
				or (a and not b and not c and not d)
				or (a and not b and not c and d)
				or (a and not b and c and not d)
				or (a and b and not c and not d)
				or (a and b and c and not d)
				or (a and b and c and d) );
				
	qt(1) <= not ( (not a and not b and not c and not d) 
				or (not a and not b and not c and d)
				or (not a and not b and c and not d)
				or (not a and not b and c and c)
				or (not a and b and not c and not d)
				or (not a and b and c and d)
				or (a and not b and not c and not d)
				or (a and not b and not c and d)
				or (a and not b and c and not d)
				or (a and b and not c and d) );
				
	qt(2) <=	not ( (not a and not b and not c and not d)
				or (not a and not b and not c and d)
				or (not a and not b and c and d)
				or (not a and b and not c and not d)
				or (not a and b and not c and d)
				or (not a and b and c and not d)
				or (not a and b and c and d)
				or (a and not b and not c and not d)
				or (a and not b and not c and d)
				or (a and not b and c and not d)
				or (a and not b and c and d)
				or (a and b and not c and d) );
	qt(3) <=	not ((not a and not b and not c and not d)
				or (not a and not b and c and not d)
				or (not a and not b and c and d)
				or (not a and b and not c and d)
				or (not a and b and c and not d)
				or (a and not b and not c and not d)
				or (a and not b and c and d)
				or (a and b and not c and not d)
				or (a and b and not c and d)
				or (a and b and c and not d) );

	--qt(4) <=	not ((not a and not b and not c and not d)
	--			or (not a and not b and c and not d)
	--			or (not a and b and c and not d)
	--			or (a and not b and not c and not d)
	--			or (a and not b and c and not d)
	--			or (a and not b and c and d)
	--			or (a and b and not c and not d)
	--			or (a and b and not c and d)
	--			or (a and b and c and not d)
	--			or (a and b and c and d) );

	
				
	--qt(5) <= 	not ((not a and not b and not c and not d)
	--			or (not a and b and not c and not d)
	--			or (not a and b and not c and d)
	--			or (not a and b and c and not d)
	--			or (a and not b and not c and not d)
	--			or (a and not b and not c and d)
	--			or (a and not b and c and not d)
	--			or (a and not b and c and d)
	--			or (a and b and not c and not d)
	--			or	(a and b and c and not d)
	--			or (a and b and c and d) );

				
	--qt(6) <=	not ((not a and not b and c and not d)
	--			or (not a and not b and c and d)
	--			or (not a and b and not c and not d)
	--			or (not a and b and not c and d)
	--			or (not a and b and c and not d)
	--			or (a and not b and not c and not d)
	--			or (a and not b and not c and d)
	--			or (a and not b and c and not d)
	--			or (a and not b and c and d)
	--			or (a and b and not c and d)
	--			or (a and b and c and not d)
	--			or (a and b and c and d) );

	-- Minimized expression:

	qt(4) <= not( (a and b) or (a and c) or (c and not d) or (not b and not d) );
	qt(5) <= not( (b and not d) or (not a and b and not c) or (a and not b) or (a and c) or (not c and not d) );
	qt(6) <= not( (not a and b and not c) or (a and not b) or (a and d) or (not b and c and d) or (c and not d) );


end Behavioral;

