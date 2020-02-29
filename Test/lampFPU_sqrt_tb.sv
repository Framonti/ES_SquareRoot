`timescale 1ns/1ps

module lampFPU_sqrt_tb;
	import lampFPU_pkg::*;

	logic                              clk_tb;
	logic                              rst_tb;
	logic                              doSqrt_i_tb;
	logic [LAMP_FLOAT_S_DW-1:0]        signum_op_i_tb;
	logic [(LAMP_FLOAT_E_DW)-1:0]      extExp_op_i_tb;
	logic [(1+LAMP_FLOAT_F_DW)-1:0]    extMant_op_i_tb;
	logic                              isZero_op_i_tb;
    logic                              isInf_op_i_tb;
    logic                              isSNAN_op_i_tb;
    logic                              isQNAN_op_i_tb;
	
	logic								valid_o_tb;
	logic                               s_res_o_tb;
	logic [LAMP_FLOAT_E_DW-1:0]	        e_res_o_tb;
	logic [LAMP_FLOAT_F_DW-1:0]         f_res_o_tb;

	always #5 clk_tb = ~clk_tb;

	initial
	begin
		clk_tb            <= 1;
		rst_tb            = 1;
		doSqrt_i_tb       = 0;
		signum_op_i_tb    <= 1;
        extExp_op_i_tb    <= 8'b11111111;
        extMant_op_i_tb   <= 8'b01111111;
        isZero_op_i_tb    <= 0;
        isInf_op_i_tb     <= 0;
        isSNAN_op_i_tb    <= 1;
        isQNAN_op_i_tb    <= 0;
		
		
		@(posedge clk_tb);
		@(posedge clk_tb);
		rst_tb    <= 0;

		@(posedge clk_tb);
		doSqrt_i_tb   <= 1'b1;
		

		while (valid_o_tb == 0) @(posedge clk_tb);

		$display("s_res_o: %b,   e_res_o: %b,   f_res_o: 1.%b", s_res_o_tb, e_res_o_tb, f_res_o_tb);
		doSqrt_i_tb   = 0;

		repeat(5) @(posedge clk_tb);
		$finish;
	end

	lampFPU_sqrt #()
		sqrt0(	.clk(clk_tb),
				.rst(rst_tb),
				.doSqrt_i(doSqrt_i_tb),
				.signum_op_i(signum_op_i_tb),
				.extExp_op_i(extExp_op_i_tb),
				.extMant_op_i(extMant_op_i_tb),
				.isInf_op_i(isInf_op_i_tb),
				.isZero_op_i(isZero_op_i_tb),
				.isQNAN_op_i(isQNAN_op_i_tb),
				.isSNAN_op_i(isSNAN_op_i_tb),
				.valid_o(valid_o_tb),
				.s_res_o(s_res_o_tb),
				.e_res_o(e_res_o_tb),
				.f_res_o(f_res_o_tb));

endmodule