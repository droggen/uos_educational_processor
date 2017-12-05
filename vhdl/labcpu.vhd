library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity main is
    Port ( 
				clk : in STD_LOGIC;
				btnU : in STD_LOGIC;
				btnD : in STD_LOGIC;
				btnL : in STD_LOGIC;
				btnC : in STD_LOGIC;
				btnR : in STD_LOGIC;
				btnCpuReset : in STD_LOGIC;
				sw : in	STD_LOGIC_VECTOR (15 downto 0);
				led : out	STD_LOGIC_VECTOR (15 downto 0);
				seg : out STD_LOGIC_VECTOR(6 downto 0);
				an : out STD_LOGIC_VECTOR(7 downto 0) 
			  );
			  
end main;

architecture Structural of main is
	signal reset : STD_LOGIC;
	
	-- clocks
	signal clkmain : STD_LOGIC;
	signal clkslow : STD_LOGIC;
	
	
	
	
	
	signal cpu_ram_we : STD_LOGIC;
	signal cpu_ram_address : STD_LOGIC_VECTOR(4 downto 0);
	signal cpu_ram_datawr : STD_LOGIC_VECTOR(7 downto 0);
	signal cpu_ram_datard : STD_LOGIC_VECTOR(7 downto 0);
	
	signal ramedit_address : STD_LOGIC_VECTOR(4 downto 0);
	signal ramedit_data : STD_LOGIC_VECTOR(7 downto 0);
	signal ramedit_enable : STD_LOGIC;
	signal ramedit_we : STD_LOGIC;
	
	-- Display signals
	signal display_d7 : STD_LOGIC_VECTOR(3 downto 0);
	signal display_d6 : STD_LOGIC_VECTOR(3 downto 0);
	signal display_d5 : STD_LOGIC_VECTOR(3 downto 0);
	signal display_d4 : STD_LOGIC_VECTOR(3 downto 0);
	signal display_d3 : STD_LOGIC_VECTOR(3 downto 0);
	signal display_d2 : STD_LOGIC_VECTOR(3 downto 0);
	signal display_d1 : STD_LOGIC_VECTOR(3 downto 0);
	signal display_d0 : STD_LOGIC_VECTOR(3 downto 0);
	signal display_blink : STD_LOGIC_VECTOR(7 downto 0);
	signal cpu_d0, cpu_d1, cpu_d2, cpu_d3, cpu_d4, cpu_d5, cpu_d6, cpu_d7 : STD_LOGIC_VECTOR(3 downto 0);
	
	-- RAM signals
	signal ramclk : STD_LOGIC;
	signal ram_address : STD_LOGIC_VECTOR(4 downto 0);
	signal ram_datain : STD_LOGIC_VECTOR(7 downto 0);
	signal ram_we : STD_LOGIC;
	signal ram_dataout : STD_LOGIC_VECTOR(7 downto 0);
	
	-- debouncing
	signal btnUd,btnDd,btnLd,btnCd,btnRd,btnCpuResetd : STD_LOGIC;
	signal sw15d,sw13d : STD_LOGIC;
	-- edge detect
	signal btnUde,btnDde,btnLde,btnRde : STD_LOGIC;
	
	-- Only for CPU debugging
	signal dbg_qa : STD_LOGIC_VECTOR(7 downto 0);
	signal dbg_qb : STD_LOGIC_VECTOR(7 downto 0);
	signal dbg_qc : STD_LOGIC_VECTOR(7 downto 0);
	signal dbg_qd : STD_LOGIC_VECTOR(7 downto 0);
	signal dbg_instr : STD_LOGIC_VECTOR(15 downto 0);
	signal dbg_seq : STD_LOGIC_VECTOR(1 downto 0);
	signal dbg_flags : STD_LOGIC_VECTOR(3 downto 0);
	
