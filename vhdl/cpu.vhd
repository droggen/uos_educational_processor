

----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;


entity cpu is
	generic(N : integer);
	port(
			clk : in STD_LOGIC;
			rst : in STD_LOGIC;
			ext_in : in STD_LOGIC_VECTOR(7 downto 0);
			ext_out : out STD_LOGIC_VECTOR(7 downto 0);
			ram_we : out STD_LOGIC;
			ram_address : out STD_LOGIC_VECTOR(N-1 downto 0);
			ram_datawr : out STD_LOGIC_VECTOR(7 downto 0);
			ram_datard : in STD_LOGIC_VECTOR(7 downto 0);
			-- Only for debugging
			dbg_qa : out STD_LOGIC_VECTOR(7 downto 0);
			dbg_qb : out STD_LOGIC_VECTOR(7 downto 0);
			dbg_qc : out STD_LOGIC_VECTOR(7 downto 0);
			dbg_qd : out STD_LOGIC_VECTOR(7 downto 0);
			dbg_instr : out STD_LOGIC_VECTOR(15 downto 0);
			dbg_seq : out STD_LOGIC_VECTOR(1 downto 0);
			dbg_flags : out STD_LOGIC_VECTOR(3 downto 0)
		);
end cpu;

architecture Behavioral of cpu is


	-- Instruction
	signal instruction : STD_LOGIC_VECTOR(15 downto 0);
	
	-- Helper
	signal source : STD_LOGIC_VECTOR(7 downto 0);
	signal wrdata : STD_LOGIC_VECTOR(7 downto 0);
	
	-- register bank
	signal regwren : STD_LOGIC;
	signal reg1out : STD_LOGIC_VECTOR(7 downto 0);
	signal reg2out : STD_LOGIC_VECTOR(7 downto 0);
	
	-- flags
	signal flagwren : STD_LOGIC;
	signal flags : STD_LOGIC_VECTOR(3 downto 0);	--  zf, ovf, cf, sf
	signal zf,ovf,cf,sf : STD_LOGIC;
	
	-- fetch/execute signals
	signal seq : STD_LOGIC_VECTOR(1 downto 0);
	signal execute,fetch,fetchh,fetchl : STD_LOGIC;
	
	-- Instruction pointer
	signal ip: STD_LOGIC_VECTOR(N-1 downto 0);
	signal ipnext: STD_LOGIC_VECTOR(N-1 downto 0);
	
	-- ALU input and output signals
	signal aluqout: STD_LOGIC_VECTOR(7 downto 0);
	signal alufout : STD_LOGIC_VECTOR(3 downto 0);
	
	-- Jumps
	signal jump : STD_LOGIC;
	signal jumpip: STD_LOGIC_VECTOR(N-1 downto 0);
	signal jumpconditionvalid : STD_LOGIC;
	
	-- External interface
	signal ext_wren : STD_LOGIC;
	
	-- Debug signals
	--signal tdbg_qa,tdbg_qb,tdbg_qc,tdbg_qd : STD_LOGIC_VECTOR(7 downto 0);
	
