`timescale 1ns/1ps

module cpu_branch_types_tb;

	logic clk;
	logic rst;

	integer pass_count;
	integer fail_count;

	cpu #(
		.MEM_FILE("programs/branch_types_test.hex")
	) dut (
		.clk(clk),
		.rst(rst)
	);

	always #5 clk = ~clk;

	task check_register;
		input [4:0] reg_num;
		input [31:0] expected;
		input [8*30-1:0] test_name;

		begin
			if (dut.u_regfile.registers[reg_num] !== expected) begin
				$display("FAIL: %0s", test_name);
				$display("  expected = %h", expected);
				$display("  actual   = %h", dut.u_regfile.registers[reg_num]);
				fail_count = fail_count + 1;
			end
			else begin
				$display("PASS: %0s", test_name);
				pass_count = pass_count + 1;
			end
		end
	endtask

	initial begin

		clk = 0;
		rst = 1;

		pass_count = 0;
		fail_count = 0;

		// Reset CPU
		@(posedge clk);
		#1;
		rst = 0;

		// 15 instructions should actually execute.
		repeat (15) begin
			@(posedge clk);
			#1;
		end

		check_register(5'd1, 32'd5, "x1 = 5");
		check_register(5'd2, 32'd10, "x2 = 10");
		check_register(5'd3, 32'hFFFFFFFF, "x3 = -1");
		check_register(5'd4, 32'd1, "x4 = 1");

		check_register(5'd5, 32'd1, "BNE taken");
		check_register(5'd6, 32'd2, "BLT signed taken");
		check_register(5'd7, 32'd3, "BGE taken");
		check_register(5'd8, 32'd4, "BLTU not taken");
		check_register(5'd9, 32'd5, "post-BLTU execution");
		check_register(5'd10, 32'd6, "BGEU taken");

		if (dut.pc_current !== 32'h0000004C) begin
			$display("FAIL: PC");
			$display("  expected = 0000004C");
			$display("  actual   = %h", dut.pc_current);
			fail_count = fail_count + 1;
		end
		else begin
			$display("PASS: PC = 0x4C");
			pass_count = pass_count + 1;
		end

		$display("");
		$display("Tests passed: %0d", pass_count);
		$display("Tests failed: %0d", fail_count);

		if (fail_count == 0)
			$display("ALL CPU BRANCH TYPE TESTS PASSED");
		else
			$display("CPU BRANCH TYPE TESTS FAILED");

		$finish;

	end

endmodule
