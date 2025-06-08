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
// Filename: small_lookahead.v
// Author: Alessandro Fermanelli
// Date: 06/2025
// Description: small look ahead. Based on 4 partial full adders.
//

module small_lookahead (
    input[3:0] A,
    input[3:0] B,
    input Ci,
    output[3:0] S,
    output Gg, Pg
);

wire [3:0] P, G;
wire [3:1] C;

partial_FA pfa1(.A(A[0]), .B(B[0]), .C(Ci), .S(S[0]), .G(G[0]), .P(P[0]));
partial_FA pfa2(.A(A[1]), .B(B[1]), .C(C[1]), .S(S[1]), .G(G[1]), .P(P[1]));
partial_FA pfa3(.A(A[2]), .B(B[2]), .C(C[2]), .S(S[2]), .G(G[2]), .P(P[2]));
partial_FA pfa4(.A(A[3]), .B(B[3]), .C(C[3]), .S(S[3]), .G(G[3]), .P(P[3]));

assign C[1] = G[0] | P[0]&Ci;
assign C[2] = G[1] | P[1]&C[1];
assign C[3] = G[2] | P[2]&C[2];

assign Gg = G[3] | P[3]&G[2] | P[3]&P[2]&G[1] | P[3]&P[2]&P[1]&G[0];
assign Pg = P[3]&P[2]&P[1]&P[0]; 

    
endmodule