


module top(
    input clk,
    input ext_rst,
);

// PARAMETERS
parameter ROM_AWIDTH = 8;
parameter RAM_AWIDTH = 8;
parameter RAM_DWIDTH = 16;


// INTERNALS
wire rom_rd;
wire[ROM_AWIDTH-1:0] rom_raddr;
wire[15:0] rom_rdata;
//--
reg regfile_clear;
wire[3:0] addr_rs;
wire rd_rs;
wire[3:0] addr_rt;
wire rd_rt;
wire[3:0] addr_rd;
wire wr_rd;
wire[15:0] wdata_rd;
wire[15:0] rs, rt;
//--
wire[15:0] alu_op1, alu_op2;
wire[2:0] alu_cmd;
wire[15:0] alu_res;
wire alu_eqbit, alu_ovF;
//--
reg ram_rst;
wire ram_rd, ram_wr;
wire[RAM_AWIDTH-1:0] ram_raddr, ram_waddr;
wire[RAM_DWIDTH-1:0] ram_wdata;
wire[RAM_DWIDTH-1:0] ram_rdata;
//--
reg control_rst;
wire[15:0] control_rom_data;
wire control_rom_rd;
wire control_ram_rd;
wire control_ram_wr;
wire control_rd_rs;
wire control_rd_rt;
wire[3:0] control_addr_rs;
wire[3:0] control_addr_rt;
wire control_wr_rd;
wire[2:0] control_alu_cmd;
wire mux_res, mux_op2, mux_pc, mux_shamt_imm, mux_beq, mux_jump, mux_wb, mux_silence, mux_save_pc;


// ALLOCATIONS
reg[ROM_AWIDTH-1:0] PC;
rom #(.AWIDTH(ROM_AWIDTH)) rom(.clk(clk), .i_rd(), .i_raddr(), .o_rdata());
regfile #(.AWIDTH(4)) regfile(.clk(clk), .clear(regfile_clear), .addr_rs(addr_rs), .req_rs(rd_rs), .addr_rt(addr_rt), .req_rt(rd_rt), .addr_rd(addr_rd), .req_rd(wr_rd), .wdata(wdata_rd), .rs(rs), .rt(rt));
alu alu(.OP1(alu_op1), .OP2(alu_op2), .cmd(alu_cmd), .RES(alu_res), .eq_bit(alu_eqbit), .ovF(alu_ovF));
ram #(.AWIDTH(RAM_AWIDTH), .DWIDTH(RAM_DWIDTH)) ram(.clk(clk), .rst(ram_rst), .i_rd(ram_rd), .i_wr(ram_wr), .i_raddr(ram_raddr), .i_waddr(ram_waddr), .i_wdata(ram_wdata), .o_rdata(ram_rdata));

control control(.clk(clk), .rst(control_rst), .ROM_data(control_rom_data), .rom_rd(control_rom_rd), .ram_rd(control_ram_rd), 
.ram_wr(control_ram_wr), .rd_rs(control_rd_rs), .rd_rt(control_rd_rt), .addr_rs(control_addr_rs), .addr_rt(control_addr_rt), 
.wr_rd(control_wr_rd), .ALU_cmd(control_alu_cmd), .RES_MUX(mux_res), .OP2_MUX(mux_op2), .PC_MUX(mux_pc), .SHAMT_IMM_MUX(mux_shamt_imm), 
.BEQ_MUX(mux_beq), .JUMP_MUX(mux_jump), .WB_MUX(mux_wb), .SILENCE_MUX(mux_silence), .SAVE_PC_MUX(mux_save_pc));


// PIPELINE CHAINS

    
endmodule