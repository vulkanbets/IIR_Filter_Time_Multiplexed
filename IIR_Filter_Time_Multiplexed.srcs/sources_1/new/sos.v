`timescale 1ns / 1ps

module sos
#
( parameter
    WI_in = 3, WF_in = 40,                  // Input integer and fraction bits
    WL = WI_in + WF_in,                     // This is for the register module
    WI_coeff = 2, WF_coeff = 8,             // Coefficients Integer and Fraction bits
    b0 = 10'h0, b1 = 10'h0, b2 = 10'h0,     // b coefficients
    a1 = 10'h0, a2 = 10'h0                  // a coefficients already negated
)
    
(
    input CLK,
    input [WI_in + WF_in - 1 : 0] in,
    output [WI_in + WF_in - 1 : 0] out
);
    
    //  <----------Feedforward system---------->
    //  <----------Feedforward system---------->
    //  <----------Feedforward system---------->
    
    mult_Fixed # ( .WI1(WI_in), .WF1(WF_in), .WI2(WI_coeff), .WF2(WF_coeff), .WIO(WI_in), .WFO(WF_in) )             // b0 Multiplier
    mult_b0( .in1(in), .in2(b0), .out()  );                                                                         // b0 Multiplier
    
    
    delay_register # ( .WL(WL) )                                                                                    // Delay b 1
    delay_b_1( .CLK(CLK), .in(in), .out() );                                                                        // Delay b 1
    
    
    mult_Fixed # ( .WI1(WI_in), .WF1(WF_in), .WI2(WI_coeff), .WF2(WF_coeff), .WIO(WI_in), .WFO(WF_in) )                  // b1 Multiplier
    mult_b1( .in1(delay_b_1.out), .in2(b1), .out()  );                                                              // b1 Multiplier
    
    
    delay_register # ( .WL(WL) )                                                                                    // Delay b 2
    delay_b_2( .CLK(CLK), .in(delay_b_1.out), .out() );                                                             // Delay b 2
    
    
    mult_Fixed # ( .WI1(WI_in), .WF1(WF_in), .WI2(WI_coeff), .WF2(WF_coeff), .WIO(WI_in), .WFO(WF_in) )             // b2 Multiplier
    mult_b2( .in1(delay_b_2.out), .in2(b2), .out()  );                                                              // b2 Multiplier
    
    
    add_Fixed # ( .WI1(WI_in), .WF1(WF_in), .WI2(WI_in), .WF2(WF_in), .WIO(WI_in), .WFO(WF_in) )
    b1_b2_adder( .in1(mult_b1.out), .in2(mult_b2.out), .out() );
    
    
    add_Fixed # ( .WI1(WI_in), .WF1(WF_in), .WI2(WI_in), .WF2(WF_in), .WIO(WI_in), .WFO(WF_in) )
    b0_b1_adder( .in1(mult_b0.out), .in2(b1_b2_adder.out), .out() );
    
    
    //  <----------Feedback system---------->
    //  <----------Feedback system---------->
    //  <----------Feedback system---------->
    
    
    
    add_Fixed # ( .WI1(WI_in), .WF1(WF_in), .WI2(WI_in), .WF2(WF_in),                           // final adder
                    .WIO(WI_in), .WFO(WF_in) )                                                  // final adder
    b0_b1_a1_adder( .in1(b0_b1_adder.out), .in2(a1_a2_adder.out), .out(out) );                  // final adder
    
    
    
    delay_register # ( .WL(WL) )                                                            // Delay a 1
    delay_a_1( .CLK(CLK), .in(b0_b1_a1_adder.out), .out() );                                // Delay a 1
    
    
    
    mult_Fixed # ( .WI1(WI_in), .WF1(WF_in), .WI2(WI_coeff), .WF2(WF_coeff),                // a1 multiplier
            .WIO(WI_in), .WFO( WF_in) )                                                     // a1 Multiplier
    mult_a1( .in1(delay_a_1.out), .in2(a1), .out()  );                                                  // a1 Multiplier
    
    
    
    delay_register # ( .WL(WL) )                                                                    // Delay a 2
    delay_a_2( .CLK(CLK), .in(delay_a_1.out), .out() );                                             // Delay a 2
    
    
    
    mult_Fixed # ( .WI1(WI_in), .WF1(WF_in), .WI2(WI_coeff), .WF2(WF_coeff),                // a2 Multiplier
    .WIO(WI_in), .WFO(WF_in) )                                                              // a2 Multiplier
    mult_a2( .in1(delay_a_2.out), .in2(a2), .out()  );                                                      // a2 Multiplier
    
    
    
    add_Fixed # ( .WI1(WI_in), .WF1(WF_in), .WI2(WI_in), .WF2(WF_in),   // a1 a2 adder
                    .WIO(WI_in), .WFO(WF_in) )                                                        // a1 a2 adder
    a1_a2_adder( .in1(mult_a1.out), .in2(mult_a2.out), .out() );
    
    
endmodule
