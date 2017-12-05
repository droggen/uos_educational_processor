-- CPU register banks holding the 4 CPU registers.
-- This is used to simplify the reading and writing to registers
-- by allowing to address them with a 2-bit address and enable signal.

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity cpuregbank is
	port(
		clk : in STD_LOGIC;
		rrd1 : in STD_LOGIC_VECTOR(1 downto 0);
		rrd2 : in STD_LOGIC_VECTOR(1 downto 0);
		rwr : in STD_LOGIC_VECTOR(1 downto 0);
		rwren : in STD_LOGIC;
		rst : in STD_LOGIC;
		d : in STD_LOGIC_VECTOR(7 downto 0);
		q1 : out STD_LOGIC_VECTOR(7 downto 0);
		q2 : out STD_LOGIC_VECTOR(7 downto 0);
		-- Only for debugging
		dbg_qa : out STD_LOGIC_VECTOR(7 downto 0);
		dbg_qb : out STD_LOGIC_VECTOR(7 downto 0);
		dbg_qc : out STD_LOGIC_VECTOR(7 downto 0);
		dbg_qd : out STD_LOGIC_VECTOR(7 downto 0)
		);
		
end cpuregbank;

architecture Behavioral of cpuregbank is
	signal enables: STD_LOGIC_VECTOR(3 downto 0);
	signal qa,qb,qc,qd: STD_LOGIC_VECTOR(7 downto 0);
begin

	ra: entity work.dffre generic map (N=>8) port map(clk=>clk,en=>enables(0),rst=>rst,d=>d,q=>qa);
	rb: entity work.dffre generic map (N=>8) port map(clk=>clk,en=>enables(1),rst=>rst,d=>d,q=>qb);
	rc: entity work.dffre generic map (N=>8) port map(clk=>clk,en=>enables(2),rst=>rst,d=>d,q=>qc);
	rd: entity work.dffre generic map (N=>8) port map(clk=>clk,en=>enables(3),rst=>rst,d=>d,q=>qd);

	with rwr select
		enables <=	"0001" and rwren&rwren&rwren&rwren when "00",
						"0010" and rwren&rwren&rwren&rwren when "01",
						"0100" and rwren&rwren&rwren&rwren when "10",
						"1000" and rwren&rwren&rwren&rwren when others;
						
	with rrd1 select
		q1 <=	qa when "00",
				qb when "01",
				qc when "10",
				qd when others;		
	
	with rrd2 select
		q2 <=	qa when "00",
				qb when "01",
				qc when "10",
				qd when others;

	-- Only for debugging
	dbg_qa <= qa;
	dbg_qb <= qb;
	dbg_qc <= qc;
	dbg_qd <= qd;

end Behavioral;

