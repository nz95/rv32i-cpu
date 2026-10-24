`timescale 1ns/1ps

module forwarding_unit_tb;

	logic [4:0] rs1_ex;
	logic [4:0] rs2_ex;

	logic [4:0] rd_mem;
	logic reg_write_mem;

	logic [4:0] rd_wb;
	logic reg_write_wb;

	logic [1:0] forward_a;
	logic [1:0] forward_b;

	integer pass_count;
	integer fail_count;

	forwarding_unit dut (
		.rs1_ex(rs1_ex),
		.rs2_ex(rs2_ex),

		.rd_mem(rd_mem),
		.reg_write_mem(reg_write_mem),

		.rd_wb(rd_wb),
		.reg_write_wb(reg_write_wb),

		.forward_a(forward_a),
		.forward_b(forward_b)
	);

	task check_forwarding;
		input [1:0] expected_a;
		input [1:0] expected_b;
		input [8*50-1:0] test_name;

		begin
			#1;

			if (
				forward_a !== expected_a ||
				forward_b !== expected_b
			) begin
				$display(
					"FAIL: %0s | forward_a=%b expected=%b | forward_b=%b expected=%b",
					test_name,
					forward_a,
					expected_a,
					forward_b,
					expected_b
				);
				fail_count = fail_count + 1;
			end
			else begin
				$display("PASS: %0s", test_name);
				pass_count = pass_count + 1;
			end
		end
	endtask

	initial begin

		pass_count = 0;
		fail_count = 0;

		rs1_ex = 5'd0;
		rs2_ex = 5'd0;

		rd_mem = 5'd0;
		reg_write_mem = 1'b0;

		rd_wb = 5'd0;
		reg_write_wb = 1'b0;

		// 1. No hazard
		rs1_ex = 5'd1;
		rs2_ex = 5'd2;

		rd_mem = 5'd3;
		reg_write_mem = 1'b1;

		rd_wb = 5'd4;
		reg_write_wb = 1'b1;

		check_forwarding(
			2'b00,
			2'b00,
			"no forwarding"
		);

		// 2. MEM forwards to rs1
		rs1_ex = 5'd5;
		rs2_ex = 5'd2;

		rd_mem = 5'd5;
		reg_write_mem = 1'b1;

		rd_wb = 5'd4;
		reg_write_wb = 1'b1;

		check_forwarding(
			2'b10,
			2'b00,
			"MEM forwards to rs1"
		);

		// 3. MEM forwards to rs2
		rs1_ex = 5'd1;
		rs2_ex = 5'd6;

		rd_mem = 5'd6;
		reg_write_mem = 1'b1;

		rd_wb = 5'd4;
		reg_write_wb = 1'b1;

		check_forwarding(
			2'b00,
			2'b10,
			"MEM forwards to rs2"
		);

		// 4. WB forwards to rs1
		rs1_ex = 5'd7;
		rs2_ex = 5'd2;

		rd_mem = 5'd3;
		reg_write_mem = 1'b1;

		rd_wb = 5'd7;
		reg_write_wb = 1'b1;

		check_forwarding(
			2'b01,
			2'b00,
			"WB forwards to rs1"
		);

		// 5. WB forwards to rs2
		rs1_ex = 5'd1;
		rs2_ex = 5'd8;

		rd_mem = 5'd3;
		reg_write_mem = 1'b1;

		rd_wb = 5'd8;
		reg_write_wb = 1'b1;

		check_forwarding(
			2'b00,
			2'b01,
			"WB forwards to rs2"
		);

		// 6. MEM and WB both match rs1
		rs1_ex = 5'd9;
		rs2_ex = 5'd2;

		rd_mem = 5'd9;
		reg_write_mem = 1'b1;

		rd_wb = 5'd9;
		reg_write_wb = 1'b1;

		check_forwarding(
			2'b10,
			2'b00,
			"MEM has priority over WB for rs1"
		);

		// 7. MEM and WB both match rs2
		rs1_ex = 5'd1;
		rs2_ex = 5'd10;

		rd_mem = 5'd10;
		reg_write_mem = 1'b1;

		rd_wb = 5'd10;
		reg_write_wb = 1'b1;

		check_forwarding(
			2'b00,
			2'b10,
			"MEM has priority over WB for rs2"
		);

		// 8. MEM rd is x0
		rs1_ex = 5'd0;
		rs2_ex = 5'd2;

		rd_mem = 5'd0;
		reg_write_mem = 1'b1;

		rd_wb = 5'd4;
		reg_write_wb = 1'b0;

		check_forwarding(
			2'b00,
			2'b00,
			"MEM x0 does not forward"
		);

		// 9. WB rd is x0
		rs1_ex = 5'd1;
		rs2_ex = 5'd0;

		rd_mem = 5'd3;
		reg_write_mem = 1'b0;

		rd_wb = 5'd0;
		reg_write_wb = 1'b1;

		check_forwarding(
			2'b00,
			2'b00,
			"WB x0 does not forward"
		);

		// 10. MEM match but reg_write disabled
		rs1_ex = 5'd11;
		rs2_ex = 5'd2;

		rd_mem = 5'd11;
		reg_write_mem = 1'b0;

		rd_wb = 5'd4;
		reg_write_wb = 1'b0;

		check_forwarding(
			2'b00,
			2'b00,
			"MEM disabled write does not forward"
		);

		// 11. WB match but reg_write disabled
		rs1_ex = 5'd1;
		rs2_ex = 5'd12;

		rd_mem = 5'd3;
		reg_write_mem = 1'b0;

		rd_wb = 5'd12;
		reg_write_wb = 1'b0;

		check_forwarding(
			2'b00,
			2'b00,
			"WB disabled write does not forward"
		);

		// 12. MEM forwards to rs1 and WB forwards to rs2 simultaneously
		rs1_ex = 5'd13;
		rs2_ex = 5'd14;

		rd_mem = 5'd13;
		reg_write_mem = 1'b1;

		rd_wb = 5'd14;
		reg_write_wb = 1'b1;

		check_forwarding(
			2'b10,
			2'b01,
			"independent forwarding for rs1 and rs2"
		);

		$display("");
		$display("Tests passed: %0d", pass_count);
		$display("Tests failed: %0d", fail_count);

		if (fail_count == 0)
			$display("ALL FORWARDING UNIT TESTS PASSED");
		else
			$display("FORWARDING UNIT TESTS FAILED");

		$finish;

	end

endmodule
