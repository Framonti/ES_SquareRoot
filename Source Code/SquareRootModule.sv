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

module SquareRootModule(clk, rst, doSqrt_i, s_i, valid_o, res_o);

    import lampFPU_pkg::*;
    
    input   clk;                                // Clock signal
    input   rst;                                // Reset signal   
    input   doSqrt_i;                           // Input command that signals the start of computation
    input   [(1+LAMP_FLOAT_F_DW)-1:0]	s_i;    // Significant of the value we want the sqrt of (8 bits)
         
    output  logic valid_o;                              // Signals that the output is valid
    output  logic [2*(1+LAMP_FLOAT_F_DW)-1:0] res_o;    // Final computed value  (16 bits)

    
    
    localparam logic [1:0]  IDLE        = 2'b00,
                            SQRT        = 2'b01,
                            OUTSTATE    = 2'b10;
endmodule
