/*
A simple complex multiplier.
Written in VHDL-2008.
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

library IEEE;
context IEEE.ieee_std_context;

library work;
use work.complex_signed_pkg.all;

entity complex_multiplier is
    port (
        clk   : in  std_ulogic;
        a_in  : in  u_complex_signed;
        b_in  : in  u_complex_signed;
        c_out : out u_complex_signed
    );

    attribute LATENCY : natural;
    attribute LATENCY of complex_multiplier : entity is 3;
    
    -- attribute use_dsp : string;
    -- attribute use_dsp of complex_multiplier : entity is "yes";

end entity;

architecture rtl of complex_multiplier is

    -- Internal multiplications widths
    constant RE_RE_WIDTH : natural := a_in.re'length + b_in.re'length;
    constant IM_IM_WIDTH : natural := a_in.im'length + b_in.im'length;
    constant RE_IM_WIDTH : natural := a_in.re'length + b_in.im'length;
    constant IM_RE_WIDTH : natural := a_in.im'length + b_in.re'length;

    -- Result's components widths
    constant RE_WIDTH : natural := maximum(RE_RE_WIDTH, IM_IM_WIDTH) + 1;
    constant IM_WIDTH : natural := maximum(RE_IM_WIDTH, IM_RE_WIDTH) + 1;

    signal are_bre : u_signed(RE_RE_WIDTH-1 downto 0) := (others => '0');
    signal aim_bim : u_signed(IM_IM_WIDTH-1 downto 0) := (others => '0');
    signal are_bim : u_signed(RE_IM_WIDTH-1 downto 0) := (others => '0');
    signal aim_bre : u_signed(IM_RE_WIDTH-1 downto 0) := (others => '0');

    -- ModelSim 2020.4 doesn't support O'subtype for the records
    subtype a_t is u_complex_signed(re(a_in.re'range), im(a_in.im'range));
    subtype b_t is u_complex_signed(re(b_in.re'range), im(b_in.im'range));
    subtype c_t is u_complex_signed(re(c_out.re'range), im(c_out.im'range));

    signal a_d1, a_d2 : a_t := (re => (others => '0'), im => (others => '0'));
    signal b_d1, b_d2 : b_t := (re => (others => '0'), im => (others => '0'));
    signal c_out_s    : c_t := (re => (others => '0'), im => (others => '0'));

begin

    first_dsp48 : process(clk)
    begin
        if rising_edge(clk) then
            a_d1.re <= a_in.re;
            b_d1.re <= b_in.re;
            are_bre <= a_d1.re * b_d1.re;
        end if;
    end process;

    second_dsp48 : process(clk)
    begin
        if rising_edge(clk) then
            a_d1.im <= a_in.im;
            b_d1.im <= b_in.im;
            aim_bim <= a_d1.im * b_d1.im;
            c_out_s.re  <= resize(are_bre, RE_WIDTH) - aim_bim;
        end if;
    end process;

    third_dsp48 : process(clk)
    begin
        if rising_edge(clk) then
            a_d2.re <= a_in.re;
            b_d2.im <= b_in.im;
            are_bim <= a_d2.re * b_d2.im;
        end if;
    end process;

    fourth_dsp48 : process(clk)
    begin
        if rising_edge(clk) then
            a_d2.im <= a_in.im;
            b_d2.re <= b_in.re;
            aim_bre <= a_d2.im * b_d2.re;
            c_out_s.im  <= resize(are_bim, IM_WIDTH) + aim_bre;
        end if;
    end process;

    c_out <= c_out_s;

end architecture;
