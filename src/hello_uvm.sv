
// FAKE MEMORY MODULE
module dut (
    input logic           clk,                 // Clock at some freq
    input logic           rstn,                // Active Low  Sync Reset
    input logic           wr,                  // Active High Write
    input logic           rd,                  // Active High Write
    input logic           en,                  // Module Enable
    input logic[7:0]      wdata,               // Write Data
    input logic[7:0]      addr,                // Address
//
    output logic[7:0] rdata                // Read Data
);

reg[7:0] input_data;

    always @(posedge clk or negedge rstn) begin
        if (!rstn) begin
            input_data <= 0;
        end else begin
            if (en) begin
                if (wr) begin
                    input_data <= wdata;
                end
                if (rd) begin
                    rdata <= input_data;
                end
            end
        end

    end


endmodule


interface dut_if (input clk);
    logic rstn;
    logic[7:0] wdata;
    logic[7:0] rdata;
    logic[7:0] addr;
    logic wr;
    logic rd;
    logic en;
endinterface //dut_if (input clk)



module dut_wrapper (dut_if _if);

dut dsn0 (  .clk     (_if.clk),
            .rstn    (_if.rstn),
            .wr      (_if.wr),
            .en      (_if.en),
            .wdata   (_if.wdata),
            .addr    (_if.addr),
            .rdata   (_if.rdata));

endmodule

class base_test extends uvm_test;
    `uvm_component_utils (base_test)
    
    my_env m_top_env;
    virtual dut_if dut_vi;

    function new (string name, uvm_component parent = null);
        super.new(name, parent);
    endfunction

    virtual function void build_phase (uvm_phase phase);
        super.build_phase (phase);

        m_top_env = my_env::type_id::create ("m_top_env", this);

        if (! uvm_config_db #(virtual dut_if) :: get (this, "", "dut_if", dut_vi)) begin
            `uvm_error (get_type_name(), "DUT INTERFACE NOT found!")
        end
    endfunction

    virtual function void end_of_elaboration_phase (uvm_phase phase);
        uvm_top.print_topology();
    endfunction
endclass


class my_env extends uvm_env;
    `uvm_component_utils (my_env)

    function new(string name, uvm_component parent);
        super.new(name, parent);
    endfunction

    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
    endfunction

    task run_phase (uvm_phase phase);
        set_report_verbosity_level (UVM_MEDIUM);
        uvm_report_info (get_name(), $sformatf("HELLO UVM"), UVM_MEDIUM, `__FILE__, `__LINE__);
        `uvm_info (get_name(), $sformatf("Finishing with run_phase"), UVM_LOW)
    endtask

endclass