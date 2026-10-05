`timescale 1ns/1ps

module data_memory_tb;

	logic clk;
	logic mem_write;
	logic [31:0] addr;
	logic [31:0] write_data;
	logic [31:0] read_data;

	integer pass_count;
	integer fail_count;

	data_memory dut (
		.clk(clk),
		.mem_write(mem_write),
		.addr(addr),
		.write_data(write_data),
		.read_data(read_data)
	);

	always #5 clk = ~clk;

	task check_read;
		input [31:0] expected;
		input [8*30-1:0] test_name;

		begin
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

	initial begin

		clk = 0;
		mem_write = 0;
		addr = 0;
		write_data = 0;

		pass_count = 0;
		fail_count = 0;

		// Test 1: write 42 to address 0x00
		addr = 32'h00000000;
		write_data = 32'd42;
		mem_write = 1;

		@(posedge clk);
		#1;

		mem_write = 0;
		check_read(32'd42, "write and read address 0x00");

		// Test 2: write 99 to address 0x04
		addr = 32'h00000004;
		write_data = 32'd99;
		mem_write = 1;

		@(posedge clk);
		#1;

		mem_write = 0;
		check_read(32'd99, "write and read address 0x04");

		// Test 3: verify address 0x00 still contains 42
		addr = 32'h00000000;
		check_read(32'd42, "multiple addresses preserved");

		// Test 4: disabled write should not change memory
		addr = 32'h00000004;
		write_data = 32'd1234;
		mem_write = 0;

		@(posedge clk);
		#1;

		check_read(32'd99, "disabled write");

		// Test 5: overwrite address 0x00
		addr = 32'h00000000;
		write_data = 32'd77;
		mem_write = 1;

		@(posedge clk);
		#1;

		mem_write = 0;
		check_read(32'd77, "overwrite address 0x00");

		// Test 6: write to another word address
		addr = 32'h00000018;
		write_data = 32'hDEADBEEF;
		mem_write = 1;

		@(posedge clk);
		#1;

		mem_write = 0;
		check_read(32'hDEADBEEF, "write address 0x18");

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
