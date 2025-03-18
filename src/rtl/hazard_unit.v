


module hazard_unit #(
    parameter RST_POL = 1'b0
) (
    input clk,
    input rst,
    // instruction
    input wire[15:0] instruction,
    input wire[15:0] alu_res,
    input wire[15:0] ma_res,
    output reg[1:0] FORWARD_OP1_MUX,
    output reg[1:0] FORWARD_OP2_MUX,
    output reg FORWARD_RAM_WADDR_MUX,
    output reg FORWARD_RAM_WDATA_MUX,
    output wire FORWARD_RAM_MUX,
    output reg[15:0] fw_op1,
    output reg[15:0] fw_op2,
    output wire[15:0] fw_ram_wdata
);

wire[3:0] opcode;
wire[2:0] rd;
wire[2:0] rs;
wire[2:0] rt;
reg forward_ram_wdata_mux, forward_ram_wdata_mux_d;
reg[5:0] forward_regs;

assign FORWARD_RAM_MUX = forward_ram_wdata_mux_d;

assign opcode = instruction[15:12];
assign rd = instruction[5:3];
assign rs = instruction[11:9];
assign rt = instruction[8:6];

// always @(*) begin
//     if (opcode==0) begin
//         if (rs==forward_regs[5:3]) begin
//             // cold
//             FORWARD_OP1_MUX <= 2;
//         end
//         if (rs==forward_regs[2:0]) begin
//             FORWARD_OP1_MUX <= 1;
//         end
//         if (rs!=forward_regs[5:3] & rs!=forward_regs[2:0]) begin
//             FORWARD_OP1_MUX <= 0;
//         end
//         if (rt==forward_regs[5:3]) begin
//             // cold
//             FORWARD_OP2_MUX <= 2;
//         end
//         if (rt==forward_regs[2:0]) begin
//             // hot
//             FORWARD_OP2_MUX <= 1;
//         end
//         if (rt!=forward_regs[5:3] & rt!=forward_regs[2:0]) begin
//             FORWARD_OP2_MUX <= 0;
//         end
//     end

//     if (opcode==1 || opcode==3) begin
//         if (rt==forward_regs[5:3]) begin
//             // cold
//             FORWARD_OP2_MUX <= 2;
//         end
//         if (rt==forward_regs[2:0]) begin
//             // hot
//             FORWARD_OP2_MUX <= 1;
//         end
//         if (rt!=forward_regs[5:3] & rt!=forward_regs[2:0]) begin
//             FORWARD_OP2_MUX <= 0;            
//         end
//     end
// end


// hazard logic
always @(posedge clk or rst) begin
    if (rst==RST_POL) begin
        FORWARD_OP1_MUX <= 0;
        FORWARD_OP2_MUX <= 0;
        fw_op1 <= 0;
        fw_op2 <= 0;
        forward_regs <= 0;

    end else if (clk) begin

        FORWARD_OP1_MUX <= 0;
        FORWARD_OP2_MUX <= 0;
        //
        forward_regs <= {forward_regs[2:0], 3'b000};
        //
        forward_ram_wdata_mux <= 1'b0;
        forward_ram_wdata_mux_d <= forward_ram_wdata_mux;
        //
        FORWARD_RAM_WADDR_MUX <= 0;
        FORWARD_RAM_WDATA_MUX <= 0;

        
        if (opcode==0) begin
        //RFORMAT
            // shift_register = [reg_cold|reg_hot]
            forward_regs <= {forward_regs[2:0], rd[2:0]};
            // HAZARD!
            if (rs==forward_regs[5:3]) begin
                // cold
                FORWARD_OP1_MUX <= 2;
            end
            if (rs==forward_regs[2:0]) begin
                FORWARD_OP1_MUX <= 1;
            end
            if (rt==forward_regs[5:3]) begin
                // cold
                FORWARD_OP2_MUX <= 2;
            end
            if (rt==forward_regs[2:0]) begin
                // hot
                FORWARD_OP2_MUX <= 1;
            end
        end

        //IFORMAT [WIP]
        // addi + slti
        // shift_register = [reg_cold|reg_hot]
        if (opcode==1 || opcode==3) begin
            forward_regs <= {forward_regs[2:0], rt[2:0]};
            if (rs==forward_regs[5:3]) begin
                // cold
                FORWARD_OP2_MUX <= 2;
            end
            if (rs==forward_regs[2:0]) begin
                // hot
                FORWARD_OP2_MUX <= 1;
            end
        end
        

        // lw
        if (opcode==4'b0100) begin
            // destination address, and one of their operands is a register
            forward_regs <= {forward_regs[2:0], rt[2:0]};
            if (rs==forward_regs[5:3]) begin
                // cold
                FORWARD_OP1_MUX <= 2;
            end
            if (rs==forward_regs[2:0]) begin
                // hot
                FORWARD_OP1_MUX <= 1;
            end
        end

        // sw
        if (opcode==4'b0101) begin
            // both operands are registers
            // Store rt in RAM[rs+offset]
            // if (rs==forward_regs[5:3]) begin
            //     // cold
            //     FORWARD_RAM_MUX <= 2;
            // end
            if (rs==forward_regs[2:0]) begin
                // ONLY hot
                FORWARD_RAM_WADDR_MUX <= 1;
            end
            // if (rt==forward_regs[5:3]) begin
            //     // cold
            //     FORWARD_RAM_MUX <= 2;
            // end
            if (rt==forward_regs[2:0]) begin
                // ONLY hot
                FORWARD_RAM_WDATA_MUX <= 1;
            end
        end

        // beq
        // if (opcode==4'b0110) begin
        //     if (rs==forward_regs[5:3]) begin
        //         // cold
        //         FORWARD_OP1_MUX <= 2;
        //     end
        //      if (rs==forward_regs[2:0]) begin
        //         // hot
        //         FORWARD_OP1_MUX <= 1;
        //     end
        //     if (rt==forward_regs[5:3]) begin
        //         // cold
        //         FORWARD_OP2_MUX <= 2;
        //     end
        //     if (rt==forward_regs[2:0]) begin
        //         // hot
        //         FORWARD_OP2_MUX <= 1;
        //     end
        // end


    end
end

assign fw_ram_wdata = (forward_ram_wdata_mux_d) ? ma_res : 0;
    
endmodule