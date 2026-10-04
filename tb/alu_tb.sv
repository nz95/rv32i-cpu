`timescale 1ns/1ps

module alu_tb;

    logic [31:0] a;
    logic [31:0] b;
    logic [3:0] alu_control;
    logic [31:0] result;

    integer pass_count;
    integer fail_count;

    alu dut (
        .a(a),
        .b(b),
        .alu_control(alu_control),
        .result(result)
    );

    task check_result;
        input [31:0] expected;
        input [8*20-1:0] test_name;

        begin
            #10;

            if (result !== expected) begin
                $display("FAIL: %0s", test_name);
                $display("  expected = %h", expected);
                $display("  result   = %h", result);
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

        // Test 1: ADD
        a = 32'd10;
        b = 32'd5;
        alu_control = 4'b0000;
        check_result(32'd15, "ADD");

        // Test 2: SUB
        a = 32'd10;
        b = 32'd5;
        alu_control = 4'b0001;
        check_result(32'd5, "SUB");

        // Test 3: AND
        a = 32'hF0F0F0F0;
        b = 32'h0F0F0F0F;
        alu_control = 4'b0010;
        check_result(32'h00000000, "AND");

        // Test 4: OR
        alu_control = 4'b0011;
        check_result(32'hFFFFFFFF, "OR");

        // Test 5: XOR
        alu_control = 4'b0100;
        check_result(32'hFFFFFFFF, "XOR");

        // Test 6: SLL
        a = 32'd1;
        b = 32'd4;
        alu_control = 4'b0101;
        check_result(32'd16, "SLL");

        // Test 7: SRL
        a = 32'h80000000;
        b = 32'd1;
        alu_control = 4'b0110;
        check_result(32'h40000000, "SRL");

        // Test 8: SRA
        a = 32'h80000000;
        b = 32'd1;
        alu_control = 4'b0111;
        check_result(32'hC0000000, "SRA");

        // Test 9: SLT
        a = 32'hFFFFFFFF;
        b = 32'd1;
        alu_control = 4'b1000;
        check_result(32'd1, "SLT");

        // Test 10: SLTU
        alu_control = 4'b1001;
        check_result(32'd0, "SLTU");

        $display("");
        $display("Tests passed: %0d", pass_count);
        $display("Tests failed: %0d", fail_count);

        if (fail_count == 0)
            $display("ALL ALU TESTS PASSED");
        else
            $display("ALU TESTS FAILED");

        $finish;

    end

endmodule
