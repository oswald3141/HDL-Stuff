/*
A testbench for complex multiplier
Feeds the module with random complex numbers and checks the 
results. The test will print an error message and break the
simulation if it sees any mismatch between the module's
results and the reference result.

The code is distributed under The MIT License
Copyright (c) 2022 Andrey Smolyakov
    (andreismolyakow 'at' gmail 'punto' com)
See LICENSE for the complete license text
*/

`timescale 1ns / 1ps
`default_nettype none

module complex_multiplier_tb
import complex::*;;

localparam A_WIDTH = 10,
           B_WIDTH = 15;

localparam UUT_LATENCY = 3;
localparam N_TESTS = 100;

localparam enum {VHDL_2008, VHDL_1987, SV} UUT_VERSION = SV;

localparam C_WIDTH = complex::lmlt_width(A_WIDTH, B_WIDTH);

typedef complex::logic_#(A_WIDTH)::p a_t;
typedef complex::logic_#(B_WIDTH)::p b_t;
typedef complex::logic_#(C_WIDTH)::p c_t;

a_t a_in = '0;
b_t b_in = '0;
c_t c_out, c_ref = '0;

logic clk = 0;
localparam CLK_PERIOD = 4;
always #(CLK_PERIOD/2) clk = ~clk;

always @(posedge clk) begin : input_gen
    automatic a_t a_tmp = '0;
    automatic b_t b_tmp = '0;

    assert(std::randomize(a_tmp, b_tmp));

    a_in <= a_tmp;
    b_in <= b_tmp;
    c_ref <= complex::mlt(a_tmp, b_tmp);
end

initial begin : stopper
    repeat(N_TESTS) @(posedge clk);
    $display("No incorrect result detected. Test PASSED.");
    $stop();
end

property multiplies_correctly;
    @(posedge clk)
    c_out == $past(c_ref, UUT_LATENCY);
endproperty

assert property(multiplies_correctly) else begin
    #(CLK_PERIOD/2); // Let the simulator to render waveform
    $fatal(1, "Incorrect result. Test FAILED.");
end

generate case(UUT_VERSION)
    VHDL_1987: begin
        complex_multiplier uut (
            .clk (clk),
            .a_re(a_in.re),
            .a_im(a_in.im),
            .b_re(b_in.re),
            .b_im(b_in.im),
            .c_re(c_out.re),
            .c_im(c_out.im)
        );
    end VHDL_2008: begin
        complex_multiplier_2008_wrapper
        #(
            .a_comp_width(A_WIDTH),
            .b_comp_width(B_WIDTH)
        ) uut (
            .clk(clk),
            .a_in(a_in),
            .b_in(b_in),
            .c_out(c_out)
        );
    end SV: begin
        complex_multiplier
        #(
            .A_WIDTH(A_WIDTH),
            .B_WIDTH(B_WIDTH)
        ) uut (
            .clk(clk),
            .a_i(a_in),
            .b_i(b_in),
            .c_o(c_out)
        );
    end
endcase endgenerate;

endmodule
