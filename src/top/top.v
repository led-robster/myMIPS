// f_clk=40 MHz, T_clk=25e-9 s


module top #(
    parameter RST_POL = 1'b0
) (
    input clk,
    input ext_rst
);

wire rst;

// ALLOCATIONS
rst_unit #(.EXT_RST_POL(1'b0), .INT_RST_POL(1'b0)) rst_unit_inst(.clk(clk), .ext_rst(ext_rst), .int_rst(rst));
cpu #(.RST_POL(1'b0)) cpu_inst(.clk(clk), .rst(rst));

    
endmodule