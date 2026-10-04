`timescale 1ns/1ps

module control_unit_tb;

	logic [6:0] opcode;
	logic reg_write;
	logic mem_write;
	logic [1:0] alu_src_a;
	logic alu_src_b;
	logic [1:0] result_src;
	logic branch;
	logic jump;
	logic jalr;
	logic [1:0] alu_op;

	integer pass_count;
	integer fail_count;

	control_unit dut (
		.opcode(opcode),
		.reg_write(reg_write),
		.mem_write(mem_write),
		.alu_src_a(alu_src_a),
		.alu_src_b(alu_src_b),
		.result_src(result_src),
		.branch(branch),
		.jump(jump),
		.jalr(jalr),
		.alu_op(alu_op)
	);

	task check_control;
		input expected_reg_write;
		input expected_mem_write;
		input [1:0] expected_alu_src_a;
		input expected_alu_src_b;
		input [1:0] expected_result_src;
		input expected_branch;
		input expected_jump;
		input expected_jalr;
		input [1:0] expected_alu_op;
		input [8*30-1:0] test_name;

		begin
			#1;

			if (
				reg_write !== expected_reg_write ||
				mem_write !== expected_mem_write ||
				alu_src_a !== expected_alu_src_a ||
				alu_src_b !== expected_alu_src_b ||
				result_src !== expected_result_src ||
				branch !== expected_branch ||
				jump !== expected_jump ||
				jalr !== expected_jalr ||
				alu_op !== expected_alu_op
			) begin
				$display("FAIL: %0s", test_name);
				$display("  reg_write  expected=%b actual=%b", expected_reg_write, reg_write);
				$display("  mem_write  expected=%b actual=%b", expected_mem_write, mem_write);
				$display("  alu_src_a  expected=%b actual=%b", expected_alu_src_a, alu_src_a);
				$display("  alu_src_b  expected=%b actual=%b", expected_alu_src_b, alu_src_b);
				$display("  result_src expected=%b actual=%b", expected_result_src, result_src);
				$display("  branch     expected=%b actual=%b", expected_branch, branch);
				$display("  jump       expected=%b actual=%b", expected_jump, jump);
				$display("  jalr       expected=%b actual=%b", expected_jalr, jalr);
				$display("  alu_op     expected=%b actual=%b", expected_alu_op, alu_op);
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

		// Test 1: R-type
		opcode = 7'b0110011;
		check_control(
			1'b1,
			1'b0,
			2'b00,
			1'b0,
			2'b00,
			1'b0,
			1'b0,
			1'b0,
			2'b01,
			"R-type"
		);

		// Test 2: I-type arithmetic
		opcode = 7'b0010011;
		check_control(
			1'b1,
			1'b0,
			2'b00,
			1'b1,
			2'b00,
			1'b0,
			1'b0,
			1'b0,
			2'b10,
			"I-type"
		);

		// Test 3: load
		opcode = 7'b0000011;
		check_control(
			1'b1,
			1'b0,
			2'b00,
			1'b1,
			2'b01,
			1'b0,
			1'b0,
			1'b0,
			2'b00,
			"LOAD"
		);

		// Test 4: store
		opcode = 7'b0100011;
		check_control(
			1'b0,
			1'b1,
			2'b00,
			1'b1,
			2'b00,
			1'b0,
			1'b0,
			1'b0,
			2'b00,
			"STORE"
		);

		// Test 5: branch
		opcode = 7'b1100011;
		check_control(
			1'b0,
			1'b0,
			2'b00,
			1'b0,
			2'b00,
			1'b1,
			1'b0,
			1'b0,
			2'b00,
			"BRANCH"
		);

		// Test 6: JAL
		opcode = 7'b1101111;
		check_control(
			1'b1,
			1'b0,
			2'b00,
			1'b0,
			2'b10,
			1'b0,
			1'b1,
			1'b0,
			2'b00,
			"JAL"
		);

		// Test 7: JALR
		opcode = 7'b1100111;
		check_control(
			1'b1,
			1'b0,
			2'b00,
			1'b1,
			2'b10,
			1'b0,
			1'b1,
			1'b1,
			2'b00,
			"JALR"
		);

		// Test 8: LUI
		opcode = 7'b0110111;
		check_control(
			1'b1,
			1'b0,
			2'b10,
			1'b1,
			2'b00,
			1'b0,
			1'b0,
			1'b0,
			2'b00,
			"LUI"
		);

		// Test 9: AUIPC
		opcode = 7'b0010111;
		check_control(
			1'b1,
			1'b0,
			2'b01,
			1'b1,
			2'b00,
			1'b0,
			1'b0,
			1'b0,
			2'b00,
			"AUIPC"
		);

		// Test 10: invalid opcode should use defaults
		opcode = 7'b1111111;
		check_control(
			1'b0,
			1'b0,
			2'b00,
			1'b0,
			2'b00,
			1'b0,
			1'b0,
			1'b0,
			2'b00,
			"invalid opcode"
		);

		$display("");
		$display("Tests passed: %0d", pass_count);
		$display("Tests failed: %0d", fail_count);

		if (fail_count == 0)
			$display("ALL CONTROL UNIT TESTS PASSED");
		else
			$display("CONTROL UNIT TESTS FAILED");

		$finish;

	end

endmodule
