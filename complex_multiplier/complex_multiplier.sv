/*
A simple complex multiplier.
Written in SystemVerilog.
Performes the multiplication as following:

a = ar + j*ai
b = br + j*bi
c = a*b = (ar*br - ai*bi) + j*(ar*bi + ai*br)

Optimized for Xilinx DSP48: if ports widths don't
exceed DSP48's posrts widths, the module will fit
exactly into 4 DSP48 without any additional logic.

The code is distributed under The MIT License
Copyright (c) 2022 Andrey Smolyakov
    (andreismolyakow 'at' gmail 'punto' com)
See LICENSE for the complete license text
*/

`timescale 1ns / 1ps
`default_nettype none

// (* use_dsp = "yes" *)
module complex_multiplier
import complex::*;
#(
	parameter
		A_WIDTH = 10,
		B_WIDTH = 11,
	localparam
		C_WIDTH = complex::lmlt_width(A_WIDTH, B_WIDTH)
)
(
	input
		wire logic clk,
		complex::logic_#(A_WIDTH)::p a_i,
		complex::logic_#(B_WIDTH)::p b_i,
	output
		complex::logic_#(C_WIDTH)::p c_o
);

	localparam int AB_MLT = A_WIDTH + B_WIDTH;
	logic signed [AB_MLT-1:0] are_bre = '0, aim_bim = '0,
		are_bim = '0, aim_bre ='0;

	complex::logic_#(A_WIDTH)::p a_d1 = '0, a_d2 = '0;
	complex::logic_#(B_WIDTH)::p b_d1 = '0, b_d2 = '0;
	complex::logic_#(C_WIDTH)::p c = '0;
	
	always @(posedge clk) begin : first_dsp48
		a_d1.re <= a_i.re;
		b_d1.re <= b_i.re;
		are_bre <= a_d1.re * b_d1.re;
	end
	
	always @(posedge clk) begin : second_dsp48
		a_d1.im <= a_i.im;
		b_d1.im <= b_i.im;
		aim_bim <= a_d1.im * b_d1.im;
		c.re  <= are_bre - aim_bim;
	end
	
	always @(posedge clk) begin : third_dsp48
        a_d2.re <= a_i.re;
        b_d2.im <= b_i.im;
        are_bim <= a_d2.re * b_d2.im;
	end
	
	always @(posedge clk) begin : fourth_dsp48
        a_d2.im <= a_i.im;
        b_d2.re <= b_i.re;
        aim_bre <= a_d2.im * b_d2.re;
        c.im  <= are_bim + aim_bre;
	end
	
	assign c_o = c;
	
endmodule
