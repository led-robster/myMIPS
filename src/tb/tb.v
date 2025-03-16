`timescale 1ns/1ps

module tb;
    
    reg clk = 1'b0;
    reg ext_rst = 1'b1;
    reg rd = 1'b0;
    reg[7:0] raddr = 8'd0;
    wire[15:0] rdata;

    wire int_rst;


    top top_inst(.clk(clk), .ext_rst(ext_rst));

    always #12.5 clk = ~clk;

    initial begin
        ext_rst <= 0;
        #70 ext_rst <= 1;
        #20 
        #40000000 $finish;
    end

    initial
    begin
        $dumpfile("test.fst");
        $dumpvars(0);
    end


endmodule