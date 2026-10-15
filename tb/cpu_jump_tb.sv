`timescale 1ns/1ps

module cpu_jump_tb;

	logic clk;
	logic rst;

	integer pass_count;
	integer fail_count;

	cpu #(
		.MEM_FILE("programs/jump_test.hex")
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

		// Five instructions should actually execute:
		//
		// 0x00: jal  x1, 8
		// 0x08: addi x2, x0, 42
		// 0x0C: addi x3, x0, 25
		// 0x10: jalr x4, 0(x3)
		// 0x18: addi x5, x0, 7
		repeat (5) begin
			@(posedge clk);
			#1;
		end

		check_register(5'd1, 32'h00000004, "JAL link x1 = 0x04");
		check_register(5'd2, 32'd42, "JAL skipped instruction");
		check_register(5'd3, 32'd25, "x3 = JALR base");
		check_register(5'd4, 32'h00000014, "JALR link x4 = 0x14");
		check_register(5'd5, 32'd7, "JALR skipped instruction");

		if (dut.pc_current !== 32'h0000001C) begin
			$display("FAIL: PC");
			$display("  expected = 0000001C");
			$display("  actual   = %h", dut.pc_current);
			fail_count = fail_count + 1;
		end
		else begin
			$display("PASS: PC = 0x1C");
			pass_count = pass_count + 1;
		end

		$display("");
		$display("Tests passed: %0d", pass_count);
		$display("Tests failed: %0d", fail_count);

		if (fail_count == 0)
			$display("ALL CPU JUMP TESTS PASSED");
		else
			$display("CPU JUMP TESTS FAILED");

		$finish;

	end

endmodule
