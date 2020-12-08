`timescale 1ns / 1ps

module top # ( parameter M = 4, WI = 3, WF = 29, WIS = 5, WFS = 11, WI_coeff = 2, WF_coeff = 8 )
(
    input CLK,
    output reg [WI + WF - 1 : 0] answer
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
    
    input_mux input_mux( .cascade_counter(cascade_counter), .x_input(x_input[counter]), .y_input(sos.out), .out() );
    
    mux_4_to_1 # ( .WIS(WIS), .WFS(WFS) ) scale_factor_mux( .cascade_counter(cascade_counter), .in0(16'h000a), .in1(16'h0800), .in2(16'h0800), .in3(16'h0800), .out() );
    
    mult_Fixed # ( .WI1(WI), .WF1(WF), .WI2(WIS), .WF2(WFS), .WIO(WI), .WFO(WF) )               // First scalar is 0.004726381845108
        scalar_1( .in1(input_mux.out), .in2(scale_factor_mux.out), .out() );                    // First scalar is 0.004726381845108
    
    mux_4_to_1 b0_mux( .cascade_counter(cascade_counter), .in0(10'h100), .in1(10'h100), .in2(10'h100), .in3(10'h100), .out() );
    
    mux_4_to_1 b1_mux( .cascade_counter(cascade_counter), .in0(10'h1df), .in1(10'h133), .in2(10'h0ab), .in3(10'h070), .out() );
    
    mux_4_to_1 b2_mux( .cascade_counter(cascade_counter), .in0(10'h100), .in1(10'h100), .in2(10'h100), .in3(10'h100), .out() );
    
    mux_4_to_1 a1_mux( .cascade_counter(cascade_counter), .in0(10'h133), .in1(10'h0d3), .in2(10'h078), .in3(10'h04b), .out() );
    
    mux_4_to_1 a2_mux( .cascade_counter(cascade_counter), .in0(10'h392), .in1(10'h363), .in2(10'h332), .in3(10'h30f), .out() );
    
    
    sos # ( .WI_in(WI), .WF_in(WF), .WL(WI + WF), .WI_coeff(WI_coeff), .WF_coeff(WF_coeff) )
        sos( .CLK(CLK), .cascade_counter(cascade_counter), .in(scalar_1.out), .b0(b0_mux.out), .b1(b1_mux.out), .b2(b2_mux.out), .a1(a1_mux.out), .a2(a2_mux.out), .out() );
    
    
    always @ (posedge CLK) if(cascade_counter == 3) answer <= sos.b0_b1_a1_adder.out;
    
    
endmodule
