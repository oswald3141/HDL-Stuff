/*
The entity for rounding signed numbers

Drops frac_width bits of a given number, but before it adds a correction to the
numer to ensure the desired rounding result.
May consume 1 DSP48 to perform the correction addition.

Supported rounding methods:
    - Floor (FLOOR). Just drops the bits without any correction, thus, always
      rounding towards the negative infinity, no matter what's in fractional
      part. Does not use DSP48, has zero latency.
      Equivalent to floor(x) in MATLAB.
      Yields a bias of -0.5.
    - Ceil (CEIL). Always rounds towards the positive infinity, no matter what's
      in fractional part.
      Equivalent to ceil(x) in MATLAB.
      Yields a bias of 0.5.
    - Non-symmetric Round-half-up (HALF_UP_NONSYM). Round towards the closest
      integer. The value of 0.5 gets rounded towards the positive infinity.
      Equivalent to floor(x+0.5) in MATLAB.
      Yields a bias of +2^-(frac_width+1).
    - Non-symmetric Round-half-down (HALF_DOWN_NONSYM). Round towards the
      closest integer. The value of 0.5 gets rounded towards the negative
      infinity.
      Equivalent to ceil(x-0.5) in MATLAB.
      Yields a bias of -2^-(frac_width+1).
    - Symmetric Round-half-up (HALF_UP_SYM). Rounds towards the closest
      integer, 0.5 gets rounded towards the highest magnitude (1.5 -> 2,
      -4.5 -> -5).
      Equivalent to round(x) in MATLAB.
      Yields no bias.
    - Symmetric Round-half-down (HALF_DOWN_SYM). Rounds towards the closest
      integer, 0.5 gets rounded towards the zero (1.5 -> 1, -4.5 -> -4).
      Has no direct equivalent in MATLAB.
      Yields no bias.
    - Round-half-even (HALF_EVEN). Rounds towards the closest integer, 0.5 gets
      rounded towards the closest even number (1.5 -> 2, -4.5 -> -4, 3.5 -> 4).
      Equivalent to convergent(x) in MATLAB.
      Yields no bias.
    - Round-half-odd (HALF_ODD). Rounds towards the closest integer, 0.5 gets
      rounded towards the closest odd number (1.5 -> 1, -4.5 -> -5, 0.5 -> 1).
      Has no direct equivalent in MATLAB.
      Yields no bias.
      
For the additional details on rounding methods, please, refer to the following
materials:
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

library ieee;
context ieee.ieee_std_context;

entity signed_rounder is
    generic (
        int_width  : natural;
        frac_width : natural;
        method     : string
    );
    port (
        clk   : in  std_ulogic;
        n_in  : in  u_signed(int_width+frac_width-1 downto 0);
        n_out : out u_signed(int_width-1 downto 0)
    );
    
    -- Please, use a package defined below to determine the
    -- entity's LATENCY
    
    -- attribute use_dsp : string;
    -- attribute use_dsp of signed_rounder : entity is "yes";
    
end entity;

architecture rtl of signed_rounder is

    constant T : natural := int_width + frac_width;
    alias    I : natural is int_width;
    alias    F : natural is frac_width;
    
    alias SIGN    : std_ulogic is n_in(T-1);
    alias INT_LSB : std_ulogic is n_in(F);
                   
    signal a_reg, c_reg, p_reg : u_signed(T-1 downto 0) := (others => '0');

    signal FRAC_NZ : std_ulogic;
    signal rounding_correction : a_reg'subtype;
    
begin

    FRAC_NZ <= or n_in(F-1 downto 0);
    
    rounding_correction <=
        (others => '0')
            when method = "FLOOR" else
            
        ((T-1 downto F+1 => '0'), FRAC_NZ, (F-1 downto 0 => '0'))
            when method = "CEIL" else
            
        ((T-1 downto F => '0'), '1', (F-2 downto 0 => '0'))
            when method = "HALF_UP_NONSYM" else
            
        ((T-1 downto F => '0'), '0', (F-2 downto 0 => '1'))
            when method = "HALF_DOWN_NONSYM" else
            
        ((T-1 downto F => '0'), not SIGN, (F-2 downto 0 => SIGN))
            when method = "HALF_UP_SYM" else
            
        ((T-1 downto F => '0'), SIGN, (F-2 downto 0 => not SIGN))
            when method = "HALF_DOWN_SYM" else
            
        ((T-1 downto F => '0'), INT_LSB, (F-2 downto 0 => not INT_LSB))
            when method = "HALF_EVEN" else
            
        ((T-1 downto F => '0'), not INT_LSB, (F-2 downto 0 => INT_LSB))
            when method = "HALF_ODD"  else
            
        -- Incorrect method string, cause an elaboration error
        (a_reg'high+1 downto 0 => '0');


    rounding : process(clk)
    begin
        if rising_edge(clk) then
            a_reg <= n_in;
            c_reg <= rounding_correction;
            p_reg <= a_reg + c_reg;
        end if;
    end process;
    
    n_out <= n_in (T-1 downto F) when (method = "FLOOR") else
             p_reg(T-1 downto F);

end architecture;

package signed_rounder_latency is
    function get(method : string) return natural;
end;
package body signed_rounder_latency is
    function get(method : string) return natural is
        variable res : natural;
    begin
        res := 0 when method = "FLOOR" else 2;
        return res;
    end;
end;
