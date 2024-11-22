// debouncing circuit for unstable input eg. buttons

module debouncer #(
    paremeter DEFAULT = 0
) (
    input clk,
    input i_d,
    output reg q
);
    

reg[2:0] state = 0;
parameter zero=3'd0, zero_0=3'd1, zero_1=3'd2, zero_2=3'd3, one=3'd4, one_0=3'd5, one_1=3'd6, one_2=3'd7;


always @(posedge clk ) begin
    
    case (state):
        zero: 
        zero_0:
        zero_1:
        zero_2:
        one:
        one_0:
        one_1:
        one_2:
        default: 
    endcase


end



endmodule