`timescale 1ns/1ps

module regfile_tb;

	logic clk;
	logic write_enable;
	logic [4:0] rs1;
	logic [4:0] rs2;
	logic [4:0] rd;
	logic [31:0] write_data;
	logic [31:0] read_data1;
	logic [31:0] read_data2;

	integer pass_count;
    integer fail_count;

    regfile dut (
        .clk(clk),
        .write_enable(write_enable),
        .rs1(rs1),
        .rs2(rs2),
        .rd(rd),
        .write_data(write_data),
        .read_data1(read_data1),
        .read_data2(read_data2)
    );

    always #5 clk = ~clk;

    task check_read;
        input [31:0] expected1;
        input [31:0] expected2;
        input [8*30-1:0] test_name;

        begin
            #1;

            if (read_data1 !== expected1 || read_data2 !== expected2) begin
                $display("FAIL: %0s", test_name);
                $display("  expected read_data1 = %h", expected1);
                $display("  actual   read_data1 = %h", read_data1);
                $display("  expected read_data2 = %h", expected2);
                $display("  actual   read_data2 = %h", read_data2);
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
        write_enable = 0;
        rs1 = 0;
        rs2 = 0;
        rd = 0;
        write_data = 0;

        pass_count = 0;
        fail_count = 0;

        // Test 1: x0 should always read as zero
        rs1 = 5'd0;
        rs2 = 5'd0;
        check_read(32'd0, 32'd0, "x0 reads as zero");

        // Test 2: write 42 to x5
        rd = 5'd5;
        write_data = 32'd42;
        write_enable = 1;

        @(posedge clk);
        #1;

        write_enable = 0;
        rs1 = 5'd5;
        rs2 = 5'd0;
        check_read(32'd42, 32'd0, "write and read x5");

        // Test 3: write 99 to x10
        rd = 5'd10;
        write_data = 32'd99;
        write_enable = 1;

        @(posedge clk);
        #1;

        write_enable = 0;
        rs1 = 5'd5;
        rs2 = 5'd10;
        check_read(32'd42, 32'd99, "read two registers");

        // Test 4: disabled write should not change x5
        rd = 5'd5;
        write_data = 32'd1234;
        write_enable = 0;

        @(posedge clk);
        #1;

        rs1 = 5'd5;
        rs2 = 5'd10;
        check_read(32'd42, 32'd99, "disabled write");

        // Test 5: attempt to write to x0
        rd = 5'd0;
        write_data = 32'd555;
        write_enable = 1;

        @(posedge clk);
        #1;

        write_enable = 0;
        rs1 = 5'd0;
        rs2 = 5'd5;
        check_read(32'd0, 32'd42, "x0 ignores writes");

        // Test 6: overwrite x5
        rd = 5'd5;
        write_data = 32'd77;
        write_enable = 1;

        @(posedge clk);
        #1;

        write_enable = 0;
        rs1 = 5'd5;
        rs2 = 5'd10;
        check_read(32'd77, 32'd99, "overwrite x5");

        $display("");
        $display("Tests passed: %0d", pass_count);
        $display("Tests failed: %0d", fail_count);

        if (fail_count == 0)
            $display("ALL REGISTER FILE TESTS PASSED");
        else
            $display("REGISTER FILE TESTS FAILED");

        $finish;

    end

endmodule
