// basic implementation of memory with open accessible data lanes
// size=2**AWIDTH

module open_mem #(
    parameter RST_POL = 1'b0,
    parameter AWIDTH = 2,
    parameter DWIDTH = 8
) (
    input clk,
    input rst, 
    input i_wr,
    input[AWIDTH-1 : 0] i_wlane,
    input[DWIDTH-1 : 0] i_wdata,
    output[DWIDTH*AWIDTH-1 : 0] o_datalane
);


reg[DWIDTH-1 : 0] mem_bank [AWIDTH-1 : 0];


// genvar i;
// generate
//     for (i=0; i<AWIDTH; i = i+1) begin
//         assign o_datalane[DWIDTH*i+DWIDTH-1 : DWIDTH*i] = mem_bank[i];        
//     end
// endgenerate


// always @(posedge clk or rst) begin
//     if (rst==RST_POL) begin
//         genvar i;
//         generate
//             for (i=0; i<AWIDTH; i = i+1) begin
//                 mem_bank[i] <= 0;        
//             end
//         endgenerate
//     end else if (clk) begin
//         if (i_wr) begin
//             mem_bank[i_wlane] <= i_wdata; 
//         end
//     end
// end
    
endmodule