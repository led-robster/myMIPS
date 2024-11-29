


module cpu #(
    parameter RST_POL = 1'b0
) (
    input clk,
    input rst
);

// PARAMETERS
parameter ROM_AWIDTH = 8;
parameter RAM_AWIDTH = 8;
parameter RAM_DWIDTH = 16;


// INTERNALS
    // rom port
reg rom_rd, rom_rd_d;
wire[ROM_AWIDTH-1:0] rom_raddr;
wire[15:0] rom_rdata;
    // regfile port
reg regfile_clear;
wire[3:0] addr_rs;
reg rd_rs;
wire[3:0] addr_rt;
reg rd_rt;
wire[3:0] addr_rd;
wire wr_rd;
wire[15:0] wdata_rd;
wire[15:0] rs, rt;
    // alu port
wire[15:0] alu_op1, alu_op2;
wire[2:0] alu_cmd;
wire[15:0] alu_res;
wire alu_eqbit, alu_ovF;
    // ram port
reg ram_rst;
wire ram_rd, ram_wr;
wire[RAM_AWIDTH-1:0] ram_raddr, ram_waddr;
wire[RAM_DWIDTH-1:0] ram_wdata;
wire[RAM_DWIDTH-1:0] ram_rdata;
    // control port
reg control_rst;
wire[15:0] control_rom_data;
wire control_rom_rd;
wire control_ram_rd;
wire control_ram_wr;
wire control_rd_rs;
wire control_rd_rt;
wire[2:0] control_addr_rs;
wire[2:0] control_addr_rt;
wire[2:0] control_addr_rd;
wire control_wr_rd;
wire[3:0] control_wb_waddr;
wire[2:0] control_shamt;
wire[5:0] control_immediate;
wire[2:0] control_alu_cmd;
wire mux_res, mux_op2, mux_pc, mux_shamt_imm, mux_beq, mux_jump, mux_wb, mux_silence, mux_save_pc;
// pipeline
reg mux_jump_d;
reg mux_jump_dd;
reg alu_eqbit_d;
reg alu_eqbit_dd;
reg mux_pc_d;
reg mux_pc_dd;
reg[5:0] offset_d;
reg[5:0] offset_dd;
reg[5:0] offset_ddd;
reg[5:0] imm_d;
reg[2:0] shamt_d;
reg wb_wr_d;
reg wb_wr_dd;
reg[15:0] rt_d;
reg[15:0] alu_res_d;
reg[15:0] alu_res_dd;
reg ram_rd_d;
reg ram_wr_d;
reg mux_res_d;
reg mux_res_dd;
reg[ROM_AWIDTH-1:0] PC_d;
reg[ROM_AWIDTH-1:0] PC_dd;
reg[ROM_AWIDTH-1:0] PC_ddd;
reg[2:0] addr_rd_d;  
reg[2:0] addr_rd_dd;
reg[2:0] addr_rd_ddd;
reg[3:0] wb_waddr_d;
reg[3:0] wb_waddr_dd;
reg mux_save_pc_d;
reg mux_save_pc_dd;
reg[15:0] save_pc_mux_out_d;
reg mux_wb_d; 
reg mux_wb_dd;
//
wire[ROM_AWIDTH-1:0] pc_incr_out;
wire silence_mux_out;
wire[3:0] wb_mux_out;
wire[5:0] shamt_imm_mux_out;
wire[15:0] op2_mux_out;
wire[15:0] res_mux_out;
wire[15:0] save_pc_mux_out;
wire[ROM_AWIDTH-1:0] jump_mux_out;
wire[15:0] beq_mux_out;
wire[1:0] pc_mux_out;


// ALLOCATIONS
reg unsigned[ROM_AWIDTH-1:0] PC;
rom #(.AWIDTH(ROM_AWIDTH)) rom(.clk(clk), .i_rd(rom_rd_d), .i_raddr(rom_raddr), .o_rdata(rom_rdata));
regfile #(.AWIDTH(4)) regfile(.clk(clk), .clear(regfile_clear), .addr_rs(addr_rs), .req_rs(rd_rs), .addr_rt(addr_rt), .req_rt(rd_rt), .addr_rd(addr_rd), .req_rd(wr_rd), .wdata(wdata_rd), .rs(rs), .rt(rt));
alu alu(.OP1(alu_op1), .OP2(alu_op2), .cmd(alu_cmd), .RES(alu_res), .eq_bit(alu_eqbit), .ovF(alu_ovF));
ram #(.AWIDTH(RAM_AWIDTH), .DWIDTH(RAM_DWIDTH)) ram(.clk(clk), .rst(rst), .i_rd(ram_rd), .i_wr(ram_wr), .i_raddr(ram_raddr), .i_waddr(ram_waddr), .i_wdata(ram_wdata), .o_rdata(ram_rdata));

control control(.clk(clk), .rst(rst), .ROM_data(control_rom_data), .rom_rd(control_rom_rd), .ram_rd(control_ram_rd), 
.ram_wr(control_ram_wr), .rd_rs(control_rd_rs), .rd_rt(control_rd_rt), .addr_rs(control_addr_rs), .addr_rt(control_addr_rt), .addr_rd(control_addr_rd), 
.wr_rd(control_wr_rd), .wb_waddr(control_wb_waddr), .shamt(control_shamt), .immediate(control_immediate), .ALU_cmd(control_alu_cmd), .RES_MUX(mux_res), .OP2_MUX(mux_op2), .PC_MUX(mux_pc), .SHAMT_IMM_MUX(mux_shamt_imm), 
.BEQ_MUX(mux_beq), .JUMP_MUX(mux_jump), .WB_MUX(mux_wb), .SILENCE_MUX(mux_silence), .SAVE_PC_MUX(mux_save_pc));



