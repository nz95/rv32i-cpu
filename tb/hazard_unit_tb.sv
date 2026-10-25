`timescale 1ns/1ps

module hazard_unit_tb;

	logic [4:0] rs1_id;
	logic [4:0] rs2_id;

	logic [4:0] rd_ex;
	logic [1:0] result_src_ex;

	logic pc_enable;
	logic if_id_enable;
	logic id_ex_flush;

	integer pass_count;
	integer fail_count;

	hazard_unit dut (
		.rs1_id(rs1_id),
		.rs2_id(rs2_id),

		.rd_ex(rd_ex),
		.result_src_ex(result_src_ex),

		.pc_enable(pc_enable),
		.if_id_enable(if_id_enable),
		.id_ex_flush(id_ex_flush)
	);

	task check_outputs;
		input logic expected_pc_enable;
		input logic expected_if_id_enable;
		input logic expected_id_ex_flush;
		input [8*50-1:0] test_name;

		begin
			#1;

			if (
				pc_enable !== expected_pc_enable ||
				if_id_enable !== expected_if_id_enable ||
				id_ex_flush !== expected_id_ex_flush
			) begin
				$display(
					"FAIL: %0s | pc=%b expected=%b | if_id=%b expected=%b | flush=%b expected=%b",
					test_name,
					pc_enable,
					expected_pc_enable,
					if_id_enable,
					expected_if_id_enable,
					id_ex_flush,
					expected_id_ex_flush
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

		rs1_id = 5'd0;
		rs2_id = 5'd0;
		rd_ex = 5'd0;
		result_src_ex = 2'b00;

		// 1. No load in EX
		rs1_id = 5'd5;
		rs2_id = 5'd6;
		rd_ex = 5'd5;
		result_src_ex = 2'b00;

		check_outputs(
			1'b1,
			1'b1,
			1'b0,
			"no load means no stall"
		);

		// 2. Load-use hazard on rs1
		rs1_id = 5'd5;
		rs2_id = 5'd6;
		rd_ex = 5'd5;
		result_src_ex = 2'b01;

		check_outputs(
			1'b0,
			1'b0,
			1'b1,
			"load-use hazard on rs1"
		);

		// 3. Load-use hazard on rs2
		rs1_id = 5'd4;
		rs2_id = 5'd7;
		rd_ex = 5'd7;
		result_src_ex = 2'b01;

		check_outputs(
			1'b0,
			1'b0,
			1'b1,
			"load-use hazard on rs2"
		);

		// 4. Load but no dependency
		rs1_id = 5'd1;
		rs2_id = 5'd2;
		rd_ex = 5'd8;
		result_src_ex = 2'b01;

		check_outputs(
			1'b1,
			1'b1,
			1'b0,
			"load with no dependency"
		);

		// 5. rd_ex is x0
		rs1_id = 5'd0;
		rs2_id = 5'd2;
		rd_ex = 5'd0;
		result_src_ex = 2'b01;

		check_outputs(
			1'b1,
			1'b1,
			1'b0,
			"x0 does not cause hazard"
		);

		// 6. Both rs1 and rs2 match load destination
		rs1_id = 5'd9;
		rs2_id = 5'd9;
		rd_ex = 5'd9;
		result_src_ex = 2'b01;

		check_outputs(
			1'b0,
			1'b0,
			1'b1,
			"both operands depend on load"
		);

		// 7. Result comes from PC+4, not memory
		rs1_id = 5'd10;
		rs2_id = 5'd3;
		rd_ex = 5'd10;
		result_src_ex = 2'b10;

		check_outputs(
			1'b1,
			1'b1,
			1'b0,
			"PC plus 4 result does not stall"
		);

		// 8. Return to normal after hazard
		rs1_id = 5'd1;
		rs2_id = 5'd2;
		rd_ex = 5'd3;
		result_src_ex = 2'b00;

		check_outputs(
			1'b1,
			1'b1,
			1'b0,
			"normal operation after hazard"
		);

		$display("");
		$display("Tests passed: %0d", pass_count);
		$display("Tests failed: %0d", fail_count);

		if (fail_count == 0)
			$display("ALL HAZARD UNIT TESTS PASSED");
		else
			$display("HAZARD UNIT TESTS FAILED");

		$finish;

	end

endmodule
