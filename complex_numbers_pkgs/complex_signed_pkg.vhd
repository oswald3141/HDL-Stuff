/*
Synthesisable package describing a signed complex number in the Cartesian form

Most of the functions here just redefine the corresponding functions from
numeric_std for the complex number type. Some of them just aplly a numeric_std's
function to the both components of a complex number.

Arithmetic operations defined produce the result of a full width, guaranteeing
that no overflow will occure. It also applies to the "+" and "-" operators in
contrast with the same operators from numeric_std.

Many logical overloads from numeric_std (rotation, reduction, etc.) do not have
a definition here. It is unclear what meaning these operations should have for
the complex numbers.

The code is distributed under The MIT License
Copyright (c) 2022 Andrey Smolyakov
     (andreismolyakow 'at' gmail 'punto' com)
See LICENSE for the complete license text
*/

library IEEE;
context IEEE.ieee_std_context;

package complex_signed_pkg is

  --============================================================================
  -- Complex Signed Type Definitions
  --============================================================================

  type unresolved_complex_signed is record
    re : u_signed;
    im : u_signed;
  end record;

  alias u_complex_signed is
    unresolved_complex_signed;

  subtype complex_signed is
    (re(resolved), im(resolved)) unresolved_complex_signed;

  --============================================================================
  -- Arithmetic operations
  --============================================================================

  function "-" (ARG : u_complex_signed) return u_complex_signed;
  -- Result subtype:
  --   u_complex_signed(re(ARG.re'range), im(ARG.im'range))
  -- Result: Negates both of the ARG's components.

  function "+" (L, R : u_complex_signed) return u_complex_signed;
  -- Result subtype:
  --   u_complex_signed(re(RE_LENGTH-1 downto 0), im(IM_LENGTH-1 downto 0)),
  --   where RE_LENGTH = maximum(L.re'length, R.re'length) + 1,
  --   and   IM_LENGTH = maximum(L.im'length, R.im'length) + 1
  -- Result: Adds the components without overflow.

  function "-" (L, R : u_complex_signed) return u_complex_signed;
  -- Result subtype:
  --   u_complex_signed(re(RE_LENGTH-1 downto 0), im(IM_LENGTH-1 downto 0)),
  --   where RE_LENGTH = maximum(L.re'length, R.re'length) + 1,
  --   and   IM_LENGTH = maximum(L.im'length, R.im'length) + 1
  -- Result: Substracts the components without overflow.

  function "*" (L, R : u_complex_signed) return u_complex_signed;
  -- Result subtype:
  --   u_complex_signed(re(RE_LENGTH-1 downto 0), im(IM_LENGTH-1 downto 0)),
  --   where RE_LENGTH = 
  --     maximum(L.re'length + R.re'length, L.im'length + R.im'length) + 1,
  --   and IM_LENGTH =
  --     maximum(L.re'length + R.im'length, L.im'length + R.re'length) + 1
  -- Result: Multiplies the numbers without overflow.

  function "/" (L, R : u_complex_signed) return u_complex_signed;
  -- Result subtype:
  --   u_complex_signed(re(RE_LENGTH-1 downto 0), im(IM_LENGTH-1 downto 0)),
  --   where RE_LENGTH = 
  --     maximum(L.re'length + R.re'length, L.im'length + R.im'length) + 1,
  --   and IM_LENGTH =
  --     maximum(L.im'length + R.re'length, L.re'length + R.im'length) + 1
  -- Result: Divides the numbers without overflow.

  function conjugate (ARG : u_complex_signed) return u_complex_signed;
  -- Result subtype:
  --   u_complex_signed(re(ARG.re'range), im(ARG.im'range))
  -- Result: Negates the imaginary part of the ARG.

  --============================================================================
  -- Comparison Operators
  --============================================================================

  function "=" (L, R : u_complex_signed) return boolean;
  -- Result subtype: boolean
  -- Result: Computes "(L.re = R.re) and (L.im = R.im)" with the "=" operator
  --   from numeric_std.

  function "/=" (L, R : u_complex_signed) return boolean;
  -- Result subtype: boolean
  -- Result: Computes "(L.re /= R.re) or (L.im /= R.im)" with the "/=" operator
  --   from numeric_std.

  function "?=" (L, R : u_complex_signed) return std_ulogic;
  -- Result subtype: std_ulogic
  -- Result: Computes "(L.re ?= R.re) and (L.im ?= R.im)" with the "=" operator
  --   from numeric_std.

  function "?/=" (L, R : u_complex_signed) return std_ulogic;
  -- Result subtype: std_ulogic
  -- Result: Computes "(L.re ?/= R.re) or (L.im ?/= R.im)" with the "/="
  --   operator from numeric_std.

  --============================================================================
  -- Shift and Rotate Functions
  --============================================================================

  function shift_left
    (ARG : u_complex_signed; COUNT : natural) return u_complex_signed;
  -- Result subtype:
  --   u_complex_signed(re(ARG.re'range), im(ARG.im'range))
  -- Result: Applies "shift_left" function from numeric_std to the both ARG's
  --   components.

  function shift_right
    (ARG : u_complex_signed; COUNT : natural) return u_complex_signed;
  -- Result subtype:
  --   u_complex_signed(re(ARG.re'range), im(ARG.im'range))
  -- Result: Applies "shift_right" function from numeric_std to the both ARG's
  --   components.

  --============================================================================
  -- Resizing functions
  --============================================================================

  function resize
    (ARG : u_complex_signed; new_size : natural) return u_complex_signed;
  -- Result subtype:
  --   u_complex_signed(re(NEW_SIZE-1 downto 0), im(NEW_SIZE-1 downto 0))
  -- Result: Applies "resize" function from numeric_std to the both ARG's
  --   components.

  --============================================================================
  -- Conversion Functions
  --============================================================================

  function to_complex_signed
    (RE : u_signed; IM : u_signed) return u_complex_signed;
  -- Result subtype: u_complex_signed(re(RE'range), im(IM'range))
  -- Result: Makes a complex number with the given components.

  function to_complex_signed (RE : u_signed) return u_complex_signed;
  -- Result subtype: u_complex_signed(re(RE'range), im(RE'range))
  -- Result: Converts a signed number into the complex. Sets the imaginary part
  --   to zero.

  function to_complex_signed
    (RE, IM : integer; SIZE : natural) return u_complex_signed;
  -- Result subtype:
  --   u_complex_signed(re(SIZE-1 downto 0), im(SIZE-1 downto 0))
  -- Result: Makes a complex number with the given components. Uses "to_signed"
  --   function from numeric_std to convert integer to u_signed.

  function to_complex_signed
    (RE : integer; SIZE : natural) return u_complex_signed;
  -- Result subtype:
  --   u_complex_signed(re(SIZE-1 downto 0), im(SIZE-1 downto 0))
  -- Result: Converts an integer into complex. Uses "to_signed" function from
  --   numeric_std to convert integer to u_signed. Sets the imaginary part to
  --   zero.

  --============================================================================
  -- Match Functions
  --============================================================================

  function std_match (L, R : u_complex_signed) return boolean;
  -- Result subtype: boolean
  -- Result: Computes "std_match(L) and std_match(R)" with the "std_match"
  --   function from numeric_std.

  --============================================================================
  -- Translation Functions
  --============================================================================

  function to_01
    (S : u_complex_signed; XMAP : std_ulogic := '0') return u_complex_signed;
  -- Result subtype:
  --   u_complex_signed(re(S.re'range), im(S.im'range))
  -- Result: Applies "to_01" function from numeric_std to the both ARG's
  --   components.

  function to_X01 (S : u_complex_signed) return u_complex_signed;
  -- Result subtype:
  --   u_complex_signed(re(S.re'range), im(S.im'range))
  -- Result: Applies "to_X01" function from numeric_std to the both ARG's
  --   components.

  function to_X01Z (S : u_complex_signed) return u_complex_signed;
  -- Result subtype:
  --   u_complex_signed(re(S.re'range), im(S.im'range))
  -- Result: Applies "to_X01Z" function from numeric_std to the both ARG's
  --   components.

  function to_UX01 (S : u_complex_signed) return u_complex_signed;
  -- Result subtype:
  --   u_complex_signed(re(S.re'range), im(S.im'range))
  -- Result: Applies "to_UX01" function from numeric_std to the both ARG's
  --   components.

  function is_X (S : u_complex_signed) return boolean;
  -- Result subtype: boolean
  -- Result: Computes "is_X(S.re) or is_X(S.im)" with the "is_X" function
  --   from numeric_std.

