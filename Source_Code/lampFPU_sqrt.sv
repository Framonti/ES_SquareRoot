
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


module lampFPU_sqrt(
       clk, rst,
    
        //inputs
       doSqrt_i,
       invSqrt_i,
       signum_op_i,
       extExp_op_i,
       extMant_op_i,
       isInf_op_i,
       isZero_op_i,
       isSNAN_op_i,
       isQNAN_op_i,
 
       //outputs
       s_res_o, 
       e_res_o, 
       f_res_o, 
       valid_o,
       isToRound_o
  );
    
    import lampFPU_pkg::*;
    
    input   clk;
    input   rst;
    
    input                              doSqrt_i;
    input                              invSqrt_i;
    input   [LAMP_FLOAT_S_DW-1:0]	   signum_op_i;     // The operand signum (1 bit)
    input   [(LAMP_FLOAT_E_DW)-1:0]    extExp_op_i;     
    input   [(1+LAMP_FLOAT_F_DW)-1:0]  extMant_op_i;    // The extended mantissa (8 bits)
    input                              isInf_op_i;                             
    input                              isZero_op_i;
    input                              isQNAN_op_i;
    input                              isSNAN_op_i;
    
    output logic                            valid_o;
    output logic                            s_res_o;           // resulting sign (1 bit)
    output logic [LAMP_FLOAT_E_DW-1:0]	    e_res_o;           // resulting exponent (8 bits)
    output logic [LAMP_FLOAT_F_DW+5-1:0]    f_res_o;           // resulting significand (12 bits)
    output logic                            isToRound_o;
   
   
   //////////////////////////////////////////////////////////////////
   //      internal wires       //
   //////////////////////////////////////////////////////////////////
   
   
   //Next values
   logic                                valid_next;
   logic                                isToRound_next;
   logic                                stickyBit;
   logic                                s_res_next;
   logic [LAMP_FLOAT_E_DW-1:0]          e_res_next;
   logic [LAMP_FLOAT_F_DW+5-1:0]        f_res_next;
   logic [2*(1+LAMP_FLOAT_F_DW)-1:0]    f_initial;
   logic							    isCheckNanInfValid;
   logic                                isZeroRes;
   logic                                isCheckInfRes;
   logic                                isCheckNanRes;
   logic                                isCheckSignRes;
   logic [LAMP_FLOAT_S_DW-1:0]          signum_op_r;
   logic                                isZero_op_r, isInf_op_r, isSNAN_op_r, isQNAN_op_r;

   logic                                srm_doSqrt;
   logic                                srm_invSqrt;
   logic                                srm_is_exp_odd;
   logic [(1+LAMP_FLOAT_F_DW)-1:0]      srm_s;
   logic [2*(1+LAMP_FLOAT_F_DW)-1:0]    srm_res;
   logic                                srm_valid;
       
       
   //////////////////////////////////////////////////////////////////
   //      internal submodules      //
   //////////////////////////////////////////////////////////////////
   SquareRootModule SquareRootModule0 (
     .clk               (clk),
     .rst               (rst),
     .doSqrt_i          (srm_doSqrt),
     .s_i               (srm_s),
     .is_exp_odd_i      (srm_is_exp_odd),
     .invSqrt_i         (srm_invSqrt),
     .special_case_i    (isCheckNanInfValid),
     .res_o             (srm_res),
     .valid_o           (srm_valid)
    );
    
    //////////////////////////////////////////////////////////////////
    //      wire assignments      //
    //////////////////////////////////////////////////////////////////
    assign srm_doSqrt       = doSqrt_i;
    assign srm_invSqrt      = invSqrt_i;
    assign srm_is_exp_odd   = (~extExp_op_i[0]) & (extExp_op_i != 0);
    assign srm_s            = extMant_op_i;

    //////////////////////////////////////////////////////////////////
    // 						sequential logic						//
    //////////////////////////////////////////////////////////////////
    
    always_ff @(posedge clk)
    begin
        if (rst)
        begin
            //Internal registers
            signum_op_r         <= 0;
            isZero_op_r         <= 0;
            isInf_op_r          <= 0;
            isSNAN_op_r         <= 0;
            isQNAN_op_r         <= 0;
            
            //Output registers
            isToRound_o         <= 0;
            valid_o             <= 0;
            s_res_o             <= 0;
            e_res_o             <= '0;
            f_res_o             <= '0;
        end
        else
        begin
            //Internal registers
            signum_op_r         <= signum_op_i;
            isZero_op_r         <= isZero_op_i;
            isInf_op_r          <= isInf_op_i;
            isSNAN_op_r         <= isSNAN_op_i;
            isQNAN_op_r         <= isQNAN_op_i;
            
            //Output registers
            isToRound_o         <= isToRound_next;
            valid_o             <= valid_next;
            s_res_o             <= s_res_next;
            e_res_o             <= e_res_next;
            f_res_o             <= f_res_next;
        end
    end
    
    //////////////////////////////////////////////////////////////////
    //                         combinational logic                  //
    //////////////////////////////////////////////////////////////////

    always_comb
    begin
        {isCheckNanInfValid, isZeroRes, isCheckInfRes, isCheckNanRes, isCheckSignRes} = FUNC_calcInfNanZeroResSqrt(
                        isZero_op_i, isInf_op_i, signum_op_i, isSNAN_op_i, isQNAN_op_i, invSqrt_i      /*operand */
                );
        
        unique if (isZeroRes)
        begin
            {s_res_next, e_res_next, f_res_next}    = {isCheckSignRes, ZERO_E_F[14:7], ZERO_E_F[6:0], 5'b00000};
        end
        else if (isCheckInfRes)
        begin
            {s_res_next, e_res_next, f_res_next}    = {isCheckSignRes, INF_E_F[14:7], INF_E_F[6:0], 5'b00000};
        end
        else if (isCheckNanRes)
        begin
            {s_res_next, e_res_next, f_res_next}    = {isCheckSignRes, QNAN_E_F[14:7], QNAN_E_F[6:0], 5'b00000};
        end
        else
        begin
            e_res_next  = FUNC_calcExpSquareRoot( extExp_op_i, invSqrt_i );
            s_res_next  = 0;
            
//            f_initial = srm_res;
//            stickyBit = |f_initial[2+:3];
//            f_res_next  = {1'b0, f_initial[(2*(1+LAMP_FLOAT_F_DW)-1) -:(1+1+LAMP_FLOAT_F_DW+3-1-1-1)], f_initial[(2*(1+LAMP_FLOAT_F_DW)-1) - (1+1+LAMP_FLOAT_F_DW+3-1-1)] | stickyBit, stickyBit};
            
            f_initial = srm_res;
            stickyBit = |f_initial[4:0];
            f_res_next  = {1'b0, f_initial[(2*(1+LAMP_FLOAT_F_DW)-1) -:(1+1+LAMP_FLOAT_F_DW+3-1-1-1)], f_initial[(2*(1+LAMP_FLOAT_F_DW)-1) - (1+1+LAMP_FLOAT_F_DW+3-1-1)] | stickyBit, stickyBit};
            
        end
        
        isToRound_next  = ~isCheckNanInfValid;
        valid_next      = srm_valid;
    end

endmodule
