`timescale 1ns/1ps

module branch_comparator_tb;

	logic [31:0] a;
	logic [31:0] b;
	logic [2:0] funct3;
	logic branch_taken;

	integer pass_count;
	integer fail_count;

	branch_comparator dut (
		.a(a),
		.b(b),
		.funct3(funct3),
		.branch_taken(branch_taken)
	);

	task check_branch;
		input expected;
		input [8*30-1:0] test_name;

		begin
			#1;

			if (branch_taken !== expected) begin
				$display("FAIL: %0s", test_name);
				$display("  a            = %h", a);
				$display("  b            = %h", b);
				$display("  funct3       = %b", funct3);
				$display("  expected     = %b", expected);
				$display("  branch_taken = %b", branch_taken);
				fail_count = fail_count + 1;
			end
			else begin
				$display("PASS: %0s", test_name);
				pass_count = pass_count + 1;
			end
		end
	endtask

	initial begin

		pass_count = 0;
		fail_count = 0;

		// Test 1: BEQ true
		a = 32'd10;
		b = 32'd10;
		funct3 = 3'b000;
		check_branch(1'b1, "BEQ true");

		// Test 2: BEQ false
		b = 32'd5;
		check_branch(1'b0, "BEQ false");

		// Test 3: BNE true
		funct3 = 3'b001;
		check_branch(1'b1, "BNE true");

		// Test 4: BNE false
		b = 32'd10;
		check_branch(1'b0, "BNE false");

		// Test 5: BLT signed true
		a = 32'hFFFFFFFF;
		b = 32'd1;
		funct3 = 3'b100;
		check_branch(1'b1, "BLT signed");

		// Test 6: BGE signed false
		funct3 = 3'b101;
		check_branch(1'b0, "BGE signed");

		// Test 7: BLTU unsigned false
		funct3 = 3'b110;
		check_branch(1'b0, "BLTU unsigned");

		// Test 8: BGEU unsigned true
		funct3 = 3'b111;
		check_branch(1'b1, "BGEU unsigned");

		// Test 9: BLT positive values
		a = 32'd5;
		b = 32'd10;
		funct3 = 3'b100;
		check_branch(1'b1, "BLT positive");

		// Test 10: BGE equal values
		a = 32'd20;
		b = 32'd20;
		funct3 = 3'b101;
		check_branch(1'b1, "BGE equal");

		$display("");
		$display("Tests passed: %0d", pass_count);
		$display("Tests failed: %0d", fail_count);

		if (fail_count == 0)
			$display("ALL BRANCH COMPARATOR TESTS PASSED");
		else
			$display("BRANCH COMPARATOR TESTS FAILED");

		$finish;

	end

endmodule
