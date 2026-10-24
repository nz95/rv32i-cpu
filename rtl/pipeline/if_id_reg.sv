`timescale 1ns/1ps

module if_id_reg (
	input logic clk,
	input logic rst,
	input logic enable,
	input logic flush,
	input logic [31:0] pc_in,
	input logic [31:0] instruction_in,
	output logic [31:0] pc_out,
	output logic [31:0] instruction_out
);

	always_ff @(posedge clk) begin
		if (rst || flush) begin
			pc_out <= 32'd0;
			instruction_out <= 32'd0;
		end
		else if (enable) begin
			pc_out <= pc_in;
			instruction_out <= instruction_in;
		end
	end

endmodule
