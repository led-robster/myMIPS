

module ram #(
    parameter AWIDTH = 8,
    parameter DWIDTH = 16
) (
    input clk,
    input rst,
    input i_rd, i_wr,
    input[AWIDTH-1:0] i_raddr,
    input[AWIDTH-1:0] i_waddr,
    input[DWIDTH-1:0] i_wdata,
    output reg[DWIDTH-1:0] o_rdata 
);

    reg[DWIDTH-1:0] RAM [0:(1<<AWIDTH)-1];

    integer i = 0;


    always @(posedge clk or negedge rst) begin
        if (!rst) begin
            for (i=0; i<(1 <<(AWIDTH)); i = i+1) begin
                RAM[i] <= {DWIDTH{1'b1}};
            end
        end else if (i_rd==1'b1) begin
            o_rdata <= RAM[i_raddr]; 
        end else if (i_rd==1'b0) begin
            o_rdata <= 0;
        end else if (i_wr==1'b1) begin
            RAM[i_waddr] <= i_wdata;
        end

    end
    
endmodule