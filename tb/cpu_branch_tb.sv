`timescale 1ns/1ps

module cpu_branch_tb;

	logic clk;
	logic rst;

	integer pass_count;
	integer fail_count;

	cpu #(
		.MEM_FILE("programs/branch_test.hex")
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
				$display("  expected = %0d", expected);
				$display("  actual   = %0d", dut.u_regfile.registers[reg_num]);
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

		// addi x1, x0, 5
		@(posedge clk);
		#1;

		// addi x2, x0, 5
		@(posedge clk);
		#1;

		// beq x1, x2, 8
		// Branch should be taken from PC 0x08 to PC 0x10
		@(posedge clk);
		#1;

		// addi x3, x0, 42
		// The instruction at PC 0x0C should have been skipped
		@(posedge clk);
		#1;

		check_register(5'd1, 32'd5, "x1 = 5");
		check_register(5'd2, 32'd5, "x2 = 5");
		check_register(5'd3, 32'd42, "x3 = 42");

		if (dut.pc_current !== 32'h00000014) begin
			$display("FAIL: PC");
			$display("  expected = 00000014");
			$display("  actual   = %h", dut.pc_current);
			fail_count = fail_count + 1;
		end
		else begin
			$display("PASS: PC = 0x14");
			pass_count = pass_count + 1;
		end

		$display("");
		$display("Tests passed: %0d", pass_count);
		$display("Tests failed: %0d", fail_count);

		if (fail_count == 0)
			$display("ALL CPU BRANCH TESTS PASSED");
		else
			$display("CPU BRANCH TESTS FAILED");

		$finish;

	end

endmodule