begin
	-- Debouncing
	comp_deb1 : entity work.debounce port map(clk=>clk,button=>btnC,result=>btnCd);
	comp_deb2 : entity work.debounce port map(clk=>clk,button=>btnU,result=>btnUd);
	comp_deb3 : entity work.debounce port map(clk=>clk,button=>btnD,result=>btnDd);
	comp_deb4 : entity work.debounce port map(clk=>clk,button=>btnL,result=>btnLd);
	comp_deb5 : entity work.debounce port map(clk=>clk,button=>btnR,result=>btnRd);
	comp_deb6 : entity work.debounce port map(clk=>clk,button=>btnCpuReset,result=>btnCpuResetd);
	comp_deb7 : entity work.debounce port map(clk=>clk,button=>sw(15),result=>sw15d);
	comp_deb8 : entity work.debounce port map(clk=>clk,button=>sw(13),result=>sw13d);
	
	-- Edge detectors on some buttons (for RAM editor)
	comp_edg1 : entity work.edgedetect port map(clk=>clk,din=>btnLd,dout=>btnLde);
	comp_edg2 : entity work.edgedetect port map(clk=>clk,din=>btnRd,dout=>btnRde);
	comp_edg3 : entity work.edgedetect port map(clk=>clk,din=>btnUd,dout=>btnUde);
	comp_edg4 : entity work.edgedetect port map(clk=>clk,din=>btnDd,dout=>btnDde);
	
	-- slow clock
	--
	comp_clk : entity work.clkdiv generic map(N=>25) port map(clkin=>clk,clkout=>clkslow);
	
	-- Reset
	--
	reset <= not btnCpuResetd;
	
	-- Toggle the RAM edit mode according to sw15d
	-- 
	ramedit_enable <= sw15d;


	-- Display debug status on LEDs
	--
	led(15) <= ramedit_enable;
	led(14) <= clkmain;
	led(13 downto 12) <= dbg_seq;
	led(11 downto 8) <= dbg_flags;

	
	-- Display multiplexers: toggle between ram edit and cpu mode
	display_blink <= "00"&ramedit_enable&ramedit_enable&ramedit_enable&ramedit_enable&ramedit_enable&ramedit_enable;
	display_d7 <= "0000" when ramedit_enable='1' else cpu_d7;
	display_d6 <= "0000" when ramedit_enable='1' else cpu_d6;
	display_d5 <= "000"&ram_address(4 downto 4) when ramedit_enable='1' else cpu_d5;
	display_d4 <= ram_address(3 downto 0) when ramedit_enable='1' else cpu_d4;
	display_d3 <= 	sw(7 downto 4) when ramedit_enable='1' else cpu_d3;
	display_d2 <= 	sw(3 downto 0) when ramedit_enable='1' else cpu_d2;
	display_d1 <= 	ram_dataout(7 downto 4) when ramedit_enable='1' else  cpu_d1;
	display_d0 <=  ram_dataout(3 downto 0) when ramedit_enable='1' else cpu_d0;
	
	-- Display multiplexers: toggle cpu display modes
	cpu_d7 <= dbg_qa(7 downto 4);
	cpu_d6 <= dbg_qa(3 downto 0);
	cpu_d5 <= dbg_qb(7 downto 4) when sw(14)='1' else "000"&cpu_ram_address(4 downto 4);
	cpu_d4 <= dbg_qb(3 downto 0) when sw(14)='1' else cpu_ram_address(3 downto 0);
	cpu_d3 <= dbg_qc(7 downto 4) when sw(14)='1' else dbg_instr(15 downto 12);
	cpu_d2 <= dbg_qc(3 downto 0) when sw(14)='1' else dbg_instr(11 downto 8);
	cpu_d1 <= dbg_qd(7 downto 4) when sw(14)='1' else dbg_instr(7 downto 4);
	cpu_d0 <= dbg_qd(3 downto 0) when sw(14)='1' else dbg_instr(3 downto 0);
	
	-- Instantiate the 7-segment display
	--
	comp1: entity work.hexto7seg port map(	clk=>clk,
																d7=>display_d7, 
																d6=>display_d6,
																d5=>display_d5,
																d4=>display_d4,
																d3=>display_d3,
																d2=>display_d2,
																d1=>display_d1,
																d0=>display_d0,
																blink=>display_blink,
																q=>seg,
																active=>an);

	--comp2: entity work.clkdiv generic map (N   => 26) port map(	clkin=>clk,clkout=>clkmain );
	--led(15)<=clkmain;
	clkmain <= not ramedit_enable and( (btnCd and not sw13d) or (clkslow and sw13d));
	
	
	
	
	-- Instantiate RAM
	-- RAM clock is either board clock in edit mode, or manual clock
	ramclk <= clk when sw15d='1' else clkmain;
	comp3: entity work.ram generic map(N=>5) port map(clk=>ramclk,address=>ram_address,data=>ram_datain,we=>ram_we,q=>ram_dataout);

	-- Instantiate the RAM editor
	comp_ramedit: 
	entity work.ramedit generic map(N=>5) port map(clk=>clk,rst=>reset,btnU=>btnUde,btnD=>btnDde,btnL=>btnLde,btnR=>btnRde,din=>sw,
								we=>ramedit_we,address=>ramedit_address,data=>ramedit_data);

	-- Multiplex the editor and the CPU to the RAM
	--
	ram_we <= ramedit_we when ramedit_enable='1' else cpu_ram_we;
	ram_address <= ramedit_address when ramedit_enable='1' else cpu_ram_address;
	ram_datain <= ramedit_data when ramedit_enable='1' else cpu_ram_datawr;
	


	-- Instantiate the CPU
	comp_cpu: 
	entity work.CPU	generic map(N=>5) 
							port map(clk=>clkmain,rst=>reset,ext_in=>sw(7 downto 0),ext_out=>led(7 downto 0),
										ram_we=>cpu_ram_we,ram_address=>cpu_ram_address,ram_datawr=>cpu_ram_datawr,ram_datard=>ram_dataout,
										dbg_qa=>dbg_qa,dbg_qb=>dbg_qb,dbg_qc=>dbg_qc,dbg_qd=>dbg_qd,
										dbg_instr=>dbg_instr,dbg_seq=>dbg_seq,dbg_flags=>dbg_flags);
			

end Structural;

