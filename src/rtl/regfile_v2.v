//
// VERSION 2
//

module regfile_v2 #(
    parameter AWIDTH = 8
) (
    input                   clk,
    input                   clear,
    input  [AWIDTH-1:0]     addr_rs,
    input  [AWIDTH-1:0]     addr_rt,
    input  [AWIDTH-1:0]     addr_rd,
    input                   req_rs,
    input                   req_rt,
    input                   req_rd,
    input  [15:0]           wdata,
    output [15:0]           rs,
    output [15:0]           rt,
    output  [15:0]          reg_zero
);

    reg [15:0] REG_BANK [0:(1<<AWIDTH)-1];

    assign reg_zero = REG_BANK[0];

    reg[AWIDTH-1:0] addr_rd_int, addr_rs_int, addr_rt_int;
    
    always @(addr_rd, addr_rs, addr_rt) begin

        case (addr_rd[2:0])
        3'b000  : addr_rd_int <= 0;
        default : addr_rd_int <= addr_rd; 
        endcase
        //
        case (addr_rs[2:0])
        3'b000  : addr_rs_int <= 0;
        default : addr_rs_int <= addr_rs; 
        endcase
        //
        case (addr_rt[2:0])
        3'b000  : addr_rt_int <= 0;
        default : addr_rt_int <= addr_rt; 
        endcase

    end


    integer i_loop = 0;

    // synchronous write
    always @(posedge clk) begin
        if (clear) begin
            for (i_loop = 0; i_loop < (1<<AWIDTH); i_loop=i_loop+1) begin
                REG_BANK[i_loop] <= 16'b0;
            end
        end else if (req_rd) begin
            REG_BANK[addr_rd] <= wdata;
        end
    end

    // combinational read with bypass
    assign rs = (req_rs == 0) ? 16'bx :
                (addr_rs_int == 0) ? 16'b0 :
                (req_rd && addr_rd_int == addr_rs_int) ? wdata :
                REG_BANK[addr_rs_int];

    assign rt = (req_rt == 0) ? 16'bx :
                (addr_rt_int == 0) ? 16'b0 :
                (req_rd && addr_rd_int == addr_rt_int) ? wdata :
                REG_BANK[addr_rt_int];

endmodule
