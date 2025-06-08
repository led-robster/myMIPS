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
// Filename: cpu_monitor.v
// Author: Alessandro Fermanelli
// Date: 06/2025
// Description: Ad-hoc module built to test *cpu* operation. Shall generate **regfile** status at every clock cycle and be compared to an expected equivalent.
//

`timescale 1ns/1ps


module cpu_monitor #(
    parameter RST_POL = 1'b0
)
(
    input clk,
    input rst,
        //regfile
    input DBG_rd_rs,
    input DBG_rd_rt,
    input DBG_wr_rd,
    input[3:0] DBG_addr_rs,
    input[3:0] DBG_addr_rt,
    input[3:0] DBG_addr_rd,
    input[15:0] DBG_wdata_rd,
    input[15:0] DBG_rs,
    input[15:0] DBG_rt,
        // PC
    input[7:0] DBG_pc,
        // RAM
    input DBG_ram_rd,
    input DBG_ram_wr,
    input[7:0] DBG_ram_raddr,
    input[7:0] DBG_ram_waddr,
    input[15:0] DBG_ram_wdata,
    input[15:0] DBG_ram_rdata,
        // decoding instr
    input[15:0] INSTR_D
);

reg DBG_rd_rs_d, DBG_rd_rt_d, DBG_wr_rd_d;
reg[3:0] DBG_addr_rs_d, DBG_addr_rt_d, DBG_addr_rd_d;
reg[15:0] INSTR_E, INSTR_MA, INSTR_WB;

integer file;

// DELAY LINE
always @(posedge clk) begin
    DBG_rd_rs_d <= DBG_rd_rs;
    DBG_rd_rt_d <= DBG_rd_rt;
    DBG_wr_rd_d <= DBG_wr_rd;
    //
    DBG_addr_rs_d <= DBG_addr_rs;
    DBG_addr_rt_d <= DBG_addr_rt;
    DBG_addr_rd_d <= DBG_addr_rd;
    //
    INSTR_E <= INSTR_D;
    INSTR_MA <= INSTR_E;
    INSTR_WB <= INSTR_MA;
end

// FILE HANDLER
initial begin
    
    file = $fopen("cpu_monitor.txt", "w");
    if (file==0) begin
        $display("Error. Couldn't open file.");
    end

end

always @(posedge clk) begin



    if (rst==~RST_POL) begin

        $fdisplay(file, "#%0t PIPELINE SNAPSHOT : D        | E        | MA        | WB        ", $time);
        $fdisplay(file, "=========================================================================");
        $fdisplay(file, "        0x%0x       | 0x%0x       | 0x%0x       | 0x%0x       ", INSTR_D, INSTR_E, INSTR_MA, INSTR_WB);

        // regfile
        //****************************
        if (DBG_rd_rs) begin
            // $display("Read rs#%d", DBG_addr_rs);
            $fdisplay(file, "%0t | Read rs#%d", $time, DBG_addr_rs);
        end
        if (DBG_rd_rs_d) begin
            // $display("Read rs#%d data %d", DBG_addr_rs_d, DBG_rs);
            $fdisplay(file, "%0t | Read rs#%d data %d", $time, DBG_addr_rs_d, DBG_rs);
        end
        if (DBG_rd_rt) begin
            // $display("Read rt#%d", DBG_addr_rt);
            $fdisplay(file, "%0t | Read rt#%d", $time, DBG_addr_rt);
        end
        if (DBG_rd_rt_d) begin
            // $display("Read rt#%d data: %d", DBG_addr_rt_d, DBG_rt);
            $fdisplay(file, "%0t | Read rt#%d data: %d", $time, DBG_addr_rt_d, DBG_rt);
        end
        if (DBG_wr_rd) begin
            // $display("Write rd#%d data: %d", DBG_addr_rd, DBG_wdata_rd);
            $fdisplay(file, "%0t | Write rd#%d data: %d", $time, DBG_addr_rd, DBG_wdata_rd);
        end
        // ram
        //**********************************

        // PC
        //**********************************


        $fdisplay(file, "");
        $fdisplay(file, "");
        $fdisplay(file, "");
    end

end



endmodule