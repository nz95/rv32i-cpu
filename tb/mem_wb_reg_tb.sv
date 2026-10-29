`timescale 1ns/1ps

module mem_wb_reg_tb;

	logic clk;
	logic rst;
	logic enable;
	logic flush;

	logic [31:0] alu_result_in;
	logic [31:0] memory_data_in;
	logic [31:0] pc_plus4_in;
	logic [4:0] rd_in;

	logic reg_write_in;
	logic [1:0] result_src_in;

	logic [31:0] alu_result_out;
	logic [31:0] memory_data_out;
	logic [31:0] pc_plus4_out;
	logic [4:0] rd_out;

	logic reg_write_out;
	logic [1:0] result_src_out;

	integer pass_count;
	integer fail_count;

	mem_wb_reg dut (
		.clk(clk),
		.rst(rst),
		.enable(enable),
		.flush(flush),

		.alu_result_in(alu_result_in),
		.memory_data_in(memory_data_in),
		.pc_plus4_in(pc_plus4_in),
		.rd_in(rd_in),

		.reg_write_in(reg_write_in),
		.result_src_in(result_src_in),

		.alu_result_out(alu_result_out),
		.memory_data_out(memory_data_out),
		.pc_plus4_out(pc_plus4_out),
		.rd_out(rd_out),

		.reg_write_out(reg_write_out),
		.result_src_out(result_src_out)
	);

	always #5 clk = ~clk;

	task check_zero;
		input [8*40-1:0] test_name;

		begin
			if (
				alu_result_out !== 32'd0 ||
				memory_data_out !== 32'd0 ||
				pc_plus4_out !== 32'd0 ||
				rd_out !== 5'd0 ||
				reg_write_out !== 1'b0 ||
				result_src_out !== 2'b00
			) begin
				$display("FAIL: %0s", test_name);
				fail_count = fail_count + 1;
			end
			else begin
				$display("PASS: %0s", test_name);
				pass_count = pass_count + 1;
			end
		end
	endtask

	task check_loaded;
		input [8*40-1:0] test_name;

		begin
			if (
				alu_result_out !== 32'h12345678 ||
				memory_data_out !== 32'hAABBCCDD ||
				pc_plus4_out !== 32'h00000024 ||
				rd_out !== 5'd10 ||
				reg_write_out !== 1'b1 ||
				result_src_out !== 2'b01
			) begin
				$display("FAIL: %0s", test_name);
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

		alu_result_in = 0;
		memory_data_in = 0;
		pc_plus4_in = 0;
		rd_in = 0;

		reg_write_in = 0;
		result_src_in = 0;

		pass_count = 0;
		fail_count = 0;

		// Reset
		@(posedge clk);
		#1;

		check_zero("reset clears MEM/WB register");

		// Load values
		rst = 0;
		enable = 1;

		alu_result_in = 32'h12345678;
		memory_data_in = 32'hAABBCCDD;
		pc_plus4_in = 32'h00000024;
		rd_in = 5'd10;

		reg_write_in = 1'b1;
		result_src_in = 2'b01;

		@(posedge clk);
		#1;

		check_loaded("enable loads MEM/WB values");

		// Hold values
		enable = 0;

		alu_result_in = 32'hFFFFFFFF;
		memory_data_in = 32'h11111111;
		pc_plus4_in = 32'h22222222;
		rd_in = 5'd31;

		reg_write_in = 0;
		result_src_in = 2'b10;

		@(posedge clk);
		#1;

		check_loaded("enable low holds MEM/WB values");

		// Flush
		flush = 1;

		@(posedge clk);
		#1;

		check_zero("flush clears MEM/WB register");

		// Flush overrides enable
		enable = 1;
		flush = 1;

		@(posedge clk);
		#1;

		check_zero("flush overrides enable");

		// Resume normal operation
		flush = 0;

		alu_result_in = 32'h12345678;
		memory_data_in = 32'hAABBCCDD;
		pc_plus4_in = 32'h00000024;
		rd_in = 5'd10;

		reg_write_in = 1'b1;
		result_src_in = 2'b01;

		@(posedge clk);
		#1;

		check_loaded("normal operation after flush");

		$display("");
		$display("Tests passed: %0d", pass_count);
		$display("Tests failed: %0d", fail_count);

		if (fail_count == 0)
			$display("ALL MEM/WB REGISTER TESTS PASSED");
		else
			$display("MEM/WB REGISTER TESTS FAILED");

		$finish;

	end

endmodule
