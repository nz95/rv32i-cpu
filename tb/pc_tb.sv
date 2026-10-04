`timescale 1ns/1ps

module pc_tb;

	logic clk;
	logic rst;
	logic [31:0] next_pc;
	logic [31:0] pc;

	integer pass_count;
	integer fail_count;

	pc dut (
		.clk(clk),
		.rst(rst),
		.next_pc(next_pc),
		.pc(pc)
	);

	always #5 clk = ~clk;

	task check_pc;
		input [31:0] expected;
		input [8*30-1:0] test_name;

		begin
			#1;

			if (pc !== expected) begin
				$display("FAIL: %0s", test_name);
				$display("  expected pc = %h", expected);
				$display("  actual   pc = %h", pc);
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
		rst = 0;
		next_pc = 0;

		pass_count = 0;
		fail_count = 0;

		// Test 1: reset PC to zero
		rst = 1;

		@(posedge clk);
		#1;

		rst = 0;
		check_pc(32'h00000000, "reset pc");

		// Test 2: advance to address 4
		next_pc = 32'h00000004;

		@(posedge clk);
		#1;

		check_pc(32'h00000004, "pc to 4");

		// Test 3: advance to address 8
		next_pc = 32'h00000008;

		@(posedge clk);
		#1;

		check_pc(32'h00000008, "pc to 8");

		// Test 4: jump to arbitrary address
		next_pc = 32'h00000100;

		@(posedge clk);
		#1;

		check_pc(32'h00000100, "pc jump");

		// Test 5: rst overrides next_pc
		next_pc = 32'h12345678;
		rst = 1;

		@(posedge clk);
		#1;

		rst = 0;
		check_pc(32'h00000000, "rst overrides next pc");

		$display("");
		$display("Tests passed: %0d", pass_count);
		$display("Tests failed: %0d", fail_count);

		if (fail_count == 0)
			$display("ALL PC TESTS PASSED");
		else
			$display("PC TESTS FAILED");

		$finish;

	end

endmodule
