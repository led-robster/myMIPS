

module tb;
    
    reg clk = 1'b0;
    reg ext_rst = 1'b1;
    reg rd = 1'b0;
    reg[7:0] raddr = 8'd0;
    wire[15:0] rdata;

    top top(.clk(clk), .ext_rst(ext_rst));

    always #10 clk = ~clk;

    initial begin
        ext_rst <= 0;
        #50 ext_rst <= 1;
        #20 
        #200 $finish;
    end


endmodule