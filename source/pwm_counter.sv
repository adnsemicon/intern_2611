`timescale 1ns / 1ps

module pwm_counter #(
    parameter int RESOLUTION  = 8,
    parameter int COUNTER_MAX = 255
)(
    input  logic                  clk,
    input  logic                  arst_n,
    input  logic                  global_en,
    output logic [RESOLUTION-1:0] counter,
    output logic                  period_tick
);

    always_ff @(posedge clk or negedge arst_n) begin
        if (!arst_n) begin
            counter <= '0;
        end else if (!global_en) begin
            counter <= '0;
        end else if (counter == COUNTER_MAX[RESOLUTION-1:0]) begin
            counter <= '0;
        end else begin
            counter <= counter + 1'b1;
        end
    end

    assign period_tick = global_en & (counter == COUNTER_MAX[RESOLUTION-1:0]);

endmodule
