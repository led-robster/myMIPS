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
// Filename: tb_alu.v
// Author: Alessandro Fermanelli
// Date: 06/2025
// Description: Testbench for the ALU module.
//


`timescale 1ns/1ns

module tb_alu;

reg clk = 1'b0;
reg sum_en = 0, sub_en = 0, sll_en = 0, srl_en = 0, magg_en = 0, eq_en = 0, and_en = 0, or_en = 0;

integer fd;

reg signed[15:0] op1=16'd0, op2=16'd0;
reg signed[15:0] op1_d, op2_d;
reg signed[15:0] sum_res = 16'd0, sub_res = 16'd0, sll_res = 16'd0, srl_res = 16'd0, magg_res = 16'd0, eq_res = 16'd0, and_res = 16'd0, or_res = 16'd0;
reg[2:0] cmd= 3'd0;
wire signed[15:0] res;
reg signed[15:0] res_d;
wire ovF;
wire eq_bit;

alu dut(.OP1(op1), .OP2(op2), .cmd(cmd), .RES(res), .eq_bit(eq_bit), .ovF(ovF));

always #10 clk = ~clk;

parameter N = 32769; // (2**15)+1

integer sum_loop = 0, sub_loop = 0, sll_loop = 0, srl_loop = 0, magg_loop = 0, eq_loop = 0, and_loop = 0, or_loop = 0;

// GENERATION BLOCK
always @(posedge clk ) begin

    // delay line
    op1_d <= op1;
    op2_d <= op2;
    res_d <= res;

    if (sum_en || sub_en || sll_en || srl_en || magg_en || eq_en || and_en || or_en) begin
        if (sum_en) begin
            sum_loop <= sum_loop +1;
            op1 <= $random % N;
            op2 <= $random % N;
            sum_res = op1+op2;
            if (sum_loop>0) begin
                $fwrite(fd, "sum_loop[#%0d]>> op1=%0d, op2=%0d, sum_res=%0d, res=%0d.", sum_loop, op1, op2, sum_res, res);
                if (sum_res==res) begin
                    $fwrite(fd, "OK.✔️\n");
                end else begin
                    $fwrite(fd, "NOK.❌\n");                     
                end
            end
        end else if (sub_en) begin
            sub_loop <= sub_loop +1;
            op1 <= $random % N;
            op2 <= $random % N;
            sub_res = op1-op2;
            if (sub_loop>0) begin
                $fwrite(fd, "sub_loop[#%0d]>> op1=%0d, op2=%0d, sub_res=%0d, res=%0d.", sub_loop, op1, op2, sub_res, res);
                if (sub_res==res) begin
                    $fwrite(fd, "OK.✔️\n");
                end else begin
                    $fwrite(fd, "NOK.❌\n");                     
                end
            end            
        end else if (sll_en) begin
            sll_loop <= sll_loop +1;
            op1 <= $random % N;
            op2 <= {$random} % 16; // can be 1,2,3,4,...,16
            sll_res = op1<<op2;
            if (sll_loop>0) begin
                $fwrite(fd, "sll_loop[#%0d]>> op1=0b%0b, op2=%0d, sll_res=0b%0b, res=0b%0b.", sll_loop, op1, op2, sll_res, res);
                if (sll_res==res) begin
                    $fwrite(fd, "OK.✔️\n");
                end else begin
                    $fwrite(fd, "NOK.❌\n");                     
                end
            end  
        end else if (srl_en) begin
            srl_loop <= srl_loop + 1;
            op1 <= $random % N;
            op2 <= {$random} % 16; // can be 1,2,3,4,...,16
            srl_res = op1>>op2;
            if (srl_loop>0) begin
                $fwrite(fd, "srl_loop[#%0d]>> op1=0b%0b, op2=%0d, srl_res=0b%0b, res=0b%0b.", srl_loop, op1, op2, srl_res, res);
                if (srl_res==res) begin
                    $fwrite(fd, "OK.✔️\n");
                end else begin
                    $fwrite(fd, "NOK.❌\n");                     
                end
            end  
        end else if (magg_en) begin
            magg_loop <= magg_loop + 1;
            op1 <= $random % N;
            op2 <= $random % N; // can be 1,2,3,4,...,16
            if (op1>op2) begin
                magg_res = 16'd1;
            end else begin
                magg_res = 16'd0;
            end
            if (magg_loop>0) begin
                $fwrite(fd, "magg_loop[#%0d]>> op1=%0d, op2=%0d, magg_res=%0d, res=%0d.", magg_loop, op1, op2,  magg_res, res);
                if (magg_res==res) begin
                    $fwrite(fd, "OK.✔️\n");
                end else begin
                    $fwrite(fd, "NOK.❌\n");                    
                end

            end  
        end else if (eq_en) begin
            eq_loop <= eq_loop + 1;
            op1 <= $random % N;
            op2 <= $random % N; // can be 1,2,3,4,...,16
            if (op1==op2) begin
                eq_res = 16'd1;
            end else begin
                eq_res = 16'd0;
            end
            if (eq_loop>0) begin
                $fwrite(fd, "eq_loop[#%0d]>> op1=%0d, op2=%0d, eq_res=%0d, res=%0d.", eq_loop, op1, op2, eq_res, res);
                if (eq_res==res) begin
                    $fwrite(fd, "OK.✔️\n");
                end else begin
                    $fwrite(fd, "NOK.❌\n");                     
                end

            end              
        end else if (and_en) begin
            and_loop <= and_loop + 1;
            op1 <= $random % N;
            op2 <= $random % N; // can be 1,2,3,4,...,16
            and_res = op1&op2;
            if (and_loop>0) begin
                $fwrite(fd, "and_loop[#%0d]>> op1=0x%0h, op2=0x%0h, and_res=0x%0h, res=0x%0h.", and_loop, op1, op2, and_res, res);
                if (and_res==res) begin
                    $fwrite(fd, "OK.✔️\n");
                end else begin
                    $fwrite(fd, "NOK.❌\n");                     
                end
            end   
        end else if (or_en) begin
            or_loop <= or_loop + 1;
            op1 <= $random % N;
            op2 <= $random % N; // can be 1,2,3,4,...,16
            or_res = op1|op2;
            if (or_loop>0) begin
                $fwrite(fd, "or_loop[#%0d]>> op1=0x%0h, op2=0x%0h, or_res=0x%0h, res=0x%0h.", or_loop, op1, op2, or_res, res);
                if (or_res==res) begin
                    $fwrite(fd, "OK.✔️\n");
                end else begin
                    $fwrite(fd, "NOK.❌\n");                     
                end
            end               
        end
    end
end


initial begin

    fd = $fopen("tb_alu.log", "w");
    
    // raw null cycles
    for (integer i=0; i<10; i=i+1) begin
        @(posedge clk);
    end

    $fwrite(fd, "-----------------------------------------------------\n");
    $fwrite(fd, "\t\t\t\tSUM TEST\n");
    $fwrite(fd, "-----------------------------------------------------\n");

    // test +
    sum_en = 1;
    cmd = 3'b000;

    for (integer i=0; i<10; i=i+1) begin
        @(posedge clk);
    end

    @(posedge clk);

    sum_en=0;

    $fwrite(fd, "-----------------------------------------------------\n");
    $fwrite(fd, "\t\t\t\tSUB TEST\n");
    $fwrite(fd, "-----------------------------------------------------\n");

    // test sub
    sub_en=1;
    cmd = 3'b001;

    for (integer i=0; i<10; i=i+1) begin
        @(posedge clk);
    end

    @(posedge clk);

    sub_en=0;

    $fwrite(fd, "-----------------------------------------------------\n");
    $fwrite(fd, "\t\t\t\tSLL TEST\n");
    $fwrite(fd, "-----------------------------------------------------\n");

    // test <<
    sll_en=1;
    cmd = 3'b010;

    for (integer i=0; i<10; i=i+1) begin
        @(posedge clk);
    end

    @(posedge clk);

    sll_en=0;

    $fwrite(fd, "-----------------------------------------------------\n");
    $fwrite(fd, "\t\t\t\tSRL TEST\n");
    $fwrite(fd, "-----------------------------------------------------\n");

    // test >>
    srl_en=1;
    cmd = 3'b100;

    for (integer i=0; i<10; i=i+1) begin
        @(posedge clk);
    end

    @(posedge clk);

    srl_en=0;

    $fwrite(fd, "-----------------------------------------------------\n");
    $fwrite(fd, "\t\t\t\t> TEST\n");
    $fwrite(fd, "-----------------------------------------------------\n");

    // test >
    magg_en=1;
    cmd=3'b011;

    for (integer i=0; i<10; i=i+1) begin
        @(posedge clk);
    end

    @(posedge clk);

    magg_en=0;

    $fwrite(fd, "-----------------------------------------------------\n");
    $fwrite(fd, "\t\t\t\t== TEST\n");
    $fwrite(fd, "-----------------------------------------------------\n");

    // test ==
    eq_en=1;
    cmd=3'b111;

    for (integer i=0; i<10; i=i+1) begin
        @(posedge clk);
    end

    @(posedge clk);

    eq_en=0;

    $fwrite(fd, "-----------------------------------------------------\n");
    $fwrite(fd, "\t\t\t\tand TEST\n");
    $fwrite(fd, "-----------------------------------------------------\n");

    // test and
    and_en=1;
    cmd=3'b101;

    for (integer i=0; i<10; i=i+1) begin
        @(posedge clk);
    end

    @(posedge clk);

    and_en=0;

    $fwrite(fd, "-----------------------------------------------------\n");
    $fwrite(fd, "\t\t\t\tor TEST\n");
    $fwrite(fd, "-----------------------------------------------------\n");
    // test or
    or_en=1;
    cmd=3'b110;

    for (integer i=0; i<10; i=i+1) begin
        @(posedge clk);
    end

    @(posedge clk);

    or_en=0;

    $fwrite(fd, "-----------------------------------------------------\n");
    $fwrite(fd, "TEST FINISH.");
    $fwrite(fd, "-----------------------------------------------------\n");

    // end of simulation
    
    #100 $fclose(fd);
    #200 $finish;

end

initial
begin
    $dumpfile("test.fst");
    $dumpvars(0,tb_alu);
end



endmodule