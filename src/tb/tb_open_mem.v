`timescale 1ns/1ps



module tb_open_mem;
    
    parameter T_clk = 20;  
    parameter AWIDTH = 2;
    parameter DWIDTH = 8;

    reg clk = 1'b0;;
    reg rst = 1'b0;

    reg wr;
    reg[AWIDTH-1 : 0] wlane;
    reg[DWIDTH-1 : 0] wdata;


    always begin
        clk <= ~clk;
        #(T_clk/2);
    end


    open_mem #(.RST_POL(1'b0), .AWIDTH(2), .DWIDTH(8)) dut (
        .clk(clk),
        .rst(rst), 
        .i_wr(wr),
        .i_wlane(wlane),
        .i_wdata(wdata),
        .o_datalane()
    );


    // initial begin
        
    //     rst <= 0;

    //     #(5*T_clk);

    //     rst <= 1;

    //     #(100*T_clk);

    //     $finish;
    // end

endmodule