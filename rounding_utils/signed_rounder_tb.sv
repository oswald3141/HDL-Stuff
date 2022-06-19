/*
Tests every possible configuration of signed_rounder. Feeds it with random
numbers and checks the rounding correction with an assert.

The code is distributed under The MIT License
Copyright (c) 2022 Andrey Smolyakov
     (andreismolyakow 'at' gmail 'punto' com)
See LICENSE for the complete license text
*/


module signed_rounder_tb
import rounding::*;;

localparam INT_WIDTH  = 8,
           FRAC_WIDTH = 4,
           WIDTH = INT_WIDTH + FRAC_WIDTH;
           
localparam N_TESTS = 100;

localparam struct {
    rounding_method method_enum;
    string method_str;
    int unsigned latency;
} UUT_PARAMS [8] = '{'{floor,            "FLOOR",            0},
                     '{ceil,             "CEIL",             2},
                     '{half_up_nonsym,   "HALF_UP_NONSYM",   2},
                     '{half_down_nonsym, "HALF_DOWN_NONSYM", 2},
                     '{half_up_sym,      "HALF_UP_SYM",      2},
                     '{half_down_sym,    "HALF_DOWN_SYM",    2},
                     '{half_even,        "HALF_EVEN",        2},
                     '{half_odd,         "HALF_ODD",         2}};

localparam N_MODES = $size(UUT_PARAMS);

logic signed [WIDTH-1:0] n_in [0:N_MODES-1] = '{default:'0};

logic signed [INT_WIDTH-1:0] n_out [0:N_MODES-1],
                             n_ref [0:N_MODES-1] = '{default:'0};

logic clk = 0;
localparam CLK_PERIOD = 4;
always #(CLK_PERIOD/2) clk = ~clk;

initial begin : stopper
    repeat(N_TESTS) @(posedge clk);
    $display("No incorrect result detected. Test PASSED.");
    $stop();
end

always @(posedge clk) begin : data_gen
    for(int i = 0; i < N_MODES; ++i) begin
        logic signed [WIDTH-1:0] newval;
        
        assert(std::randomize(newval));
        
        n_in[i] <= newval;
        n_ref[i] <= round_explicit(newval,
            FRAC_WIDTH, UUT_PARAMS[i].method_enum);
    end
end

generate for(genvar i = 0; i < N_MODES; ++i) begin
    signed_rounder
    #(
        .int_width(INT_WIDTH),
        .frac_width(FRAC_WIDTH),
        .method(UUT_PARAMS[i].method_str)
    ) uut (
        .clk(clk),
        .n_in(n_in[i]),
        .n_out(n_out[i])
    );
end endgenerate;

generate for(genvar i = 0; i < $size(UUT_PARAMS); ++i) begin
    assert property (
        @(posedge clk)
        n_out[i] == $past(n_ref[i], UUT_PARAMS[i].latency))
    else begin
        #(CLK_PERIOD/2);
        $display("Incorrect result. Test FAILED.");
        $stop();
    end;
end endgenerate;

endmodule
