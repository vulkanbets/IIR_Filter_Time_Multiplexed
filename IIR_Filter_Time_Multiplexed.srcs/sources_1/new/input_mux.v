`timescale 1ns / 1ps

module input_mux # ( parameter M = 4, WI = 3, WF = 29, NUM_OF_BITS = $clog2(M) )
(
    input [NUM_OF_BITS - 1 : 0] cascade_counter,
    input [WI + WF - 1 : 0] x_input,
    input [WI + WF - 1 : 0] y_input,
    output reg [WI + WF - 1 : 0] out
);
    
    always @ (*)
    begin
        if(cascade_counter == 0) out <= x_input;
        else out <= y_input;
    end
    
endmodule
