/*
Class "complex" provides definitions of complex numbers objects
with different types of components: logic signed, integer, real.

The classes also provide static functions for basic operations
with such numbers: +, -, *, /, equality check.

Complex operations for signed complex numbers are defined in a
separate class (signed_arith). This class requires passing widths
of the operands as parameters. This is to guaranty that overflow
won't occur.

The code is not intended for synthesis, only for use in testbenches.


The code is distributed under The MIT License
Copyright (c) 2021 Andrey Smolyakov
    (andreismolyakow 'at' gmail 'punto' com)
See LICENSE for the complete license text
*/

`ifndef COMPLEX_H
`define COMPLEX_H

class complex;

    class signed_#(integer unsigned WIDTH);
        typedef logic signed [WIDTH-1:0] component_t;
        const component_t re, im;
        
        extern function new(component_t re, im);
        extern function signed_#(WIDTH) conjugate();
    endclass : signed_
    
    class signed_arith #(integer unsigned A_WIDTH, B_WIDTH);
        localparam ADD_WIDTH = 
            A_WIDTH > B_WIDTH ? A_WIDTH + 1 : B_WIDTH + 1;
        localparam MLT_WIDTH = A_WIDTH + B_WIDTH + 1;
        
        typedef signed_#(A_WIDTH)   a_t;
        typedef signed_#(B_WIDTH)   b_t;
        typedef signed_#(ADD_WIDTH) add_res_t;
        typedef signed_#(MLT_WIDTH) mlt_res_t;

        extern static function bit equal (a_t a, b_t b);
        extern static function add_res_t add       (a_t a, b_t b);
        extern static function add_res_t substract (a_t a, b_t b);
        extern static function mlt_res_t multiply  (a_t a, b_t b);
    endclass : signed_arith
    
    class integer_;
        const integer re, im;
        extern function new(integer re, im);
        
        extern static function bit equal (integer_ a,b);
        extern static function integer_ add       (integer_ a, b);
        extern static function integer_ substract (integer_ a, b);
        extern static function integer_ multiply  (integer_ a, b);
        extern static function integer_ divide    (integer_ a, b); 
        extern        function integer_ conjugate ();
    endclass : integer_
    
    class real_;
        const real re, im;
        extern function new(real re, im);
        
        extern static function bit equal (real_ a,b, real tol);
        extern static function real_ add       (real_ a, b);
        extern static function real_ substract (real_ a, b);
        extern static function real_ multiply  (real_ a, b);
        extern static function real_ divide    (real_ a, b); 
        extern        function real_ conjugate ();
    endclass : real_

    // Implementations 
    // Signed
    function signed_::new(component_t re, im);
        this.re = re;
        this.im = im;
    endfunction
    
    function signed_#(signed_::WIDTH) signed_::conjugate();
        component_t max_pos = 2**(WIDTH-1)-1;
        bit is_im_min_neg = im[WIDTH-1] & !(|im[WIDTH-1-1:0]);
        
        component_t im_n = is_im_min_neg ? max_pos : -im;        
        signed_#(WIDTH) c = new(re, im_n);
        return c;
    endfunction : signed_::conjugate
    
    function bit signed_arith::equal (a_t a, b_t b);
        bit re_eq = a.re == b.re;
        bit im_eq = a.im == b.im;
        return (re_eq & im_eq);
    endfunction : signed_arith::equal
    
    function signed_arith::add_res_t signed_arith::add(a_t a, b_t b);
        add_res_t res = new(a.re + b.re, a.im + b.im);
        return res;
    endfunction : signed_arith::add
    
    function signed_arith::add_res_t signed_arith::substract(a_t a, b_t b);
        b_t neg_b = new(-b.re, -b.im);
        return add(a, neg_b);
    endfunction : signed_arith::substract
    
    function signed_arith::mlt_res_t signed_arith::multiply(a_t a, b_t b);      
        mlt_res_t res = new(a.re*b.re - a.im*b.im, a.im*b.re + a.re*b.im);
        return res;
    endfunction : signed_arith::multiply

    // Integer
    function integer_::new(integer re, im);
        this.re = re;
        this.im = im;
    endfunction

    function integer_ integer_::add(integer_ a, b);
        integer_ c = new(a.re + b.re, a.im + b.im);
        return c;
    endfunction : integer_::add
    
    function bit integer_::equal (integer_ a,b);
        bit re_eq = a.re == b.re;
        bit im_eq = a.im == b.im;
        return (re_eq & im_eq);
    endfunction : integer_::equal
    
    function integer_ integer_::substract(integer_ a, b);
        integer_ c = new(a.re - a.im, b.re - b.im);
        return c;
    endfunction : integer_::substract
    
    function integer_ integer_::multiply(integer_ a, b);
        integer re = a.re*b.re - a.im*b.im;
        integer im = a.im*b.re + a.re*b.im;
        integer_ c = new(re, im);
        return c;
    endfunction : integer_::multiply
    
    function integer_ integer_::divide(integer_ a, b);
        integer re = (a.re*b.re + a.im*b.im)/(b.re**2 + b.im**2);
        integer im = (a.im*b.re - a.re*b.im)/(b.re**2 + b.im**2);
        integer_ c = new(re, im);
        return c;
    endfunction : integer_::divide
    
    function integer_ integer_::conjugate();
        int max_pos =  2**(32-1)-1;
        int min_neg = -2**(32-1);
        int im_n = (im == min_neg) ? max_pos : -im;
        integer_ c = new(re, im_n);
        return c;
    endfunction : integer_::conjugate

    // Real
    function real_::new(real re, im);
        this.re = re;
        this.im = im;
    endfunction
    
    function bit real_::equal (real_ a,b, real tol);
        real re_diff = (a.re < b.re) ? b.re - a.re : a.re - b.re;
        real im_diff = (a.im < b.im) ? b.im - a.im : a.im - b.im;
        bit re_eq = re_diff <= tol;
        bit im_eq = im_diff <= tol;
        return (re_eq & im_eq);
    endfunction : real_::equal
    
    function real_ real_::add(real_ a, b);
        real_ c = new(a.re + b.re, a.im + b.im);
        return c;
    endfunction : real_::add
    
    function real_ real_::substract(real_ a, b);
        real_ c = new(a.re - a.im, b.re - b.im);
        return c;
    endfunction : real_::substract
    
    function real_ real_::multiply(real_ a, b);
        real re = a.re*b.re - a.im*b.im;
        real im = a.im*b.re + a.re*b.im;
        real_ c = new(re, im);
        return c;
    endfunction : real_::multiply
    
    function real_ real_::divide(real_ a, b);
        real re = (a.re*b.re + a.im*b.im)/(b.re**2 + b.im**2);
        real im = (a.im*b.re - a.re*b.im)/(b.re**2 + b.im**2);
        real_ c = new(re, im);
        return c;
    endfunction : real_::divide
    
    function real_ real_::conjugate();
        real_ c = new(re,-im);
        return c;
    endfunction : real_::conjugate
    
endclass : complex

`endif
