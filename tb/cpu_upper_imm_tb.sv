`timescale 1ns/1ps

module cpu_upper_imm_tb;

	logic clk;
	logic rst;

	integer pass_count;
	integer fail_count;

	cpu #(
		.MEM_FILE("programs/upper_imm_test.hex")
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

		// 0x00: lui x1, 0x12345
		@(posedge clk);
		#1;

		// 0x04: auipc x2, 0x1
		@(posedge clk);
		#1;

		// 0x08: addi x3, x1, 5
		@(posedge clk);
		#1;

		check_register(
			5'd1,
			32'h12345000,
			"LUI x1 = 0x12345000"
		);

		check_register(
			5'd2,
			32'h00001004,
			"AUIPC x2 = 0x00001004"
		);

		check_register(
			5'd3,
			32'h12345005,
			"ADDI after LUI"
		);

		if (dut.pc_current !== 32'h0000000C) begin
			$display("FAIL: PC");
			$display("  expected = 0000000C");
			$display("  actual   = %h", dut.pc_current);
			fail_count = fail_count + 1;
		end
		else begin
			$display("PASS: PC = 0x0C");
			pass_count = pass_count + 1;
		end

		$display("");
		$display("Tests passed: %0d", pass_count);
		$display("Tests failed: %0d", fail_count);

		if (fail_count == 0)
			$display("ALL CPU UPPER IMMEDIATE TESTS PASSED");
		else
			$display("CPU UPPER IMMEDIATE TESTS FAILED");

		$finish;

	end

endmodule
