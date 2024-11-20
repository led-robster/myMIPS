# myMIPS

Project to understand how processors are built.  
Based on MIPS instruction set.

## GOAL 👟💨⚽

[] run on FPGA  
[] integrate in a system with IO, display, sound, ...  

## PLATFORM
source: Verilog & SystemVerilog
### BUILD1
compilation: `iverilog`  
linker + simulation: `iverilog`  
inspection: `gtkwave`  

### BUILD 2
compilation: `modelsim` (**vlog**)
linker + simulation: `modelsim` (**vsim**)  
inspection: `modelsim`\`gtkwave`  

### VERSIONS

Modelsim: 10.5c
UVM library:
GTKWave:
iverilog:

## FUTURE 🔮

> RISC-v  
> advanced features: fpu, coprocessors, dma engines, branch prediction, privileges,...  
> linux on risc-v  
> run minimal programs  
