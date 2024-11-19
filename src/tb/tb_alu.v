`timescale 1ns/1ns

module tb_alu;

reg clk = 1'b0;

reg[15:0] op1=16'd0, op2=16'd0;
reg[2:0] cmd= 3'd0;
wire[15:0] res;
wire ovF;
wire eq_bit;

alu dut(.OP1(op1), .OP2(op2), .cmd(cmd), .RES(res), .eq_bit(eq_bit), .ovF(ovF));

always #10 clk = ~clk;


initial begin
    
    @(posedge clk);

    // test +
    op1 = 16'd1;
    op2 = 16'd2;
    cmd = 3'b000;

    @(posedge clk);

    op1 = 16'd10;
    op2 = 16'd20;
    cmd = 3'b000;

    @(posedge clk);

    op1 = 16'h7FFF;
    op2 = 16'h7FFF;

    @(posedge clk);

    op1 = 16'd10;
    op2 = 16'd20;
    cmd = 3'b000;

    @(posedge clk);

    op1 = 16'h8000;
    op2 = 16'hFFFF;
    cmd = 3'b000;

    @(posedge clk);

    // test sub
    op1 = 16'h8000;
    op2 = 16'hFFFF;
    cmd = 3'b001;

    @(posedge clk);

    // test <<
    op1 = 16'h7000;
    op2 = 16'd1;
    cmd = 3'b010;

    // test >>

    // test >


    // test ==

    // end of simulation

    #200 $finish;

end

initial
begin
    $dumpfile("test.fst");
    $dumpvars(0,tb_alu);
end



endmodule