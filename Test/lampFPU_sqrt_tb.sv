`timescale 1ns/1ps

module lampFPU_sqrt_tb;
	import lampFPU_pkg::*;

	logic                              clk_tb;
	logic                              rst_tb;
	logic                              doSqrt_i_tb;
	logic                              invSqrt_i_tb;
	logic [LAMP_FLOAT_S_DW-1:0]        signum_op_i_tb;
	logic [(LAMP_FLOAT_E_DW)-1:0]      extExp_op_i_tb;
	logic [(1+LAMP_FLOAT_F_DW)-1:0]    extMant_op_i_tb;
	logic                              isZero_op_i_tb;
    logic                              isInf_op_i_tb;
    logic                              isSNAN_op_i_tb;
    logic                              isQNAN_op_i_tb;
	
	logic                              isToRound_o_tb;
	logic							   valid_o_tb;
	logic                              s_res_o_tb;
	logic [LAMP_FLOAT_E_DW-1:0]	       e_res_o_tb;
	logic [LAMP_FLOAT_F_DW+5-1:0]      f_res_o_tb;

	always #5 clk_tb = ~clk_tb;

	initial
	begin
		clk_tb            <= 1;
		rst_tb            = 1;
		
		// Test 1
		// QNaN, positive sign
		doSqrt_i_tb       <= 0;
		invSqrt_i_tb      <= 0;	
		signum_op_i_tb    <= 0;	
        extExp_op_i_tb    <= 8'b11111111;
        extMant_op_i_tb   <= 8'b11000000;
        isZero_op_i_tb    <= 0;
        isInf_op_i_tb     <= 0;
        isSNAN_op_i_tb    <= 0;
        isQNAN_op_i_tb    <= 1;
			
		@(posedge clk_tb);
		rst_tb    <= 0;

		@(posedge clk_tb);
		doSqrt_i_tb   <= 1'b1;

		while (valid_o_tb == 0) @(posedge clk_tb);
		// QNaN (Positive)
        assert(s_res_o_tb == 0);
        assert(e_res_o_tb == 8'b11111111);
        assert(f_res_o_tb == 12'b100000000000);
        assert(isToRound_o_tb == 0);
		$display("s_res_o: %b,   e_res_o: %b,   f_res_o: 1.%b", s_res_o_tb, e_res_o_tb, f_res_o_tb);
		doSqrt_i_tb   = 0;
		
		repeat(5) @(posedge clk_tb);
		
		rst_tb    <= 1;       //clean up internal module before following test
        // Test 2
        // QNaN, negative sign
        doSqrt_i_tb       <= 0;
        invSqrt_i_tb      <= 0;    
        signum_op_i_tb    <= 1;    
        extExp_op_i_tb    <= 8'b11111111;
        extMant_op_i_tb   <= 8'b11000000;
        isZero_op_i_tb    <= 0;
        isInf_op_i_tb     <= 0;
        isSNAN_op_i_tb    <= 0;
        isQNAN_op_i_tb    <= 1;
            
        @(posedge clk_tb);
        rst_tb    <= 0;

        @(posedge clk_tb);
        doSqrt_i_tb   <= 1'b1;

        while (valid_o_tb == 0) @(posedge clk_tb);
        // QNaN (Negative)
        assert(s_res_o_tb == 1);
        assert(e_res_o_tb == 8'b11111111);
        assert(f_res_o_tb == 12'b100000000000);
        assert(isToRound_o_tb == 0);
        $display("s_res_o: %b,   e_res_o: %b,   f_res_o: 1.%b", s_res_o_tb, e_res_o_tb, f_res_o_tb);
        doSqrt_i_tb   = 0;
    
        repeat(5) @(posedge clk_tb);	
        rst_tb    <= 1;       //clean up internal module before following test
        // Test 3
        // SNaN, positive sign
        doSqrt_i_tb       <= 0;
        invSqrt_i_tb      <= 0;    
        signum_op_i_tb    <= 0;    
        extExp_op_i_tb    <= 8'b11111111;
        extMant_op_i_tb   <= 8'b10111111;
        isZero_op_i_tb    <= 0;
        isInf_op_i_tb     <= 0;
        isSNAN_op_i_tb    <= 1;
        isQNAN_op_i_tb    <= 0;
            
        @(posedge clk_tb);
        rst_tb    <= 0;

        @(posedge clk_tb);
        doSqrt_i_tb   <= 1'b1;

        while (valid_o_tb == 0) @(posedge clk_tb);
        // QNaN (positive)
        assert(s_res_o_tb == 0);
        assert(e_res_o_tb == 8'b11111111);
        assert(f_res_o_tb == 12'b100000000000);
        assert(isToRound_o_tb == 0);
        $display("s_res_o: %b,   e_res_o: %b,   f_res_o: 1.%b", s_res_o_tb, e_res_o_tb, f_res_o_tb);
        doSqrt_i_tb   = 0;
    
        repeat(5) @(posedge clk_tb);	
        rst_tb    <= 1;       //clean up internal module before following test
        // Test 4
        // SNaN, negative sign
        doSqrt_i_tb       <= 0;
        invSqrt_i_tb      <= 0;    
        signum_op_i_tb    <= 1;    
        extExp_op_i_tb    <= 8'b11111111;
        extMant_op_i_tb   <= 8'b10111111;
        isZero_op_i_tb    <= 0;
        isInf_op_i_tb     <= 0;
        isSNAN_op_i_tb    <= 1;
        isQNAN_op_i_tb    <= 0;
            
        @(posedge clk_tb);
        rst_tb    <= 0;

        @(posedge clk_tb);
        doSqrt_i_tb   <= 1'b1;

        while (valid_o_tb == 0) @(posedge clk_tb);
        // QNaN (Negative)
        assert(s_res_o_tb == 1);
        assert(e_res_o_tb == 8'b11111111);
        assert(f_res_o_tb == 12'b100000000000);
        assert(isToRound_o_tb == 0);
        $display("s_res_o: %b,   e_res_o: %b,   f_res_o: 1.%b", s_res_o_tb, e_res_o_tb, f_res_o_tb);
        doSqrt_i_tb   = 0;
    
        repeat(5) @(posedge clk_tb);	
        rst_tb    <= 1;       //clean up internal module before following test
        // Test 5
        // Infinite, positive
        doSqrt_i_tb       <= 0;
        invSqrt_i_tb      <= 0;    
        signum_op_i_tb    <= 0;    
        extExp_op_i_tb    <= 8'b11111111;
        extMant_op_i_tb   <= 8'b10000000;
        isZero_op_i_tb    <= 0;
        isInf_op_i_tb     <= 1;
        isSNAN_op_i_tb    <= 0;
        isQNAN_op_i_tb    <= 0;
            
        @(posedge clk_tb);
        rst_tb    <= 0;

        @(posedge clk_tb);
        doSqrt_i_tb   <= 1'b1;

        while (valid_o_tb == 0) @(posedge clk_tb);
        // Infinite (positive)
        assert(s_res_o_tb == 0);
        assert(e_res_o_tb == 8'b11111111);
        assert(f_res_o_tb == 12'b000000000000);
        assert(isToRound_o_tb == 0);
        $display("s_res_o: %b,   e_res_o: %b,   f_res_o: 1.%b", s_res_o_tb, e_res_o_tb, f_res_o_tb);
        doSqrt_i_tb   = 0;
    
        repeat(5) @(posedge clk_tb);
         rst_tb    <= 1;       //clean up internal module before following test
        // Test 6
        // Infinite, negative
        doSqrt_i_tb       <= 0;
        invSqrt_i_tb      <= 0;    
        signum_op_i_tb    <= 1;    
        extExp_op_i_tb    <= 8'b11111111;
        extMant_op_i_tb   <= 8'b10000000;
        isZero_op_i_tb    <= 0;
        isInf_op_i_tb     <= 1;
        isSNAN_op_i_tb    <= 0;
        isQNAN_op_i_tb    <= 0;
            
        @(posedge clk_tb);
        rst_tb    <= 0;

        @(posedge clk_tb);
        doSqrt_i_tb   <= 1'b1;

        while (valid_o_tb == 0) @(posedge clk_tb);
        // QNaN (negative)
        assert(s_res_o_tb == 1);
        assert(e_res_o_tb == 8'b11111111);
        assert(f_res_o_tb == 12'b100000000000);
        assert(isToRound_o_tb == 0);
        $display("s_res_o: %b,   e_res_o: %b,   f_res_o: 1.%b", s_res_o_tb, e_res_o_tb, f_res_o_tb);
        doSqrt_i_tb   = 0;
    
        repeat(5) @(posedge clk_tb);	
         rst_tb    <= 1;       //clean up internal module before following test
        // Test 7
        // Zero (positive)
        doSqrt_i_tb       <= 0;
        invSqrt_i_tb      <= 0;    
        signum_op_i_tb    <= 0;    
        extExp_op_i_tb    <= 8'b00000000;
        extMant_op_i_tb   <= 8'b10000000;
        isZero_op_i_tb    <= 1;
        isInf_op_i_tb     <= 0;
        isSNAN_op_i_tb    <= 0;
        isQNAN_op_i_tb    <= 0;
            
        @(posedge clk_tb);
        rst_tb    <= 0;

        @(posedge clk_tb);
        doSqrt_i_tb   <= 1'b1;

        while (valid_o_tb == 0) @(posedge clk_tb);
        // Zero (positive)
        assert(s_res_o_tb == 0);
        assert(e_res_o_tb == 8'b00000000);
        assert(f_res_o_tb == 12'b000000000000);
        assert(isToRound_o_tb == 0);
        $display("s_res_o: %b,   e_res_o: %b,   f_res_o: 1.%b", s_res_o_tb, e_res_o_tb, f_res_o_tb);
        doSqrt_i_tb   = 0;
    
        repeat(5) @(posedge clk_tb);	
         rst_tb    <= 1;       //clean up internal module before following test
        // Test 8
        // Zero (negative)
        doSqrt_i_tb       <= 0;
        invSqrt_i_tb      <= 0;    
        signum_op_i_tb    <= 1;    
        extExp_op_i_tb    <= 8'b00000000;
        extMant_op_i_tb   <= 8'b10000000;
        isZero_op_i_tb    <= 1;
        isInf_op_i_tb     <= 0;
        isSNAN_op_i_tb    <= 0;
        isQNAN_op_i_tb    <= 0;
            
        @(posedge clk_tb);
        rst_tb    <= 0;

        @(posedge clk_tb);
        doSqrt_i_tb   <= 1'b1;

        while (valid_o_tb == 0) @(posedge clk_tb);
        // Zero (negative)
        assert(s_res_o_tb == 1);
        assert(e_res_o_tb == 8'b00000000);
        assert(f_res_o_tb == 12'b000000000000);
        assert(isToRound_o_tb == 0);
        $display("s_res_o: %b,   e_res_o: %b,   f_res_o: 1.%b", s_res_o_tb, e_res_o_tb, f_res_o_tb);
        doSqrt_i_tb   = 0;
    
        repeat(5) @(posedge clk_tb);		

        rst_tb    <= 1;       //clean up internal module before following test
        // Test 9
        // inv QNaN (positive)
        doSqrt_i_tb       <= 0;
        invSqrt_i_tb      <= 1;    
        signum_op_i_tb    <= 0;    
        extExp_op_i_tb    <= 8'b11111111;
        extMant_op_i_tb   <= 8'b11000000;
        isZero_op_i_tb    <= 0;
        isInf_op_i_tb     <= 0;
        isSNAN_op_i_tb    <= 0;
        isQNAN_op_i_tb    <= 1;
            
        @(posedge clk_tb);
        rst_tb    <= 0;

        @(posedge clk_tb);
        doSqrt_i_tb   <= 1'b1;

        while (valid_o_tb == 0) @(posedge clk_tb);
        // QNaN (Positive)
        assert(s_res_o_tb == 0);
        assert(e_res_o_tb == 8'b11111111);
        assert(f_res_o_tb == 12'b100000000000);
        assert(isToRound_o_tb == 0);
        $display("s_res_o: %b,   e_res_o: %b,   f_res_o: 1.%b", s_res_o_tb, e_res_o_tb, f_res_o_tb);
        doSqrt_i_tb   = 0;
    
        repeat(5) @(posedge clk_tb);	
             rst_tb    <= 1;       //clean up internal module before following test
        // Test 10
        // inv QNaN (negative)
        doSqrt_i_tb       <= 0;
        invSqrt_i_tb      <= 1;    
        signum_op_i_tb    <= 1;    
        extExp_op_i_tb    <= 8'b11111111;
        extMant_op_i_tb   <= 8'b11000000;
        isZero_op_i_tb    <= 0;
        isInf_op_i_tb     <= 0;
        isSNAN_op_i_tb    <= 0;
        isQNAN_op_i_tb    <= 1;
            
        @(posedge clk_tb);
        rst_tb    <= 0;

        @(posedge clk_tb);
        doSqrt_i_tb   <= 1'b1;

        while (valid_o_tb == 0) @(posedge clk_tb);
        // QNaN (negative)
        assert(s_res_o_tb == 1);
        assert(e_res_o_tb == 8'b11111111);
        assert(f_res_o_tb == 12'b100000000000);
        assert(isToRound_o_tb == 0);
        $display("s_res_o: %b,   e_res_o: %b,   f_res_o: 1.%b", s_res_o_tb, e_res_o_tb, f_res_o_tb);
        doSqrt_i_tb   = 0;
    
        repeat(5) @(posedge clk_tb);	
             rst_tb    <= 1;       //clean up internal module before following test
        // Test 11
        // inv SNaN (positive)
        doSqrt_i_tb       <= 0;
        invSqrt_i_tb      <= 1;    
        signum_op_i_tb    <= 0;    
        extExp_op_i_tb    <= 8'b11111111;
        extMant_op_i_tb   <= 8'b10111111;
        isZero_op_i_tb    <= 0;
        isInf_op_i_tb     <= 0;
        isSNAN_op_i_tb    <= 1;
        isQNAN_op_i_tb    <= 0;
            
        @(posedge clk_tb);
        rst_tb    <= 0;

        @(posedge clk_tb);
        doSqrt_i_tb   <= 1'b1;

        while (valid_o_tb == 0) @(posedge clk_tb);
        // QNaN (positive)
        assert(s_res_o_tb == 0);
        assert(e_res_o_tb == 8'b11111111);
        assert(f_res_o_tb == 12'b100000000000);
        assert(isToRound_o_tb == 0);
        $display("s_res_o: %b,   e_res_o: %b,   f_res_o: 1.%b", s_res_o_tb, e_res_o_tb, f_res_o_tb);
        doSqrt_i_tb   = 0;
    
        repeat(5) @(posedge clk_tb);	
             rst_tb    <= 1;       //clean up internal module before following test
        // Test 12
        // inv SNaN (negative)
        doSqrt_i_tb       <= 0;
        invSqrt_i_tb      <= 1;    
        signum_op_i_tb    <= 1;    
        extExp_op_i_tb    <= 8'b11111111;
        extMant_op_i_tb   <= 8'b10111111;
        isZero_op_i_tb    <= 0;
        isInf_op_i_tb     <= 0;
        isSNAN_op_i_tb    <= 1;
        isQNAN_op_i_tb    <= 0;
            
        @(posedge clk_tb);
        rst_tb    <= 0;

        @(posedge clk_tb);
        doSqrt_i_tb   <= 1'b1;

        while (valid_o_tb == 0) @(posedge clk_tb);
        // QNaN (negative)
        assert(s_res_o_tb == 1);
        assert(e_res_o_tb == 8'b11111111);
        assert(f_res_o_tb == 12'b100000000000);
        assert(isToRound_o_tb == 0);
        $display("s_res_o: %b,   e_res_o: %b,   f_res_o: 1.%b", s_res_o_tb, e_res_o_tb, f_res_o_tb);
        doSqrt_i_tb   = 0;
    
        repeat(5) @(posedge clk_tb);	
             rst_tb    <= 1;       //clean up internal module before following test
        // Test 13
        // Inv inf (positive)
        doSqrt_i_tb       <= 0;
        invSqrt_i_tb      <= 1;    
        signum_op_i_tb    <= 0;    
        extExp_op_i_tb    <= 8'b11111111;
        extMant_op_i_tb   <= 8'b10000000;
        isZero_op_i_tb    <= 0;
        isInf_op_i_tb     <= 1;
        isSNAN_op_i_tb    <= 0;
        isQNAN_op_i_tb    <= 0;
            
        @(posedge clk_tb);
        rst_tb    <= 0;

        @(posedge clk_tb);
        doSqrt_i_tb   <= 1'b1;

        while (valid_o_tb == 0) @(posedge clk_tb);
        // Zero (positive)
        assert(s_res_o_tb == 0);
        assert(e_res_o_tb == 8'b00000000);
        assert(f_res_o_tb == 12'b000000000000);
        assert(isToRound_o_tb == 0);
        $display("s_res_o: %b,   e_res_o: %b,   f_res_o: 1.%b", s_res_o_tb, e_res_o_tb, f_res_o_tb);
        doSqrt_i_tb   = 0;
    
        repeat(5) @(posedge clk_tb);	
             rst_tb    <= 1;       //clean up internal module before following test
        // Test 14
        // Inv inf (negative)
        doSqrt_i_tb       <= 0;
        invSqrt_i_tb      <= 1;    
        signum_op_i_tb    <= 1;    
        extExp_op_i_tb    <= 8'b11111111;
        extMant_op_i_tb   <= 8'b10000000;
        isZero_op_i_tb    <= 0;
        isInf_op_i_tb     <= 1;
        isSNAN_op_i_tb    <= 0;
        isQNAN_op_i_tb    <= 0;
            
        @(posedge clk_tb);
        rst_tb    <= 0;

        @(posedge clk_tb);
        doSqrt_i_tb   <= 1'b1;

        while (valid_o_tb == 0) @(posedge clk_tb);
        // QNaN (negative)
        assert(s_res_o_tb == 1);
        assert(e_res_o_tb == 8'b11111111);
        assert(f_res_o_tb == 12'b100000000000);
        assert(isToRound_o_tb == 0);
        $display("s_res_o: %b,   e_res_o: %b,   f_res_o: 1.%b", s_res_o_tb, e_res_o_tb, f_res_o_tb);
        doSqrt_i_tb   = 0;
    
        repeat(5) @(posedge clk_tb);	
        rst_tb    <= 1;       //clean up internal module before following test
        // Test 15
        // inv Zero (positive)
        doSqrt_i_tb       <= 0;
        invSqrt_i_tb      <= 1;    
        signum_op_i_tb    <= 0;    
        extExp_op_i_tb    <= 8'b00000000;
        extMant_op_i_tb   <= 8'b10000000;
        isZero_op_i_tb    <= 1;
        isInf_op_i_tb     <= 0;
        isSNAN_op_i_tb    <= 0;
        isQNAN_op_i_tb    <= 0;
            
        @(posedge clk_tb);
        rst_tb    <= 0;

        @(posedge clk_tb);
        doSqrt_i_tb   <= 1'b1;

        while (valid_o_tb == 0) @(posedge clk_tb);
        // QNaN (positive)
        assert(s_res_o_tb == 0);
        assert(e_res_o_tb == 8'b11111111);
        assert(f_res_o_tb == 12'b100000000000);
        assert(isToRound_o_tb == 0);
        $display("s_res_o: %b,   e_res_o: %b,   f_res_o: 1.%b", s_res_o_tb, e_res_o_tb, f_res_o_tb);
        doSqrt_i_tb   = 0;

         rst_tb    <= 1;       //clean up internal module before following test
        // Test 16
        // Inv Zero (negative)
        doSqrt_i_tb       <= 0;
        invSqrt_i_tb      <= 1;    
        signum_op_i_tb    <= 1;    
        extExp_op_i_tb    <= 8'b00000000;
        extMant_op_i_tb   <= 8'b10000000;
        isZero_op_i_tb    <= 1;
        isInf_op_i_tb     <= 0;
        isSNAN_op_i_tb    <= 0;
        isQNAN_op_i_tb    <= 0;
            
        @(posedge clk_tb);
        rst_tb    <= 0;

        @(posedge clk_tb);
        doSqrt_i_tb   <= 1'b1;

        while (valid_o_tb == 0) @(posedge clk_tb);
        // QNaN (negative)
        assert(s_res_o_tb == 1);
        assert(e_res_o_tb == 8'b11111111);
        assert(f_res_o_tb == 12'b100000000000);
        assert(isToRound_o_tb == 0);
        $display("s_res_o: %b,   e_res_o: %b,   f_res_o: 1.%b", s_res_o_tb, e_res_o_tb, f_res_o_tb);
        doSqrt_i_tb   = 0;
    
        repeat(5) @(posedge clk_tb);	
		$finish;
	end

	lampFPU_sqrt #()
		sqrt0(	.clk            (clk_tb),
				.rst            (rst_tb),
				.doSqrt_i       (doSqrt_i_tb),
				.invSqrt_i      (invSqrt_i_tb),
				.signum_op_i    (signum_op_i_tb),
				.extExp_op_i    (extExp_op_i_tb),
				.extMant_op_i   (extMant_op_i_tb),
				.isInf_op_i     (isInf_op_i_tb),
				.isZero_op_i    (isZero_op_i_tb),
				.isQNAN_op_i    (isQNAN_op_i_tb),
				.isSNAN_op_i    (isSNAN_op_i_tb),
				.isToRound_o    (isToRound_o_tb),
				.valid_o        (valid_o_tb),
				.s_res_o        (s_res_o_tb),
				.e_res_o        (e_res_o_tb),
				.f_res_o        (f_res_o_tb));

endmodule