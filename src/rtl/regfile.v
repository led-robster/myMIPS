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
    output reg[15:0] rt,
    output[15:0] reg_zero
);



reg[15:0] REG_BANK [0:(1<<AWIDTH)-1];

integer i_loop = 0;

assign reg_zero = REG_BANK[0];

// ADDRESSES INTERNAL
//------------------------------------------------------------
// Nominally address is what comes from interface. Register 1_000 and 0_000 are equivalent, in the sense that writing/reading to 1_000, eventually resorts to 0_000.
// This functionality is needed for the reg-zero morphism and the register bank handling.
reg[AWIDTH-1:0] addr_rd_int, addr_rs_int, addr_rt_int;
always @(addr_rd, addr_rs, addr_rt) begin

    case (addr_rd[2:0])
      3'b000  : addr_rd_int <= 0;
      default : addr_rd_int <= addr_rd; 
    endcase
    //
    case (addr_rs[2:0])
      3'b000  : addr_rs_int <= 0;
      default : addr_rs_int <= addr_rs; 
    endcase
    //
    case (addr_rt[2:0])
      3'b000  : addr_rt_int <= 0;
      default : addr_rt_int <= addr_rt; 
    endcase

end

// WRITE
//------------------------------------------------------------
// Write to output reg.
always @(negedge clk) begin
    if (req_rd==1'b1) begin
        REG_BANK[addr_rd_int] <= wdata;
    end
    if (clear==1'b1) begin
        for (i_loop=0 ;i_loop<(1<<AWIDTH) ;i_loop=i_loop+1 ) begin
            REG_BANK[i_loop] <= {16{1'b0}};
        end
    end
end

// READ
//------------------------------------------------------------
// Read to output reg.
always @(posedge clk) begin
    if (req_rs==1'b1) begin
        if (addr_rs_int==0) begin
            // Always return 0.
            rs <= 0;
        end else begin
            rs <= REG_BANK[addr_rs_int];            
        end
    end
    if (req_rt==1'b1) begin
        if (addr_rt_int==0) begin
            rt <= 0;
        end else begin
            rt <= REG_BANK[addr_rt_int];
        end
    end
end

    
endmodule
    