end package;

package body complex_signed_pkg is

  function "-" (ARG : u_complex_signed) return u_complex_signed is
    constant RES : u_complex_signed := (re => -ARG.re, im => -ARG.im);
  begin
    return RES;
  end function;

  function "+" (L, R : u_complex_signed) return u_complex_signed is
    constant RE_W : natural := maximum(L.re'length, R.re'length) + 1;
    constant IM_W : natural := maximum(L.im'length, R.im'length) + 1;
    variable res : u_complex_signed(re(RE_W-1 downto 0), im(IM_W-1 downto 0));
  begin
    res := ( 
      re => resize(L.re, RE_W) + R.re,
      im => resize(L.im, IM_W) + R.im
    );
    return res;
  end function;

  function "-" (L, R : u_complex_signed) return u_complex_signed is
    constant RE_W : natural := maximum(L.re'length, R.re'length) + 1;
    constant IM_W : natural := maximum(L.im'length, R.im'length) + 1;
    variable res : u_complex_signed(re(RE_W-1 downto 0), im(IM_W-1 downto 0));
  begin
    res := ( 
      re => resize(L.re, RE_W) - R.re,
      im => resize(L.im, IM_W) - R.im
    );
    return res;
  end function;

  function "*" (L, R : u_complex_signed) return u_complex_signed is
    constant RE_W : natural := maximum(L.re'length + R.re'length,
                                       L.im'length + R.im'length) + 1;
    constant IM_W : natural := maximum(L.re'length + R.im'length,
                                       L.im'length + R.re'length) + 1;
    variable res : u_complex_signed(re(RE_W-1 downto 0), im(IM_W-1 downto 0));
  begin
    res := ( 
      re => resize(L.re*R.re, RE_W) - L.im*R.im,
      im => resize(L.re*R.im, IM_W) + L.im*R.re
    );
    return res;
  end function;

  function "/" (L, R : u_complex_signed) return u_complex_signed is
    constant NUM_RE_W : natural := 
      maximum(L.re'length + R.re'length, L.im'length + R.im'length) + 1;
    constant NUM_IM_W : natural := 
      maximum(L.im'length + R.re'length, L.re'length + R.im'length) + 1;
    constant DENOM_W : natural := maximum(2*R.re'length, 2*R.im'length) + 1;

    constant RE_W : natural := NUM_RE_W;
    constant IM_W : natural := NUM_IM_W;

    constant NUM_RE : signed := resize(L.re*R.re, NUM_RE_W) + L.im*R.im;
    constant NUM_IM : signed := resize(L.im*R.re, NUM_IM_W) - L.re*R.im;
    constant DENUM  : signed := resize(R.re*R.re, DENOM_W ) + R.im*R.im;
    variable res : u_complex_signed(re(RE_W-1 downto 0), im(IM_W-1 downto 0));
  begin
    res := (
      re => NUM_RE/DENUM,
      im => NUM_IM/DENUM
    );
    return res;
  end function;

  function conjugate (ARG : u_complex_signed) return u_complex_signed is
    constant RES : u_complex_signed := (re => ARG.re, im => -ARG.im);
  begin
    return RES;
  end function;

  function "=" (L, R : u_complex_signed) return boolean is
  begin
    return ((L.re = R.re) and (L.im = R.im));
  end function;

  function "/=" (L, R : u_complex_signed) return boolean is
  begin
    return ((L.re /= R.re) or (L.im /= R.im));
  end function;

  function "?=" (L, R : u_complex_signed) return std_ulogic is
  begin
    return ((L.re ?= R.re) and (L.im ?= R.im));
  end function;

  function "?/=" (L, R : u_complex_signed) return std_ulogic is
  begin
    return ((L.re ?/= R.re) or (L.im ?/= R.im));
  end function;

  function shift_left
    (ARG : u_complex_signed; COUNT : natural) return u_complex_signed is
    constant RES : u_complex_signed :=
        (re => shift_left(ARG.re, COUNT), im => shift_left(ARG.im, COUNT));
  begin
    return RES;
  end function;

  function shift_right
    (ARG : u_complex_signed; COUNT : natural) return u_complex_signed is
    constant RES : u_complex_signed :=
        (re => shift_right(ARG.re, COUNT), im => shift_right(ARG.im, COUNT));
  begin
    return RES;
  end function;

  function resize
    (ARG : u_complex_signed; new_size : natural) return u_complex_signed is
    constant RES : u_complex_signed := (
      re => resize(ARG.re, new_size),
      im => resize(ARG.im, new_size)
    );
  begin
    return RES;
  end function;

  function to_complex_signed
    (RE : u_signed; IM : u_signed) return u_complex_signed is
    constant RES : u_complex_signed := (re => RE, im => IM);
  begin
    return RES;
  end function;

  function to_complex_signed (RE : u_signed) return u_complex_signed is
    constant RES : u_complex_signed(re(RE'range), im(RE'range)) := (
      re => RE,
      im => (RE'range => '0')
    );
  begin
    return RES;
  end function;

  function to_complex_signed
    (RE, IM : integer; SIZE : natural) return u_complex_signed is
    constant RES : u_complex_signed := (
      re => to_signed(RE, SIZE),
      im => to_signed(IM, SIZE)
    );
  begin
    return RES;
  end function;

  function to_complex_signed
    (RE : integer; SIZE : natural) return u_complex_signed is
    constant RES : u_complex_signed := (
      re => to_signed(RE, SIZE),
      im => to_signed(0,  SIZE)
    );
  begin
    return RES;
  end function;

  function std_match (L, R : u_complex_signed) return boolean is
  begin
    return (std_match(L.re, R.re) and std_match(L.im, R.im));
  end function;

  function to_01
    (S : u_complex_signed; XMAP : std_ulogic := '0') return u_complex_signed is
    constant RES : u_complex_signed := (
      re => to_01(S.re, XMAP),
      im => to_01(S.im, XMAP)
    );
  begin
    return RES;
  end function;

  function to_X01 (S : u_complex_signed) return u_complex_signed is
    constant RES : u_complex_signed := (
      re => to_X01(S.re),
      im => to_X01(S.im)
    );
  begin
    return RES;
  end function;

  function to_X01Z (S : u_complex_signed) return u_complex_signed is
    constant RES : u_complex_signed := (
      re => to_X01Z(S.re),
      im => to_X01Z(S.im)
    );
  begin
    return RES;
  end function;

  function to_UX01 (S : u_complex_signed) return u_complex_signed is
    constant RES : u_complex_signed := (
      re => to_UX01(S.re),
      im => to_UX01(S.im)
    );
  begin
    return RES;
  end function;

  function is_X (S : u_complex_signed) return boolean is
  begin
    return is_X(S.re) or is_X(S.im);
  end function;

end package body;
