`timescale 1ns/1ps

module pipelined_cpu_tb;

	logic clk;
	logic rst;

	integer pass_count;
	integer fail_count;

	logic seen_x1;
	logic seen_x2;
	logic seen_x3;
	logic seen_x4;

	pipelined_cpu #(
		.MEM_FILE("programs/pipeline_basic.hex")
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

		repeat (2)
			@(posedge clk);

		rst = 0;

		repeat (12) begin
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
						if (dut.write_data_wb === 32'd10) begin
							$display("PASS: x2 = 10");
							pass_count = pass_count + 1;
							seen_x2 = 1;
						end
						else begin
							$display("FAIL: x2 expected 10, got %0d", dut.write_data_wb);
							fail_count = fail_count + 1;
						end
					end

					5'd3: begin
						if (dut.write_data_wb === 32'd20) begin
							$display("PASS: x3 = 20");
							pass_count = pass_count + 1;
							seen_x3 = 1;
						end
						else begin
							$display("FAIL: x3 expected 20, got %0d", dut.write_data_wb);
							fail_count = fail_count + 1;
						end
					end

					5'd4: begin
						if (dut.write_data_wb === 32'd30) begin
							$display("PASS: x4 = 30");
							pass_count = pass_count + 1;
							seen_x4 = 1;
						end
						else begin
							$display("FAIL: x4 expected 30, got %0d", dut.write_data_wb);
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

		$display("");
		$display("Passed: %0d", pass_count);
		$display("Failed: %0d", fail_count);

		$finish;
	end

endmodule
