
A working cpu essential elements:

- Program Counter (PC)
- Instruction Memory
- Control Unit
- Register File
- ALU
- Data Memory
- Sign Extender
- MUXes (for ALU inputs, write-back, next PC)


# myMIPS

in myMIPS the cited modules are developed as follows:

> PC: simple register, incremented by muxes handled by control.v
> Instruction Memory: rom.v, embedded ROM (implemented with built-in RAM blocks)
> Control Unit: control.v, FSM
> Register File: regfile.v, register bank
> ALU: alu.v
> RAM: ram.v, built-in RAM
> Sign Extender: not necessary
> MUXes: ...

