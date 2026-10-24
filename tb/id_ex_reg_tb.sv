`timescale 1ns/1ps

module id_ex_reg_tb;

	logic clk;
	logic rst;
	logic enable;
	logic flush;

	logic [31:0] pc_in;
	logic [31:0] read_data1_in;
	logic [31:0] read_data2_in;
	logic [31:0] immediate_in;
	logic [4:0] rs1_in;
	logic [4:0] rs2_in;
	logic [4:0] rd_in;
	logic [2:0] funct3_in;
	logic [6:0] funct7_in;

	logic reg_write_in;
	logic mem_write_in;
	logic [1:0] alu_src_a_in;
	logic alu_src_b_in;
	logic [1:0] result_src_in;
	logic branch_in;
	logic jump_in;
	logic jalr_in;
	logic [1:0] alu_op_in;

	logic [31:0] pc_out;
	logic [31:0] read_data1_out;
	logic [31:0] read_data2_out;
	logic [31:0] immediate_out;
	logic [4:0] rs1_out;
	logic [4:0] rs2_out;
	logic [4:0] rd_out;
	logic [2:0] funct3_out;
	logic [6:0] funct7_out;

	logic reg_write_out;
	logic mem_write_out;
	logic [1:0] alu_src_a_out;
	logic alu_src_b_out;
	logic [1:0] result_src_out;
	logic branch_out;
	logic jump_out;
	logic jalr_out;
	logic [1:0] alu_op_out;

	integer pass_count;
	integer fail_count;

	id_ex_reg dut (
		.clk(clk),
		.rst(rst),
		.enable(enable),
		.flush(flush),

		.pc_in(pc_in),
		.read_data1_in(read_data1_in),
		.read_data2_in(read_data2_in),
		.immediate_in(immediate_in),
		.rs1_in(rs1_in),
		.rs2_in(rs2_in),
		.rd_in(rd_in),
		.funct3_in(funct3_in),
		.funct7_in(funct7_in),

		.reg_write_in(reg_write_in),
		.mem_write_in(mem_write_in),
		.alu_src_a_in(alu_src_a_in),
		.alu_src_b_in(alu_src_b_in),
		.result_src_in(result_src_in),
		.branch_in(branch_in),
		.jump_in(jump_in),
		.jalr_in(jalr_in),
		.alu_op_in(alu_op_in),

		.pc_out(pc_out),
		.read_data1_out(read_data1_out),
		.read_data2_out(read_data2_out),
		.immediate_out(immediate_out),
		.rs1_out(rs1_out),
		.rs2_out(rs2_out),
		.rd_out(rd_out),
		.funct3_out(funct3_out),
		.funct7_out(funct7_out),

		.reg_write_out(reg_write_out),
		.mem_write_out(mem_write_out),
		.alu_src_a_out(alu_src_a_out),
		.alu_src_b_out(alu_src_b_out),
		.result_src_out(result_src_out),
		.branch_out(branch_out),
		.jump_out(jump_out),
		.jalr_out(jalr_out),
		.alu_op_out(alu_op_out)
	);

	always #5 clk = ~clk;

	task check_all_zero;
		input [8*40-1:0] test_name;

		begin
			if (
				pc_out !== 32'd0 ||
				read_data1_out !== 32'd0 ||
				read_data2_out !== 32'd0 ||
				immediate_out !== 32'd0 ||
				rs1_out !== 5'd0 ||
				rs2_out !== 5'd0 ||
				rd_out !== 5'd0 ||
				funct3_out !== 3'd0 ||
				funct7_out !== 7'd0 ||
				reg_write_out !== 1'b0 ||
				mem_write_out !== 1'b0 ||
				alu_src_a_out !== 2'b00 ||
				alu_src_b_out !== 1'b0 ||
				result_src_out !== 2'b00 ||
				branch_out !== 1'b0 ||
				jump_out !== 1'b0 ||
				jalr_out !== 1'b0 ||
				alu_op_out !== 2'b00
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

	task check_loaded_values;
		input [8*40-1:0] test_name;

		begin
			if (
				pc_out !== 32'h00000020 ||
				read_data1_out !== 32'h11111111 ||
				read_data2_out !== 32'h22222222 ||
				immediate_out !== 32'h00000010 ||
				rs1_out !== 5'd1 ||
				rs2_out !== 5'd2 ||
				rd_out !== 5'd3 ||
				funct3_out !== 3'b101 ||
				funct7_out !== 7'b0100000 ||
				reg_write_out !== 1'b1 ||
				mem_write_out !== 1'b1 ||
				alu_src_a_out !== 2'b01 ||
				alu_src_b_out !== 1'b1 ||
				result_src_out !== 2'b10 ||
				branch_out !== 1'b1 ||
				jump_out !== 1'b1 ||
				jalr_out !== 1'b1 ||
				alu_op_out !== 2'b10
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

		pc_in = 0;
		read_data1_in = 0;
		read_data2_in = 0;
		immediate_in = 0;
		rs1_in = 0;
		rs2_in = 0;
		rd_in = 0;
		funct3_in = 0;
		funct7_in = 0;

		reg_write_in = 0;
		mem_write_in = 0;
		alu_src_a_in = 0;
		alu_src_b_in = 0;
		result_src_in = 0;
		branch_in = 0;
		jump_in = 0;
		jalr_in = 0;
		alu_op_in = 0;

		pass_count = 0;
		fail_count = 0;

		// Reset
		@(posedge clk);
		#1;

		check_all_zero("reset clears ID/EX register");

		// Load values
		rst = 0;
		enable = 1;

		pc_in = 32'h00000020;
		read_data1_in = 32'h11111111;
		read_data2_in = 32'h22222222;
		immediate_in = 32'h00000010;
		rs1_in = 5'd1;
		rs2_in = 5'd2;
		rd_in = 5'd3;
		funct3_in = 3'b101;
		funct7_in = 7'b0100000;

		reg_write_in = 1'b1;
		mem_write_in = 1'b1;
		alu_src_a_in = 2'b01;
		alu_src_b_in = 1'b1;
		result_src_in = 2'b10;
		branch_in = 1'b1;
		jump_in = 1'b1;
		jalr_in = 1'b1;
		alu_op_in = 2'b10;

		@(posedge clk);
		#1;

		check_loaded_values("enable loads all ID/EX values");

		// Hold
		enable = 0;

		pc_in = 32'hAAAAAAAA;
		read_data1_in = 32'hBBBBBBBB;
		read_data2_in = 32'hCCCCCCCC;
		immediate_in = 32'hDDDDDDDD;

		reg_write_in = 0;
		mem_write_in = 0;
		branch_in = 0;
		jump_in = 0;
		jalr_in = 0;

		@(posedge clk);
		#1;

		check_loaded_values("enable low holds all values");

		// Flush
		flush = 1;

		@(posedge clk);
		#1;

		check_all_zero("flush clears ID/EX register");

		// Flush priority over enable
		enable = 1;
		flush = 1;

		@(posedge clk);
		#1;

		check_all_zero("flush overrides enable");

		$display("");
		$display("Tests passed: %0d", pass_count);
		$display("Tests failed: %0d", fail_count);

		if (fail_count == 0)
			$display("ALL ID/EX REGISTER TESTS PASSED");
		else
			$display("ID/EX REGISTER TESTS FAILED");

		$finish;

	end

endmodule
