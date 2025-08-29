`timescale 1ns/100ps



module tb_regfile;


    parameter TCLK = 40;
    

    reg clk = 1'b0;


    // dut
    reg clear = 1'b0;
    reg [3:0]addr_rs;
    reg [3:0]addr_rt;
    reg [3:0]addr_rd;
    reg req_rs;
    reg req_rt;
    reg req_rd;
    reg [15:0]wdata;


    regfile_v2
    #(.AWIDTH(4)) 
    dut
    (
        .clk(clk),
        .clear(clear),
        .addr_rs(addr_rs),
        .addr_rt(addr_rt),
        .addr_rd(addr_rd),
        .req_rs(req_rs),
        .req_rt(req_rt),
        .req_rd(req_rd),
        .wdata(wdata)
        // .rs(),
        // .rt(),
        // .reg_zero(),
    );



    always
    begin
        #(TCLK/2);
        clk <= ~clk;    
    end


    initial
    begin

        //initalize
        addr_rd <= 0;
        addr_rs <= 0;
        addr_rt <= 0;
        req_rd <= 0;
        req_rs <= 0;
        req_rt <= 0;
        wdata <= 0;

        #(TCLK*20);
        @(posedge clk);

        // WRITE $r1
        req_rd <= 1;
        addr_rd <= 1;
        wdata <= 1;

        #(TCLK);
        @(posedge clk);

        req_rd <= 0;

        #(TCLK);
        @(posedge clk);

        // WRITE $r2
        req_rd <= 1;
        addr_rd <= 2;
        wdata <= 2;

        #(TCLK);
        @(posedge clk);

        req_rd <= 0;

        #(TCLK);
        @(posedge clk);

        // READ $r1
        req_rs <= 1;
        addr_rs <= 1;

        #(TCLK);
        @(posedge clk);

        req_rs <= 0;

        #(TCLK);
        @(posedge clk);

        // READ $r2
        req_rt <= 1;
        addr_rt <= 2;

        #(TCLK);
        @(posedge clk);

        req_rt <= 0;

        #(TCLK);
        @(posedge clk);
        // writing and reading same cycle same address
        req_rd <= 1;
        req_rs <= 1;
        addr_rd <= 2;
        addr_rs <= 2;
        wdata <= 8;

        #(TCLK);
        @(posedge clk);

        req_rd <= 0;
        req_rs <= 0;

        #(TCLK);
        @(posedge clk);
        // writing and reading same cycle but different addresses
        req_rd <= 1;
        req_rs <= 1;
        addr_rd <= 3;
        addr_rs <= 2;
        wdata <= 8;

        
        #(TCLK);
        @(posedge clk);
        req_rd <= 0;
        req_rs <= 0;



        #(TCLK*100);

        $finish;

    end

    initial begin
        $dumpfile("tb_regfile.vcd");
        $dumpvars(0, tb_regfile);
    end


endmodule