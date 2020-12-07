`timescale 1ns / 1ps

module mux_4_to_1 # ( parameter M = 4, WIS = 5, WFS = 11, NUM_OF_BITS = $clog2(M) )
(
    input [NUM_OF_BITS - 1 : 0] cascade_counter,
    input [WIS + WFS - 1 : 0] in0,
    input [WIS + WFS - 1 : 0] in1,
    input [WIS + WFS - 1 : 0] in2,
    input [WIS + WFS - 1 : 0] in3,
    output reg [WIS + WFS - 1 : 0] out
);
    always @ (*)
    begin
        case (cascade_counter)
            0: out <= in0;
            1: out <= in1;
            2: out <= in2;
            3: out <= in3;
            default out <= 0;
        endcase
    end
endmodule
