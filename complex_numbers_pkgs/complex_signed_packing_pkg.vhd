/*
Functions for the complex signed integer packing

Contains the function converting a complex signed integer into single sulv, and
the functions for converting a sulv back into the complex number form.

The code is distributed under The MIT License
Copyright (c) 2022 Andrey Smolyakov
     (andreismolyakow 'at' gmail 'punto' com)
See LICENSE for the complete license text
*/

library IEEE;
context IEEE.ieee_std_context;

library work;
use work.complex_signed_pkg.all;

package complex_signed_packing is
  
  type packing_method is (re_to_high, re_to_low);
  -- Defines where to put the real part: into the high bits of the sulv, or into
  -- the low ones.
  
  function packed_length(ARG : u_complex_signed) return natural;
  -- Result subtype: natural
  -- Result: Returns the size of the ARG packed into sulv with to_sulv.

  function packed_length(RE_LENGTH, IM_LENGTH : natural) return natural;
  -- Result subtype: natural
  -- Result: Returns the size of the signed complex integer with the components
  --   lenghts of RE_LENGTH and IM_LENGTH packed into sulv with to_sulv.

  function to_sulv
    (ARG : u_complex_signed;
    METHOD : packing_method := re_to_high) return std_ulogic_vector;
  -- Result subtype: std_ulogic_vector(ARG.re'length+ARG.im'length-1 downto 0)
  -- Result: Returns ARG packed into a single sulv with the given METHOD.

  function from_sulv
    (ARG : std_ulogic_vector;
    RE_LENGTH, IM_LENGTH : natural;
    METHOD : packing_method := re_to_high) return u_complex_signed;
  -- Result subtype:
  --   u_complex_signed(re(RE_LENGTH-1 downto 0), im(IM_LENGTH-1 downto 0))
  -- Result: Unpacks sulv returned by to_sulv back into the complex number.

  function from_sulv
    (ARG : std_ulogic_vector;
    METHOD : packing_method := re_to_high) return u_complex_signed;
  -- Result subtype:
  --   u_complex_signed
  --     (re(ARG'length/2-1 downto 0), im(ARG'length/2-1 downto 0))
  -- Result: Unpacks sulv returned by to_sulv back into the complex number.
  -- Implies the lengths of the number's real and imaginary parts to be equal.

end package;

package body complex_signed_packing is

  function packed_length(ARG : u_complex_signed) return natural is
  begin 
    return ARG.re'length + ARG.im'length;
  end function;

  function packed_length(RE_LENGTH, IM_LENGTH : natural) return natural is
  begin
    return RE_LENGTH + IM_LENGTH;
  end function;

  function to_sulv
    (ARG : u_complex_signed;
    METHOD : packing_method := re_to_high) return std_ulogic_vector is
    
    constant RES_RTH : std_ulogic_vector :=
        std_ulogic_vector(ARG.re) & std_ulogic_vector(ARG.im);
    constant RES_RTL : std_ulogic_vector :=
        std_ulogic_vector(ARG.im) & std_ulogic_vector(ARG.re);
  begin
    case METHOD is
      when re_to_high =>
        return RES_RTH;
      when re_to_low =>
        return RES_RTL;
    end case;
  end function;

  function from_sulv
    (ARG : std_ulogic_vector;
    RE_LENGTH, IM_LENGTH : natural;
    METHOD : packing_method := re_to_high) return u_complex_signed is

    constant ARG_LEFT : integer := ARG'length-1;
    alias XARG : std_ulogic_vector(ARG_LEFT downto 0) is ARG;

    -- If METHOD is Re_To_High
    constant RE_RTH : u_signed :=
      u_signed(XARG(XARG'high downto XARG'length - RE_LENGTH));
    constant IM_RTH : u_signed :=
      u_signed(XARG(IM_LENGTH-1 downto 0));
    constant RES_RTH : u_complex_signed :=
      (re => RE_RTH, im => IM_RTH);

    -- If METHOD is Re_To_Low
    constant RE_RTL : u_signed :=
      u_signed(XARG(RE_LENGTH-1 downto 0));
    constant IM_RTL : u_signed :=
      u_signed(XARG(XARG'high downto XARG'length - IM_LENGTH));
    constant RES_RTL : u_complex_signed :=
      (re => RE_RTL, im => IM_RTL);

  begin
    assert ARG'length = RE_LENGTH + IM_LENGTH
      report "COMPLEX_SIGNED_PACKING: Incorrect components lengths"
      severity ERROR;

    case METHOD is
      when re_to_high =>
        return RES_RTH;
      when re_to_low =>
        return RES_RTL;
    end case;
  end function;
  
  function from_sulv
    (ARG : std_ulogic_vector;
    METHOD : packing_method := re_to_high) return u_complex_signed is
  begin
    return from_sulv(ARG, ARG'length/2, ARG'length/2, METHOD);
  end function;

end package body;
