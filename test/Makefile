# !!! by default the top entity is called: top.v and the testbench: tb.v

top_dir := ../src/top
tb_dir := ../src/tb
rtl_dir := ../src/rtl

# source_library := control.v ram.v regfile.v rom.v
source_library := ram.v regfile.v rom.v
# every source prefixed by parent dir
source_library_path := $(addprefix $(rtl_dir)/, $(source_library))
simulation_library := $(tb_dir)/tb.v

# Timestamp file to track compilation
compiled_file := $(tb_dir)/my_design.vvp

$(info source_library_path: $(source_library_path))

all: run

compile: $(compiled_file)

$(compiled_file): $(source_library_path) $(simulation_library)
	@echo "Compiling design..."
	iverilog -o $(compiled_file) $(source_library_path) $(simulation_library)

run: $(compiled_file)
	@echo "Running simulation..."
	vvp $(compiled_file) -fst
	mv test.fst $(tb_dir)/test.fst
	@echo "User can run GTKwave."


.PHONY:
clean:
	@echo "CLEAN...."
	rm -f $(tb_dir)/*.vcd $(tb_dir)/*.fst 