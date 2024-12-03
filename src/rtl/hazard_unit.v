


module hazard_unit #(
    parameter RST_POL = 1'b0
) (
    input clk,
    input rst,
    // instruction
    input wire[15:0] instruction,
    input wire[15:0] alu_res,
    input wire[15:0] ma_res,
    output reg FORWARD_OP1_MUX,
    output reg FORWARD_OP2_MUX,
    output wire FORWARD_RAM_MUX,
    output reg[15:0] fw_op1,
    output reg[15:0] fw_op2,
    output wire[15:0] fw_ram_wdata
);

wire[3:0] opcode;
wire[2:0] rd;
wire[2:0] rs;
wire[2:0] rt;

assign FORWARD_RAM_MUX = forward_ram_wdata_mux_d;
assign 

assign opcode = instruction[15:12];
assign rd = instruction[5:3];
assign rs = instruction[11:9];
assign rt = instruction[8:6];


// hazard logic
always @(posedge clk or rst) begin
    if (rst==RST_POL) begin
        FORWARD_OP1_MUX <= 1'b0;
        FORWARD_OP2_MUX <= 1'b0;
        fw_op1 <= 0;
        fw_op2 <= 0;

    end else if (clk) begin

        FORWARD_OP1_MUX <= 1'b0;
        FORWARD_OP2_MUX <= 1'b0;
        //
        forward_regs <= {forward_regs[2:0], 3'b000};
        //
        forward_ram_wdata_mux <= 1'b0;
        forward_ram_wdata_mux_d <= forward_ram_wdata_mux;

        
        if (opcode==0) begin
        //RFORMAT
            // shift_register = [reg_cold|reg_hot]
            forward_regs <= {forward_regs[2:0], rd[2:0]};
            // HAZARD!
            if (rs==forward_regs[5:3]) begin
                // cold
                FORWARD_OP1_MUX <= 1'b1;
                fw_data_op1 <= ma_res;
            end else if (rs[2:0]==forward_regs[2:0]) begin
                FORWARD_OP1_MUX <= 1'b1;
                fw_data_op1 <= alu_res;
            end
            if (rt==forward_regs[5:3]) begin
                // cold
                FORWARD_OP2_MUX <= 1'b1;
                fw_data_op2 <= ma_res;
            end else if (rt==forward_regs[2:0]) begin
                // hot
                FORWARD_OP2_MUX <= 1'b1;
                fw_data_op2 <= alu_res;
            end
        end

        //IFORMAT [WIP]
        // addi + slti
        // shift_register = [reg_cold|reg_hot]
        if (opcode==1 or opcode==3) begin
            forward_regs <= {forward_regs[2:0], rs[2:0]};
            if (rt==forward_regs[5:3]) begin
                // cold
                FORWARD_OP2_MUX <= 1'b1;
                fw_data_op2 <= ma_res;
            end else if (rt==forward_regs[2:0]) begin
                // hot
                FORWARD_OP2_MUX <= 1'b1;
                fw_data_op2 <= alu_res;
            end
        end
        

        // lw
        if (opcode==4'b0100) begin
            // these instructions don't have a destination address, but one of their operands is a register
            if (rs==forward_regs[5:3]) begin
                // cold
                FORWARD_OP1_MUX <= 1'b1;
                fw_data_op1 <= ma_res;
            end else if (rs==forward_regs[2:0]) begin
                // hot
                FORWARD_OP1_MUX <= 1'b1;
                fw_data_op1 <= alu_res;
            end
        end

        // sw
        if (opcode==4'b0101) begin
            if (rs==forward_regs[5:3]) begin
                // cold
                FORWARD_OP1_MUX <= 1'b1;
                fw_data_op1 <= ma_res;
            end else if (rs==forward_regs[2:0]) begin
                // hot
                FORWARD_OP1_MUX <= 1'b1;
                fw_data_op1 <= alu_res;
            end
            if (rt==forward_regs[2:0]) begin
                forward_ram_wdata_mux <= 1'b1;
                // fw_ram_wdata
            end
        end

        // beq
        if (opcode==4'b0110) begin
            if (rs==forward_regs[5:3]) begin
                // cold
                FORWARD_OP1_MUX <= 1'b1;
                fw_data_op1 <= ma_res;
            end else if (rs==forward_regs[2:0]) begin
                // hot
                FORWARD_OP1_MUX <= 1'b1;
                fw_data_op1 <= alu_res;
            end
            if (rt==forward_regs[5:3]) begin
                // cold
                FORWARD_OP2_MUX <= 1'b1;
                fw_data_op2 <= ma_res;
            end else if (rt==forward_regs[2:0]) begin
                // hot
                FORWARD_OP2_MUX <= 1'b1;
                fw_data_op2 <= alu_res;
            end
        end


    end
end

assign fw_ram_wdata = (forward_ram_wdata_mux_d) ? ma_res : 0;
    
endmodule