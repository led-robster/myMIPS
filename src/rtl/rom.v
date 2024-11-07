

module rom
(
    input clk,
    input i_rd,
    input [7:0] i_raddr,
    output reg[15:0] o_rdata
);


wire [15:0] ROM [0:(1<<8)-1];

assign ROM[0] = 16'd0;
assign ROM[1] = 16'd1;
assign ROM[2] = 16'd2;
assign ROM[3] = 16'd3;
assign ROM[4] = 16'd4;
assign ROM[5] = 16'd5;
assign ROM[6] = 16'd6;
assign ROM[7] = 16'd7;

// initial begin
//     ROM[0] = 16'd0;
//     ROM[1] = 16'd1;
//     ROM[2] = 16'd2;
//     ROM[3] = 16'd3;
//     ROM[4] = 16'd4;
//     ROM[5] = 16'd5;
//     ROM[6] = 16'd6;
//     ROM[7] = 16'd7;
// end



always @(posedge clk ) begin
    if (i_rd==1'b1) begin
        o_rdata <= ROM[i_raddr];
    end else begin
        o_rdata <= 0;
    end
end

//initial $readmemh();
    
endmodule