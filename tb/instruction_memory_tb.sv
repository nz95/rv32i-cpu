`timescale 1ns/1ps

module instruction_memory_tb;

	logic [31:0] addr;
	logic [31:0] instruction;

	integer pass_count;
	integer fail_count;

	instruction_memory dut (
		.addr(addr),
		.instruction(instruction)
	);

	task check_instruction;
		input [31:0] expected;
		input [8*30-1:0] test_name;

		begin
			#1;

			if (instruction !== expected) begin
				$display("FAIL: %0s", test_name);
				$display("  expected instruction = %h", expected);
				$display("  actual   instruction = %h", instruction);
				fail_count = fail_count + 1;
			end
			else begin
				$display("PASS: %0s", test_name);
				pass_count = pass_count + 1;
			end
		end
	endtask

	initial begin

		addr = 32'd0;

		pass_count = 0;
		fail_count = 0;

		// Test 1: address 0x00 should read memory[0]
		addr = 32'h00000000;
		check_instruction(32'h00500093, "instruction at 0x00");

		// Test 2: address 0x04 should read memory[1]
		addr = 32'h00000004;
		check_instruction(32'h00A00113, "instruction at 0x04");

		// Test 3: address 0x08 should read memory[2]
		addr = 32'h00000008;
		check_instruction(32'h002081B3, "instruction at 0x08");

		// Test 4: address 0x0C should read memory[3]
		addr = 32'h0000000C;
		check_instruction(32'h40110233, "instruction at 0x0C");

		$display("");
		$display("Tests passed: %0d", pass_count);
		$display("Tests failed: %0d", fail_count);

		if (fail_count == 0)
			$display("ALL INSTRUCTION MEMORY TESTS PASSED");
		else
			$display("INSTRUCTION MEMORY TESTS FAILED");

		$finish;

	end

endmodule
