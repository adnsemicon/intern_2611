`timescale 1ns / 1ps

module pwm_counter #(
    parameter int RESOLUTION  = 8,
    parameter int COUNTER_MAX = 255
)(
    input  logic                  clk_i,
    input  logic                  arst_n,
    output logic [RESOLUTION-1:0] cnt
);

    always_ff @(posedge clk_i or negedge arst_n) begin
        if (!arst_n) begin
            cnt <= '0;
        end else if (cnt == COUNTER_MAX[RESOLUTION-1:0]) begin
            cnt <= '0;
        end else begin
            cnt <= cnt + 1'b1;
        end
    end

endmodule
