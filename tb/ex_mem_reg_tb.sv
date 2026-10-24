`timescale 1ns/1ps

module ex_mem_reg_tb;

	logic clk;
	logic rst;
	logic enable;
	logic flush;

	logic [31:0] alu_result_in;
	logic [31:0] store_data_in;
	logic [31:0] pc_plus4_in;
	logic [4:0] rd_in;
	logic [2:0] funct3_in;

	logic reg_write_in;
	logic mem_write_in;
	logic [1:0] result_src_in;

	logic [31:0] alu_result_out;
	logic [31:0] store_data_out;
	logic [31:0] pc_plus4_out;
	logic [4:0] rd_out;
	logic [2:0] funct3_out;

	logic reg_write_out;
	logic mem_write_out;
	logic [1:0] result_src_out;

	integer pass_count;
	integer fail_count;

	ex_mem_reg dut (
		.clk(clk),
		.rst(rst),
		.enable(enable),
		.flush(flush),

		.alu_result_in(alu_result_in),
		.store_data_in(store_data_in),
		.pc_plus4_in(pc_plus4_in),
		.rd_in(rd_in),
		.funct3_in(funct3_in),

		.reg_write_in(reg_write_in),
		.mem_write_in(mem_write_in),
		.result_src_in(result_src_in),

		.alu_result_out(alu_result_out),
		.store_data_out(store_data_out),
		.pc_plus4_out(pc_plus4_out),
		.rd_out(rd_out),
		.funct3_out(funct3_out),

		.reg_write_out(reg_write_out),
		.mem_write_out(mem_write_out),
		.result_src_out(result_src_out)
	);

	always #5 clk = ~clk;

	task check_zero;
		input [8*40-1:0] test_name;

		begin
			if (
				alu_result_out !== 32'd0 ||
				store_data_out !== 32'd0 ||
				pc_plus4_out !== 32'd0 ||
				rd_out !== 5'd0 ||
				funct3_out !== 3'd0 ||
				reg_write_out !== 1'b0 ||
				mem_write_out !== 1'b0 ||
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
				store_data_out !== 32'hAABBCCDD ||
				pc_plus4_out !== 32'h00000024 ||
				rd_out !== 5'd10 ||
				funct3_out !== 3'b010 ||
				reg_write_out !== 1'b1 ||
				mem_write_out !== 1'b1 ||
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
		store_data_in = 0;
		pc_plus4_in = 0;
		rd_in = 0;
		funct3_in = 0;

		reg_write_in = 0;
		mem_write_in = 0;
		result_src_in = 0;

		pass_count = 0;
		fail_count = 0;

		// Reset
		@(posedge clk);
		#1;

		check_zero("reset clears EX/MEM register");

		// Load values
		rst = 0;
		enable = 1;

		alu_result_in = 32'h12345678;
		store_data_in = 32'hAABBCCDD;
		pc_plus4_in = 32'h00000024;
		rd_in = 5'd10;
		funct3_in = 3'b010;

		reg_write_in = 1'b1;
		mem_write_in = 1'b1;
		result_src_in = 2'b01;

		@(posedge clk);
		#1;

		check_loaded("enable loads EX/MEM values");

		// Hold old values
		enable = 0;

		alu_result_in = 32'hFFFFFFFF;
		store_data_in = 32'h11111111;
		pc_plus4_in = 32'h22222222;
		rd_in = 5'd31;
		funct3_in = 3'b111;

		reg_write_in = 0;
		mem_write_in = 0;
		result_src_in = 2'b10;

		@(posedge clk);
		#1;

		check_loaded("enable low holds EX/MEM values");

		// Flush
		flush = 1;

		@(posedge clk);
		#1;

		check_zero("flush clears EX/MEM register");

		// Flush overrides enable
		enable = 1;
		flush = 1;

		@(posedge clk);
		#1;

		check_zero("flush overrides enable");

		// Resume normal operation
		flush = 0;

		alu_result_in = 32'h12345678;
		store_data_in = 32'hAABBCCDD;
		pc_plus4_in = 32'h00000024;
		rd_in = 5'd10;
		funct3_in = 3'b010;

		reg_write_in = 1'b1;
		mem_write_in = 1'b1;
		result_src_in = 2'b01;

		@(posedge clk);
		#1;

		check_loaded("normal operation after flush");

		$display("");
		$display("Tests passed: %0d", pass_count);
		$display("Tests failed: %0d", fail_count);

		if (fail_count == 0)
			$display("ALL EX/MEM REGISTER TESTS PASSED");
		else
			$display("EX/MEM REGISTER TESTS FAILED");

		$finish;

	end

endmodule
