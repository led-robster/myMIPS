

class reset_agent extends uvm_agent;

    function new();

    reset_cfg m_reset_cfg;
        
    endfunction //new()
endclass //className


module tb_top;
    import uvm_pkg::*;

    // clk
    bit clk;
    always #10 clk <= ~clk;

    //

endmodule
