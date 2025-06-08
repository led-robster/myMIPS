//==============================================================================
//                 .                                            .
//      *   .                  .              .        .   *          .
//   .         .                     .       .           .      .        .
//         o                             .                   .
//          .              .                  .           .
//           0     .
//                  .          .                 ,                ,    ,
//  .          \          .                         .
//       .      \   ,
//    .          o     .                 .                   .            .
//      .         \                 ,             .                .
//                #\##\#      .                              .        .
//              #  #O##\###                .                        .
//    .        #*#  #\##\###                       .                     ,
//         .   ##*#  #\##\##               .                     .
//       .      ##*#  #o##\#         .                             ,       .
//           .     *#  #\#     .                    .             .          ,
//                       \          .                         .
// ____^/\___^--____/\____O______________/\/\---/\___________---______________
//    /\^   ^  ^    ^                  ^^ ^  '\ ^          ^       ---
//          --           -            --  -      -         ---  __       ^
//    --  __                      ___--  ^  ^                         --  __
//===============================================================================
//
// Filename: debouncer.v
// Author: Alessandro Fermanelli
// Date: 06/2025
// Description: Debouncer circuit for unstable async input.
//

module debouncer #(
    parameter DEFAULT_D = 1'b0,
    parameter CNT_10MS = 19'h3D090
) (
    input clk,
    input i_d,
    output reg o_q
);
    

reg[2:0] state = 0;
parameter zero=3'd0, zero_0=3'd1, zero_1=3'd2, zero_2=3'd3, one=3'd4, one_0=3'd5, one_1=3'd6, one_2=3'd7;

reg counter_en = 1'b0;
reg counter_rst =1'b1;
reg unsigned[18:0] counter = 0;


always @(posedge clk) begin

        // triggers
        counter_rst <= 1'b0;

        case (state)
        zero:   begin
                    o_q <= DEFAULT_D;  
                    counter_en <= 1'b0;
                    if (i_d!=DEFAULT_D) begin
                        state <= zero_0;
                        counter_en <= 1'b1;
                    end
                end
        zero_0: begin
                    if (counter==CNT_10MS) begin
                        counter_rst <= 1'b1;
                        counter_en <= 1'b1;
                        state <= zero_1;
                    end
                    if (i_d==DEFAULT_D) begin
                        state <= zero;
                        counter_rst <= 1'b1;
                    end
                end
            
        zero_1: begin
                    if (counter==CNT_10MS) begin
                        counter_rst <= 1'b1;
                        counter_en <= 1'b1;
                        state <= zero_2;
                    end
                    if (i_d==DEFAULT_D) begin
                        state <= zero;
                        counter_rst <= 1'b1;
                    end
                end

        zero_2: begin
                    if (counter==CNT_10MS) begin
                        counter_rst <= 1'b1;
                        counter_en <= 1'b0;
                        state <= one;
                    end
                    if (i_d==DEFAULT_D) begin
                        state <= zero;
                        counter_rst <= 1'b1;
                    end
                end

        one:    begin
                    o_q <= ~DEFAULT_D;
                    counter_en <= 1'b0;
                    if (i_d==DEFAULT_D) begin
                        state <= one_0;
                        counter_en <= 1'b1;
                    end
                end

        one_0:  begin
                    if (counter==CNT_10MS) begin
                        counter_rst <= 1'b1;
                        counter_en <= 1'b1;
                        state <= one_1;
                    end
                    if (i_d!=DEFAULT_D) begin
                        state <= one;
                        counter_rst <= 1'b1;
                    end
                end

        one_1:  begin
                    if (counter==CNT_10MS) begin
                        counter_rst <= 1'b1;
                        counter_en <= 1'b1;
                        state <= one_2;
                    end
                    if (i_d!=DEFAULT_D) begin
                        state <= one;
                        counter_rst <= 1'b1;
                    end
                end

        one_2:  begin
                    if (counter==CNT_10MS) begin
                        counter_rst <= 1'b1;
                        counter_en <= 1'b0;
                        state <= zero;
                    end
                    if (i_d!=DEFAULT_D) begin
                        state <= one;
                        counter_rst <= 1'b1;
                    end
                end

        default:    begin
                        $display("impossible state.");
                    end

    endcase

end


// supposing a 30MHz clk then T_clk=33.33 ns, for 10 ms counter -> 300030*T_clk
// formula: cnt_max=10ms/T_clk=10ms*F_clk
always @(posedge clk) begin

    if (counter_en==1) begin
        counter <= counter + 1;
    end
    if (counter_rst==1'b1) begin
        counter <= 0;
    end

end



endmodule