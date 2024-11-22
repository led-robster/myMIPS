

module tb_ram;

// internal
reg clk=0;

integer fd, flog;

reg[7:0] stored_addr;
reg[15:0] stored_data;

integer i_loop=0;

// RAM connections
reg ram_rst=0;
reg ram_rd=0, ram_wr=0;
reg[7:0] ram_raddr=0;
reg[7:0] ram_waddr=0;
reg[15:0] ram_wdata=0;
wire[15:0] ram_rdata;


ram #(.AWIDTH(8), .DWIDTH(16)) ram(.clk(clk), .rst(ram_rst), .i_rd(ram_rd), .i_wr(ram_wr), .i_raddr(ram_raddr), .i_waddr(ram_waddr), .i_wdata(ram_wdata), .o_rdata(ram_rdata));


always #10 clk = ~clk;


// MAIN
initial begin

    fd = $fopen("../src/mem/ram.txt", "r");
    flog = $fopen("tb_ram.log", "w");

    if (!fd) begin
        $display("Couldn't open ram.txt");
        $finish;
    end

    if (!flog) begin
        $display("Couldn't open tb_ram.log");
        $finish;        
    end

    // raw null cycles
    for (integer i = 0;i<10 ;i+=1 ) begin
        @(posedge clk);
    end
    
    ram_rst = 1;

    while ($fscanf(fd, "address=0x%0x data=0x%0x\n", stored_addr, stored_data)>0) begin
        ram_wr <= 1'b1;
        ram_waddr <= stored_addr;
        ram_wdata <= stored_data;
        @(posedge clk);
        ram_wr <= 1'b0;
        @(posedge clk);
        ram_rd <= 1'b1;
        ram_raddr <= stored_addr;
        @(posedge clk);
        ram_rd <= 0;
        @(posedge clk);
        $fwrite(flog, "line in file: %0h, line in ram: %0h.\t",stored_data ,ram_rdata );
        if (stored_data==ram_rdata) begin
            $fwrite(flog, "✔️\n");
        end else begin
            $fwrite(flog, "❌\n");
        end
        i_loop += 1;
    end
    

    $fclose(fd);
    $fclose(flog);

    $finish;
    
end




endmodule