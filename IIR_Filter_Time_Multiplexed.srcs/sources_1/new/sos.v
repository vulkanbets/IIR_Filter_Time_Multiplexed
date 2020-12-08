`timescale 1ns / 1ps

module sos # ( parameter M = 4, NUM_OF_BITS = $clog2(M), WI_in = 3, WF_in = 29, WL = WI_in + WF_in, WI_coeff = 2, WF_coeff = 8 )
(
    input CLK,
    input [NUM_OF_BITS - 1 : 0] cascade_counter,
    input [WI_in + WF_in - 1 : 0] in,
    input [WI_coeff + WF_coeff - 1 : 0] b0,
    input [WI_coeff + WF_coeff - 1 : 0] b1,
    input [WI_coeff + WF_coeff - 1 : 0] b2,
    input [WI_coeff + WF_coeff - 1 : 0] a1,
    input [WI_coeff + WF_coeff - 1 : 0] a2,
    output reg [WI_in + WF_in - 1 : 0] out
);
    
    reg en_0 = 0;
    reg en_1 = 0;
    reg en_2 = 0;
    reg en_3 = 0;
    
    always @ (*)
    begin
        case (cascade_counter)
            0: begin en_0 <= 1; en_1 <= 0; en_2 <= 0; en_3 <= 0; end        // Enable signals for Delay Registers
            1: begin en_0 <= 0; en_1 <= 1; en_2 <= 0; en_3 <= 0; end        // Enable signals for Delay Registers
            2: begin en_0 <= 0; en_1 <= 0; en_2 <= 1; en_3 <= 0; end        // Enable signals for Delay Registers
            3: begin en_0 <= 0; en_1 <= 0; en_2 <= 0; en_3 <= 1; end        // Enable signals for Delay Registers
       default begin en_0 <= 0; en_1 <= 0; en_2 <= 0; en_3 <= 0; end        // Enable signals for Delay Registers
        endcase
    end
    
    //  <----------Feedforward system---------->
    //  <----------Feedforward system---------->
    //  <----------Feedforward system---------->
    
    mult_Fixed # ( .WI1(WI_in), .WF1(WF_in), .WI2(WI_coeff), .WF2(WF_coeff), .WIO(WI_in), .WFO(WF_in) )         // b0 Multiplier
    mult_b0( .in1(in), .in2(b0), .out()  );                                                                     // b0 Multiplier
    
    
    
    
    
    
    delay_register # ( .WL(WL) )                                                                                // Delay b 1 1
    delay_b_1_1( .CLK(CLK), .EN(en_0), .in(in), .out() );                                                       // Delay b 1 1
    
    delay_register # ( .WL(WL) )                                                                                // Delay b 1 2
    delay_b_1_2( .CLK(CLK), .EN(en_1), .in(in), .out() );                                                       // Delay b 1 2
    
    delay_register # ( .WL(WL) )                                                                                // Delay b 1 3
    delay_b_1_3( .CLK(CLK), .EN(en_2), .in(in), .out() );                                                       // Delay b 1 3
    
    delay_register # ( .WL(WL) )                                                                                // Delay b 1 4
    delay_b_1_4( .CLK(CLK), .EN(en_3), .in(in), .out() );                                                       // Delay b 1 4
    
    mux_4_to_1 # ( .WIS(WI_in), .WFS(WF_in) ) b1_mux( .cascade_counter(cascade_counter),
                    .in0(delay_b_1_1.out), .in1(delay_b_1_2.out), .in2(delay_b_1_3.out), .in3(delay_b_1_4.out), .out() );
    
    mult_Fixed # ( .WI1(WI_in), .WF1(WF_in), .WI2(WI_coeff), .WF2(WF_coeff), .WIO(WI_in), .WFO(WF_in) )         // b1 Multiplier
    mult_b1( .in1(b1_mux.out), .in2(b1), .out()  );                                                             // b1 Multiplier
    
    
    
    
    
    
    delay_register # ( .WL(WL) )                                                                // Delay b 2 1
    delay_b_2_1( .CLK(CLK), .EN(en_0), .in(b1_mux.out), .out() );                               // Delay b 2 1
    
    delay_register # ( .WL(WL) )                                                                // Delay b 2 2
    delay_b_2_2( .CLK(CLK), .EN(en_1), .in(b1_mux.out), .out() );                               // Delay b 2 2
    
    delay_register # ( .WL(WL) )                                                                // Delay b 2 3
    delay_b_2_3( .CLK(CLK), .EN(en_2), .in(b1_mux.out), .out() );                               // Delay b 2 3
    
    delay_register # ( .WL(WL) )                                                                // Delay b 2 4
    delay_b_2_4( .CLK(CLK), .EN(en_3), .in(b1_mux.out), .out() );                               // Delay b 2 4
    
    mux_4_to_1 # ( .WIS(WI_in), .WFS(WF_in) ) b2_mux( .cascade_counter(cascade_counter),
                    .in0(delay_b_2_1.out), .in1(delay_b_2_2.out), .in2(delay_b_2_3.out), .in3(delay_b_2_4.out), .out() );
    
    mult_Fixed # ( .WI1(WI_in), .WF1(WF_in), .WI2(WI_coeff), .WF2(WF_coeff), .WIO(WI_in), .WFO(WF_in) )         // b2 Multiplier
    mult_b2( .in1(b2_mux.out), .in2(b2), .out()  );                                                                       // b2 Multiplier
    
    
    
    
    
    
    add_Fixed # ( .WI1(WI_in), .WF1(WF_in), .WI2(WI_in), .WF2(WF_in), .WIO(WI_in), .WFO(WF_in) )
    b1_b2_adder( .in1(mult_b1.out), .in2(mult_b2.out), .out() );
    
    
    add_Fixed # ( .WI1(WI_in), .WF1(WF_in), .WI2(WI_in), .WF2(WF_in), .WIO(WI_in), .WFO(WF_in) )
    b0_b1_adder( .in1(mult_b0.out), .in2(b1_b2_adder.out), .out() );
    
//    //  <----------Feedback system---------->
//    //  <----------Feedback system---------->
//    //  <----------Feedback system---------->
    
    
    
    
    delay_register # ( .WL(WL) )                                                                                // Delay a 1 1
    delay_a_1_1( .CLK(CLK), .EN(en_0), .in(b0_b1_a1_adder.out), .out() );                                       // Delay a 1 1
    
    delay_register # ( .WL(WL) )                                                                                // Delay a 1 2
    delay_a_1_2( .CLK(CLK), .EN(en_1), .in(b0_b1_a1_adder.out), .out() );                                       // Delay a 1 2
    
    delay_register # ( .WL(WL) )                                                                                // Delay a 1 3
    delay_a_1_3( .CLK(CLK), .EN(en_2), .in(b0_b1_a1_adder.out), .out() );                                       // Delay a 1 3
    
    delay_register # ( .WL(WL) )                                                                                // Delay a 1 4
    delay_a_1_4( .CLK(CLK), .EN(en_3), .in(b0_b1_a1_adder.out), .out() );                                       // Delay a 1 4
    
    mux_4_to_1 # ( .WIS(WI_in), .WFS(WF_in) ) a1_mux( .cascade_counter(cascade_counter),
                    .in0(delay_a_1_1.out), .in1(delay_a_1_2.out), .in2(delay_a_1_3.out), .in3(delay_a_1_4.out), .out() );
    
    mult_Fixed # ( .WI1(WI_in), .WF1(WF_in), .WI2(WI_coeff), .WF2(WF_coeff), .WIO(WI_in), .WFO( WF_in) )        // a1 Multiplier
    mult_a1( .in1(a1_mux.out), .in2(a1), .out()  );                                                             // a1 Multiplier
    
    
    
    
    
    
    
    
    delay_register # ( .WL(WL) )                                                        // Delay a 2 1
    delay_a_2_1( .CLK(CLK), .EN(en_0), .in(a1_mux.out), .out() );                       // Delay a 2 1
    
    delay_register # ( .WL(WL) )                                                        // Delay a 2 2
    delay_a_2_2( .CLK(CLK), .EN(en_1), .in(a1_mux.out), .out() );                       // Delay a 2 2
    
    delay_register # ( .WL(WL) )                                                        // Delay a 2 3
    delay_a_2_3( .CLK(CLK), .EN(en_2), .in(a1_mux.out), .out() );                       // Delay a 2 3
    
    delay_register # ( .WL(WL) )                                                        // Delay a 2 4
    delay_a_2_4( .CLK(CLK), .EN(en_3), .in(a1_mux.out), .out() );                       // Delay a 2 4
    
    mux_4_to_1 # ( .WIS(WI_in), .WFS(WF_in) ) a2_mux( .cascade_counter(cascade_counter),
                    .in0(delay_a_2_1.out), .in1(delay_a_2_2.out), .in2(delay_a_2_3.out), .in3(delay_a_2_4.out), .out() );
    
    
    mult_Fixed # ( .WI1(WI_in), .WF1(WF_in), .WI2(WI_coeff), .WF2(WF_coeff), .WIO(WI_in), .WFO(WF_in) )     // a2 Multiplier
    mult_a2( .in1(a2_mux.out), .in2(a2), .out()  );                                                         // a2 Multiplier
    
    
    
    
    
    
    
    
    add_Fixed # ( .WI1(WI_in), .WF1(WF_in), .WI2(WI_in), .WF2(WF_in), .WIO(WI_in), .WFO(WF_in) )          // a1 a2 adder
    a1_a2_adder( .in1(mult_a1.out), .in2(mult_a2.out), .out() );
    
    
    add_Fixed # ( .WI1(WI_in), .WF1(WF_in), .WI2(WI_in), .WF2(WF_in), .WIO(WI_in), .WFO(WF_in) )        // final adder
    b0_b1_a1_adder( .in1(b0_b1_adder.out), .in2(a1_a2_adder.out), .out() );                             // final adder
    
    always @ (posedge CLK) out <= b0_b1_a1_adder.out;
    
    
    
endmodule
