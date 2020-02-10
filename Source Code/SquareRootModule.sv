`timescale 1ns / 1ps

//////////////////////////////////////////////////////////////////////////////////
// Create Date: 02/10/2020 09:49:53 AM
// Module Name: SquareRootModule
// Project Name: ES_SquareRoot

// Target: xc7a12tcpg238-3

// Revision:
// Revision 0.01 - Interface
// Revision 0.02 - 
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////

module SquareRootModule(s_i, doSqrt_i, clk_i, valid_o, sqrt_o);

    input   s_i;        // Value we want to compute the sqrt of
    input   doSqrt_i;   // Input command that impones the start of computation
    input   clk_i;      // Clock signal
    output  valid_o;    // Signals that the output is valid
    output  sqrt_o;     // Final computed value  

    localparam logic [1:0]  IDLE        = 2'b00,
                            SQRT        = 2'b01,
                            OUTSTATE    = 2'b10;
endmodule
