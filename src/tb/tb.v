

module tb;
    
    reg clk = 1'b0;
    reg rd = 1'b0;
    reg[7:0] raddr = 8'd0;
    wire[15:0] rdata;

    rom ROM (.clk(clk), .i_rd(rd), .i_raddr(raddr), .o_rdata(rdata)); 

    //ram RAM (.clk(clk), .rst(rst), .i_rd(rd), .i_wr(wr), .i_raddr())

    always #10 clk = ~clk;

    initial
    begin
        $dumpfile("test.fst");
        $dumpvars(0,tb);
    end

    initial begin
        #50 rd <= 1;
            raddr <= 8'd1;
        #20 rd <= 0;
        #200 $finish;
    end


endmodule