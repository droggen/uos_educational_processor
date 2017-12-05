University of Sussex Educational Processor
(c) Daniel Roggen, 2014-2017

**Files**
CPU:
- cpu.vhd: CPU itself
- cpualu.vhd: ALU
- cpuregbank.vhd: register bank
- cpusequencer.vhd: fetchh/fetchl/exec cycles
Top-level:
- labcpu.vhd: top level instantiating CPU, ram, ram editor, and interfacing to 7-segments, leds, and switches
Support:
- ram.vhd: RAM 
- ramedit.vhd: RAM editor
- hexto7seg.vhd: hex to 7-seg decoder
- edgedetect.vhd: edge detector
- dffre.vhd: D flip-flop with reset and enable
- clkdiv.vhd: clock divider
- debounce.vhd: debouncer (borrowed from Altera Quartus)
- Nexys4_Master.xdc: constraint file
