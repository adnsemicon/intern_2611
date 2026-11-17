module pwm_top #(
    parameter int NUM_CHANNELS = 8,
    parameter int ADDR_WIDTH   = 4,
    parameter int DATA_WIDTH   = 8,
    parameter int RESOLUTION   = 8,
    parameter int COUNTER_MAX  = 255
)(
    input  logic                    clk,
    input  logic                    arst_n,
    input  logic [ADDR_WIDTH-1:0]   addr,
    input  logic [DATA_WIDTH-1:0]   wrdata,
    input  logic                    wen,
    output logic [DATA_WIDTH-1:0]   rdata,
    output logic [NUM_CHANNELS-1:0] pwm_out
);

    // Internal signals
    logic [NUM_CHANNELS-1:0][RESOLUTION-1:0] duty_reg;
    logic [NUM_CHANNELS-1:0]                 ch_en;
    logic [RESOLUTION-1:0]                   counter;
    logic                                    period_tick;

    // 1: Registers & Address Decoder
    pwm_registers #(
        .NUM_CHANNELS (NUM_CHANNELS),
        .ADDR_WIDTH   (ADDR_WIDTH),
        .DATA_WIDTH   (DATA_WIDTH),
        .RESOLUTION   (RESOLUTION)
    ) u_registers (
        .clk       (clk),
        .arst_n    (arst_n),
        .addr      (addr),
        .wrdata    (wrdata),
        .wen       (wen),
        .rdata     (rdata),
        .duty_reg  (duty_reg),
        .ch_en     (ch_en)
    );

    // 2: Shared Timing Reference Generator
    pwm_counter #(
        .RESOLUTION  (RESOLUTION),
        .COUNTER_MAX (COUNTER_MAX)
    ) u_counter (
        .clk         (clk),
        .arst_n      (arst_n),
        .counter     (counter),
        .period_tick (period_tick)
    );

    //  3: 8 Parallel Channel Engines (glitch free)
    genvar i;
    generate
        for (i = 0; i < NUM_CHANNELS; i++) begin : gen_channel
            pwm_channel #(
                .RESOLUTION (RESOLUTION)
            ) u_channel (
                .clk         (clk),
                .arst_n      (arst_n),
                .ch_en       (ch_en[i]),
                .period_tick (period_tick),
                .counter     (counter),
                .duty_in     (duty_reg[i]),
                .pwm_out     (pwm_out[i])
            );
        end
    endgenerate

endmodule