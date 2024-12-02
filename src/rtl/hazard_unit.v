


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
    output reg[15:0] fw_op1,
    output reg[15:0] fw_op2
);

wire[3:0] opcode;
wire[2:0] rd;
wire[2:0] rs;

assign opcode;
assign rd;
assign rs;


// hazard logic
always @(posedge clk or rst) begin
    if (rst==RST_POL) begin
        FORWARD_OP1_MUX <= 1'b0;
        FORWARD_OP2_MUX <= 1'b0;
        fw_op1 <= 0;
        fw_op2 <= 0;
    end else if (clk) begin
        
        //RFORMAT [WIP]
        // shift_register = [reg_cold|reg_hot]
        forward_regs <= {forward_regs[2:0], addr_rd[2:0]};
        // HAZARD!
        if (addr_rs[2:0]==forward_regs[5:3]) begin
            // cold
            FORWARD_OP1_MUX <= 1'b1;
            fw_data_op1 <= 
        end else if (addr_rs[2:0]==forward_regs[2:0]) begin
            FORWARD_OP1_MUX <= 1'b1;
        end

        //IFORMAT [WIP]
        // shift_register = [reg_cold|reg_hot]
        forward_regs <= {forward_regs[2:0], addr_rs[2:0]};



    end
end
    
endmodule