// MUXes
assign silence_mux_out = mux_silence ? 16'b0 : rom_rdata;
assign wb_mux_out = mux_wb_dd ? wb_waddr_dd : addr_rd_ddd; 
assign shamt_imm_mux_out = mux_shamt_imm ? shamt_d : imm_d;
assign op2_mux_out = mux_op2 ? shamt_imm_mux_out : rt;
assign res_mux_out = mux_res_dd ? alu_res_d : ram_rdata;
assign save_pc_mux_out = mux_save_pc_dd ? PC_ddd : res_mux_out;
assign beq_mux_out = (alu_eqbit_dd) ? (offset_ddd<<1 + 2) : pc_mux_out;
assign jump_mux_out = mux_jump_dd ? res_mux_out : pc_incr_out;
assign pc_mux_out = (mux_pc_dd) ? 2 : 0;

// combinatorial nets
assign pc_incr_out = PC + beq_mux_out;
assign rom_raddr = PC;
assign control_rom_data = rom_rdata;
    //alu
assign alu_op1 = rs;
assign alu_op2 = op2_mux_out;
assign alu_cmd = control_alu_cmd;
    //regfile
//assign regfile_clear = 1'b0; // inactive
assign wr_rd = wb_wr_dd;
assign wdata_rd = save_pc_mux_out_d;
assign addr_rs = control_addr_rs;
assign addr_rt = control_addr_rt;
assign addr_rd = wb_mux_out;

// sequential nets
// ((RST_POL && ext_rst) || (!RST_POL && !ext_rst))
always @(posedge clk or rst) begin
    if (rst==RST_POL) begin
        rom_rd <= 0;
        rom_rd_d <= 0;
        rd_rs <= 0;
        rd_rt <= 0;
    end else if(clk) begin
        rom_rd <= 1;
        rom_rd_d <= rom_rd;
        rd_rs <= 1;
        rd_rt <= 1;
    end
end

    // regfile_clear
always @(posedge clk or rst) begin
    if (rst==RST_POL) begin
        regfile_clear <= 1;
    end else if (clk) begin
        regfile_clear <= 0;
    end
end


// PC
always @(posedge clk or rst) begin
    if (rst==RST_POL) begin
        PC <= 0;
    end else if (clk) begin
        PC <= jump_mux_out;
    end
end

// pipelines
always @(posedge clk or rst) begin
    if (rst==RST_POL) begin
        mux_jump_d      <= 0;          
        mux_jump_dd     <= 0;    
        alu_eqbit_d     <= 0;    
        alu_eqbit_dd    <= 0;
        mux_pc_d        <= 0;    
        mux_pc_dd       <= 0;    
        offset_d        <= 0;    
        offset_dd       <= 0;    
        offset_ddd      <= 0;    
        imm_d           <= 0;
        shamt_d         <= 0;
        wb_wr_d         <= 0;
        wb_wr_dd        <= 0;    
        rt_d            <= 0;
        alu_res_d       <= 0;    
        alu_res_dd      <= 0;    
        ram_rd_d        <= 0;    
        ram_wr_d        <= 0;    
        mux_res_d       <= 0;    
        mux_res_dd      <= 0;    
        PC_d            <= 0;
        PC_dd           <= 0;
        PC_ddd          <= 0;
        addr_rd_d       <= 0;
        addr_rd_dd      <= 0;
        addr_rd_ddd     <= 0;
        wb_waddr_d      <= 0;
        wb_waddr_dd     <= 0;
        mux_save_pc_d   <= 0;
        mux_save_pc_dd  <= 0;
        save_pc_mux_out_d <= 0;
        mux_wb_d        <= 0;
        mux_wb_dd       <= 0;
    end else if (clk) begin

            mux_jump_d      <= mux_jump;
            mux_jump_dd     <= mux_jump_d;
            alu_eqbit_d     <= alu_eqbit;
            alu_eqbit_dd    <= alu_eqbit_d;
            mux_pc_d        <= mux_pc;
            mux_pc_dd       <= mux_pc_d;
            offset_d        <= control_immediate;
            offset_dd       <= offset_d;
            offset_ddd      <= offset_dd;
            imm_d           <= control_immediate;
            shamt_d         <= control_shamt;
            wb_wr_d         <= control_wr_rd;
            wb_wr_dd        <= wb_wr_d;
            rt_d            <= rt;
            alu_res_d       <= alu_res;
            alu_res_dd      <= alu_res_d;
            ram_rd_d        <= control_ram_rd;
            ram_wr_d        <= control_ram_wr;
            mux_res_d       <= mux_res;
            mux_res_dd      <= mux_res_d;
            PC_d            <= PC;
            PC_dd           <= PC_d;
            PC_ddd          <= PC_dd;
            addr_rd_d       <= control_addr_rd;
            addr_rd_dd      <= addr_rd_d;
            addr_rd_ddd     <= addr_rd_dd;
            wb_waddr_d      <= control_wb_waddr;
            wb_waddr_dd     <= wb_waddr_d;
            mux_save_pc_d   <= mux_save_pc;
            mux_save_pc_dd  <= mux_save_pc_d;
            save_pc_mux_out_d <= save_pc_mux_out;
            mux_wb_d        <= mux_wb;
            mux_wb_dd       <= mux_wb_d;
    end
    
end
    
endmodule