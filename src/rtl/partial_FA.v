// partial full adder
// dependency for small_lookahead.v


module partial_FA (
    input A,
    input B,
    input C,
    output S,
    output G,P
);


assign G = A & B;
assign P = A ^ B;
assign S = A ^ B ^ C;
    
endmodule