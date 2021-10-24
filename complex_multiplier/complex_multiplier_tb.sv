/*
A testbench for complex_multiplier.vhd
Feeds the module with random complex numbers and checks the 
results. The test will print an error message and break the
simulation if it sees any mismatch between the module's
results and the reference result.

The code is distributed under The MIT License
Copyright (c) 2021 Andrey Smolyakov
See LICENSE.md for details
*/

`timescale 1ns / 1ps
`include "../complex.sv"

module complex_multiplier_tb();

localparam A_WIDTH = 10;
localparam B_WIDTH = 15;

localparam UUT_DELAY = 3;
localparam N_TESTS = 10;

typedef complex::signed_arith#(A_WIDTH,B_WIDTH) cs_arith;
localparam C_WIDTH = cs_arith::MLT_WIDTH;

logic clk = 0;
localparam CLK_PERIOD = 4;
always #(CLK_PERIOD/2) clk = ~clk;

logic [A_WIDTH-1:0] a_re, a_im;
logic [B_WIDTH-1:0] b_re, b_im;
logic [C_WIDTH-1:0] c_re, c_im;

complex::signed_#(A_WIDTH) a;
complex::signed_#(B_WIDTH) b;
complex::signed_#(C_WIDTH) c_uut, c_ref, c_queue[$];

initial begin : generate_data
    repeat(N_TESTS) begin
        a = new($urandom(),$urandom());
        b = new($urandom(),$urandom());
        c_queue.push_front(cs_arith::multiply(a,b));
        
        a_re = a.re;
        a_im = a.im;
        b_re = b.re;
        b_im = b.im;
        
        @(posedge clk);
    end
    $display("All results were CORRECT!");
    $stop;
end : generate_data

initial begin : check_data
    repeat (UUT_DELAY) @(negedge clk);
    forever begin
        c_uut = new(c_re, c_im);
        c_ref = c_queue.pop_back();
        if (!complex::signed_arith#(C_WIDTH,C_WIDTH)::
                                equal(c_uut, c_ref)) begin
            $display("INCORRECT result detected!");
            $stop;
        end
        @(negedge clk);
    end
end : check_data

complex_multiplier uut (
    .clk (clk),
    .a_re(a_re),
    .a_im(a_im),
    .b_re(b_re),
    .b_im(b_im),
    .c_re(c_re),
    .c_im(c_im)
);

endmodule
