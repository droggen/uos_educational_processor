# uos_educational_processor
University of Sussex Educational Processor

Processor:
* 8-bit, 4 register processor
* Von Neumann architecture
* 3 clock cycle per instruction
* 16-bit instruction set (inspired by x86 ISA)
* Direct, indirect, immediate, register addressing
* Customizable instructions
* External memory bus (for program/data)
* I/O interface (as in microcontrollers)
* Implemented in VHDL
* Synthesizable

Top level system:
* Designed for Nexys 4
* Instantiates a processor, RAM and RAM editor
* Allows to edit the RAM using the Nexys 5 switches, push buttons and 7-segment display
* Allows to visualize the CPU registers (RA-RD), memory bus address and instruction register on the 7-segment display, as well as ALU flags and sequencing state on the LEDs
* Interfaces the CPU output port to the Nexys 4 LEDs
* Interfaces the CPU input port to the Nexys 4 switches


All the content, including VHDL, lecture material (powerpoint), images and others is licensed under LGPL 2.1.

Original author: Daniel Roggen.


