/*
Package provides types definitions for the complex numbers.
There are two classes defined here: generic_ and logic_. Each of them contains
unpacked (unp) and packed (p) structure definitions.

generic_ provides flexible typedefs allowing one to define the numbers with the
components of arbitraty type. The package provides typedefs for the numbers with
the components of the SV's standard types (shortint, int, longint, shortreal,
real).

logic_ describes the synthesizable numbers with the components of the logic
type.

The package also provides the arithmetic functions for the complex numbers. They
are defined as type-independent let-macros, so can be used with any complex
number.
Additionally, there are functions here to determine the width of the addition of
two complex numbers with the logic-typed components (ladd_width) and the width
of their multiplication (lmlt_width).

The code is distributed under The MIT License
Copyright (c) 2022 Andrey Smolyakov
    (andreismolyakow 'at' gmail 'punto' com)
See LICENSE for the complete license text
*/

package complex;

// Use for your own types
virtual class generic_;
    virtual class unp#(type T);
        typedef struct {rand T re, im;} _t;
    endclass
    
    virtual class p#(type T);
        typedef struct packed {T re, im;} _t;
    endclass
endclass

// Use in synthesis
virtual class logic_#(int WIDTH);
    typedef struct {rand logic signed [WIDTH-1:0] re, im;} unp;
    typedef struct packed {logic signed [WIDTH-1:0] re, im;} p;
endclass

// Standard SustemVerilog's types
typedef generic_::unp#(shortint)::_t  shortint_unp;
typedef generic_::unp#(int)::_t       int_unp;
typedef generic_::unp#(longint)::_t   longint_unp;
typedef generic_::unp#(shortreal)::_t shortreal_unp;
typedef generic_::unp#(real)::_t      real_unp;

typedef generic_::p#(shortint)::_t  shortint_p;
typedef generic_::p#(int)::_t       int_p;
typedef generic_::p#(longint)::_t   longint_p;

// Arithmetic
let conj(a)  = '{re:(a.re),
                 im:(-a.im)};
let add(a,b) = '{re:(a.re + b.re),
                 im:(a.im + b.im)};
let sub(a,b) = '{re:(a.re - b.re),
                 im:(a.im - b.im)};
let mlt(a,b) = '{re:(a.re*b.re - a.im*b.im),
                 im:(a.re*b.im + a.im*b.re)};
let div(a,b) = '{re:((a.re*b.re + a.im*b.im)/(b.re**2 + b.im**2)),
                 im:((a.im*b.re - a.re*b.im)/(b.re**2 + b.im**2))};

// Width of the arithmetic operations with logic
function automatic int ladd_width(int a_width, b_width);
    let max(int a, int b) = a > b ? a : b;
    return max(a_width, b_width) + 1;
endfunction

function automatic int lmlt_width(int a_width, b_width);
    return a_width + b_width + 1;
endfunction

endpackage
