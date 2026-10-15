module instruction_memory #(
	parameter MEM_FILE = "programs/test_program.hex"
)(
	input logic [31:0] addr,
	output logic [31:0] instruction
);

	logic [31:0] memory [0:255];

	initial begin
		$readmemh(MEM_FILE, memory);
	end

	always_comb begin
		instruction = memory[addr[9:2]];
	end	

endmodule
