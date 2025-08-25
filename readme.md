# myMIPS

Project to understand how processors are built.  
Based on MIPS instruction set.
16-bit 5-stage CPU core. (16-b registers, 16-b instructions)
Includes Hazard Unit for *forwarding* data hazards.

## FEATURES

[X] Data Hazard Unit (forwarding strategy)  
[X] Control Hazard Unit (stalling strategy)  
[] Interrupt Center  
[] FPAu  

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
inspection: `modelsim` or `gtkwave`    

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

## TODO

[] test regfile, specifically write in phase1 and read in phase2  
[] ISA green card  
[] case[0011] : check why the instruction is extended for 2 ccs after jump instruction  