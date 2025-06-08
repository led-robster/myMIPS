// write first half of T_clk , read second half of T_clk
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
// Filename: regfile.v
// Author: Alessandro Fermanelli
// Date: 06/2025
// Description: Register File. Works on both clock edges. On RE writes data, on FE reads data.
//

module regfile #(
    parameter AWIDTH = 8
) (
    input clk,
    input clear,
    input[AWIDTH-1:0] addr_rs,
    input req_rs,
    input[AWIDTH-1:0] addr_rt,
    input req_rt,
    input[AWIDTH-1:0] addr_rd,
    input req_rd,
    input[15:0] wdata,
    output reg[15:0] rs, 
    output reg[15:0] rt 
);


reg[15:0] REG_BANK [0:(1<<AWIDTH)-1];

integer i_loop = 0;

// write
always @(negedge clk ) begin
    if (req_rd==1'b1) begin
        REG_BANK[addr_rd] <= wdata;
    end
    if (clear==1'b1) begin
        for (i_loop=0 ;i_loop<(1<<AWIDTH) ;i_loop=i_loop+1 ) begin
            REG_BANK[i_loop] <= {16{1'b0}};
        end
    end
end

// read
always @(posedge clk ) begin
    if (req_rs==1'b1) begin
        rs <= REG_BANK[addr_rs];
    end
    if (req_rt==1'b1) begin
        rt <= REG_BANK[addr_rt];
    end
end

    
endmodule