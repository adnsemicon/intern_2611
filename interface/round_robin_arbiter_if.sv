`ifndef ROUND_ROBIN_ARBITER_IF_SV
`define ROUND_ROBIN_ARBITER_IF_SV

interface round_robin_arbiter_if #(
    parameter int N = 8
);

    logic clk_i;
    logic arst_ni;

    logic [N-1:0] req_i;
    logic [N-1:0] gnt_o;

    modport DUT (
        input  clk_i,
        input  arst_ni,
        input  req_i,
        output gnt_o
    );

    modport TB (
        output clk_i,
        output arst_ni,
        output req_i,
        input  gnt_o
    );

endinterface

`endif