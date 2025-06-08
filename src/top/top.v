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
// Filename: top.v
// Author: Alessandro Fermanelli
// Date: 06/2025
// Description: Top unit allocates the SoC. Currently SoC is composed of *rst_unit* and *cpu*.
//

module top #(
    parameter RST_POL = 1'b0
) (
    input clk,
    input ext_rst
);

wire rst;

// ALLOCATIONS
rst_unit #(.EXT_RST_POL(1'b0), .INT_RST_POL(1'b0)) rst_unit_inst(.clk(clk), .ext_rst(ext_rst), .int_rst(rst));
cpu #(.RST_POL(1'b0)) cpu_inst(.clk(clk), .rst(rst));

    
endmodule