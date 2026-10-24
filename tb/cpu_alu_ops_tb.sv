`timescale 1ns/1ps

module cpu_alu_ops_tb;

	logic clk;
	logic rst;

	integer pass_count;
	integer fail_count;

	cpu #(
		.MEM_FILE("programs/alu_ops_test.hex")
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

	initial begin

		clk = 0;
		rst = 1;

		pass_count = 0;
		fail_count = 0;

		// Reset CPU
		@(posedge clk);
		#1;
		rst = 0;

		// Execute all 22 instructions
		repeat (22) begin
			@(posedge clk);
			#1;
		end

		check_register(5'd1,  32'd5,        "x1 = 5");
		check_register(5'd2,  32'd3,        "x2 = 3");

		check_register(5'd3,  32'd8,        "ADD");
		check_register(5'd4,  32'd2,        "SUB");
		check_register(5'd5,  32'd24,       "SLL");
		check_register(5'd6,  32'd1,        "SLT");
		check_register(5'd7,  32'd0,        "SLTU");
		check_register(5'd8,  32'd6,        "XOR");
		check_register(5'd9,  32'd3,        "SRL");

		check_register(
			5'd10,
			32'hFFFFFFF0,
			"x10 = -16"
		);

		check_register(
			5'd11,
			32'hFFFFFFFE,
			"SRA"
		);

		check_register(5'd12, 32'd7, "OR");
		check_register(5'd13, 32'd1, "AND");

		check_register(5'd14, 32'd15, "ADDI");
		check_register(5'd15, 32'd1,  "SLTI");
		check_register(5'd16, 32'd0,  "SLTIU");
		check_register(5'd17, 32'd6,  "XORI");
		check_register(5'd18, 32'd7,  "ORI");
		check_register(5'd19, 32'd1,  "ANDI");

		check_register(5'd20, 32'd12, "SLLI");

		check_register(
			5'd21,
			32'h3FFFFFFC,
			"SRLI"
		);

		check_register(
			5'd22,
			32'hFFFFFFFC,
			"SRAI"
		);

		if (dut.pc_current !== 32'h00000058) begin
			$display("FAIL: PC");
			$display("  expected = 00000058");
			$display("  actual   = %h", dut.pc_current);
			fail_count = fail_count + 1;
		end
		else begin
			$display("PASS: PC = 0x58");
			pass_count = pass_count + 1;
		end

		$display("");
		$display("Tests passed: %0d", pass_count);
		$display("Tests failed: %0d", fail_count);

		if (fail_count == 0)
			$display("ALL CPU ALU OPERATION TESTS PASSED");
		else
			$display("CPU ALU OPERATION TESTS FAILED");

		$finish;

	end

endmodule
