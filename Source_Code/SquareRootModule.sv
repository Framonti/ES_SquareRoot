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

module SquareRootModule(clk, rst, doSqrt_i, s_i, is_exp_odd_i, special_case_i, valid_o, res_o);

    import lampFPU_pkg::*;
    
    input   clk;                                // Clock signal
    input   rst;                                // Reset signal   
    input   doSqrt_i;                           // Input command that signals the start of computation
    input   [(1+LAMP_FLOAT_F_DW)-1:0]	s_i;    // Significant of the value we want the sqrt of (8 bits)
    input   is_exp_odd_i;
    input   special_case_i;
         
    output  logic valid_o;                              // Signals that the output is valid
    output  logic [(1+LAMP_FLOAT_F_DW)-1:0] res_o;    // Final computed value  (8 bits)


//////////////////////////////////////////////////////////////////
//						internal wires							//
//////////////////////////////////////////////////////////////////

    logic  [2*(1+LAMP_FLOAT_F_DW+LAMP_PREC_DW)-1:0] 	b_tmp;             //32 bits
	logic  [(1+LAMP_FLOAT_F_DW+LAMP_PREC_DW)-1:0] 	    y_tmp;             //16 bits
	logic  [2*(1+LAMP_FLOAT_F_DW+LAMP_PREC_DW)-1:0] 	x_tmp;             //32 bits
	logic  [(1+LAMP_FLOAT_F_DW+LAMP_PREC_DW)-1:0] 	    r_tmp;             //16 bits
	
	logic  [(1+LAMP_FLOAT_F_DW+LAMP_PREC_DW)-1:0]       b_r, b_next;       //16 bits
	logic  [(1+LAMP_FLOAT_F_DW)-1:0]		            y_r, y_next;       //8 bits
	logic  [(1+LAMP_FLOAT_F_DW)-1:0]                    r_r, r_next;       //8 bits  
	logic  [(1+LAMP_FLOAT_F_DW+LAMP_PREC_DW)-1:0]       x_r, x_next;       //16 bits
	logic                                               is_exp_odd_r, is_exp_odd_next;
	
	logic	[(1+LAMP_FLOAT_F_DW)-1:0]					res_next;          //8 bits
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
                ss              <=    IDLE;
                b_r             <=    '0;
                y_r             <=    '0;
                r_r             <=    '0;
                x_r             <=    '0;
                is_exp_odd_r    <=    0;
                res_o           <=    '0;
                valid_o         <=    1'b0;
            end
            else
            begin
                ss              <=  ss_next;
                b_r             <=  b_next;
                y_r             <=  y_next;
                r_r             <=  r_next;
                x_r             <=  x_next;
                is_exp_odd_r    <=  is_exp_odd_next;
                res_o           <=  res_next;
                valid_o         <=  valid_next;
            end
        end

//////////////////////////////////////////////////////////////////
// 						combinational logic						//
//////////////////////////////////////////////////////////////////

    always_comb
	begin
		ss_next		=	ss;
		
		b_tmp       =   b_r * (r_r ** 2);
		r_tmp 		= 	(THREE_17 - {1'b0, b_r}) >> 1;
		x_tmp       =   (x_r * r_r) << (1+LAMP_FLOAT_F_DW);        //16 * 16 bits (maybe r_r?)
		y_tmp       =   y_r * r_r;
		//y_tmp       =   (y_r * r_r) >> 8;
		
		b_next		      =	b_r;
		y_next		      =	y_r;
		r_next		      =	r_r;
		x_next		      =	x_r;
		is_exp_odd_next   = is_exp_odd_r;
		res_next          =	'0;
		valid_next        =	1'b0;
		
		case (ss)
			IDLE:
			begin
			    if (special_case_i)
			    begin
			        valid_next = 1;
			    end
				else if (doSqrt_i)
				begin
					ss_next            =   SQRT_B;
					b_next             =   s_i << (1+LAMP_FLOAT_F_DW);                     //8 bits shift
				    y_next             =   (THREE_9 - {1'b0, s_i}) >> 1;
					r_next		       =   y_next;
					x_next		       =   ((s_i * r_next) << 1);   //first bit is always a 0 so we can remove it
					is_exp_odd_next    =   is_exp_odd_i;
				end
			end
			
			SQRT_B:
			begin
			    if (r_r == APPROX_ONE)
			    begin
			         ss_next = IDLE;
			         if (is_exp_odd_r)
			         begin
                         x_tmp = (x_r * SQRT2);
                         res_next = x_tmp[(2*(1+LAMP_FLOAT_F_DW+LAMP_PREC_DW)-2)-:(1+LAMP_FLOAT_F_DW)] + 2 * (x_r[7] | x_r[6]);
                     end
                     else
                     begin
                         res_next = x_r[((1+LAMP_FLOAT_F_DW+LAMP_PREC_DW)-1)-:(1+LAMP_FLOAT_F_DW)] + (x_r[7] | x_r[6]);
                     end
                     valid_next = 1'b1;
			    end
			    else
			    begin
                    b_next = b_tmp[(2*(1+LAMP_FLOAT_F_DW+LAMP_PREC_DW)-3)-:(1+LAMP_FLOAT_F_DW+LAMP_PREC_DW)];  //first 2 bits are always 0 so we can remove them
                                             
                    ss_next = SQRT_R;
			    end
			end
			
			SQRT_R:
            begin
                r_next = r_tmp[(2*(1+LAMP_FLOAT_F_DW)-1)-:(1+LAMP_FLOAT_F_DW)];
                ss_next = SQRT_XY;
            end
            
            SQRT_XY:
            begin
                x_next = x_tmp[(2*(1+LAMP_FLOAT_F_DW+LAMP_PREC_DW)-2)-:(1+LAMP_FLOAT_F_DW+LAMP_PREC_DW)];
                y_next = y_tmp[(2*(1+LAMP_FLOAT_F_DW)-2)-:(1+LAMP_FLOAT_F_DW)];
                
                ss_next = SQRT_B;
            end
			
		endcase
	end
                                   
endmodule

// ~
