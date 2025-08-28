//==============================================================================
//                 .                                            .
//      *   .                  .              .        .   *          .
//   .         .                     .       .           .      .        .
//         o                             .                   .
//          .              .                  .           .
//           0     .
//                  .          .                 ,                ,    ,
//  .          \          .                         .
//       .      \   ,
//    .          o     .                 .                   .            .
//      .         \                 ,             .                .
//                #\##\#      .                              .        .
//              #  #O##\###                .                        .
//    .        #*#  #\##\###                       .                     ,
//         .   ##*#  #\##\##               .                     .
//       .      ##*#  #o##\#         .                             ,       .
//           .     *#  #\#     .                    .             .          ,
//                       \          .                         .
// ____^/\___^--____/\____O______________/\/\---/\___________---______________
//    /\^   ^  ^    ^                  ^^ ^  '\ ^          ^       ---
//          --           -            --  -      -         ---  __       ^
//    --  __                      ___--  ^  ^                         --  __
//===============================================================================
//
// Filename: alu.v
// Author: Alessandro Fermanelli
// Date: 06/2025
// Dependency: carry_lookahead.v
// Description: Arithmetic Logic Unit. Implements basic math operations in 16-b.
//      Sum, Difference, Less Than, SRL, SLL, and, or, equal .
//      Arithmetic on 16-b signed. MAX_REPRESENTATION_VALUE= 2**15-1 (0111_1111_1111_1111)= 32767, MIN_REPRESENTATION_VALUE= -2**15 (1000_0000_0000_0000)= -32768
//      Addition and Subtraction implemented with carry-look-ahead.

module alu (
    input[15:0] OP1,
    input[15:0] OP2,
    input[2:0] cmd,
    output reg[15:0] RES,
    output reg eq_bit,
    output ovF
);


reg[15:0] cl_A, cl_B;
wire[15:0] cl_C;
reg cl_Ci;

wire signed[15:0] s_op1, s_op2;
assign s_op1 = OP1;
assign s_op2 = OP2;

carry_lookahead CL (.A(cl_A), .B(cl_B), .Ci(cl_Ci), .C(cl_C), .ovF(ovF));


always @(*) begin

    cl_A = 16'd0;
    eq_bit <= 1'b0;

    if (cmd==3'b000) begin
        // +
        cl_A = OP1;
        cl_B = OP2;
        cl_Ci = 1'b0;
        RES = cl_C;
    end else if (cmd==3'b001) begin
        // -
        cl_A = OP1;
        cl_B = ~OP2;
        cl_Ci = 1'b1;
        RES = cl_C;
    end else if (cmd==3'b010) begin
        // <<, sll
        RES = OP1 << OP2;
    end else if (cmd==3'b011) begin
        // <
        if (s_op1<s_op2) begin
            RES = 16'd1;
        end else begin
            RES = 16'd0;
        end
    end else if (cmd==3'b100) begin
        // >>, srl
        RES = OP1 >> OP2;
    end else if (cmd==3'b101) begin
        // AND
        RES = OP1 & OP2;
    end else if (cmd==3'b110) begin
        // OR
        RES = OP1 | OP2;
    end else if (cmd==3'b111) begin
        // ==
        if (OP1==OP2) begin
            RES = 16'd1;
            eq_bit <= 1'b1;
        end else begin
            RES = 16'd0;
            eq_bit <= 1'b0;
        end
    end

end


    
endmodule


