`timescale 1ns/1ns

module tb_alu;

reg clk = 1'b0;
reg sum_en = 0, sub_en = 0, sll_en = 0, srl_en = 0, magg_en = 0;

integer fd;

reg signed[15:0] op1=16'd0, op2=16'd0;
reg signed[15:0] sum_res = 16'd0, sub_res = 16'd0, sll_res = 16'd0, srl_res = 16'd0, magg_res = 16'd0;
reg[2:0] cmd= 3'd0;
wire signed[15:0] res;
wire ovF;
wire eq_bit;

alu dut(.OP1(op1), .OP2(op2), .cmd(cmd), .RES(res), .eq_bit(eq_bit), .ovF(ovF));

always #10 clk = ~clk;

parameter N = 32769; // (2**15)+1

integer sum_loop = 0, sub_loop = 0, sll_loop = 0, srl_loop = 0, magg_loop = 0;

// GENERATION BLOCK
always @(posedge clk ) begin
    if (sum_en || sub_en || sll_en || srl_en || magg_en) begin
        if (sum_en) begin
            sum_loop <= sum_loop +1;
            op1 = $random % N;
            op2 = $random % N;
            sum_res <= op1+op2;
            if (sum_loop>0) begin
                if (res!=sum_res) begin
                    $fwrite(fd, "op1=%0d, op2=%0d, sum_res=%0d but res=%0d\n", op1, op2, sum_res, res);
                end else begin
                    $fwrite(fd, "sum_loop[#%0d]they are equal.\n", sum_loop);
                end
            end
        end else if (sub_en) begin
            sub_loop <= sub_loop +1;
            op1 = $random % N;
            op2 = $random % N;
            sub_res <= op1-op2;
            if (sub_loop>0) begin
                if (res!=sub_res) begin
                    $fwrite(fd, "op1=%0d, op2=%0d, sub_res=%0d but res=%0d\n", op1, op2, sub_res, res);
                end else begin
                    $fwrite(fd, "sub_loop[#%0d]they are equal.\n", sub_loop);
                end
            end            
        end else if (sll_en) begin
            sll_loop <= sll_loop +1;
            op1 = $random % N;
            op2 = {$random} % 16; // can be 1,2,3,4,...,16
            sll_res <= op1<<op2;
            if (sll_loop>0) begin
                if (res!=sll_res) begin
                    $fwrite(fd, "op1=%0d, op2=%0d, sll_res=%0d but res=%0d\n", op1, op2, sll_res, res);
                end else begin
                    $fwrite(fd, "sll_loop[#%0d]they are equal.\n", sll_loop);
                end
            end  
        end else if (srl_en) begin
            srl_loop <= srl_loop + 1;
            op1 = $random % N;
            op2 = {$random} % 16; // can be 1,2,3,4,...,16
            srl_res <= op1>>op2;
            if (srl_loop>0) begin
                if (res!=srl_res) begin
                    $fwrite(fd, "op1=%0d, op2=%0d, srl_res=%0d but res=%0d\n", op1, op2, srl_res, res);
                end else begin
                    $fwrite(fd, "srl_loop[#%0d]they are equal.\n", srl_loop);
                end
            end  
        end else if (magg_en) begin
            magg_loop <= magg_loop + 1;
            op1 = $random % N;
            op2 = $random % N; // can be 1,2,3,4,...,16
            if (op1>op2) begin
                magg_res <= 16'd1;
            end else begin
                magg_res <= 16'd0;
            end
            if (magg_loop>0) begin
                if (res!=magg_res) begin
                    $fwrite(fd, "op1=%0d, op2=%0d, magg_res=%0d but res=%0d\n", op1, op2, magg_res, res);
                end else begin
                    $fwrite(fd, "magg_loop[#%0d]they are equal.\n", magg_loop);
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