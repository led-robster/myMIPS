// TODO : yo bro fix Immediate fmt , you messed up with rs/rt/rd

module control #(
    parameter RST_POL = 1'b0
) (
    input clk,
    input rst,
    // ROM
    input[15:0] ROM_data,
    output reg rom_rd,
    // RAM
    output reg ram_rd,
    output reg ram_wr,
    // REGFILE
    output reg rd_rs,
    output reg rd_rt,
    output reg[3:0] addr_rs,
    output reg[3:0] addr_rt,
    output reg[3:0] addr_rd,
    output reg[3:0] wb_waddr,
    output wr_rd,
    //
    output [5:0] immediate,
    output [2:0] shamt,
    // ALU
    output reg[2:0] ALU_cmd,
    // MUXes
    output reg RES_MUX,
    output reg OP2_MUX,
    output reg PC_MUX,
    output reg SHAMT_IMM_MUX, 
    output reg BEQ_MUX,
    output reg JUMP_MUX,
    output reg WB_MUX,
    output reg SILENCE_MUX,
    output reg SAVE_PC_MUX
);

reg[3:0] state;
parameter [3:0] BOOT                = 4'b0000,
                INSTRUCTION_FETCH   = 4'b0001,
                INSTRUCTION_DECODE  = 4'b0010,
                EXECUTE             = 4'b0100,
                MEMORY_ACCESS       = 4'b1000,
                WRITE_BACK          = 4'b1111;


wire[2:0] Fcode;
wire[3:0] opcode;
wire[2:0] rs,rt;
reg[2:0] rd;
wire[5:0] offset;
wire[11:0] address;

// internals
wire[15:0] instruction;
reg jump, jump_d, jump_dd;
reg memory_op, memory_op_d, memory_op_dd;
reg shamt_d;
reg wb_wr; // write-back write in regfile 
reg silence_op, silence_d, silence_dd, silence_ddd; // 1: silence_on, 0: silence_off


assign Fcode = instruction[2:0];
assign opcode = instruction[15:12];
assign rs = instruction[11:9];
assign rt = instruction[8:6];
//assign rd = instruction[5:3];
assign immediate = instruction[5:0];
assign shamt = instruction[5:3];
assign offset = instruction[5:0];
assign address = instruction[11:0];
assign wr_rd = wb_wr;


// instruction fetch process
always @(posedge clk or posedge rst or negedge rst) begin

    if (rst==RST_POL) begin

        rom_rd <= 1'b0;

    end else begin

        rom_rd <= 1'b1; 

    end

end

always @(posedge clk or negedge rst) begin
    if (rst==RST_POL) begin
        rd_rs <= 1'b0;
        rd_rt <= 1'b0;
    end else begin

        // always reading source registers
        rd_rs <= 1'b1;
        rd_rt <= 1'b1;                 

    end
end

assign instruction = ROM_data;
// assign addr_rs = {1'b0, instruction[11:9]};
// assign addr_rt = {1'b0, instruction[8:6]};
// assign addr_rd = {1'b0, instruction[5:3]};

wire op_switch; // used for sll and srl
assign op_switch = (opcode==0 & Fcode==5 | opcode==0 & Fcode==6) ? (1) : (0);

