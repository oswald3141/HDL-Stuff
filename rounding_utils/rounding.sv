/*
Functions for rounding integer numbers

Drops the fractional bits of a given signed/unsigned number and increases
the remaining integer part by 1, if required. Allows to explicitly state
what rounding method must be used.

The package is not intended to be used in synthesis, only in simulation and
constants calculation at elaboration.

Supported rounding methods:
  - Floor (floor). Always rounds towards the negative infinity, no matter
    what's in fractional part.
    Equivalent to floor(x) in MATLAB.
    Yields a bias of -0.5.
  - Ceil (ceil). Always rounds towards the positive infinity, no matter
    what's in fractional part.
    Equivalent to ceil(x) in MATLAB.
    Yields a bias of +0.5.
  - Non-symmetric Round-half-up (half_up_nonsym). Round towards the closest
    integer. The value of 0.5 gets rounded towards the positive infinity.
    Equivalent to floor(x+0.5) in MATLAB.
    Yields a bias of +2^-(fractional_width+1).
  - Non-symmetric Round-half-down (half_down_nonsym). Round towards the
    closest integer. The value of 0.5 gets rounded towards the negative
    infinity.
    Equivalent to ceil(x-0.5) in MATLAB.
    Yields a bias of -2^-(fractional_width+1).
  - Symmetric Round-half-up (half_up_sym). Rounds towards the closest
    integer, 0.5 gets rounded towards the highest magnitude (1.5 -> 2,
    -4.5 -> -5).
    Equivalent to round(x) in MATLAB.
    Yields no bias.
  - Symmetric Round-half-down (half_down_sym). Rounds towards the closest
    integer, 0.5 gets rounded towards the zero (1.5 -> 1, -4.5 -> -4).
    Has no direct equivalent in MATLAB.
    Yields no bias.
  - Round-half-even (half_even). Rounds towards the closest integer, 0.5
    gets rounded towards the closest even number (1.5 -> 2, -4.5 -> -4,
    3.5 -> 4).
    Equivalent to convergent(x) in MATLAB.
    Yields no bias.
    - Round-half-odd (half_odd). Rounds towards the closest integer, 0.5
    gets rounded towards the closest odd number (1.5 -> 1, -4.5 -> -5,
    0.5 -> 1).
    Has no direct equivalent in MATLAB. Never rounds to zero!
    Yields no bias.
    
For the additional details on rounding methods, please, refer to the 
following materials:
- "An introduction to different rounding algorithms" by Clive “Max” Maxfield
  https://www.eetimes.com/an-introduction-to-different-rounding-algorithms/
- "Rounding Numbers without Adding a Bias" on ZipCPU
  https://zipcpu.com/dsp/2017/07/22/rounding.html
- "Output rounding" section of PG149.

The code is distributed under The MIT License
Copyright (c) 2022 Andrey Smolyakov
     (andreismolyakow 'at' gmail 'punto' com)
See LICENSE for the complete license text
*/

package rounding;

//Defines how exactly the rounding should be done
typedef enum {floor,
              ceil,
              half_up_nonsym,
              half_down_nonsym,
              half_up_sym,
              half_down_sym,
              half_even,
              half_odd} rounding_method;

// Rounds the number "n" with fractional part witdth of "frac_width" using the
// "method" method. "n" may be signed or unsigned
let round_explicit(n, frac_width, method) =
    ($bits(n) < frac_width) ? {$bits(n){'X}} : // Ill-formed rounding
    (frac_width == 0) ? n :
        $rtoi(_round_explicit_real_($itor(n), 2.0**(frac_width), method));


// Implementation function, do not call direclty! Use round_explicit instead.
function automatic real _round_explicit_real_(real s_r,
                                              real f_scale,
                                              rounding_method method);
    const real s_r_scaled      = s_r/f_scale;
    const real s_r_scaled_int  = $floor(s_r_scaled);
    const real s_r_scaled_frac = s_r_scaled - s_r_scaled_int;
    
    const bit s_r_scaled_int_even = 
        ($floor(s_r_scaled_int/2.0)*2.0 == s_r_scaled_int);
    const bit s_r_scaled_int_odd =
        !s_r_scaled_int_even;
    
    real res_r;
    
    case (method)
        floor :
            res_r = $floor(s_r_scaled);
        ceil :
            res_r = $ceil(s_r_scaled);
        half_up_nonsym :
            res_r = $floor(s_r_scaled + 0.5);
        half_down_nonsym :
            res_r = $ceil (s_r_scaled - 0.5);
        half_up_sym :
            res_r = int'(s_r_scaled);
        half_down_sym :
            res_r = (s_r_scaled > 0.0) ? $ceil (s_r_scaled - 0.5) :
                    (s_r_scaled < 0.0) ? $floor(s_r_scaled + 0.5) :
                    0.0;
        half_even :
            res_r = (s_r_scaled_frac < 0.5) ? s_r_scaled_int       :
                    (s_r_scaled_frac > 0.5) ? s_r_scaled_int + 1.0 :
                    (s_r_scaled_int_even  ) ? s_r_scaled_int       :
                    s_r_scaled_int + 1.0;
        half_odd :
            res_r = (s_r_scaled_frac < 0.5) ? s_r_scaled_int       :
                    (s_r_scaled_frac > 0.5) ? s_r_scaled_int + 1.0 :
                    (s_r_scaled_int_odd   ) ? s_r_scaled_int       :
                    s_r_scaled_int + 1.0;
    endcase

    return res_r;
endfunction

endpackage
