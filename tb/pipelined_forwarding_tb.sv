`timescale 1ns/1ps

module pipelined_forwarding_tb;

	logic clk;
	logic rst;

	integer pass_count;
	integer fail_count;

	logic seen_x1;
	logic seen_x2;
	logic seen_x3;
	logic seen_x4;
	logic seen_x5;

	pipelined_cpu #(
		.MEM_FILE("programs/pipeline_forwarding.hex")
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

		seen_x1 = 0;
		seen_x2 = 0;
		seen_x3 = 0;
		seen_x4 = 0;
		seen_x5 = 0;

		repeat (2)
			@(posedge clk);

		rst = 0;

		repeat (15) begin
			@(posedge clk);

			if (dut.reg_write_wb && dut.rd_wb != 5'd0) begin
				case (dut.rd_wb)
					5'd1: begin
						if (dut.write_data_wb === 32'd5) begin
							$display("PASS: x1 = 5");
							pass_count = pass_count + 1;
							seen_x1 = 1;
						end
						else begin
							$display("FAIL: x1 expected 5, got %0d", dut.write_data_wb);
							fail_count = fail_count + 1;
						end
					end

					5'd2: begin
						if (dut.write_data_wb === 32'd8) begin
							$display("PASS: x2 = 8");
							pass_count = pass_count + 1;
							seen_x2 = 1;
						end
						else begin
							$display("FAIL: x2 expected 8, got %0d", dut.write_data_wb);
							fail_count = fail_count + 1;
						end
					end

					5'd3: begin
						if (dut.write_data_wb === 32'd13) begin
							$display("PASS: x3 = 13");
							pass_count = pass_count + 1;
							seen_x3 = 1;
						end
						else begin
							$display("FAIL: x3 expected 13, got %0d", dut.write_data_wb);
							fail_count = fail_count + 1;
						end
					end

					5'd4: begin
						if (dut.write_data_wb === 32'd21) begin
							$display("PASS: x4 = 21");
							pass_count = pass_count + 1;
							seen_x4 = 1;
						end
						else begin
							$display("FAIL: x4 expected 21, got %0d", dut.write_data_wb);
							fail_count = fail_count + 1;
						end
					end

					5'd5: begin
						if (dut.write_data_wb === 32'd34) begin
							$display("PASS: x5 = 34");
							pass_count = pass_count + 1;
							seen_x5 = 1;
						end
						else begin
							$display("FAIL: x5 expected 34, got %0d", dut.write_data_wb);
							fail_count = fail_count + 1;
						end
					end
				endcase
			end
		end

		if (!seen_x1) begin
			$display("FAIL: x1 was never written");
			fail_count = fail_count + 1;
		end

		if (!seen_x2) begin
			$display("FAIL: x2 was never written");
			fail_count = fail_count + 1;
		end

		if (!seen_x3) begin
			$display("FAIL: x3 was never written");
			fail_count = fail_count + 1;
		end

		if (!seen_x4) begin
			$display("FAIL: x4 was never written");
			fail_count = fail_count + 1;
		end

		if (!seen_x5) begin
			$display("FAIL: x5 was never written");
			fail_count = fail_count + 1;
		end

		$display("");
		$display("Passed: %0d", pass_count);
		$display("Failed: %0d", fail_count);

		$finish;
	end

endmodule
