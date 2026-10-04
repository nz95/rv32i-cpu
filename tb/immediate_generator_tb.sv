`timescale 1ns/1ps

module immediate_generator_tb;

	logic [31:0] instruction;
	logic [31:0] immediate;

	integer pass_count;
	integer fail_count;

	immediate_generator dut (
		.instruction(instruction),
		.immediate(immediate)
	);

	task check_immediate;
		input [31:0] expected;
		input [8*30-1:0] test_name;

		begin
			#1;

			if (immediate !== expected) begin
				$display("FAIL: %0s", test_name);
				$display("  instruction        = %h", instruction);
				$display("  expected immediate = %h", expected);
				$display("  actual   immediate = %h", immediate);
				fail_count = fail_count + 1;
			end
			else begin
				$display("PASS: %0s", test_name);
				pass_count = pass_count + 1;
			end
		end
	endtask

	initial begin

		instruction = 32'd0;

		pass_count = 0;
		fail_count = 0;

		// Test 1: I-type - addi x1, x0, 5
		instruction = 32'h00500093;
		check_immediate(32'd5, "I-type positive");

		// Test 2: I-type - addi x1, x0, -5
		instruction = 32'hFFB00093;
		check_immediate(32'hFFFFFFFB, "I-type negative");

		// Test 3: S-type - sw x2, 12(x1)
		instruction = 32'h0020A623;
		check_immediate(32'd12, "S-type");

		// Test 4: B-type - beq x1, x2, 16
		instruction = 32'h00208863;
		check_immediate(32'd16, "B-type positive");

		// Test 5: B-type - beq x1, x2, -16
		instruction = 32'hFE2088E3;
		check_immediate(32'hFFFFFFF0, "B-type negative");

		// Test 6: U-type - lui x5, 0x12345
		instruction = 32'h123452B7;
		check_immediate(32'h12345000, "U-type");

		// Test 7: J-type - jal x1, 32
		instruction = 32'h020000EF;
		check_immediate(32'd32, "J-type positive");

		// Test 8: J-type - jal x1, -32
		instruction = 32'hFE1FF0EF;
		check_immediate(32'hFFFFFFE0, "J-type negative");

		$display("");
		$display("Tests passed: %0d", pass_count);
		$display("Tests failed: %0d", fail_count);

		if (fail_count == 0)
			$display("ALL IMMEDIATE GENERATOR TESTS PASSED");
		else
			$display("IMMEDIATE GENERATOR TESTS FAILED");

		$finish;

	end

endmodule
