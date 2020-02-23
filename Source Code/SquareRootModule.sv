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
// CHECK FIRST BIT OF s_i IS A 0!!
//////////////////////////////////////////////////////////////////////////////////

module SquareRootModule(clk, rst, doSqrt_i, s_i, valid_o, res_o);

    import lampFPU_pkg::*;
    
    input   clk;                                // Clock signal
    input   rst;                                // Reset signal   
    input   doSqrt_i;                           // Input command that signals the start of computation
    input   signed [(1+LAMP_FLOAT_F_DW)-1:0]	s_i;    // Significant of the value we want the sqrt of (8 bits)
         
    output  logic valid_o;                              // Signals that the output is valid
    output  logic [2*(1+LAMP_FLOAT_F_DW)-1:0] res_o;    // Final computed value  (16 bits)


//////////////////////////////////////////////////////////////////
//						internal wires							//
//////////////////////////////////////////////////////////////////

    logic	signed [2*(1+LAMP_FLOAT_F_DW+LAMP_PREC_DW)-1:0] 	b_tmp;             //32 bits
	logic	signed [(1+LAMP_FLOAT_F_DW+LAMP_PREC_DW)-1:0] 	    y_tmp;             //16 bits
	logic	signed [2*(1+LAMP_FLOAT_F_DW+LAMP_PREC_DW)-1:0] 	x_tmp;             //32 bits
	logic	signed [(1+LAMP_FLOAT_F_DW+LAMP_PREC_DW)-1:0] 	    r_tmp;             //16 bits
	
	logic	signed [(1+LAMP_FLOAT_F_DW+LAMP_PREC_DW)-1:0]  b_r, b_next;       //16 bits
	logic	signed [(1+LAMP_FLOAT_F_DW)-1:0]		       y_r, y_next;       //8 bits
	logic	signed [(1+LAMP_FLOAT_F_DW)-1:0]		       r_r, r_next;       //8 bits  
	logic	signed [(1+LAMP_FLOAT_F_DW+LAMP_PREC_DW)-1:0]  x_r, x_next;       //16 bits
	logic	[$clog2(LAMP_APPROX_MULS)-1:0]				   i_r, i_next;       //2 bits
	
	
	logic	[2*(1+LAMP_FLOAT_F_DW)-1:0]					res_next;          //16 bits
	logic												valid_next;        //1 bit

    
    localparam logic [1:0]  IDLE        = 2'b00,
                            SQRT_B      = 2'b01,
                            SQRT_R      = 2'b10,
                            SQRT_XY     = 2'b11;
                            
    logic [1:0]	ss, ss_next;
    
    always_ff @(posedge clk)
        begin
            if (rst)
            begin
                ss         <=    IDLE;
                b_r        <=    '0;
                y_r        <=    '0;
                r_r        <=    '0;
                x_r        <=    '0;
                i_r        <=    '0;
                res_o      <=    '0;
                valid_o    <=    1'b0;
            end
            else
            begin
                ss         <=    ss_next;
                b_r        <=    b_next;
                y_r        <=    y_next;
                r_r        <=    r_next;
                x_r        <=    x_next;
                i_r        <=    i_next;
                res_o      <=    res_next;
                valid_o    <=    valid_next;
            end
        end

//////////////////////////////////////////////////////////////////
// 						combinational logic						//
//////////////////////////////////////////////////////////////////

always_comb
	begin
		ss_next		=	ss;
		
		b_tmp       =   b_r * (y_r ** 2);
		r_tmp       =   (3 - b_r) >> 1;
		x_tmp       =   x_r * r_tmp;        //16 * 16 bits (maybe r_r?)
		y_tmp       =   y_r * r_r;
		
		b_next		=	b_r;
		y_next		=	y_r;
		r_next		=	r_r;
		x_next		=	x_r;
		i_next		=	i_r;
		res_next	=	'0;
		valid_next	=	1'b0;
		
		case (ss)
			IDLE:
			begin
				if (doSqrt_i)
				begin
					ss_next		=	SQRT_B;
					b_next		=	s_i;// << (1+LAMP_FLOAT_F_DW);  //8 bits shift????
					y_next		=	(3 - s_i) >> 1;
					r_next		=	y_next;
					x_next		=	s_i * r_next;
					i_next		=	'0;
				end
			end
			
			SQRT_B:
			begin
			    if (i_r == LAMP_APPROX_MULS - 1)
			    begin
			         ss_next = IDLE;
                     res_next = x_r;
                     valid_next = 1'b1;
			    end
			    else
			    begin
                     b_next = b_tmp[(2*(1+LAMP_FLOAT_F_DW+LAMP_PREC_DW)-2)-:(1+LAMP_FLOAT_F_DW+LAMP_PREC_DW)];
                     // b_next = b_tmp[(31-FUNC_i2f_integerExponent(b_tmp))-:(1+LAMP_FLOAT_F_DW+LAMP_PREC_DW)];  roba di nappo
                     ss_next = SQRT_R;
			    end
			end
			
			SQRT_R:
            begin
                r_next = r_tmp[(2*(1+LAMP_FLOAT_F_DW)-2)-:(1+LAMP_FLOAT_F_DW)];
                ss_next = SQRT_XY;
            end
            
            SQRT_XY:
            begin
                x_next = x_tmp[(2*(1+LAMP_FLOAT_F_DW+LAMP_PREC_DW)-2)-:(1+LAMP_FLOAT_F_DW+LAMP_PREC_DW)];
                
                y_next = y_tmp[(2*(1+LAMP_FLOAT_F_DW)-2)-:(1+LAMP_FLOAT_F_DW)];
                
                i_next = i_r + 1;
                ss_next = SQRT_B;
            end
			
		endcase
	end
                                   
endmodule

// ~
