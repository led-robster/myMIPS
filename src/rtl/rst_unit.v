


module rst_unit #(
    parameter EXT_RST_POL = 1'b0,
    parameter INT_RST_POL = 1'b0
) (
    input clk,
    input ext_rst,
    output int_rst
);

reg ext_rst_d;
reg ext_rst_dd;
reg ext_rst_ddd;

// debouncer
debouncer #(.DEFAULT_D(INT_RST_POL), .CNT_10MS(19'h61A80)) debouncer (.clk(clk), .i_d(ext_rst_ddd), .o_q(int_rst));


always @(posedge clk or ext_rst) begin
    
    if (ext_rst==EXT_RST_POL) begin
        ext_rst_d <= INT_RST_POL;
        ext_rst_dd <= INT_RST_POL;
        ext_rst_ddd <= INT_RST_POL;
    end else if (clk) begin
        
        ext_rst_d <= ~INT_RST_POL;
        ext_rst_dd <= ext_rst_d;
        ext_rst_ddd <= ext_rst_dd;

    end


end

    
endmodule