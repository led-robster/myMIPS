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
// Filename: carry_lookahead.v
// Author: Alessandro Fermanelli
// Date: 06/2025
// Description: 16-b carry look ahead.
//

module carry_lookahead (
    input[15:0] A,
    input[15:0] B,
    input Ci,
    output[15:0] C,
    output reg ovF
);

wire [3:0] carry; // carry[0]=C4, carry[1]=C8, carry[2]=C12
wire [3:0] Gg, Pg;
wire GG, PG;

small_lookahead u1(.A(A[3:0]), .B(B[3:0]), .Ci(Ci), .S(C[3:0]), .Gg(Gg[0]), .Pg(Pg[0]));
small_lookahead u2(.A(A[7:4]), .B(B[7:4]), .Ci(carry[0]), .S(C[7:4]), .Gg(Gg[1]), .Pg(Pg[1]));
small_lookahead u3(.A(A[11:8]), .B(B[11:8]), .Ci(carry[1]), .S(C[11:8]), .Gg(Gg[2]), .Pg(Pg[2]));
small_lookahead u4(.A(A[15:12]), .B(B[15:12]), .Ci(carry[2]), .S(C[15:12]), .Gg(Gg[3]), .Pg(Pg[3]));

assign GG = Gg[3] | Pg[3]&Gg[2] | Pg[3]&Pg[2]&Gg[1] | Pg[3]&Pg[2]&Pg[1]&Gg[0];
assign PG = Pg[3]&Pg[2]&Pg[1]&Pg[0];

assign carry[0] = Gg[0] | Pg[0]&Ci;
assign carry[1] = Gg[1] | Pg[1]&Gg[0] | Pg[1]&Pg[0]&Ci;
assign carry[2] = Gg[2] | Pg[2]&Gg[1] | Pg[2]&Pg[1]&Gg[0] | Pg[2]&Pg[1]&Pg[0]&Ci;
assign carry[3] = GG | PG&Ci;

always @(*) begin
    if (A[15]==B[15]) begin
        //same sign
        if (carry[3]!=C[15]) begin
            // carry-out different from carry-on
            ovF = 1'b1;
        end else begin
            ovF = 1'b0;
        end
    end else begin
        ovF = 1'b0;
    end
end
    
endmodule