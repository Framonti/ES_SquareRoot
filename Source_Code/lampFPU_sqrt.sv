`timescale 1ns / 1ps

//////////////////////////////////////////////////////////////////////////////////
// Create Date: 02/17/2020 04:00:13 PM
// Module Name: lampFPU_sqrt
// Project Name: ES_SquareRoot

// Target: xc7a12tcpg238-3

// Revision:
// Revision 0.01 - Interface
// Revision 0.02 - 
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module lampFPU_sqrt(clk, rst,
    //inputs
   doSqrt_i,
   signum_op_i,
   extExp_op_i,
   extMant_op_i,
   isInf_op_i,
   isZero_op_i,
   //isSignumNAN_i,      
   //outputs
   s_res_o, 
   e_res_o, 
   f_res_o, 
   valid_o,
   isOverflow_o,
   isUnderflow_o
  // isToRound_o
    );
    
    import lampFPU_pkg::*;
    
    input   clk;
    input   rst;
    
    input                               doSqrt_i;
    input   [LAMP_FLOAT_S_DW-1:0]	   signum_op_i; //The operand signum (1 bit)
    input   [(LAMP_FLOAT_E_DW+1)-1:0]  extExp_op_i; // The extended exponent (8 bits)       
    input   [(1+LAMP_FLOAT_F_DW)-1:0]  extMant_op_i;// the extended mantissa (8 bits)
    input   isInf_op_i;                             
    input   isZero_op_i;
    //input isNegative_op_i ???
    
    output logic                            s_res_o;           // it will always be 0 by sqrt definition
    output logic [LAMP_FLOAT_E_DW-1:0]	    e_res_o;           // 
    output logic /*[LAMP_FLOAT_F_DW+5-1:0]*/   f_res_o; 
    output logic                            valid_o;
    output logic isOverflow_o;
    output logic isUnderflow_o;
   // output logic isToRound_o;
    
endmodule
