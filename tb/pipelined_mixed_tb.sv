`timescale 1ns/1ps

module pipelined_mixed_tb;

	logic clk;
	logic rst;

	integer pass_count;
	integer fail_count;
	integer stall_count;
	integer redirect_count;

	logic seen_x1;
	logic seen_x2;
	logic seen_x3;
	logic seen_x4;
	logic seen_x5;
	logic seen_x6;
	logic seen_x7;
	logic seen_x8;
	logic seen_x9;
	logic seen_x10;
	logic seen_x11;
	logic seen_x12;

	logic wrong_path_write;

	pipelined_cpu #(
		.MEM_FILE("programs/pipeline_mixed.hex")
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
		redirect_count = 0;

		seen_x1 = 0;
		seen_x2 = 0;
		seen_x3 = 0;
		seen_x4 = 0;
		seen_x5 = 0;
		seen_x6 = 0;
		seen_x7 = 0;
		seen_x8 = 0;
		seen_x9 = 0;
		seen_x10 = 0;
		seen_x11 = 0;
		seen_x12 = 0;

		wrong_path_write = 0;

		repeat (2)
			@(posedge clk);

		rst = 0;

		repeat (40) begin
			@(posedge clk);

			if (!dut.pc_enable) begin
				stall_count = stall_count + 1;
				$display("INFO: pipeline stall detected");
			end

			if (dut.control_redirect_ex) begin
				redirect_count = redirect_count + 1;
				$display("INFO: control redirect detected");
			end

			if (dut.reg_write_wb && dut.rd_wb != 5'd0) begin
				case (dut.rd_wb)

					5'd1: begin
						if (dut.write_data_wb === 32'd10) begin
							$display("PASS: x1 = 10");
							pass_count = pass_count + 1;
							seen_x1 = 1;
						end
						else begin
							$display("FAIL: x1 expected 10, got %0d",
								dut.write_data_wb);
							fail_count = fail_count + 1;
						end
					end

					5'd2: begin
						if (dut.write_data_wb === 32'd15) begin
							$display("PASS: x2 = 15");
							pass_count = pass_count + 1;
							seen_x2 = 1;
						end
						else begin
							$display("FAIL: x2 expected 15, got %0d",
								dut.write_data_wb);
							fail_count = fail_count + 1;
						end
					end

					5'd3: begin
						if (dut.write_data_wb === 32'd25) begin
							$display("PASS: x3 = 25");
							pass_count = pass_count + 1;
							seen_x3 = 1;
						end
						else begin
							$display("FAIL: x3 expected 25, got %0d",
								dut.write_data_wb);
							fail_count = fail_count + 1;
						end
					end

					5'd4: begin
						if (dut.write_data_wb === 32'd25) begin
							$display("PASS: x4 = 25");
							pass_count = pass_count + 1;
							seen_x4 = 1;
						end
						else begin
							$display("FAIL: x4 expected 25, got %0d",
								dut.write_data_wb);
							fail_count = fail_count + 1;
						end
					end

					5'd5: begin
						if (dut.write_data_wb === 32'd35) begin
							$display("PASS: x5 = 35");
							pass_count = pass_count + 1;
							seen_x5 = 1;
						end
						else begin
							$display("FAIL: x5 expected 35, got %0d",
								dut.write_data_wb);
							fail_count = fail_count + 1;
						end
					end

					5'd6: begin
						if (dut.write_data_wb === 32'd99) begin
							$display("FAIL: wrong-path x6 = 99 was not flushed");
							wrong_path_write = 1;
							fail_count = fail_count + 1;
						end
						else if (dut.write_data_wb === 32'd60) begin
							$display("PASS: x6 = 60");
							pass_count = pass_count + 1;
							seen_x6 = 1;
						end
					end

					5'd7: begin
						if (dut.write_data_wb === 32'd99) begin
							$display("FAIL: wrong-path x7 = 99 was not flushed");
							wrong_path_write = 1;
							fail_count = fail_count + 1;
						end
						else if (dut.write_data_wb === 32'd70) begin
							$display("PASS: x7 = 70");
							pass_count = pass_count + 1;
							seen_x7 = 1;
						end
					end

					5'd8: begin
						if (dut.write_data_wb === 32'h0000002C) begin
							$display("PASS: JAL link x8 = 0x0000002C");
							pass_count = pass_count + 1;
							seen_x8 = 1;
						end
						else begin
							$display("FAIL: x8 expected 0x0000002C, got %h",
								dut.write_data_wb);
							fail_count = fail_count + 1;
						end
					end

					5'd9: begin
						if (dut.write_data_wb === 32'd99) begin
							$display("FAIL: wrong-path x9 = 99 was not flushed");
							wrong_path_write = 1;
							fail_count = fail_count + 1;
						end
						else if (dut.write_data_wb === 32'd90) begin
							$display("PASS: x9 = 90");
							pass_count = pass_count + 1;
							seen_x9 = 1;
						end
					end

					5'd10: begin
						if (dut.write_data_wb === 32'h00000048) begin
							$display("PASS: x10 = 0x00000048");
							pass_count = pass_count + 1;
							seen_x10 = 1;
						end
						else begin
							$display("FAIL: x10 expected 0x00000048, got %h",
								dut.write_data_wb);
							fail_count = fail_count + 1;
						end
					end

					5'd11: begin
						if (dut.write_data_wb === 32'h00000040) begin
							$display("PASS: JALR link x11 = 0x00000040");
							pass_count = pass_count + 1;
							seen_x11 = 1;
						end
						else begin
							$display("FAIL: x11 expected 0x00000040, got %h",
								dut.write_data_wb);
							fail_count = fail_count + 1;
						end
					end

					5'd12: begin
						if (dut.write_data_wb === 32'd99) begin
							$display("FAIL: wrong-path x12 = 99 was not flushed");
							wrong_path_write = 1;
							fail_count = fail_count + 1;
						end
						else if (dut.write_data_wb === 32'd120) begin
							$display("PASS: x12 = 120");
							pass_count = pass_count + 1;
							seen_x12 = 1;
						end
					end
				endcase
			end
		end

		if (!seen_x1) begin
			$display("FAIL: x1 was never written correctly");
			fail_count = fail_count + 1;
		end

		if (!seen_x2) begin
			$display("FAIL: x2 was never written correctly");
			fail_count = fail_count + 1;
		end

		if (!seen_x3) begin
			$display("FAIL: x3 was never written correctly");
			fail_count = fail_count + 1;
		end

		if (!seen_x4) begin
			$display("FAIL: x4 was never written correctly");
			fail_count = fail_count + 1;
		end

		if (!seen_x5) begin
			$display("FAIL: x5 was never written correctly");
			fail_count = fail_count + 1;
		end

		if (!seen_x6) begin
			$display("FAIL: x6 was never written correctly");
			fail_count = fail_count + 1;
		end

		if (!seen_x7) begin
			$display("FAIL: x7 was never written correctly");
			fail_count = fail_count + 1;
		end

		if (!seen_x8) begin
			$display("FAIL: JAL link x8 was never written correctly");
			fail_count = fail_count + 1;
		end

		if (!seen_x9) begin
			$display("FAIL: x9 was never written correctly");
			fail_count = fail_count + 1;
		end

		if (!seen_x10) begin
			$display("FAIL: x10 was never written correctly");
			fail_count = fail_count + 1;
		end

		if (!seen_x11) begin
			$display("FAIL: JALR link x11 was never written correctly");
			fail_count = fail_count + 1;
		end

		if (!seen_x12) begin
			$display("FAIL: x12 was never written correctly");
			fail_count = fail_count + 1;
		end

		if (!wrong_path_write) begin
			$display("PASS: all wrong-path writes were flushed");
			pass_count = pass_count + 1;
		end

		if (stall_count === 1) begin
			$display("PASS: exactly one load-use stall occurred");
			pass_count = pass_count + 1;
		end
		else begin
			$display("FAIL: expected 1 stall, got %0d", stall_count);
			fail_count = fail_count + 1;
		end

		if (redirect_count === 3) begin
			$display("PASS: exactly three control redirects occurred");
			pass_count = pass_count + 1;
		end
		else begin
			$display("FAIL: expected 3 redirects, got %0d", redirect_count);
			fail_count = fail_count + 1;
		end

		$display("");
		$display("Passed: %0d", pass_count);
		$display("Failed: %0d", fail_count);

		$finish;
	end

endmodule
