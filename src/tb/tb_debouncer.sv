`timescale 1ns/1ns

module tb_debouncer;
    
reg clk=1'b0; 
reg rst=1'b0;

reg d=1'b0;
wire q;

always #20 clk=~clk;

debouncer #(.RST_POLARITY(1'b0), .DEFAULT_D(1'b0)) debouncer(.clk(clk), .rst(rst), .i_d(d), .q(q));

initial begin
    $dumpfile("test.fst");
    $dumpvars(0,tb_debouncer);
end

// main
initial begin
    
    for (integer i =0 ;i<10 ;i+=1 ) begin
        @(posedge clk);
    end

    rst <= 1'b1;

    for (integer i =0 ;i<10 ;i+=1 ) begin
        @(posedge clk);
    end

    #5 d=1'b1;
    #100 d=1'b0;
    #200 d=1'b1;
    
    for (integer i =0 ;i<10 ;i+=1 ) begin
        @(posedge clk);
    end
    
    #50000000 $finish;

end



endmodule