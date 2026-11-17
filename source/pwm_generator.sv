module pwm_generator #(
    parameter int NUM_CHANNELS = 8,
    parameter int RESOLUTION   = 8,
    parameter int COUNTER_MAX  = 255
)(
    input  logic                                     clk_i,
    input  logic                                     arst_ni,
    input  logic [NUM_CHANNELS-1:0][RESOLUTION-1:0] duty_reg,
    input  logic [NUM_CHANNELS-1:0]                  en_reg,
    output logic [NUM_CHANNELS-1:0]                  pwm_o
);

    // Shared 8-Bit Free-Running Timing Reference Counter
    logic [RESOLUTION-1:0] cnt;

    always_ff @(posedge clk_i or negedge arst_ni) begin
        if (!arst_ni) begin
            cnt <= '0;
        end else if (cnt == COUNTER_MAX[RESOLUTION-1:0]) begin
            cnt <= '0;
        end else begin
            cnt <= cnt + 1'b1;
        end
    end

    // 8 Parallel Magnitude Comparators & Output Enable AND Gates
    always_comb begin
        for (int i = 0; i < NUM_CHANNELS; i++) begin
            pwm_o[i] = en_reg[i] & (cnt < duty_reg[i]);
        end
    end

endmodule