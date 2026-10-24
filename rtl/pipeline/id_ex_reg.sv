`timescale 1ns/1ps

module id_ex_reg (
	input logic clk,
	input logic rst,
	input logic enable,
	input logic flush,

	input logic [31:0] pc_in,
	input logic [31:0] read_data1_in,
	input logic [31:0] read_data2_in,
	input logic [31:0] immediate_in,
	input logic [4:0] rs1_in,
	input logic [4:0] rs2_in,
	input logic [4:0] rd_in,
	input logic [2:0] funct3_in,
	input logic [6:0] funct7_in,

	input logic reg_write_in,
	input logic mem_write_in,
	input logic [1:0] alu_src_a_in,
	input logic alu_src_b_in,
	input logic [1:0] result_src_in,
	input logic branch_in,
	input logic jump_in,
	input logic jalr_in,
	input logic [1:0] alu_op_in,
	

	output logic [31:0] pc_out,
	output logic [31:0] read_data1_out,
	output logic [31:0] read_data2_out,
	output logic [31:0] immediate_out,
	output logic [4:0] rs1_out,
	output logic [4:0] rs2_out,
	output logic [4:0] rd_out,
	output logic [2:0] funct3_out,
	output logic [6:0] funct7_out,

	output logic reg_write_out,
	output logic mem_write_out,
	output logic [1:0] alu_src_a_out,
	output logic alu_src_b_out,
	output logic [1:0] result_src_out,
	output logic branch_out,
	output logic jump_out,
	output logic jalr_out,
	output logic [1:0] alu_op_out
);

	always_ff @(posedge clk) begin
		if (rst || flush) begin
			pc_out <= 32'd0;
			read_data1_out <= 32'd0;
			read_data2_out <= 32'd0;
			immediate_out <= 32'd0;
			rs1_out <= 5'd0;
			rs2_out <= 5'd0;
			rd_out <= 5'd0;
			funct3_out <= 3'd0;
			funct7_out <= 7'd0;
			reg_write_out <= 1'b0;
			mem_write_out <= 1'b0;
			alu_src_a_out <= 2'b00;
			alu_src_b_out <= 1'b0;
			result_src_out <= 2'b00;
			branch_out <= 1'b0;
			jump_out <= 1'b0;
			jalr_out <= 1'b0;
			alu_op_out <= 2'b00;
		end
		else if (enable) begin
			pc_out <= pc_in;
			read_data1_out <= read_data1_in;
			read_data2_out <= read_data2_in;
			immediate_out <= immediate_in;
			rs1_out <= rs1_in;
			rs2_out <= rs2_in;
			rd_out <= rd_in;
			funct3_out <= funct3_in;
			funct7_out <= funct7_in;
			reg_write_out <= reg_write_in;
			mem_write_out <= mem_write_in;
			alu_src_a_out <= alu_src_a_in;
			alu_src_b_out <= alu_src_b_in;
			result_src_out <= result_src_in;
			branch_out <= branch_in;
			jump_out <= jump_in;
			jalr_out <= jalr_in;
			alu_op_out <= alu_op_in;
		end
	end

endmodule
