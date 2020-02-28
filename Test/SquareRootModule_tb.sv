`timescale 1ns/1ps

module SquareRootModule_tb;
	import lampFPU_pkg::*;

	logic 								clk_tb;
	logic 								rst_tb;
	logic [(1+LAMP_FLOAT_F_DW)-1:0]		s_i_tb;
	logic                               is_exp_odd_i_tb;
	logic 								doSqrt_i_tb;
	logic                               special_case_i_tb;

	logic								valid_o_tb;
	logic [(1+LAMP_FLOAT_F_DW)-1:0] 	res_o_tb;

	always #5 clk_tb = ~clk_tb;

	initial
	begin
		clk_tb 		<= 1;
		rst_tb 		= 1;
		doSqrt_i_tb = 0;
		s_i_tb 		= '0;
		is_exp_odd_i_tb = 0;
		special_case_i_tb = 0;
		//$display("LAMP: %d", LAMP_APPROX_MULS);
		//$display("clog: %b", $clog2(LAMP_APPROX_MULS)-1);

		@(posedge clk_tb);
		@(posedge clk_tb);
		rst_tb <= 0;

		@(posedge clk_tb);
		special_case_i_tb = 1;
		is_exp_odd_i_tb = 1;
		s_i_tb 		<= 8'b00000000;
		doSqrt_i_tb <= 1'b1;

		while (valid_o_tb == 0) @(posedge clk_tb);

		$display("res_o: %b", res_o_tb);
		doSqrt_i_tb = 0;

		repeat(5) @(posedge clk_tb);
		$finish;
	end

	SquareRootModule #()
		sqrt0(	.clk(clk_tb),
				.rst(rst_tb),
				.doSqrt_i(doSqrt_i_tb),
				.s_i(s_i_tb),
				.is_exp_odd_i(is_exp_odd_i_tb),
				.special_case_i(special_case_i_tb),
				.res_o(res_o_tb),
				.valid_o(valid_o_tb));

endmodule