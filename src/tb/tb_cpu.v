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
// Filename: t_cpu.v
// Author: Alessandro Fermanelli
// Date: 06/2025
// Description: Refined testbench to check correct CPU operation. Instantiates *cpu* and *cpu_monitor*.
//

`timescale 1ns/1ps

module tb_cpu;

    parameter time T_CLK = 25;
    
    reg clk = 1'b0;
    reg ext_rst = 1'b1;
    reg rd = 1'b0;
    reg[7:0] raddr = 8'd0;
    wire[15:0] rdata;

    wire int_rst;
    
    //
    wire DBG_rd_rs;
    wire DBG_rd_rt;
    wire DBG_wr_rd;
    wire[3:0] DBG_addr_rs;
    wire[3:0] DBG_addr_rt;
    wire[3:0] DBG_addr_rd;
    wire[15:0] DBG_wdata_rd;
    wire DBG_rs;
    wire DBG_rt;
    wire[7:0] DBG_pc;
    wire DBG_ram_rd;
    wire DBG_ram_wr;
    wire[7:0] DBG_ram_raddr;
    wire[7:0] DBG_ram_waddr;
    wire[15:0] DBG_ram_wdata;
    wire[15:0] DBG_ram_rdata;
    wire[15:0] INSTR_D;

    cpu #(.RST_POL(1'b1)) cpu_inst(clk,
    ext_rst,
    DBG_rd_rs,
    DBG_rd_rt,
    DBG_wr_rd,
    DBG_addr_rs,
    DBG_addr_rt,
    DBG_addr_rd,
    DBG_wdata_rd,
    DBG_rs,
    DBG_rt,
    DBG_pc,
    DBG_ram_rd,
    DBG_ram_wr,
    DBG_ram_raddr,
    DBG_ram_waddr,
    DBG_ram_wdata,
    DBG_ram_rdata,
    INSTR_D
    );

    cpu_monitor #(1'b1) cpu_monitor_inst(
        clk,
        ext_rst,
        DBG_rd_rs,
        DBG_rd_rt,
        DBG_wr_rd,
        DBG_addr_rs,
        DBG_addr_rt,
        DBG_addr_rd,
        DBG_wdata_rd,
        DBG_rs,
        DBG_rt,
        DBG_pc,
        DBG_ram_rd,
        DBG_ram_wr,
        DBG_ram_raddr,
        DBG_ram_waddr,
        DBG_ram_wdata,
        DBG_ram_rdata,
        INSTR_D
    ); 

    // CLK PROCESS
    always #(T_CLK/2) clk = ~clk;

    // MAIN PROCESS
    initial begin
        ext_rst <= 0;
        # (T_CLK) 
        ext_rst <= 1;
        // #70 ext_rst <= 1;
        // #20 
        #30000000 ext_rst <= 0;
        # (40*T_CLK)  $finish;
        //#40000000 $finish;
    end

    initial
    begin
        $dumpfile("tb_cpu.vcd");
        $dumpvars(0);
    end


endmodule