always @(*) begin
    addr_rs <= {1'b0, instruction[11:9]};
    addr_rt <= {1'b0, instruction[8:6]};
    addr_rd <= {1'b0, instruction[5:3]};
    if (op_switch) begin
        addr_rs <= {1'b0, instruction[8:6]};
        addr_rd <= {1'b0, instruction[11:9]};
    end
end


// PIPELINE IS EXTERNAL.
// shamt 1cc pipeline. shamt can arrive to EXECUTE.
// always @(posedge clk or negedge rst) begin
//     if (!rst) begin
//         shamt_d <= 1'b0;
//     end else begin
//         shamt_d <= shamt;
//     end 
// end

// DECODE process
always @(posedge clk or rst) begin

    if (rst==RST_POL) begin

        OP2_MUX         <= 1'b0;
        ALU_cmd         <= 3'b000;
        jump            <= 1'b0;
        memory_op       <= 1'b0;
        SHAMT_IMM_MUX   <= 1'b0;
        SAVE_PC_MUX     <= 1'b0;
        wb_wr           <= 1'b0;
        SILENCE_MUX     <= 1'b0;

    end else if (clk) begin

            // default
            SHAMT_IMM_MUX   <= 1'b0;
            RES_MUX         <= 1'b1;
            OP2_MUX         <= 1'b0;
            PC_MUX          <= 1'b1;
            JUMP_MUX        <= 1'b0;
            BEQ_MUX         <= 1'b1;
            WB_MUX          <= 1'b0;
            SAVE_PC_MUX     <= 1'b0;
            ram_rd          <= 1'b0;
            ram_wr          <= 1'b0;
            wb_wr           <= 1'b0;
            silence_op      <= 1'b0;

            // silence_op HIGH @EXECUTE, silence_d HIGH @MA, silence_dd HIGH @WRITEBACK
            silence_d <= silence_op;
            silence_dd <= silence_d;
            silence_ddd <= silence_dd;

            
            if (opcode==0) begin
                // R-format
                
                if (Fcode==0) begin
                    // add
                    OP2_MUX <= 1'b0;
                    wb_wr <= 1'b1;
                    //
                    ALU_cmd <= 3'b000;
                end else if (Fcode==1) begin 
                    // subtract
                    OP2_MUX <= 1'b0;
                    wb_wr <= 1'b1;
                    //
                    ALU_cmd <= 3'b001;
                end else if (Fcode==2) begin
                    // and
                    OP2_MUX <= 1'b0;
                    wb_wr <= 1'b1;
                    //
                    ALU_cmd <= 3'b101;
                end else if (Fcode==3) begin
                    // or
                    OP2_MUX <= 1'b0;
                    wb_wr <= 1'b1;
                    //
                    ALU_cmd <= 3'b110;
                end else if (Fcode==4) begin
                    // slt 
                    OP2_MUX <= 1'b0;
                    wb_wr <= 1'b1;
                    //
                    ALU_cmd <= 3'b011;
                end else if (Fcode==5) begin
                    // sll
                    OP2_MUX <= 1'b1;
                    SHAMT_IMM_MUX <= 1'b1;
                    wb_wr <= 1'b1;
                    //
                    ALU_cmd <= 3'b010;
                end else if (Fcode==6) begin
                    // srl
                    OP2_MUX <= 1'b1;
                    SHAMT_IMM_MUX <= 1'b1;
                    wb_wr <= 1'b1;
                    //
                    ALU_cmd <= 3'b100;
                end else if (Fcode==7) begin
                    // jr
                    OP2_MUX <= 1'b0; // read $r0
                    // add operation
                    ALU_cmd <= 3'b000;
                    //
                    JUMP_MUX <= 1'b1;
                end
            end else if (opcode==4'b0001) begin
                // addi
                OP2_MUX <= 1'b1;
                wb_wr <= 1'b1;
                wb_waddr <= rt;
                WB_MUX <= 1'b1;
                // +
                ALU_cmd <= 3'b000;
            end else if (opcode==4'b0011) begin
                // slti
                OP2_MUX <= 1'b1;
                wb_wr <= 1'b1;
                wb_waddr <= rt;
                WB_MUX <= 1'b1;
                // >
                ALU_cmd <= 3'b011;
            end else if (opcode==4'b0100) begin
                // lw
                OP2_MUX <= 1'b1;
                ram_rd <= 1'b1;
                RES_MUX <= 1'b0;
                wb_wr <= 1'b1;
                wb_waddr <= rt;
                WB_MUX <= 1'b1;
                // +
                ALU_cmd <= 3'b000;
            end else if (opcode==4'b0101) begin
                // sw
                OP2_MUX <= 1'b1;
                ram_wr <= 1'b1; 
                // +
                ALU_cmd <= 3'b000;
            end else if (opcode==4'b0110) begin
                // beq
                BEQ_MUX <= 1'b0;
                SILENCE_MUX <= 1'b1;
                PC_MUX <= 1'b0;
                silence_op <= 1'b1; 
                //== 
                ALU_cmd <= 3'b111;
            end else if (opcode==4'b0111) begin
                // j
                OP2_MUX <= 1'b1; 
                JUMP_MUX <= 1'b1;
                silence_op <= 1'b1;
                SILENCE_MUX <= 1'b1;
                // + , 0+imm
                ALU_cmd <= 3'b000;
            end else if (opcode==4'b1000) begin
                // jal
                OP2_MUX <= 1'b1;
                JUMP_MUX <= 1'b1; 
                WB_MUX <= 1'b1;
                wb_wr <= 1'b1;
                wb_waddr <= 4'b1111;// $ra
                SILENCE_MUX <= 1'b1;
                silence_op <= 1'b1; 
                SAVE_PC_MUX <= 1'b1;
            end


            if (silence_ddd==1'b1) begin
                SILENCE_MUX <= 1'b0;
            end

            // handle null instruction
            if (instruction==0) begin
                // default
                SHAMT_IMM_MUX   <= 1'b0;
                RES_MUX         <= 1'b1;
                OP2_MUX         <= 1'b0;
                PC_MUX          <= 1'b1;
                JUMP_MUX        <= 1'b0;
                BEQ_MUX         <= 1'b1;
                WB_MUX          <= 1'b0;
                SAVE_PC_MUX     <= 1'b0;
                ram_rd          <= 1'b0;
                ram_wr          <= 1'b0;
                wb_wr           <= 1'b0;
                silence_op      <= 1'b0;
            end

            if (SILENCE_MUX==1'b1) begin
                PC_MUX <= 1'b0;
            end
            if (silence_ddd==1'b1) begin
                PC_MUX <= 1'b1;
            end

    end

        

end

    
endmodule