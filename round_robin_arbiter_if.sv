
interface round_robin_arbiter_if #(
    parameter int N = 8
);

    // ============================================
    // 1. Interface Signal Declarations
    // ============================================

    logic clk_i;
    logic arst_ni;

    logic [N-1:0] req_i;
    logic [N-1:0] gnt_o;


    // ============================================
    // 2. DUT Modport
    // ============================================

    modport DUT (
        input  clk_i,
        input  arst_ni,
        input  req_i,
        output gnt_o
    );


    // ============================================
    // 3. Testbench Modport
    // ============================================

    modport TB (
        output clk_i,
        output arst_ni,
        output req_i,
        input  gnt_o
    );


endinterface
