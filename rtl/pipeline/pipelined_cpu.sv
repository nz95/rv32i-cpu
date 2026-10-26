`timescale 1ns/1ps

module pipelined_cpu #(
	parameter MEM_FILE = "programs/test_program.hex"
)(
	input logic clk,
	input logic rst
);

	logic [31:0] pc_plus4_if;
	logic [31:0] pc_if;
	logic [31:0] pc_id;

        logic [31:0] instruction_if;
        logic [31:0] instruction_id;

	logic [4:0] rs1_id;
	logic [4:0] rs2_id;
	logic [4:0] rd_id;

	logic reg_write_id;
	logic mem_write_id;
	logic [1:0] alu_src_a_id;
	logic alu_src_b_id;
	logic [1:0] result_src_id;
	logic branch_id;
        logic jump_id;
        logic jalr_id;
        logic [1:0] alu_op_id;
	logic [31:0] immediate_id;
        logic [31:0] read_data1_id;
        logic [31:0] read_data2_id;
	logic [2:0] funct3_id;
	logic [6:0] funct7_id;

	logic [31:0] pc_ex;
	logic [31:0] read_data1_ex;
	logic [31:0] read_data2_ex;
	logic [31:0] immediate_ex;
	logic [4:0] rs1_ex;
	logic [4:0] rs2_ex;
	logic [4:0] rd_ex;
	logic [2:0] funct3_ex;
	logic [6:0] funct7_ex;

	logic reg_write_ex;
	logic mem_write_ex;
	logic [1:0] alu_src_a_ex;
	logic alu_src_b_ex;
	logic [1:0] result_src_ex;
	logic branch_ex;
	logic jump_ex;
	logic jalr_ex;
	logic [1:0] alu_op_ex;

	logic [3:0] alu_control_ex;
	logic [31:0] alu_operand_a_ex;
	logic [31:0] alu_operand_b_ex;
	logic [31:0] alu_result_ex;

	logic branch_taken_ex;

	logic [31:0] pc_target_ex;
	logic [31:0] jalr_target_ex;
	logic [31:0] pc_plus4_ex;

	logic [31:0] alu_result_mem;
	logic [31:0] store_data_mem;
	logic [31:0] pc_plus4_mem;
	logic [4:0] rd_mem;
	logic [2:0] funct3_mem;

	logic reg_write_mem;
	logic mem_write_mem;
	logic [1:0] result_src_mem;

	localparam logic [1:0] ALU_A_RS1 = 2'b00;
	localparam logic [1:0] ALU_A_PC = 2'b01;
	localparam logic [1:0] ALU_A_ZERO = 2'b10;

	logic [31:0] memory_read_data_mem;

	logic [31:0] alu_result_wb;
	logic [31:0] memory_data_wb;
	logic [31:0] pc_plus4_wb;
	logic [4:0] rd_wb;

	logic reg_write_wb;
	logic [1:0] result_src_wb;

	logic [31:0] write_data_wb;

	pc u_pc (
                .clk(clk),
                .rst(rst),
                .next_pc(pc_plus4_if),
                .pc(pc_if)
        );

	assign pc_plus4_if = pc_if + 32'd4;

        instruction_memory #(
                .MEM_FILE(MEM_FILE)
        ) u_instruction_memory (
                .addr(pc_if),
                .instruction(instruction_if)
        );

	if_id_reg u_if_id_reg (
		.clk(clk),
		.rst(rst),
		.enable(1'b1),
		.flush(1'b0),
		.pc_in(pc_if),
		.instruction_in(instruction_if),
		.pc_out(pc_id),
		.instruction_out(instruction_id)
	);

	assign rs1_id = instruction_id[19:15];
	assign rs2_id = instruction_id[24:20];
	assign rd_id = instruction_id[11:7];
	assign funct3_id = instruction_id[14:12];
	assign funct7_id = instruction_id[31:25];

	control_unit u_control_unit (
                .opcode(instruction_id[6:0]),
                .reg_write(reg_write_id),
                .mem_write(mem_write_id),
                .alu_src_a(alu_src_a_id),
                .alu_src_b(alu_src_b_id),
                .result_src(result_src_id),
                .branch(branch_id),
                .jump(jump_id),
                .jalr(jalr_id),
                .alu_op(alu_op_id)
        );

        immediate_generator u_immediate_generator (
                .instruction(instruction_id),
                .immediate(immediate_id)
        );

        regfile u_regfile (
                .clk(clk),
                .write_enable(reg_write_wb),
                .rs1(rs1_id),
                .rs2(rs2_id),
                .rd(rd_wb),
                .write_data(write_data_wb),
                .read_data1(read_data1_id),
                .read_data2(read_data2_id)
        );

	id_ex_reg u_id_ex_reg (
		.clk(clk),
		.rst(rst),
		.enable(1'b1),
		.flush(1'b0),

		.pc_in(pc_id),
		.read_data1_in(read_data1_id),
		.read_data2_in(read_data2_id),
		.immediate_in(immediate_id),
		.rs1_in(rs1_id),
		.rs2_in(rs2_id),
		.rd_in(rd_id),
		.funct3_in(funct3_id),
		.funct7_in(funct7_id),

		.reg_write_in(reg_write_id),
		.mem_write_in(mem_write_id),
		.alu_src_a_in(alu_src_a_id),
		.alu_src_b_in(alu_src_b_id),
		.result_src_in(result_src_id),
		.branch_in(branch_id),
		.jump_in(jump_id),
		.jalr_in(jalr_id),
		.alu_op_in(alu_op_id),

		.pc_out(pc_ex),
		.read_data1_out(read_data1_ex),
		.read_data2_out(read_data2_ex),
		.immediate_out(immediate_ex),
		.rs1_out(rs1_ex),
		.rs2_out(rs2_ex),
		.rd_out(rd_ex),
		.funct3_out(funct3_ex),
		.funct7_out(funct7_ex),

		.reg_write_out(reg_write_ex),
		.mem_write_out(mem_write_ex),
		.alu_src_a_out(alu_src_a_ex),
		.alu_src_b_out(alu_src_b_ex),
		.result_src_out(result_src_ex),
		.branch_out(branch_ex),
		.jump_out(jump_ex),
		.jalr_out(jalr_ex),
		.alu_op_out(alu_op_ex)
	);

	alu_decoder u_alu_decoder (
                .alu_op(alu_op_ex),
                .funct3(funct3_ex),
                .funct7(funct7_ex),
                .alu_control(alu_control_ex)
        );

        always_comb begin
                case (alu_src_a_ex)
                        ALU_A_RS1:
                                alu_operand_a_ex = read_data1_ex;

                        ALU_A_PC:
                                alu_operand_a_ex = pc_ex;

                        ALU_A_ZERO:
                                alu_operand_a_ex = 32'd0;

                        default:
                                alu_operand_a_ex = read_data1_ex;
                endcase

                if (alu_src_b_ex)
                        alu_operand_b_ex = immediate_ex;
                else
                        alu_operand_b_ex = read_data2_ex;
        end

        alu u_alu (
                .a(alu_operand_a_ex),
                .b(alu_operand_b_ex),
                .alu_control(alu_control_ex),
                .result(alu_result_ex)
        );

        branch_comparator u_branch_comparator (
                .a(read_data1_ex),
                .b(read_data2_ex),
                .funct3(funct3_ex),
                .branch_taken(branch_taken_ex)
        );

	ex_mem_reg u_ex_mem_reg (
		.clk(clk),
		.rst(rst),
		.enable(1'b1),
		.flush(1'b0),
		.alu_result_in(alu_result_ex),
		.store_data_in(read_data2_ex),
		.pc_plus4_in(pc_plus4_ex),
		.rd_in(rd_ex),
		.funct3_in(funct3_ex),
		.reg_write_in(reg_write_ex),
		.mem_write_in(mem_write_ex),
		.result_src_in(result_src_ex),
		.alu_result_out(alu_result_mem),
		.store_data_out(store_data_mem),
		.pc_plus4_out(pc_plus4_mem),
		.rd_out(rd_mem),
		.funct3_out(funct3_mem),
		.reg_write_out(reg_write_mem),
		.mem_write_out(mem_write_mem),
		.result_src_out(result_src_mem)
	);

	assign pc_plus4_ex = pc_ex + 32'd4;
	assign pc_target_ex = pc_ex + immediate_ex;
	assign jalr_target_ex = (read_data1_ex + immediate_ex) & 32'hFFFFFFFE;

	data_memory u_data_memory (
                .clk(clk),
                .mem_write(mem_write_mem),
                .funct3(funct3_mem),
                .addr(alu_result_mem),
                .write_data(store_data_mem),
                .read_data(memory_read_data_mem)
        );

	mem_wb_reg u_mem_wb_reg (
		.clk(clk),
		.rst(rst),
		.enable(1'b1),
		.flush(1'b0),
		.alu_result_in(alu_result_mem),
		.memory_data_in(memory_read_data_mem),
		.pc_plus4_in(pc_plus4_mem),
		.rd_in(rd_mem),
		.reg_write_in(reg_write_mem),
		.result_src_in(result_src_mem),
		.alu_result_out(alu_result_wb),
		.memory_data_out(memory_data_wb),
		.pc_plus4_out(pc_plus4_wb),
		.rd_out(rd_wb),
		.reg_write_out(reg_write_wb),
		.result_src_out(result_src_wb)
	);

	always_comb begin
		case(result_src_wb)
			2'b00: begin
				write_data_wb = alu_result_wb;
			end
			2'b01: begin
				write_data_wb = memory_data_wb;
			end
			2'b10: begin
				write_data_wb = pc_plus4_wb;
			end
			default: begin
				write_data_wb = alu_result_wb;
			end
		endcase
	end
endmodule

