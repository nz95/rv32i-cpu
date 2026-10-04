module control_unit (
	input logic [6:0] opcode,
	output logic reg_write,
	output logic mem_write,
	output logic [1:0] alu_src_a,
	output logic alu_src_b,
	output logic [1:0] result_src,
	output logic branch,
	output logic jump,
	output logic jalr,
	output logic [1:0] alu_op
);
	
	localparam OP_RTYPE = 7'b0110011;
        localparam OP_ITYPE = 7'b0010011;
        localparam OP_LOAD = 7'b0000011;
        localparam OP_STORE = 7'b0100011;
        localparam OP_BRANCH = 7'b1100011;
        localparam OP_JAL = 7'b1101111;
        localparam OP_JALR = 7'b1100111;
        localparam OP_LUI = 7'b0110111;
        localparam OP_AUIPC = 7'b0010111;

        localparam ALU_A_RS1 = 2'b00;
        localparam ALU_A_PC = 2'b01;
        localparam ALU_A_ZERO = 2'b10;

        localparam RESULT_ALU = 2'b00;
        localparam RESULT_MEM = 2'b01;
        localparam RESULT_PC4 = 2'b10;

        localparam ALUOP_ADD = 2'b00;
        localparam ALUOP_RTYPE = 2'b01;
        localparam ALUOP_ITYPE = 2'b10;

	always_comb begin
		reg_write = 1'b0;
		mem_write = 1'b0;
		alu_src_a = ALU_A_RS1;
		alu_src_b = 1'b0;
		result_src = RESULT_ALU;
		branch = 1'b0;
		jump = 1'b0;
		jalr = 1'b0;
		alu_op = ALUOP_ADD;

		case (opcode)
			OP_RTYPE: begin
				reg_write = 1'b1;
				alu_src_a = ALU_A_RS1;
				alu_src_b = 1'b0;
				result_src = RESULT_ALU;
				alu_op = ALUOP_RTYPE;
			end

			OP_ITYPE: begin
				reg_write = 1'b1;
				alu_src_a = ALU_A_RS1;
				alu_src_b = 1'b1;
				result_src = RESULT_ALU;
				alu_op = ALUOP_ITYPE;
			end

			OP_LOAD: begin
				reg_write = 1'b1;
				alu_src_a = ALU_A_RS1;
				alu_src_b = 1'b1;
				result_src = RESULT_MEM;
				alu_op = ALUOP_ADD;
			end

			OP_STORE: begin
				mem_write = 1'b1;
				alu_src_a = ALU_A_RS1;
				alu_src_b = 1'b1;
				alu_op = ALUOP_ADD;
			end

			OP_BRANCH: begin
				branch = 1'b1;
			end

			OP_JAL: begin
				reg_write = 1'b1;
				result_src = RESULT_PC4;
				jump = 1'b1;
			end

			OP_JALR: begin
				reg_write = 1'b1;
				alu_src_a = ALU_A_RS1;
				alu_src_b = 1'b1;
				result_src = RESULT_PC4;
				jump = 1'b1;
				jalr = 1'b1;
				alu_op = ALUOP_ADD;
			end

			OP_LUI: begin
				reg_write = 1'b1;
				alu_src_a = ALU_A_ZERO;
				alu_src_b = 1'b1;
				result_src = RESULT_ALU;
				alu_op = ALUOP_ADD;
			end

			OP_AUIPC: begin
				reg_write = 1'b1;
				alu_src_a = ALU_A_PC;
				alu_src_b = 1'b1;
				result_src = RESULT_ALU;
				alu_op = ALUOP_ADD;
			end

			default: begin
			end
		endcase
	end

endmodule
