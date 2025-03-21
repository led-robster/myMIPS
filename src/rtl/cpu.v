


module cpu #(
    parameter RST_POL = 1'b0,
    parameter DBG = 0
) (
    input clk,
    input rst,
    // debug ITF
        //regfile
    output DBG_rd_rs,
    output DBG_rd_rt,
    output DBG_wr_rd,
    output[3:0] DBG_addr_rs,
    output[3:0] DBG_addr_rt,
    output[3:0] DBG_addr_rd,
    output[15:0] DBG_wdata_rd,
    output[15:0] DBG_rs,
    output[15:0] DBG_rt,
        // PC
    output[7:0] DBG_pc,
        // RAM
    output DBG_ram_rd,
    output DBG_ram_wr,
    output[7:0] DBG_ram_raddr,
    output[7:0] DBG_ram_waddr,
    output[15:0] DBG_ram_wdata,
    output[15:0] DBG_ram_rdata,
    output[15:0] INSTR_D
);

// CONSTANTS
// =========================================================
parameter ROM_AWIDTH = 8;
parameter RAM_AWIDTH = 8;
parameter RAM_DWIDTH = 16;

// =========================================================
// DECLARATIONS

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
wire[11:0] control_jimmediate;
wire[11:0] mux_jump_immediate_out;
wire[2:0] control_alu_cmd;
// MULTIPLEXERS
wire mux_res, mux_op2, mux_pc, mux_shamt_imm, mux_beq, mux_jump, mux_wb, mux_silence, mux_save_pc, mux_jump_immediate;
wire[1:0] mux_forward_op1, mux_forward_op2;
wire mux_forward_ram_wdata, mux_forward_ram_waddr;
reg mux_forward_ram_wdata_d, mux_forward_ram_waddr_d;
wire[15:0] fw_op1, fw_op2, fw_ram_wdata;
reg mux_silence_d;

// pipeline signals
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
reg[15:0] res_mux_out_d;
//
wire[ROM_AWIDTH-1:0] pc_incr_out;
wire[15:0] silence_mux_out;
wire[3:0] wb_mux_out;
wire[11:0] shamt_imm_mux_out;
wire[15:0] op2_mux_out;
wire[15:0] res_mux_out;
wire[15:0] save_pc_mux_out;
wire[ROM_AWIDTH-1:0] jump_mux_out;
wire[15:0] beq_mux_out;
wire[1:0] pc_mux_out;
reg[15:0] rs_sampled;
reg[15:0] rt_sampled;


// ALLOCATIONS
// PC
reg unsigned[ROM_AWIDTH-1:0] PC;
// internal ROM
rom #(.AWIDTH(ROM_AWIDTH)) rom(.clk(clk), .i_rd(rom_rd_d), .i_raddr(rom_raddr), .o_rdata(rom_rdata));
// REGFILE
regfile #(.AWIDTH(4)) regfile(.clk(clk), .clear(regfile_clear), .addr_rs(addr_rs), .req_rs(rd_rs), .addr_rt(addr_rt), 
.req_rt(rd_rt), .addr_rd(addr_rd), .req_rd(wr_rd), .wdata(wdata_rd), .rs(rs), .rt(rt));
// ALU
alu alu(.OP1(alu_op1), .OP2(alu_op2), .cmd(alu_cmd), .RES(alu_res), .eq_bit(alu_eqbit), .ovF(alu_ovF));
// RAM internal
ram #(.AWIDTH(RAM_AWIDTH), .DWIDTH(RAM_DWIDTH)) ram(.clk(clk), .rst(rst), .i_rd(ram_rd), .i_wr(ram_wr), 
.i_raddr(ram_raddr), .i_waddr(ram_waddr), .i_wdata(ram_wdata), .o_rdata(ram_rdata));
// CONTROL
control #(.RST_POL(RST_POL)) control(.clk(clk), .rst(rst), .ROM_data(control_rom_data), .rom_rd(control_rom_rd), .ram_rd(control_ram_rd), 
.ram_wr(control_ram_wr), .rd_rs(control_rd_rs), .rd_rt(control_rd_rt), .addr_rs(control_addr_rs), .addr_rt(control_addr_rt), .addr_rd(control_addr_rd), 
.wr_rd(control_wr_rd), .wb_waddr(control_wb_waddr), .shamt(control_shamt), .immediate(control_immediate), .jump_immediate(control_jimmediate), .ALU_cmd(control_alu_cmd), .RES_MUX(mux_res), 
.OP2_MUX(mux_op2), .PC_MUX(mux_pc), .SHAMT_IMM_MUX(mux_shamt_imm), 
.BEQ_MUX(mux_beq), .JUMP_MUX(mux_jump), .WB_MUX(mux_wb), .SILENCE_MUX(mux_silence), .SAVE_PC_MUX(mux_save_pc), .JUMP_IMMEDIATE_MUX(mux_jump_immediate));
// HAZARD UNIT
hazard_unit #(.RST_POL(RST_POL)) hazard_unit(.clk(clk), .rst(rst), .instruction(rom_rdata), .alu_res(alu_res_d), .ma_res(mux_res_d), 
.FORWARD_OP1_MUX(mux_forward_op1), .FORWARD_OP2_MUX(mux_forward_op2),
.FORWARD_RAM_WADDR_MUX(mux_forward_ram_waddr), .FORWARD_RAM_WDATA_MUX(mux_forward_ram_wdata), .fw_op1(fw_op1), .fw_op2(fw_op2), .fw_ram_wdata(fw_ram_wdata));


