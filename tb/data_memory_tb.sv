`timescale 1ns/1ps

module data_memory_tb;

	logic clk;
	logic mem_write;
	logic [2:0] funct3;
	logic [31:0] addr;
	logic [31:0] write_data;
	logic [31:0] read_data;

	integer pass_count;
	integer fail_count;

	data_memory dut (
		.clk(clk),
		.mem_write(mem_write),
		.funct3(funct3),
		.addr(addr),
		.write_data(write_data),
		.read_data(read_data)
	);

	always #5 clk = ~clk;

	task write_memory;
		input [31:0] test_addr;
		input [31:0] test_data;
		input [2:0] test_funct3;

		begin
			addr = test_addr;
			write_data = test_data;
			funct3 = test_funct3;
			mem_write = 1'b1;

			@(posedge clk);
			#1;

			mem_write = 1'b0;
		end
	endtask

	task check_read;
		input [31:0] test_addr;
		input [2:0] test_funct3;
		input [31:0] expected;
		input [8*40-1:0] test_name;

		begin
			addr = test_addr;
			funct3 = test_funct3;
			#1;

			if (read_data !== expected) begin
				$display("FAIL: %0s", test_name);
				$display("  expected = %h", expected);
				$display("  actual   = %h", read_data);
				fail_count = fail_count + 1;
			end
			else begin
				$display("PASS: %0s", test_name);
				pass_count = pass_count + 1;
			end
		end
	endtask

	task check_memory;
		input [7:0] word_index;
		input [31:0] expected;
		input [8*40-1:0] test_name;

		begin
			if (dut.memory[word_index] !== expected) begin
				$display("FAIL: %0s", test_name);
				$display("  expected = %h", expected);
				$display("  actual   = %h", dut.memory[word_index]);
				fail_count = fail_count + 1;
			end
			else begin
				$display("PASS: %0s", test_name);
				pass_count = pass_count + 1;
			end
		end
	endtask

	initial begin

		clk = 0;
		mem_write = 0;
		funct3 = 0;
		addr = 0;
		write_data = 0;

		pass_count = 0;
		fail_count = 0;

		// ------------------------------------------------
		// Start with:
		//
		// memory[0] = AABBCCDD
		//
		// address 0 -> DD
		// address 1 -> CC
		// address 2 -> BB
		// address 3 -> AA
		// ------------------------------------------------

		write_memory(
			32'h00000000,
			32'hAABBCCDD,
			3'b010
		);

		check_memory(
			8'd0,
			32'hAABBCCDD,
			"SW writes full word"
		);

		// LB
		check_read(
			32'h00000000,
			3'b000,
			32'hFFFFFFDD,
			"LB address 0"
		);

		check_read(
			32'h00000001,
			3'b000,
			32'hFFFFFFCC,
			"LB address 1"
		);

		check_read(
			32'h00000002,
			3'b000,
			32'hFFFFFFBB,
			"LB address 2"
		);

		check_read(
			32'h00000003,
			3'b000,
			32'hFFFFFFAA,
			"LB address 3"
		);

		// LBU
		check_read(
			32'h00000000,
			3'b100,
			32'h000000DD,
			"LBU address 0"
		);

		check_read(
			32'h00000001,
			3'b100,
			32'h000000CC,
			"LBU address 1"
		);

		check_read(
			32'h00000002,
			3'b100,
			32'h000000BB,
			"LBU address 2"
		);

		check_read(
			32'h00000003,
			3'b100,
			32'h000000AA,
			"LBU address 3"
		);

		// LH
		check_read(
			32'h00000000,
			3'b001,
			32'hFFFFCCDD,
			"LH lower halfword"
		);

		check_read(
			32'h00000002,
			3'b001,
			32'hFFFFAABB,
			"LH upper halfword"
		);

		// LHU
		check_read(
			32'h00000000,
			3'b101,
			32'h0000CCDD,
			"LHU lower halfword"
		);

		check_read(
			32'h00000002,
			3'b101,
			32'h0000AABB,
			"LHU upper halfword"
		);

		// LW
		check_read(
			32'h00000000,
			3'b010,
			32'hAABBCCDD,
			"LW full word"
		);

		// ------------------------------------------------
		// SB test
		//
		// AABBCCDD
		//    ^^
		// replace BB with 55
		//
		// expected = AA55CCDD
		// ------------------------------------------------

		write_memory(
			32'h00000002,
			32'h00000055,
			3'b000
		);

		check_memory(
			8'd0,
			32'hAA55CCDD,
			"SB preserves other bytes"
		);

		// ------------------------------------------------
		// SH lower half
		//
		// AA55CCDD -> AA551234
		// ------------------------------------------------

		write_memory(
			32'h00000000,
			32'h00001234,
			3'b001
		);

		check_memory(
			8'd0,
			32'hAA551234,
			"SH lower halfword"
		);

		// ------------------------------------------------
		// SH upper half
		//
		// AA551234 -> BEEF1234
		// ------------------------------------------------

		write_memory(
			32'h00000002,
			32'h0000BEEF,
			3'b001
		);

		check_memory(
			8'd0,
			32'hBEEF1234,
			"SH upper halfword"
		);

		// Verify next word uses a different memory entry
		write_memory(
			32'h00000004,
			32'h11223344,
			3'b010
		);

		check_memory(
			8'd1,
			32'h11223344,
			"SW address 4 writes memory word 1"
		);

		check_memory(
			8'd0,
			32'hBEEF1234,
			"word 0 preserved"
		);

		$display("");
		$display("Tests passed: %0d", pass_count);
		$display("Tests failed: %0d", fail_count);

		if (fail_count == 0)
			$display("ALL DATA MEMORY TESTS PASSED");
		else
			$display("DATA MEMORY TESTS FAILED");

		$finish;

	end

endmodule
