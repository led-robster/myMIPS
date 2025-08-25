// 2-way set-associative 
// cache_size = 2**AWIDTH
// replacement policy : random
// write policy : write-trough
// DISCLAIMER: this cache is built to work with a 128Mbit (byte-adressable ???), 16Mbyte
// CALCULATION: 2**4*2**20=2**24 bytes= 2**23 words -> if memory is only word-adressable then a block=2byte
// set_size=2*block=4byte , se cache_size=256bytes allora # sets = cache_size/set_size=256/4=64

module cache #(
    parameter DWIDTH = 16,
    parameter AWIDTH = 10 
) (
    input clk,
    input rst,
    // flags
    output o_miss_nhit,
    output o_full_nempty,
    // PORTA - fast
    input i_wr_A,
    input[DWIDTH-1 : 0] i_wdata_A,
    input[AWIDTH-1 : 0] i_waddr_A,
    input i_rd_A,
    input[DWIDTH-1 : 0] o_rdata_A,
    input[AWIDTH-1 : 0] i_raddr_A,
    // PORTB - slow
    output o_wr_B,
    output[DWIDTH-1 : 0] o_wdata_B,
    output[AWIDTH-1 : 0] o_waddr_B,
    output o_rd_B,
    input[DWIDTH-1 : 0] i_rdata_B,
    output[AWIDTH-1 : 0] o_raddr_B
);

reg miss_nhit;

// output assignments
assign o_miss_nhit = miss_nhit;


// generating sets


// always @(posedge clk) begin
    
//     if (i_rd_A) begin
//         if i_raddr_A=
//     end

// end
    
endmodule