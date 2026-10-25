`timescale 1ns/1ps

module hazard_unit (
	input logic [4:0] rs1_id,
	input logic [4:0] rs2_id,

	input logic [4:0] rd_ex,
	input logic [1:0] result_src_ex,

	output logic pc_enable,
	output logic if_id_enable,
	output logic id_ex_flush
);

	always_comb begin
		if (result_src_ex == 2'b01 && rd_ex != 5'd0 && (rd_ex == rs1_id || rd_ex == rs2_id)) begin
			pc_enable = 0;
			if_id_enable = 0;
			id_ex_flush = 1;
		end
		else begin
			pc_enable = 1;
			if_id_enable = 1;
			id_ex_flush = 0;
		end
	end

endmodule
