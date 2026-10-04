module instruction_memory (
	input logic [31:0] addr,
	output logic [31:0] instruction
);

	logic [31:0] memory [0:255];

	initial begin
		$readmemh("programs/test_program.hex", memory);
	end

	always_comb begin
		instruction = memory[addr[9:2]];
	end	

endmodule
