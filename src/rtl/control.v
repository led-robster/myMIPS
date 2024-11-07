

module control (
    input clk,
    input rst,
    input[15:0] ROM_data,
    output reg req_rd,
    output reg ram_rd,
    output reg ram_wr,
    output reg req_rs,
    output reg req_rt,
    output reg[2:0] ALU_cmd,
    output reg RES_MUX,
    output reg OP2_MUX,
    output reg[1:0] PC_MUX
);

reg state;
parameter [3:0] IDLE                = 4'b0000,
                INSTRUCTION_FETCH   = 4'b0001,
                INSTRUCTION_DECODE  = 4'b0010,
                EXECUTE             = 4'b0100,
                MEMORY_ACCESS       = 4'b1000,
                WRITE_BACK          = 4'b1111;


wire[2:0] Fcode;
wire[3:0] opcode;
wire[2:0] rs,rt,rd;
wire[5:0] immediate;
wire[2:0] shamt;
wire[5:0] offset;
wire[11:0] address;

// internals
reg[15:0] instruction;
reg jump, jump_d, jump_dd;
reg memory_op, memory_op_d, memory_op_dd;
reg[15:0] 


assign Fcode = instruction[2:0];
assign opcode = instruction[15:12];
assign rs = instruction[11:9];
assign rt = instruction[8:6];
assign rd = instruction[5:3];
assign immediate = instruction[5:0];
assign shamt = instruction[5:3];
assign offset = instruction[5:0];
assign address = instruction[11:0];


always @(posedge clk or negedge rst) begin
    if (!rst) begin
        state <= IDLE;
        instruction <= 0;
        jump <= 0;
        memory_op <= 1'b0;
    end else begin

        // defaults/triggers
        req_rs  <= 1'b0;
        req_rd  <= 1'b0;
        req_rt  <= 1'b0;
        ram_rd  <= 1'b0;
        ram_wr  <= 1'b0;
        jump    <= 1'b0;
        memory_op <= 1'b0;

        // delays
        jump_d <= jump;
        jump_dd <= jump_d;
        memory_op_d <= memory_op;
        memory_op_dd <= memory_op_d;

        

        case (state)
            IDLE:
                state <= INSTRUCTION_FETCH;
            
            INSTRUCTION_FETCH:
                instruction <= ROM_data;
                state <= INSTRUCTION_DECODE;

            INSTRUCTION_DECODE:
                if (opcode==0) begin
                    // R-format
                    if (Fcode==0) begin
                        // add
                        req_rs <= 1'b1;
                        req_rt <= 1'b1;
                        OP2_MUX <= 1'b0;
                        //
                        ALU_cmd <= 3'b000;
                    end else if (Fcode==1) begin
                        // subtract
                        req_rs <= 1'b1;
                        req_rt <= 1'b1;
                        OP2_MUX <= 1'b0;
                        //
                        ALU_cmd <= 3'b001;
                    end else if (Fcode==2) begin
                        // and
                        req_rs <= 1'b1;
                        req_rt <= 1'b1;
                        OP2_MUX <= 1'b0;
                        //
                        ALU_cmd <= 3'b101;
                    end else if (Fcode==3) begin
                        // or
                        req_rs <= 1'b1;
                        req_rt <= 1'b1;
                        OP2_MUX <= 1'b0;
                        //
                        ALU_cmd <= 3'b110;
                    end else if (Fcode==4) begin
                        // slt
                        req_rs <= 1'b1;
                        req_rt <= 1'b1;
                        OP2_MUX <= 1'b0;
                        //
                        ALU_cmd <= 3'b011;
                    end else if (Fcode==5) begin
                        // sll
                        req_rs <= 1'b1;
                        OP2_MUX <= 1'b1;
                        //
                        ALU_cmd <= 3'b010;
                    end else if (Fcode==6) begin
                        // srl
                        req_rs <= 1'b1;
                        OP2_MUX <= 1'b1;
                        //
                        ALU_cmd <= 3'b010;
                    end else if (Fcode==7) begin
                        // jr
                        req_rs <= 1'b1;
                        req_rt <= 1'b0; // require $0
                        OP2_MUX <= 1'b0;
                        // add operation
                        ALU_cmd <= 3'b000;
                        //
                        jump <= 1'b1;
                    end
                end else if (opcode==4'b0001) begin
                    // addi
                    req_rs <= 1'b1;
                    OP2_MUX <= 1'b1;
                    //
                    ALU_cmd <= 1'b0;
                end else if (opcode==4'b0011) begin
                    // slti
                    req_rs <= 1'b1;
                    OP2_MUX <= 1'b1;
                    // >
                    ALU_cmd <= 3'b011;
                end else if (opcode==4'b0100) begin
                    // lw
                    req_rs <= 1'b1;
                    OP2_MUX <= 1'b1;
                    // +
                    ALU_cmd <= 3'b000;
                    //
                    memory_op <= 1'b1;
                end else if (opcode==4'b0101) begin
                    // sw
                    req_rs 
                end else if (opcode==4'b0110) begin
                    // beq

                end else if (opcode==4'b0111) begin
                    // j

                end else if (opcode==4'b1000) begin
                    // jal

                end
                //
                state <= EXECUTE;

            
            EXECUTE:
                //
                state <= MEMORY_ACCESS;


            MEMORY_ACCESS:
                //
                state <= WRITE_BACK;

            WRITE_BACK:
                //
                state <= INSTRUCTION_FETCH;


            default: 
        endcase



    end





end

    
endmodule