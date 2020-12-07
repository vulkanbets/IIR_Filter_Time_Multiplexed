`timescale 1ns / 1ps

module delay_register # (parameter WL = 8)
(
    input CLK,
    input [WL - 1 : 0] in,
    output reg [WL - 1 : 0] out
);
    initial out <= 0;
    
    always @ (posedge CLK)
    begin
        out <= in;
    end
    
    
    
endmodule
