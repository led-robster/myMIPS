# !!! by default the top entity is called: top.v and the testbench: tb.v

top_dir := ../src/top
tb_dir := ../src/tb
rtl_dir := ../src/rtl
modelsim_dir = C:\Microsemi\Libero_SoC_v11.9\ModelsimPro\win32acoem

# source_library := control.v ram.v regfile.v rom.v
source_library := ram.v regfile.v rom.v alu.v carry_lookahead.v small_lookahead.v partial_FA.v
# every source prefixed by parent dir
source_library_path := $(addprefix $(rtl_dir)/, $(source_library))
simulation_library := $(tb_dir)/tb.v $(tb_dir)/tb_alu.sv

# Timestamp file to track compilation
compiled_file := $(tb_dir)/my_design.vvp

$(info source_library_path: $(source_library_path))

all: run

######################################################################################
#							ICARUS VERILOG + GTK

$(compiled_file): $(source_library_path) $(simulation_library)
	@echo "Compiling design..."
	iverilog -o $(compiled_file) $(source_library_path) $(simulation_library)

run: $(compiled_file)
	@echo "Running simulation..."
	vvp $(compiled_file) -fst
	mv test.fst $(tb_dir)/test.fst
	@echo "User can run GTKwave."


######################################################################################
#							MODELSIM

# moved in compile.do and clean.do


.PHONY:
clean:
	@echo "CLEAN...."
	rm -f $(tb_dir)/*.vcd $(tb_dir)/*.fst 

modelsim_clean:
	rm -r mips_design/ mips_verif/ library.cfg