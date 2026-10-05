module data_memory (
	input  logic clk,
	input  logic mem_write,
	input  logic [31:0] addr,
	input  logic [31:0] write_data,
	output logic [31:0] read_data
);

	logic [31:0] memory [0:255];
	
	always_ff @(posedge clk) begin
		if (mem_write)
			memory[addr[9:2]] <= write_data;
	end

	always_comb begin
		read_data = memory[addr[9:2]];
	end

endmodule
