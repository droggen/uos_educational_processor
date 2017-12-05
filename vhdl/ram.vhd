LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;

ENTITY ram IS
	generic(N : integer);
   PORT
   (
      clk: IN   std_logic;
      address:  IN   STD_LOGIC_VECTOR(N-1 downto 0);
		data:  IN   STD_LOGIC_VECTOR(7 downto 0);
      we:    IN   std_logic;
      q:     OUT  STD_LOGIC_VECTOR(7 DOWNTO 0)
   );
END ram;


ARCHITECTURE rtl OF ram IS
   TYPE mem IS ARRAY(0 TO 2**N-1) OF std_logic_vector(7 DOWNTO 0);
   SIGNAL ram_block : mem := (	
											
-- Put the initial content of the memory here. Note: provide exactly 32 bytes
											X"00", X"00",
											X"00", X"00",
											X"00", X"00",
											X"00", X"00",
											X"00", X"00",
											X"00", X"00",
											X"00", X"00",
											X"00", X"00",
											X"00", X"00",
											X"00", X"00",
											X"00", X"00",
											X"00", X"00",
											X"00", X"00",
											X"00", X"00",
											X"00", X"00",
											X"00", X"00"
										);

BEGIN
   PROCESS(clk)
   BEGIN
      IF rising_edge(clk) THEN
         IF we = '1' THEN
            ram_block(to_integer(unsigned(address))) <= data;
         END IF;
      END IF;
   END PROCESS;
	q <= ram_block(to_integer(unsigned(address)));
END rtl;

