module data_memory (
	input logic clk,
	input logic mem_write,
	input logic [2:0] funct3,
	input logic [31:0] addr,
	input logic [31:0] write_data,
	output logic [31:0] read_data
);

	logic [31:0] memory [0:255];
	
	always_ff @(posedge clk) begin
		if (mem_write) begin
			case (funct3)
				// SB
				3'b000: begin
					case (addr[1:0])
						2'b00:
							memory[addr[9:2]][7:0] <= write_data[7:0];
						2'b01:
							memory[addr[9:2]][15:8] <= write_data[7:0];
						2'b10:
							memory[addr[9:2]][23:16] <= write_data[7:0];
						2'b11:
							memory[addr[9:2]][31:24] <= write_data[7:0];
					endcase
				end
				// SH
				3'b001: begin
					case (addr[1])
						1'b0:
							memory[addr[9:2]][15:0] <= write_data[15:0];
						1'b1:
							memory[addr[9:2]][31:16] <= write_data[15:0];
					endcase
				end
				// SW
				3'b010:
					memory[addr[9:2]] <= write_data;
				default: begin
				end
			endcase
		end
	end

	always_comb begin
		read_data = 32'd0;

		case (funct3)
			// LB
			3'b000: begin
				case (addr[1:0])
					2'b00:
						read_data = {{24{memory[addr[9:2]][7]}}, memory[addr[9:2]][7:0]};
					2'b01:
						read_data = {{24{memory[addr[9:2]][15]}}, memory[addr[9:2]][15:8]};
					2'b10:
						read_data = {{24{memory[addr[9:2]][23]}}, memory[addr[9:2]][23:16]};
					2'b11:
						read_data = {{24{memory[addr[9:2]][31]}}, memory[addr[9:2]][31:24]};
				endcase
			end
			// LH
			3'b001: begin
				case (addr[1])
					1'b0:
						read_data = {{16{memory[addr[9:2]][15]}}, memory[addr[9:2]][15:0]};
					1'b1:
						read_data = {{16{memory[addr[9:2]][31]}}, memory[addr[9:2]][31:16]};
				endcase
			end
			// LW
			3'b010: begin
				read_data = memory[addr[9:2]];
			end
			// LBU
			3'b100: begin
				case (addr[1:0])
					2'b00:
						read_data = {24'd0, memory[addr[9:2]][7:0]};
					2'b01:
						read_data = {24'd0, memory[addr[9:2]][15:8]};
					2'b10:
						read_data = {24'd0, memory[addr[9:2]][23:16]};
					2'b11:
						read_data = {24'd0, memory[addr[9:2]][31:24]};
				endcase
			end
			// LHU
			3'b101: begin
				case (addr[1])
					1'b0:
						read_data = {16'd0, memory[addr[9:2]][15:0]};
					1'b1:
						read_data = {16'd0, memory[addr[9:2]][31:16]};
				endcase
			end
			default:
				read_data = 32'd0;
		endcase
	end

endmodule
