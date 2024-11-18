

module alu (
    input[15:0] OP1,
    input[15:0] OP2,
    input[2:0] cmd,
    output[15:0] RES,
    output eq_bit,
    output ovF
);


wire[15:0] cl_A, cl_B, cl_C;
wire cl_Ci;

carry_lookahead CL (.A(cl_A), .B(cl_B), .Ci(cl_Ci), .C(cl_C), .ovF(ovF));


always @(*) begin

    if (cmd==3'b000) begin
        // +
        cl_A = OP1;
        cl_B = OP2;
        cl_Ci = 1'b0;
        RES = cl_C;
    end else if (cmd==3'b001) begin
        // -
        cl_A = OP1;
        cl_B = ~OP2;
        cl_Ci = 1'b1;
        RES = cl_C;
    end else if (cmd==3'b010) begin
        // <<
    end else if (cmd==3'b011) begin
        // >
    end else if (cmd==3'b100) begin
        // >>
    end else if (cmd==3'b101) begin
        // and
    end else if (cmd==3'b110) begin
        // or
    end else if (cmd==3'b111) begin
        // ==
    end

end


    
endmodule