// DBG DEFINITIONS
assign DBG_rd_rs = rd_rs;
assign DBG_rd_rt = rd_rt;
assign DBG_wr_rd = wr_rd;
assign DBG_addr_rs = addr_rs;
assign DBG_addr_rt = addr_rt;
assign DBG_addr_rd = addr_rd;
assign DBG_wdata_rd = wdata_rd;
assign DBG_rs = rs;
assign DBG_rt = rt;
assign DBG_pc = PC;
assign INSTR_D = control_rom_data;

// SIGNAL ASSIGNMENTS
// =========================================================

// RAM
assign ram_rd = ram_rd_d;
assign ram_raddr = alu_res_d;
assign ram_wr = ram_wr_d;
assign ram_waddr = mux_forward_ram_waddr_d ? res_mux_out  : alu_res_d;

reg startup_screening;

// MUXes
assign silence_mux_out = (mux_silence | mux_silence_d) ? 16'b0 : rom_rdata;
assign wb_mux_out = mux_wb_dd ? wb_waddr_dd : addr_rd_ddd;
assign shamt_imm_mux_out = mux_shamt_imm ? shamt_d : mux_jump_immediate_out;
assign mux_jump_immediate_out = mux_jump_immediate ? control_jimmediate : imm_d;
assign op2_mux_out = mux_op2 ? shamt_imm_mux_out : rt;
assign res_mux_out = mux_res_dd ? alu_res_dd: ram_rdata;
assign save_pc_mux_out = mux_save_pc_dd ? PC_ddd : res_mux_out;
assign beq_mux_out = (alu_eqbit_dd) ? (offset_ddd + 1) : pc_mux_out;
assign jump_mux_out = mux_jump_dd ? res_mux_out : pc_incr_out;
assign pc_mux_out = (mux_pc & startup_screening) ? 1 : 0;

always @(posedge clk or rst) begin
    if (rst==RST_POL) begin
        startup_screening <= 1'b0;
    end else if (clk) begin
        if (rom_rd==1'b1) begin
            startup_screening <= 1'b1;
        end
    end

end

// combinatorial nets
assign pc_incr_out = PC + beq_mux_out;
assign rom_raddr = PC;
assign control_rom_data = silence_mux_out;
    //alu
assign alu_op1 = (mux_forward_op1[1]) ? res_mux_out : (mux_forward_op1[0] ? alu_res_d : rs);
assign alu_op2 = (mux_forward_op2[1]) ? res_mux_out : (mux_forward_op2[0] ? alu_res_d : op2_mux_out);
assign alu_cmd = control_alu_cmd;
    //regfile
//assign regfile_clear = 1'b0; // inactive
assign wr_rd = wb_wr_dd;
assign wdata_rd = save_pc_mux_out;
assign addr_rs = control_addr_rs;
assign addr_rt = control_addr_rt;
assign addr_rd = wb_mux_out;
    // ram
assign ram_wdata = mux_forward_ram_wdata_d ? res_mux_out : rt_d ;
// assign ram_waddr = mux_forward_ram_waddr_dd ? res_mux_out  : alu_res_d;

always @(posedge clk ) begin
    rs_sampled <= rs;
end

always @(posedge clk ) begin
    rt_sampled <= rt;
end

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
        res_mux_out_d   <= 0;
        mux_silence_d   <= 0;
        mux_forward_ram_wdata_d <= 0;
        mux_forward_ram_waddr_d <= 0;

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
            res_mux_out_d   <= res_mux_out;
            mux_silence_d   <= mux_silence;
            mux_forward_ram_wdata_d <= mux_forward_ram_wdata;
            mux_forward_ram_waddr_d <= mux_forward_ram_waddr;
    
    end
    
end
    
endmodule