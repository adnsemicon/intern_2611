`timescale 1ns / 1ps

module pwm_channel #(
    parameter int RESOLUTION = 8
)(
    input  logic                  clk,
    input  logic                  arst_n,
    input  logic                  global_en,
    input  logic                  ch_en,
    input  logic                  period_tick,
    input  logic [RESOLUTION-1:0] counter,
    input  logic [RESOLUTION-1:0] duty_in,
    output logic                  pwm_out
);

    logic [RESOLUTION-1:0] duty_shadow;

    // Shadow register: latches configuration at PWM period boundary or while disabled
    always_ff @(posedge clk or negedge arst_n) begin
        if (!arst_n) begin
            duty_shadow <= '0;
        end else if (!global_en || period_tick) begin
            duty_shadow <= duty_in;
        end
    end

    // Magnitude comparator and output qualification gating logic
    assign pwm_out = global_en & ch_en & (counter < duty_shadow);

endmodule
