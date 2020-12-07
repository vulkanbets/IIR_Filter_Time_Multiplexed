`timescale 1ns / 1ps

module top # ( parameter M = 4, WI = 3, WF = 29, WIS = 5, WFS = 11, WI_coeff = 2, WF_coeff = 8 )
(
    input CLK
);
    localparam NUM_OF_BITS = $clog2(M);
    reg [NUM_OF_BITS - 1 : 0] cascade_counter = 0;                                          // Counter going through each cascaded SOS
    reg [WI + WF - 1 : 0] x_input[0 : 49];                                                  // Input values
    reg [5 : 0] counter = 0;                                                                // Counter that counts through input values
    always @ (posedge CLK)
    begin
        if( cascade_counter < (M - 1) ) cascade_counter <= cascade_counter + 1;             // Cycle through inputs
        else begin cascade_counter <= 0; if(counter < 49) counter <= counter + 1; end       // Cycle through inputs
    end
    initial $readmemh("x.mem", x_input);                                                    // Initialize Inputs
    
    input_mux input_mux( .cascade_counter(cascade_counter), .x_input(x_input[counter]), .y_input(32'h00000000), .out() );
    
    mux_4_to_1 scale_factor_mux( .cascade_counter(cascade_counter), .in0(16'h000a), .in1(16'h0800), .in2(16'h0800), .in3(16'h0800), .out() );
    
    mult_Fixed # ( .WI1(WI), .WF1(WF), .WI2(WIS), .WF2(WFS), .WIO(WI), .WFO(WF) )       // First scalar is 0.004726381845108
        scalar_1( .in1(input_mux.out), .in2(scale_factor_mux.out), .out() );            // First scalar is 0.004726381845108
    
    sos # ( .WI_in(WI), .WF_in(WF + WFS), .WL(WI + WF + WFS), .WI_coeff(WI_coeff), .WF_coeff(WF_coeff),
        .b0(10'h100), .b1(10'h1df), .b2(10'h100), .a1(10'h133), .a2(10'h392) )
    sos( .CLK(CLK), .in(scalar_1.out), .out() );
    
endmodule
