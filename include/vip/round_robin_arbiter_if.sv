`ifndef ROUND_ROBIN_ARBITER_IF_SV
`define ROUND_ROBIN_ARBITER_IF_SV

interface round_robin_arbiter_if #(
    parameter int N = 4
)(
    input logic clk_i,
    input logic arst_ni
);

    logic [N-1:0] req;
    logic [N-1:0] gnt;

    // Modport for Arbiter DUT
    modport dut (
        input  clk_i,
        input  arst_ni,
        input  req,
        output gnt
    );

    // Modport for Testbench
    modport tb (
        input  clk_i,
        input  arst_ni,
        output req,
        input  gnt
    );

endinterface

`endif // ROUND_ROBIN_ARBITER_IF_SV
