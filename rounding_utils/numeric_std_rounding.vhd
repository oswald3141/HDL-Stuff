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

library IEEE;
context IEEE.ieee_std_context;
use IEEE.math_real.all;

package numeric_std_rounding is

  type rounding_method is (floor,
                           ceil,
                           half_up_nonsym,
                           half_down_nonsym,
                           half_up_sym,
                           half_down_sym,
                           half_even,
                           half_odd);
  -- Defines how exactly the rounding should be done

  function round_explicit(ARG        : u_signed;
                          FRAC_WIDTH : positive;
                          METHOD     : rounding_method)
                          return u_signed;
  -- Result subtype: u_signed(ARG'lenght-FRAC_WIDTH-1 downto 0)
  -- Result: Round a signed integer ARG using the METHOD.

  function round_explicit(ARG        : u_unsigned;
                          FRAC_WIDTH : positive;
                          METHOD     : rounding_method)
                          return u_unsigned;
  -- Result subtype: u_unsigned(ARG'lenght-FRAC_WIDTH-1 downto 0)
  -- Result: Round an unsigned integer ARG using the METHOD.

end package;


package body numeric_std_rounding is
  
  -- Implementation function
  function round_explicit(ARG     : real;
                          F_SCALE : real;
                          METHOD  : rounding_method)
                          return real is
    
    constant ARG_SCALED      : real := ARG/F_SCALE;
    constant ARG_SCALED_INT  : real := floor(ARG_SCALED);
    constant ARG_SCALED_FRAC : real := ARG_SCALED - ARG_SCALED_INT;

    constant ARG_SCALED_INT_EVEN : boolean :=
            floor(ARG_SCALED_INT/2.0)*2.0 = ARG_SCALED_INT;
    constant ARG_SCALED_INT_ODD : boolean :=
            not ARG_SCALED_INT_EVEN;

    variable res : real;
  begin
    case METHOD is
      when floor =>
        res := floor(ARG_SCALED);
      when ceil =>
        res := ceil(ARG_SCALED);
      when half_up_nonsym =>
        res := floor(ARG_SCALED + 0.5);
      when half_down_nonsym =>
        res := ceil(ARG_SCALED - 0.5);
      when half_up_sym =>
        res := round(ARG_SCALED);
      when half_down_sym =>
        res := ceil (ARG_SCALED - 0.5) when ARG_SCALED > 0.0 else
               floor(ARG_SCALED + 0.5) when ARG_SCALED < 0.0 else
               0.0;
      when half_even =>
        res := ARG_SCALED_INT       when ARG_SCALED_FRAC < 0.5 else
               ARG_SCALED_INT + 1.0 when ARG_SCALED_FRAC > 0.5 else
               ARG_SCALED_INT       when ARG_SCALED_INT_EVEN   else
               ARG_SCALED_INT + 1.0;
      when half_odd =>
        res := ARG_SCALED_INT       when ARG_SCALED_FRAC < 0.5 else
               ARG_SCALED_INT + 1.0 when ARG_SCALED_FRAC > 0.5 else
               ARG_SCALED_INT       when ARG_SCALED_INT_ODD    else
               ARG_SCALED_INT + 1.0;
    end case;

    return res;
  end function;
  
  -- Input type independent frontend for the implementation function
  function round_explicit(ARG         : std_ulogic_vector;
                          IS_SIGNED   : boolean;
                          FRAC_WIDTH  : positive;
                          METHOD      : rounding_method)
                          return std_ulogic_vector is
                          
    constant F_SCALE   : real := 2**real(FRAC_WIDTH);
    constant INT_WIDTH : integer := ARG'length - FRAC_WIDTH;
    
    variable arg_r    : real;
    variable res_int  : integer;
    variable res_sulv : std_ulogic_vector(INT_WIDTH-1 downto 0);
    
    -- Null range sulv to trigger elaboration failure
    constant ERROR_SULV : std_ulogic_vector(0 downto 1) := (others => '0');
  begin
  
    -- Safeguards against ill-formed resize attempts
    if INT_WIDTH < 0 then
      assert false
        report "NUMERIC_STD_ROUNDING: The required rounding in ill-formed"
        severity error;
      return ERROR_SULV;
    end if;
    
    -- No need to do anything
    if FRAC_WIDTH = 0 then return ARG; end if;

    arg_r := real(to_integer(  signed(ARG))) when IS_SIGNED else
             real(to_integer(unsigned(ARG)));
    
    res_int := integer(round_explicit(arg_r, F_SCALE, METHOD));
    
    res_sulv :=
        std_ulogic_vector(to_signed(res_int, INT_WIDTH)) when IS_SIGNED else
        std_ulogic_vector(to_unsigned(res_int, INT_WIDTH));

    return res_sulv;
  end function;

  -- Signed frontend
  function round_explicit(ARG        : u_signed;
                          FRAC_WIDTH : positive;
                          METHOD     : rounding_method)
                          return u_signed is
  begin
    return u_signed(
        round_explicit(std_ulogic_vector(ARG), true, FRAC_WIDTH, METHOD));
  end function;
  
  -- Unsigned frontend
  function round_explicit(ARG        : u_unsigned;
                          FRAC_WIDTH : positive;
                          METHOD     : rounding_method)
                          return u_unsigned is
  begin
    return u_unsigned(
        round_explicit(std_ulogic_vector(ARG), false, FRAC_WIDTH, METHOD));
  end function;

end package body;
