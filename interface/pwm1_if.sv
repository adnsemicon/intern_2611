interface pwm1_if #(
    parameter int NUM_CHANNELS = 8,
    parameter int ADDR_WIDTH   = 4,
    parameter int DATA_WIDTH   = 8
)(
    input logic clk_i,
    input logic arst_ni
);

    logic [ADDR_WIDTH-1:0]   addr_i;
    logic [DATA_WIDTH-1:0]   wdata_i;
    logic                    wen_i;
    logic [DATA_WIDTH-1:0]   rdata_o;
    logic [NUM_CHANNELS-1:0] pwm_o;

    // Modport for the design (pwm_top): defines signal directions
    modport DUT (
        input  clk_i, arst_ni, addr_i, wdata_i, wen_i,
        output rdata_o, pwm_o
    );

endinterface
