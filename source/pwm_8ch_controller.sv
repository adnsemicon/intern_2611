`timescale 1ns / 1ps

module pwm_8ch_controller #(
    parameter int NUM_CHANNELS = 8,
    parameter int ADDR_WIDTH   = 4,
    parameter int DATA_WIDTH   = 8,
    parameter int RESOLUTION   = 8,
    parameter int COUNTER_MAX  = 255
)(
    input  logic                    clk_i,
    input  logic                    arst_n,
    input  logic [ADDR_WIDTH-1:0]   addr,
    input  logic [DATA_WIDTH-1:0]   wdata,
    input  logic                    w_en,
    output logic [DATA_WIDTH-1:0]   rdata,
    output logic [NUM_CHANNELS-1:0] pwm_out
);

    // Internal interconnect signals
    logic [NUM_CHANNELS-1:0][RESOLUTION-1:0] duty_reg;
    logic [NUM_CHANNELS-1:0]                 en_reg;
    logic [RESOLUTION-1:0]                   cnt;

    // Submodule 1: Register Bank & Address Decoder / MUX
    pwm_registers #(
        .NUM_CHANNELS (NUM_CHANNELS),
        .ADDR_WIDTH   (ADDR_WIDTH),
        .DATA_WIDTH   (DATA_WIDTH),
        .RESOLUTION   (RESOLUTION)
    ) u_registers (
        .clk_i    (clk_i),
        .arst_n   (arst_n),
        .addr     (addr),
        .wdata    (wdata),
        .w_en     (w_en),
        .rdata    (rdata),
        .duty_reg (duty_reg),
        .en_reg   (en_reg)
    );

    // Submodule 2: Shared 8-Bit Free-Running Timing Reference Counter
    pwm_counter #(
        .RESOLUTION  (RESOLUTION),
        .COUNTER_MAX (COUNTER_MAX)
    ) u_counter (
        .clk_i   (clk_i),
        .arst_n  (arst_n),
        .cnt     (cnt)
    );

    // 8 Parallel Magnitude Comparators & Output Enable AND Gates
    always_comb begin
        for (int i = 0; i < NUM_CHANNELS; i++) begin
            pwm_out[i] = en_reg[i] & (cnt < duty_reg[i]);
        end
    end

endmodule
