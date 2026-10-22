`timescale 1ns/1ps

module cpu_load_store_tb;

	logic clk;
	logic rst;

	integer pass_count;
	integer fail_count;

	cpu #(
		.MEM_FILE("programs/load_store_test.hex")
	) dut (
		.clk(clk),
		.rst(rst)
	);

	always #5 clk = ~clk;

	task check_register;
		input [4:0] reg_num;
		input [31:0] expected;
		input [8*40-1:0] test_name;

		begin
			if (dut.u_regfile.registers[reg_num] !== expected) begin
				$display("FAIL: %0s", test_name);
				$display("  expected = %h", expected);
				$display("  actual   = %h",
					dut.u_regfile.registers[reg_num]);
				fail_count = fail_count + 1;
			end
			else begin
				$display("PASS: %0s", test_name);
				pass_count = pass_count + 1;
			end
		end
	endtask

	task check_memory;
		input [7:0] word_index;
		input [31:0] expected;
		input [8*40-1:0] test_name;

		begin
			if (dut.u_data_memory.memory[word_index] !== expected) begin
				$display("FAIL: %0s", test_name);
				$display("  expected = %h", expected);
				$display("  actual   = %h",
					dut.u_data_memory.memory[word_index]);
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

		// Execute all 11 instructions
		repeat (11) begin
			@(posedge clk);
			#1;
		end

		check_register(
			5'd1,
			32'hFFFFFF80,
			"x1 = -128"
		);

		check_register(
			5'd2,
			32'hFFFFFF80,
			"LB sign extends byte"
		);

		check_register(
			5'd3,
			32'h00000080,
			"LBU zero extends byte"
		);

		check_register(
			5'd4,
			32'h00008001,
			"x4 = 0x00008001"
		);

		check_register(
			5'd5,
			32'hFFFF8001,
			"LH sign extends halfword"
		);

		check_register(
			5'd6,
			32'h00008001,
			"LHU zero extends halfword"
		);

		check_register(
			5'd7,
			32'h80010080,
			"LW reads final word"
		);

		check_memory(
			8'd0,
			32'h80010080,
			"SB and SH update correct bytes"
		);

		if (dut.pc_current !== 32'h0000002C) begin
			$display("FAIL: PC");
			$display("  expected = 0000002C");
			$display("  actual   = %h", dut.pc_current);
			fail_count = fail_count + 1;
		end
		else begin
			$display("PASS: PC = 0x2C");
			pass_count = pass_count + 1;
		end

		$display("");
		$display("Tests passed: %0d", pass_count);
		$display("Tests failed: %0d", fail_count);

		if (fail_count == 0)
			$display("ALL CPU LOAD/STORE TESTS PASSED");
		else
			$display("CPU LOAD/STORE TESTS FAILED");

		$finish;

	end

endmodule