begin

	

	---------------------------------------------------------------------------------------
	-- Fetch/Execute -- Fetch/Execute -- Fetch/Execute -- Fetch/Execute -- Fetch/Execute --
	---------------------------------------------------------------------------------------
	-- Instantiate a fetch/exec sequencer. Seq is 00 for load1, 01 for load2, 10 for execute
	comp_seq: entity work.cpusequencer port map(clk=>clk,rst=>rst,en=>'1',seq=>seq);
	-- Binary to one hot
	fetchh <= 	'1' when seq="00" else
					'0';
	fetchl <= 	'1' when seq="01" else
					'0';
	execute <=  '1' when seq="10" else
					'0';
	fetch <= fetchl or fetchh;
	-- Instantiate two 8-bit registers to store the 16-bit instruction during the fetchl and fetchh cycles.
	comp_instrh: entity work.dffre generic map(N=>8) port map(clk=>clk,rst=>rst,en=>fetchh,d=>ram_datard,q=>instruction(15 downto 8));
	comp_instrl: entity work.dffre generic map(N=>8) port map(clk=>clk,rst=>rst,en=>fetchl,d=>ram_datard,q=>instruction(7 downto 0));
	
	
	---------------------------------------------------------------------------------------
	-- Instruction pointer
	---------------------------------------------------------------------------------------
	comp_ip: entity work.dffre generic map(N=>N) port map(clk=>clk,rst=>rst,en=>'1',d=>ipnext,q=>ip);
	
	ipnext <= ip+1 when fetch='1' else
				 ip when jump='0' else
				 jumpip;								
	

	
	---------------------------------------------------------------------------------------
	-- Register bank -- Register bank -- Register bank -- Register bank -- Register bank --
	---------------------------------------------------------------------------------------
	-- Instantiate the register bank
	-- Always map the register 1 and register 2 to the source and destination registers in the instruction fields
	-- Always map the write register to destination register in instruction field.
	-- Always map the write input to wrdata
	comp_regs: entity work.cpuregbank port map(clk=>clk,rrd1=>instruction(9 downto 8),rrd2=>instruction(1 downto 0),rwr=>instruction(9 downto 8),rwren=>regwren,rst=>rst,d=>wrdata,q1=>reg1out,q2=>reg2out,
								dbg_qa=>dbg_qa,dbg_qb=>dbg_qb,dbg_qc=>dbg_qc,dbg_qd=>dbg_qd);
	
	-- Write to register for move instructions with direct destination, or ALU instructions except cmp.
	regwren <=		'1' when execute='1' and instruction(15 downto 13) = "000" and instruction(11)='0' else						-- opcode 000 (move)
						'1' when execute='1' and instruction(15 downto 13) = "001" else														-- opcode 001 (add,sub,and,or)
						'1' when execute='1' and instruction(15 downto 13) = "010" and instruction(11 downto 10) /= "01" else		-- opcode 010 (all except cmp)
						'1' when execute='1' and instruction(15 downto 13) = "011" else														-- opcode 011
						'1' when execute='1' and instruction(15 downto 13) = "110" and instruction(11 downto 10) = "01" else		-- opcode 110 (io)
						'0';

	
	--------------------------------------------------------------------------------------------
	-- Helper -- Helper -- Helper -- Helper -- Helper -- Helper -- Helper -- Helper -- Helper --
	--------------------------------------------------------------------------------------------
	-- Almost all instructions using a source have register or immediate mode. We 
	source <= reg2out when instruction(12)='0' else
				 instruction(7 downto 0); 

	
	-------------------------------------------------------------------------------
	-- ALU -- ALU -- ALU -- ALU -- ALU -- ALU -- ALU -- ALU -- ALU -- ALU -- ALU --
	-------------------------------------------------------------------------------
	-- Instantiate ALU
	comp_alu: entity work.cpualu port map(clk=>clk,rst=>rst,op=>instruction(14 downto 10),a=>reg1out,b=>source,q=>aluqout,f=>alufout);
	
	-----------------------------------------------------------------------------------
	-- Flags -- Flags -- Flags -- Flags -- Flags -- Flags -- Flags -- Flags -- Flags --
	-----------------------------------------------------------------------------------
	-- instantiate register to store the flags
	comp_flags: entity work.dffre generic map(N=>4) port map(clk=>clk,rst=>rst,en=>flagwren,d=>alufout,q=>flags);
	-- When to write the flags: execute phase and compare instruction
	flagwren <= '1' when execute='1' and instruction(15 downto 13)="010" and instruction(11 downto 10)="01"
					else '0';
	-- Individual signals for each flag
	zf <= flags(3);
	ovf <= flags(2);
	cf <= flags(1);
	sf <= flags(0);
		
	-----------------------------------------------------------------------------------
	-- Jump -- Jump -- Jump -- Jump -- Jump -- Jump -- Jump -- Jump -- Jump -- Jump -- 
	-----------------------------------------------------------------------------------
	-- Jump destinatinon is register or immediate
	jumpip <= 	source(N-1 downto 0);
	-- Do jump when the instruction is a jump and the jump condition is met
	jump <=	'1' when instruction(15 downto 13) = "101" and jumpconditionvalid='1' else
				'0';
	-- Jump condition
	jumpconditionvalid <=	'1' when instruction(11 downto 8) = "0000" else									-- Unconditional jump
									'1' when instruction(11 downto 8) = "0001" and zf='1' else					-- je/jz
									'1' when instruction(11 downto 8) = "1001" and zf='0'	else					-- jne/jnz
									'1' when instruction(11 downto 8) = "0010" and zf='0' and cf='0' else	-- ja
									'1' when instruction(11 downto 8) = "1011" and zf='0' and cf='1' else 	-- jb
									'0';

	
	---------------------------------------------------------------------------------------
	-- RAM interface -- RAM interface -- RAM interface -- RAM interface -- RAM interface --
	---------------------------------------------------------------------------------------
	-- ram address to read instruction and read or write data
	ram_address <= ip when fetch='1' else
						reg2out(N-1 downto 0) when instruction(15 downto 10)="000001" else
						instruction(N-1 downto 0) when instruction(15 downto 10)="000101" else
						reg1out(N-1 downto 0) when instruction(15 downto 10)="000010" else
						reg1out(N-1 downto 0) when instruction(15 downto 10)="000110" else
						(others=>'0');
		--"00000";
	-- Enable write
	ram_we <= 	'1' when execute='1' and instruction(15 downto 13)="000" and instruction(11 downto 10)="10" else
					'0';
	-- Data to write
	ram_datawr <= wrdata;
	
	
	
	------------------------------------------------------------------------------------------
	-- External interface -- External interface -- External interface -- External interface --
	------------------------------------------------------------------------------------------
	-- Instantiate a register to hold the output interface data
	comp_regextout : entity work.dffre generic map (N=>8) port map(clk=>clk,rst=>rst,en=>ext_wren,d=>source,q=>ext_out);
	ext_wren <= 	'1' when execute='1' and instruction(15 downto 13) = "110" and instruction(11 downto 10)="00" else
						'0';
	

	--------------------------------------------------------------------------------------
	-- Write data -- Write data -- Write data -- Write data -- Write data -- Write data -- 
	--------------------------------------------------------------------------------------
	-- Data may be written to ram or memory. The enable signals in the ram and register instances
	-- control whether the write occurs.
	-- Here we define what to write.
	
	wrdata <=	source when instruction(15 downto 13) = "000" and instruction(11 downto 10)="00" else			-- Move with register or immediate as source
					source when instruction(15 downto 13) = "000" and instruction(11 downto 10)="10" else			-- Move with register or immediate as source
					ram_datard when instruction(15 downto 13) = "000" and instruction(11 downto 10)="01" else		-- Move with memory as source
					aluqout when instruction(15 downto 13) = "001" else				-- ALU
					aluqout when instruction(15 downto 13) = "010" else				-- ALU
					aluqout when instruction(15 downto 13) = "011" else				-- ALU
					ext_in when instruction(15 downto 13) = "110" and instruction(11 downto 10)="01" else			-- Instruction in: read external input
					"00000000";
					
					
	-- Only for debugging
	dbg_instr <= instruction;
	dbg_seq <= seq;
	dbg_flags <= flags;
	
					

end Behavioral;



