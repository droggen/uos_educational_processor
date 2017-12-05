-- ALU
-- The ALU uses 1 or 2 operands
-- The opcode are bits 14,13,12,11,10 of the instruction
-- a: input A of ALU
-- b: input B of ALU (not used for single operand instructions)
-- q: result (except for compare which is not used)
-- f: flag vectors with zero flag, overflow flag, carry flag and sign flag.



library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity cpualu is
	port (
		clk : in STD_LOGIC;
		rst : in STD_LOGIC;
		op : in STD_LOGIC_VECTOR(4 downto 0);
		a : in STD_LOGIC_VECTOR(7 downto 0);
		b : in STD_LOGIC_VECTOR(7 downto 0);
		q : out STD_LOGIC_VECTOR(7 downto 0);
		f : out STD_LOGIC_VECTOR(3 downto 0)
		);
end cpualu;

architecture Behavioral of cpualu is
	signal sub : STD_LOGIC_VECTOR(8 downto 0);	-- Do subtraction on 9 bits to obtain the carry
	signal r: STD_LOGIC_VECTOR(7 downto 0);		-- ALU result
	signal zf,ovf,cf,sf : STD_LOGIC;
begin

	--comp_rng: entity work.rng port map(clk=>clk,rst=>rst

	sub <= ('0'&a) - ('0'&b);


	r <= 		a+b when op(4 downto 3)="01" and op(1 downto 0)="00" else
				sub(7 downto 0) when op(4 downto 3)="01" and op(1 downto 0)="01" else
				a and b when op(4 downto 3)="01" and op(1 downto 0)="10" else
				a or b when op(4 downto 3)="01" and op(1 downto 0)="11" else
				a xor b when op(4 downto 3)="10" and op(1 downto 0)="00" else
				not a when op(4 downto 0)="11000" else
				'0'&a(7 downto 1) when op(4 downto 0)="11001" else
				a(0)&a(7 downto 1) when op(4 downto 0)="11010" else
				a(7)&a(7 downto 1) when op(4 downto 0)="11011" else
				a(6 downto 0)&a(7) when op(4 downto 0)="11100" else
				"00000000";

	sf <= sub(7);
	zf <= not(sub(7) or sub(6) or sub(5) or sub(4) or sub(3) or sub(2) or sub(1) or sub(0));
	cf <= sub(8);
	ovf <= (not a(7) and b(7) and sub(7)) or (a(7) and not b(7) and not sub(7));

	f<=zf&ovf&cf&sf;
	q<=r;

end Behavioral;

