`timescale 1ns/1ps

module if_id_reg_tb;

	logic clk;
	logic rst;
	logic enable;
	logic flush;
	logic [31:0] pc_in;
	logic [31:0] instruction_in;
	logic [31:0] pc_out;
	logic [31:0] instruction_out;

	integer pass_count;
	integer fail_count;

	if_id_reg dut (
		.clk(clk),
		.rst(rst),
		.enable(enable),
		.flush(flush),
		.pc_in(pc_in),
		.instruction_in(instruction_in),
		.pc_out(pc_out),
		.instruction_out(instruction_out)
	);

	always #5 clk = ~clk;

	task check_outputs;
		input [31:0] expected_pc;
		input [31:0] expected_instruction;
		input [8*40-1:0] test_name;

		begin
			if ((pc_out !== expected_pc) ||
			    (instruction_out !== expected_instruction)) begin
				$display("FAIL: %0s", test_name);
				$display("  expected PC          = %h", expected_pc);
				$display("  actual PC            = %h", pc_out);
				$display("  expected instruction = %h", expected_instruction);
				$display("  actual instruction   = %h", instruction_out);
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
		enable = 0;
		flush = 0;
		pc_in = 0;
		instruction_in = 0;

		pass_count = 0;
		fail_count = 0;

		// Reset clears outputs
		@(posedge clk);
		#1;

		check_outputs(
			32'h00000000,
			32'h00000000,
			"reset clears IF/ID register"
		);

		// Load first instruction
		rst = 0;
		enable = 1;
		pc_in = 32'h00000004;
		instruction_in = 32'h00500093;

		@(posedge clk);
		#1;

		check_outputs(
			32'h00000004,
			32'h00500093,
			"enable loads new values"
		);

		// Disable register: outputs should hold
		enable = 0;
		pc_in = 32'h00000008;
		instruction_in = 32'h00A00113;

		@(posedge clk);
		#1;

		check_outputs(
			32'h00000004,
			32'h00500093,
			"enable low holds old values"
		);

		// Enable again and load next instruction
		enable = 1;

		@(posedge clk);
		#1;

		check_outputs(
			32'h00000008,
			32'h00A00113,
			"register loads after stall"
		);

		// Flush should clear outputs
		flush = 1;
		pc_in = 32'h0000000C;
		instruction_in = 32'h002081B3;

		@(posedge clk);
		#1;

		check_outputs(
			32'h00000000,
			32'h00000000,
			"flush clears IF/ID register"
		);

		// Flush has priority over enable
		enable = 1;
		flush = 1;
		pc_in = 32'h00000010;
		instruction_in = 32'h40110233;

		@(posedge clk);
		#1;

		check_outputs(
			32'h00000000,
			32'h00000000,
			"flush overrides enable"
		);

		// Resume normal operation
		flush = 0;

		@(posedge clk);
		#1;

		check_outputs(
			32'h00000010,
			32'h40110233,
			"normal operation after flush"
		);

		$display("");
		$display("Tests passed: %0d", pass_count);
		$display("Tests failed: %0d", fail_count);

		if (fail_count == 0)
			$display("ALL IF/ID REGISTER TESTS PASSED");
		else
			$display("IF/ID REGISTER TESTS FAILED");

		$finish;

	end

endmodule
