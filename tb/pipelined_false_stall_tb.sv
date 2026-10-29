`timescale 1ns/1ps

module pipelined_false_stall_tb;

	logic clk;
	logic rst;

	integer pass_count;
	integer fail_count;
	integer stall_count;

	logic seen_x5;
	logic seen_x6;

	pipelined_cpu #(
		.MEM_FILE("programs/pipeline_false_stall.hex")
	) dut (
		.clk(clk),
		.rst(rst)
	);

	initial begin
		clk = 0;
		forever #5 clk = ~clk;
	end

	initial begin
		rst = 1;

		pass_count = 0;
		fail_count = 0;
		stall_count = 0;

		seen_x5 = 0;
		seen_x6 = 0;

		repeat (2)
			@(posedge clk);

		rst = 0;

		repeat (15) begin
			@(posedge clk);

			if (!dut.pc_enable) begin
				stall_count = stall_count + 1;
				$display("INFO: stall detected");
			end

			if (dut.reg_write_wb && dut.rd_wb != 5'd0) begin
				case (dut.rd_wb)

					5'd5: begin
						if (dut.write_data_wb === 32'd42) begin
							$display("PASS: x5 = 42");
							pass_count = pass_count + 1;
							seen_x5 = 1;
						end
						else begin
							$display(
								"FAIL: x5 expected 42, got %0d",
								dut.write_data_wb
							);
							fail_count = fail_count + 1;
						end
					end

					5'd6: begin
						if (dut.write_data_wb === 32'd5) begin
							$display("PASS: x6 = 5");
							pass_count = pass_count + 1;
							seen_x6 = 1;
						end
						else begin
							$display(
								"FAIL: x6 expected 5, got %0d",
								dut.write_data_wb
							);
							fail_count = fail_count + 1;
						end
					end

				endcase
			end
		end

		if (!seen_x5) begin
			$display("FAIL: x5 was never written correctly");
			fail_count = fail_count + 1;
		end

		if (!seen_x6) begin
			$display("FAIL: x6 was never written correctly");
			fail_count = fail_count + 1;
		end

		if (stall_count === 0) begin
			$display("PASS: no false load-use stall occurred");
			pass_count = pass_count + 1;
		end
		else begin
			$display(
				"FAIL: expected 0 stalls, got %0d",
				stall_count
			);
			fail_count = fail_count + 1;
		end

		$display("");
		$display("Passed: %0d", pass_count);
		$display("Failed: %0d", fail_count);

		$finish;
	end

endmodule
