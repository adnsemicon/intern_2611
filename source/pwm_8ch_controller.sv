module pwm_top #(
    parameter int NUM_CHANNELS = 8,
    parameter int ADDR_WIDTH   = 4,
    parameter int DATA_WIDTH   = 8,
    parameter int RESOLUTION   = 8
)(
    input  logic                    clk_i,
    input  logic                    arst_ni,
    input  logic [ADDR_WIDTH-1:0]   addr_i,
    input  logic [DATA_WIDTH-1:0]   wdata_i,
    input  logic                    wen_i,
    output logic [DATA_WIDTH-1:0]   rdata_o,
    output logic [NUM_CHANNELS-1:0] pwm_o
);

    // =====================================================
    // Internal Signal Declarations
    // =====================================================

    // Duty cycle registers for all PWM channels
    logic [NUM_CHANNELS-1:0][RESOLUTION-1:0] duty_reg;

    // Channel enable register
    logic [NUM_CHANNELS-1:0] en_reg;


    // =====================================================
    // Module 1: Register Bank
    // =====================================================

    pwm_registers #(
        .NUM_CHANNELS (NUM_CHANNELS),
        .ADDR_WIDTH   (ADDR_WIDTH),
        .DATA_WIDTH   (DATA_WIDTH),
        .RESOLUTION   (RESOLUTION)
    ) u_registers (
        .clk_i     (clk_i),
        .arst_ni   (arst_ni),
        .addr_i    (addr_i),
        .wdata_i   (wdata_i),
        .wen_i     (wen_i),
        .rdata_o   (rdata_o),
        .duty_reg  (duty_reg),
        .en_reg    (en_reg)
    );


    // =====================================================
    // Module 2: PWM Generator (Counter + Comparators)
    // =====================================================

    pwm_generator #(
        .NUM_CHANNELS (NUM_CHANNELS),
        .RESOLUTION   (RESOLUTION)
    ) u_generator (
        .clk_i     (clk_i),
        .arst_ni   (arst_ni),
        .duty_reg  (duty_reg),
        .en_reg    (en_reg),
        .pwm_o     (pwm_o)
    );

endmodule