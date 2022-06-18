---------------------------------------------------
-- A simple complex multiplier.
-- Compatable with VHDL-1987 and newer.
-- Performes the multiplication as following:
-- 
-- a = ar + j*ai
-- b = br + j*bi
-- c = a*b = (ar*br - ai*bi) + j*(ar*bi + ai*br)
-- 
-- Optimized for Xilinx DSP48: if ports widths don't
-- exceed DSP48's posrts widths, the module will fit
-- exactly into 4 DSP48 without any additional logic.
--
-- The code is distributed under The MIT License
-- Copyright (c) 2021 Andrey Smolyakov
--     (andreismolyakow 'at' gmail 'punto' com)
-- See LICENSE for the complete license text
---------------------------------------------------


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity complex_multiplier is
    port (
        clk  : in  std_ulogic;
        a_re : in  signed;
        a_im : in  signed;
        b_re : in  signed;
        b_im : in  signed;
        c_re : out signed;
        c_im : out signed
    );

    attribute LATENCY : natural;
    attribute LATENCY of complex_multiplier : entity is 3;

    -- attribute use_dsp : string;
    -- attribute use_dsp of complex_multiplier : entity is "yes";

end complex_multiplier;

architecture rtl of complex_multiplier is

    -- For determining the result's width
    function max(a, b : natural) return natural is
    begin
        if a > b then return a;
        else return b;
        end if;
    end;

    -- Internal multiplications widths
    constant RE_RE_WIDTH : natural := a_re'length + b_re'length;
    constant IM_IM_WIDTH : natural := a_im'length + b_im'length;
    constant RE_IM_WIDTH : natural := a_re'length + b_im'length;
    constant IM_RE_WIDTH : natural := a_im'length + b_re'length;

    -- Result's components widths
    constant RE_WIDTH : natural := max(RE_RE_WIDTH, IM_IM_WIDTH) + 1;
    constant IM_WIDTH : natural := max(RE_IM_WIDTH, IM_RE_WIDTH) + 1;

    signal a_re_d1, a_re_d2 : signed(a_re'length-1 downto 0);
    signal a_im_d1, a_im_d2 : signed(a_im'length-1 downto 0);
    signal b_re_d1, b_re_d2 : signed(b_re'length-1 downto 0);
    signal b_im_d1, b_im_d2 : signed(b_im'length-1 downto 0);

    signal are_bre : signed(RE_RE_WIDTH-1 downto 0);
    signal aim_bim : signed(IM_IM_WIDTH-1 downto 0);
    signal are_bim : signed(RE_IM_WIDTH-1 downto 0);
    signal aim_bre : signed(IM_RE_WIDTH-1 downto 0);

    signal c_re_s : signed(RE_WIDTH-1 downto 0);
    signal c_im_s : signed(IM_WIDTH-1 downto 0);

begin

    -- 1st DSP48
    are_bre_calc_prcs : process(clk)
    begin
        if rising_edge(clk) then
            a_re_d1 <= a_re;
            b_re_d1 <= b_re;
            are_bre <= a_re_d1*b_re_d1;
        end if;
    end process are_bre_calc_prcs;

    -- 2nd DSP48
    real_calc_prcs : process(clk)
    begin
        if rising_edge(clk) then
            a_im_d1 <= a_im;
            b_im_d1 <= b_im;
            aim_bim <= a_im_d1 * b_im_d1;
            c_re_s  <= resize(are_bre, RE_WIDTH) - aim_bim;
        end if;
    end process real_calc_prcs;

    -- 3d DSP48
    are_bim_calc_prcs : process(clk)
    begin
        if rising_edge(clk) then
            a_re_d2 <= a_re;
            b_im_d2 <= b_im;
            are_bim <= a_re_d2*b_im_d2;
        end if;
    end process are_bim_calc_prcs;

    -- 4th DSP48
    imag_calc_prcs : process(clk)
    begin
        if rising_edge(clk) then
            a_im_d2 <= a_im;
            b_re_d2 <= b_re;
            aim_bre <= a_im_d2 * b_re_d2;
            c_im_s  <= resize(are_bim, IM_WIDTH) + aim_bre;
        end if;
    end process imag_calc_prcs;

    c_re <= c_re_s;
    c_im <= c_im_s;

end rtl;
