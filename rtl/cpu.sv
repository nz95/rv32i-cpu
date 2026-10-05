module cpu (
	input logic clk,
	input logic rst
);

	// PC signals
	logic [31:0] pc_current;
	logic [31:0] next_pc;
	logic [31:0] pc_plus4;
	logic [31:0] pc_target;
	logic [31:0] jalr_target;
	
	// instruction
	logic [31:0] instruction;
	
	// regfile signals
	logic [4:0] rs1;
	logic [4:0] rs2;
	logic [4:0] rd;
	logic [31:0] read_data1;
	logic [31:0] read_data2;
	logic [31:0] write_data;

	// immediate
	logic [31:0] immediate;

	// control signals
	logic reg_write;
	logic mem_write;
	logic [1:0] alu_src_a;
	logic alu_src_b;
	logic [1:0] result_src;	
	logic branch;
	logic jump;
	logic jalr;
	logic [1:0] alu_op;

	// ALU signals
	logic [31:0] alu_a;
	logic [31:0] alu_b;
	logic [3:0] alu_control;
	logic [31:0] alu_result;

	// memory
	logic [31:0] memory_read_data;

	// branch
	logic branch_taken;

	// write enables (rst proof)
	logic reg_write_enable;
	logic mem_write_enable;

	localparam ALU_A_RS1 = 2'b00;
	localparam ALU_A_PC = 2'b01;
	localparam ALU_A_ZERO = 2'b10;
	
	localparam RESULT_ALU = 2'b00;
	localparam RESULT_MEM = 2'b01;
	localparam RESULT_PC4 = 2'b10;

	assign rs1 = instruction[19:15];
	assign rs2 = instruction[24:20];
	assign rd = instruction[11:7];

	assign pc_plus4 = pc_current + 32'd4;
	assign pc_target = pc_current + immediate;
	assign jalr_target = (read_data1 + immediate) & 32'hFFFFFFFE;

	assign reg_write_enable = reg_write && !rst;
	assign mem_write_enable = mem_write && !rst;

	pc u_pc (
		.clk(clk),
		.rst(rst),
		.next_pc(next_pc),
		.pc(pc_current)
	);

	instruction_memory u_instruction_memory (
		.addr(pc_current),
		.instruction(instruction)
	);

	control_unit u_control_unit (
		.opcode(instruction[6:0]),
		.reg_write(reg_write),
		.mem_write(mem_write),
		.alu_src_a(alu_src_a),
		.alu_src_b(alu_src_b),
		.result_src(result_src),
		.branch(branch),
		.jump(jump),
		.jalr(jalr),
		.alu_op(alu_op)
	);

	immediate_generator u_immediate_generator (
		.instruction(instruction),
		.immediate(immediate)
	);

	regfile u_regfile (	
		.clk(clk),
		.write_enable(reg_write_enable),
		.rs1(rs1),
		.rs2(rs2),
		.rd(rd),
		.write_data(write_data),
		.read_data1(read_data1),
		.read_data2(read_data2)
	);

	alu_decoder u_alu_decoder (
		.alu_op(alu_op),
		.funct3(instruction[14:12]),
		.funct7(instruction[31:25]),
		.alu_control(alu_control)
	);

	always_comb begin
		case (alu_src_a)
			ALU_A_RS1:
				alu_a = read_data1;

			ALU_A_PC:
                                alu_a = pc_current;
			
			ALU_A_ZERO:
                                alu_a = 32'd0;
			
			default:
                                alu_a = read_data1;
		endcase

		if (alu_src_b)
			alu_b = immediate;
		else
			alu_b = read_data2;
	end

	alu u_alu (
		.a(alu_a),
		.b(alu_b),
		.alu_control(alu_control),
		.result(alu_result)
	);

	data_memory u_data_memory (
		.clk(clk),
		.mem_write(mem_write_enable),
		.addr(alu_result),
		.write_data(read_data2),
		.read_data(memory_read_data)
	);

	branch_comparator u_branch_comparator (
		.a(read_data1),
		.b(read_data2),
		.funct3(instruction[14:12]),
		.branch_taken(branch_taken)
	);

	always_comb begin
		case (result_src)
			RESULT_ALU:
				write_data = alu_result;
			
			RESULT_MEM:
				write_data = memory_read_data;
		
			RESULT_PC4:
				write_data = pc_plus4;
	
			default:
				write_data = alu_result;
		endcase
	end

	always_comb begin
		if (jalr)
			next_pc = jalr_target;
		else if (jump)
			next_pc = pc_target;
		else if (branch && branch_taken)
			next_pc = pc_target;
		else
			next_pc = pc_plus4;
	end

endmodule
