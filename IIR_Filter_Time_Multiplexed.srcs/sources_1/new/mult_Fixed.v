`timescale 1ns / 1ps

module mult_Fixed # ( parameter WI1 = 4, WF1 = 4,   // input 1 integer and fraction bits
                                WI2 = 4, WF2 = 4,   // input 2 integer and fraction bits
                             WIO = WI1 + WI2,       // output integer bits
                             WFO = WF1 + WF2 )      // output fraction bits
(
    input RESET,
    input signed [WI1 + WF1 - 1 : 0] in1,            // Multiplicand
    input signed [WI2 + WF2 - 1 : 0] in2,            // Multiplier
    output signed [WIO + WFO - 1 : 0] out,           // Output
    output reg OVF                                   // Overflow Flag
);
    // Local Parameters
    localparam WIP = WI1 + WI2;             // local parameters for Precise integer bits
    localparam WFP = WF1 + WF2;             // local parameters for Precise fraction bits
    
    // Temporary registers for output
    reg [WIO - 1 : 0] temp_out_int_bits;
    reg [WFO - 1 : 0] temp_out_frac_bits;
    
    // Compute the full precision product
    wire signed [WIP + WFP - 1 : 0] fullPreciseProduct = in1 * in2;     // Precise product
    
    // fullPreciseProduct Sign bit
    wire sign_Bit = fullPreciseProduct[WIP + WFP - 1];                  // fullPreciseProduct Sign bit
    
    // Store Integer bits and Fraction bits
    wire [WIP - 1 : 0] precise_int_bits  = fullPreciseProduct[WIP + WFP - 1 : WFP];   // Just the integer  bits of fullPreciseProduct
    wire [WFP - 1 : 0] precise_frac_bits = fullPreciseProduct[WFP - 1 : 0];           // Just the fraction bits of fullPreciseProduct
    
    // Int temp wire
    reg [WIP - WIO - 1 : 0] tmp;   // Truncated integer bits minus the sign bit
    
    initial OVF <= 0;       // Set intial state of overflow = 0
    
    always @ (*)
    begin
        if(RESET) begin temp_out_int_bits <= 0; temp_out_frac_bits <= 0; end  // asynchronous RESET
        else
        begin
            // Logic for integer bits
            if( WIO == WIP )  // Assign precise bits to temp_out_int_bits
            begin
                temp_out_int_bits <= precise_int_bits;
                // ----------------------------- Check for overflow
                if( in1[WI1+WF1-1]==in2[WI2+WF2-1]==~out[WIO+WFO-1] || (~in1[WI1+WF1-1]==~in2[WI2+WF2-1]==out[WIO+WFO-1]) )
                    OVF <= 1;
                else
                    OVF <= 0;
            end
            else if( WIO > WIP )  // sign-extend
            begin
                temp_out_int_bits <= {{ (WIO - WIP){precise_int_bits[WIP - 1]}} , precise_int_bits };
                OVF <= 0;       // Overflow always = 0 in this case
            end
            else        // WIO < WI1 + WI2 - 1;
            begin
                tmp <= precise_int_bits[WIP - 1 : WIP - (WIP - WIO)];
                temp_out_int_bits <= { precise_int_bits[WIP - 1], precise_int_bits[WIO - 2 : 0] };
                   // ----------------------------- Check for overflow
                if( (in1[WI1+WF1-1]==in2[WI2+WF2-1]== (&tmp) ) || ( ~in1[WI1+WF1-1]==~in2[WI2+WF2-1]== (|tmp)) )
                    OVF <= 0;
                else
                    OVF <= 1;
            end
            
            
            
            // Logic for fraction bits
            if( WFO == WFP ) 
            begin                       // Assign precise bits to temp_out_frac_bits
                temp_out_frac_bits <= precise_frac_bits;
                OVF <= 0;
            end
            else if( WFO > WFP )
            begin                           // Append zeros
                temp_out_frac_bits <= { precise_frac_bits[WFP - 1 : 0] , {(WFO - (WF1 + WF2 + 1)){1'b0}} };
                OVF <= 0;
            end
            else
            begin       // WFO < WF1 + WF2 + 1; Truncate bits
                temp_out_frac_bits <= precise_frac_bits[WFP - 1 : WFP - 1 - (WFO - 1)];
                OVF <= 0;
            end
        end
    end
    
    assign out = {temp_out_int_bits, temp_out_frac_bits};
    
endmodule











