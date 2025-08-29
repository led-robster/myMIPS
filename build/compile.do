# Script: compile.do
# Usage: 
# Description: 
# Author: 

#include <tcl.h> 


# PARSE POSITIONAL ARGS
set TB_ENTITY $1

set EXEC_BATCH $2


# clean before compiling 
source clean.do

# USER, desired tb/top
set top_unit "mips_verif.$TB_ENTITY"

# set source dirs
set rtl_dir "../src/rtl"
set top_dir "../src/top"
set tb_dir "../src/tb"

# compose source_library (requires USER handling)
# DO THIS: if you want to compile a restricte set of design units
#
# set source_library {ram.v regfile.v rom.v alu.v carry_lookahead.v small_lookahead.v partial_FA.v}
# set source_library_path {}
# foreach file $source_library {
#     lappend source_library_path "$rtl_dir/$file"
# }
# DO THIS: if you want to include all design file sin src/rtl
#
set source_library_path [glob -directory "../src/rtl/" *.v *.sv]
# USER
set tb_library "../src/tb/tb_debouncer.sv ../src/tb/tb_ram.sv ../src/tb/tb_rom.sv ../src/tb/tb_alu.sv ../src/tb/tb_cpu.v ../src/tb/tb_regfile.v"

# create library for modelsim
vlib mips_design
vlib mips_verif

# compile design library (vmap is automatically resolved)
foreach file $source_library_path {
    puts "Compiling: $file"; # Optional: Print the file being compiled
    vlog -work mips_design $file; # Compile the file into the mips_design library
}

# compile top
vlog -work mips_design ../src/top/top.v

# compile verif library (vmap is automatically resolved)
vlog -work mips_verif ../src/tb/tb.v -y "C:/Users/fea/Documents/1800.2-2020.3.1/src" -y "C:/Users/fea/Documents/1800.2-2020.3.1/src/base" -y "C:/Users/fea/Documents/1800.2-2020.3.1/src/comps" -y "C:/Users/fea/Documents/1800.2-2020.3.1/src/dap" -y "C:/Users/fea/Documents/1800.2-2020.3.1/src/dpi" -y "C:/Users/fea/Documents/1800.2-2020.3.1/src/macros" -y "C:/Users/fea/Documents/1800.2-2020.3.1/src/reg" -y "C:/Users/fea/Documents/1800.2-2020.3.1/src/seq" -y "C:/Users/fea/Documents/1800.2-2020.3.1/src/tlm1" -y "C:/Users/fea/Documents/1800.2-2020.3.1/src/tlm2"
foreach file $tb_library {
    puts "Compiling: $file"; # Optional: Print the file being compiled
    vlog -work mips_verif $file; # Compile the file into the mips_design library
}

if {$EXEC_BATCH} {
    exit
}

# USER, simulate top_unit and link -L libraries
vsim -L mips_design -L mips_verif $top_unit

# USER, load ROM memory
#mem load -infile ../src/mem/program.mem -format bin /$TB_ENTITY/top_inst/cpu_inst/rom
mem load -infile ../src/mem/program.mem -format bin /$TB_ENTITY/cpu_inst/rom

# USER, load RAM memory
#mem load -infile ../src/mem/data.mem -format bin /$TB_ENTITY/top_inst/cpu_inst/ram
mem load -infile ../src/mem/data.mem -format bin /$TB_ENTITY/cpu_inst/ram


# VCD GENERATION, !!!DEPRECATED , vcd generation happens in testbenches .v
# generate vcd for external consultance
# vcd file test_vcd.vcd
# vcd add -r /tb_ram/*
# vcd add -r *

# add wave -rec sim:/*


# RUN SIMULATION
run -all

#quit -sim