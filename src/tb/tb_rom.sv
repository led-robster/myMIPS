

module tb_rom;
    
reg clk = 1'b0;
reg rom_rd = 0;
reg[7:0] rom_raddr = 0;
wire[15:0] rom_rdata;

integer fd;
integer flog;

integer i_loop=0;

reg mem_en = 0;
reg[15:0] value_stored=0;

rom rom(.clk(clk), .i_rd(rom_rd), .i_raddr(rom_raddr), .o_rdata(rom_rdata));

always #10 clk = ~clk;

initial begin

    fd = $fopen("../src/mem/program.mem", "r");
    flog = $fopen("tb_rom.log", "w");

    if (!flog) begin
        $display("Couldn't open log file.");
        $finish;
    end

    if (!fd) begin
        $display("Couldn't open .mem file.");
        $finish;
    end

    // blank
    for(integer i=0; i<10; i+=1) begin
        @(posedge clk);
    end

    while ($fscanf(fd, "%0h", value_stored)>0) begin
        rom_rd <= 1'b1;
        rom_raddr <= i_loop;
        @(posedge clk);
        rom_rd <= 1'b0;
        @(posedge clk);
        $fwrite(flog, "line in file: %0h, line in rom: %0h.\t",value_stored ,rom_rdata );
        if (value_stored==rom_rdata) begin
            $fwrite(flog, "✔️\n");
        end else begin
            $fwrite(flog, "❌\n");
        end
        i_loop = i_loop +1;
    end

    
    $fclose(fd);
    $fclose(flog);

    $finish;

end


endmodule