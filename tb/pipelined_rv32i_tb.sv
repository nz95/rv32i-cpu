`timescale 1ns/1ps

module pipelined_rv32i_tb;

	logic clk;
	logic rst;

	integer pass_count;
	integer fail_count;
	integer redirect_count;
	integer stall_count;
	integer i;

	logic [31:0] observed_regs [0:31];
	logic seen_write [0:31];

	logic wrong_path_write;

	pipelined_cpu #(
		.MEM_FILE("programs/pipeline_rv32i.hex")
	) dut (
		.clk(clk),
		.rst(rst)
	);

	initial begin
		clk = 0;
		forever #5 clk = ~clk;
	end

	task check_reg;
		input [4:0] reg_num;
		input [31:0] expected;

		begin
			if (!seen_write[reg_num]) begin
				$display(
					"FAIL: x%0d was never written",
					reg_num
				);
				fail_count = fail_count + 1;
			end
			else if (observed_regs[reg_num] !== expected) begin
				$display(
					"FAIL: x%0d expected %h, got %h",
					reg_num,
					expected,
					observed_regs[reg_num]
				);
				fail_count = fail_count + 1;
			end
			else begin
				$display(
					"PASS: x%0d = %h",
					reg_num,
					expected
				);
				pass_count = pass_count + 1;
			end
		end
	endtask

	initial begin
		rst = 1;

		pass_count = 0;
		fail_count = 0;
		redirect_count = 0;
		stall_count = 0;

		wrong_path_write = 0;

		for (i = 0; i < 32; i = i + 1) begin
			observed_regs[i] = 32'd0;
			seen_write[i] = 0;
		end

		repeat (2)
			@(posedge clk);

		rst = 0;

		repeat (80) begin
			@(posedge clk);

			if (!dut.pc_enable)
				stall_count = stall_count + 1;

			if (dut.control_redirect_ex)
				redirect_count = redirect_count + 1;

			if (dut.reg_write_wb && dut.rd_wb != 5'd0) begin
				observed_regs[dut.rd_wb] = dut.write_data_wb;
				seen_write[dut.rd_wb] = 1;

				if (dut.rd_wb == 5'd3 &&
					dut.write_data_wb === 32'd99) begin
					$display(
						"FAIL: wrong-path x3 = 99 was written"
					);
					wrong_path_write = 1;
					fail_count = fail_count + 1;
				end

				if (dut.rd_wb == 5'd30 &&
					dut.write_data_wb >= 32'd100) begin
					$display(
						"FAIL: wrong-path branch instruction wrote x30"
					);
					wrong_path_write = 1;
					fail_count = fail_count + 1;
				end
			end
		end

		/*
		 * x1-x3 are overwritten near the end by the
		 * JALR test.
		 */
		check_reg(5'd1,  32'h000000E8);
		check_reg(5'd2,  32'h000000E0);
		check_reg(5'd3,  32'd77);

		/* R-type */
		check_reg(5'd4,  32'd15);
		check_reg(5'd5,  32'd5);
		check_reg(5'd6,  32'd0);
		check_reg(5'd7,  32'd15);
		check_reg(5'd8,  32'd15);
		check_reg(5'd9,  32'd5120);
		check_reg(5'd10, 32'h07FFFFFF);
		check_reg(5'd11, 32'hFFFFFFFF);
		check_reg(5'd12, 32'd1);
		check_reg(5'd13, 32'd0);

		/* I-type */
		check_reg(5'd14, 32'd12);
		check_reg(5'd15, 32'd2);
		check_reg(5'd16, 32'd13);
		check_reg(5'd17, 32'd9);
		check_reg(5'd18, 32'd40);
		check_reg(5'd19, 32'd5);
		check_reg(5'd20, 32'hFFFFFFFC);
		check_reg(5'd21, 32'd1);
		check_reg(5'd22, 32'd1);

		/* LUI / AUIPC */
		check_reg(5'd23, 32'h12345000);
		check_reg(5'd24, 32'h0000105C);

		/* Loads */
		check_reg(5'd25, 32'hFFFFFFF0);
		check_reg(5'd26, 32'h000000F0);
		check_reg(5'd27, 32'hFFFFFFF0);
		check_reg(5'd28, 32'h0000FFF0);
		check_reg(5'd29, 32'h12345000);

		/* All six branches increment x30 */
		check_reg(5'd30, 32'd6);

		/* JAL link: PC 0xCC + 4 */
		check_reg(5'd31, 32'h000000D0);

		if (!wrong_path_write) begin
			$display("PASS: no wrong-path register writes occurred");
			pass_count = pass_count + 1;
		end

		if (redirect_count === 8) begin
			$display(
				"PASS: all 8 expected control redirects occurred"
			);
			pass_count = pass_count + 1;
		end
		else begin
			$display(
				"FAIL: expected 8 redirects, got %0d",
				redirect_count
			);
			fail_count = fail_count + 1;
		end

		if (stall_count === 0) begin
			$display(
				"PASS: no unnecessary stalls occurred"
			);
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
