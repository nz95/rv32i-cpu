module branch_comparator (
	input logic [31:0] a,
	input logic [31:0] b,
	input logic [2:0] funct3,
	output logic branch_taken
);

	always_comb begin
		branch_taken = 1'b0;
	
		case (funct3)
			// BEQ
			3'b000:
				branch_taken = (a == b);
			
			// BNE
			3'b001:
				branch_taken = (a != b);

                        // BLT
                        3'b100:
                                branch_taken = ($signed(a) < $signed(b));

                        // BGE
                        3'b101:
                                branch_taken = ($signed(a) >= $signed(b));

                        // BLTU
                        3'b110:
                                branch_taken = (a < b);

                        // BGEU
                        3'b111:
                                branch_taken = (a >= b);

			default:
				branch_taken = 1'b0;
		endcase
	end

endmodule
