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
// Filename: rom.v
// Author: Alessandro Fermanelli
// Date: 06/2025
// Description: ROM. Holds program memory. Content is initialized by file ../src/mem/program.mem
//

module rom #(
    parameter AWIDTH = 8
) (
    input clk,
    input i_rd,
    input [7:0] i_raddr,
    output reg[15:0] o_rdata
);


reg [15:0] ROM [0:(1<<AWIDTH)-1];


always @(posedge clk ) begin
    if (i_rd==1'b1) begin
        o_rdata <= ROM[i_raddr];
    end else begin
        o_rdata <= 0;
    end
end

initial begin
    $readmemb("../src/mem/program.mem", ROM); // folder relative to where Makefile is
end 
    
endmodule