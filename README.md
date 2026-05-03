# 8086 Microprocessor projects

A collection of 8086/x86 assembly and hardware projects developed in Proteus and MASM/NASM.


## Projects

###  [8086-Memory-Interfacing-and-Address-Decoding](./8086-Memory-Interfacing-and-Address-Decoding)
Full memory mapping and address decoding circuit for an 8086-based system simulated in Proteus.
- 64 KB ROM block using 4× 27C128 EPROMs
- 64 KB RAM block using 2× 62256 SRAMs
- Even/odd bank selection via 74LS138 decoders and logic gates
- FAR subroutine calls verified through RAM content inspection

###  [8086-PIC-USART-Integrated-System](./8086-PIC-USART-Integrated-System)
Integrated system combining the 8086 microprocessor with a PIC microcontroller over USART serial communication.

###  [ADC-DAC-Interfacing](./ADC-DAC-Interfacing)
ADC and DAC interfacing with the 8086. Demonstrates analog signal acquisition and output through memory-mapped or I/O-mapped peripherals.

###  [Mean-squared-error](./Mean-squared-error)
Assembly implementation of the Mean Squared Error (MSE) calculation on a dataset stored in memory.

###  [Peripheral-Interfacing-8255](./Peripheral%20Interfacing%208255)
Interfacing the Intel 8255 Programmable Peripheral Interface (PPI) with the 8086 for parallel I/O operations.

###  [Prime-Factor](./Prime-Factor)
8086 assembly program that computes the prime factors of a given integer.

###  [Recursive-Binary-Search](./Recursive-Binary-Search)
Recursive binary search algorithm implemented in 8086 assembly language.

###  [Serial-Communication-USART](./Serial-Communication-USART)
Serial communication between devices using the USART protocol, implemented and simulated with the 8086.

###  [TempConv](./TempConv)
Temperature conversion program (Celsius ↔ Fahrenheit) written in 8086 assembly.

###  [x86-C-ASM-Integration](./x86-C-ASM-Integration)
Demonstrates calling 8086/x86 assembly routines from C++ code, covering calling conventions and register management.


## Tools & Environment

| Tool | Purpose |
|------|---------|
| Proteus 8 Professional | Circuit simulation |
| MASM / NASM | Assembly compilation |
| Visual Studio / GCC | C++ integration projects |
| EMU8086 | Assembly emulation |


