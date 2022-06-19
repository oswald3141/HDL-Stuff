/*
A wrapper for for complex_multiplier_2008.vhd, allowing to test this entity in
SystemVerilog. Converts the ports' types to sulv.

The code is distributed under The MIT License
Copyright (c) 2022 Andrey Smolyakov
     (andreismolyakow 'at' gmail 'punto' com)
See LICENSE for the complete license text
*/

library IEEE;
context IEEE.ieee_std_context;

library work;
use work.complex_signed_pkg.all;
use work.complex_signed_packing.all;

entity complex_multiplier_2008_wrapper is
    generic (
        a_comp_width : natural := 10;
        b_comp_width : natural := 11;
        
        -- Don't override
        c_comp_width : natural := a_comp_width + b_comp_width + 1;
        a_width : natural := packed_length(a_comp_width, a_comp_width);
        b_width : natural := packed_length(b_comp_width, b_comp_width);
        c_width : natural := packed_length(c_comp_width, c_comp_width)
    );
    port (
        clk   : in  std_ulogic;
        a_in  : in  std_ulogic_vector(a_width-1 downto 0);
        b_in  : in  std_ulogic_vector(b_width-1 downto 0);
        c_out : out std_ulogic_vector(c_width-1 downto 0)
    );
end entity;

architecture rtl of complex_multiplier_2008_wrapper is
    signal a_in_s : u_complex_signed(
        re(a_comp_width-1 downto 0),
        im(a_comp_width-1 downto 0));
    signal b_in_s : u_complex_signed(
        re(b_comp_width-1 downto 0),
        im(b_comp_width-1 downto 0));
    signal c_out_s : u_complex_signed(
        re(c_comp_width-1 downto 0),
        im(c_comp_width-1 downto 0));
begin

    a_in_s <= from_sulv(a_in);
    b_in_s <= from_sulv(b_in);
    
    c_out <= to_sulv(c_out_s);

    uut : entity work.complex_multiplier(rtl)
        port map (
            clk   => clk,
            a_in  => a_in_s,
            b_in  => b_in_s,
            c_out => c_out_s
        );
end architecture;
