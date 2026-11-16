`timescale 1ns / 1ps

module pwm_registers #(
    parameter int NUM_CHANNELS = 8,
    parameter int ADDR_WIDTH   = 4,
    parameter int DATA_WIDTH   = 8,
    parameter int RESOLUTION   = 8
)(
    input  logic                                     clk_i,
    input  logic                                     arst_n,
    input  logic [ADDR_WIDTH-1:0]                    addr,
    input  logic [DATA_WIDTH-1:0]                    wdata,
    input  logic                                     w_en,
    output logic [DATA_WIDTH-1:0]                    rdata,
    output logic [NUM_CHANNELS-1:0][RESOLUTION-1:0] duty_reg,
    output logic [NUM_CHANNELS-1:0]                  en_reg
);

    localparam logic [ADDR_WIDTH-1:0] ADDR_ENABLE = 4'h8;

    // Synchronous write access via DEMUX (sel = addr)
    always_ff @(posedge clk_i or negedge arst_n) begin
        if (!arst_n) begin
            duty_reg <= '0;
            en_reg   <= '0;
        end else if (w_en) begin
            if (addr < NUM_CHANNELS) begin
                duty_reg[addr] <= wdata[RESOLUTION-1:0];
            end else if (addr == ADDR_ENABLE) begin
                en_reg <= wdata[NUM_CHANNELS-1:0];
            end
        end
    end

    // Address decoder and READ MUX (9:1)
    always_comb begin
        if (addr < NUM_CHANNELS) begin
            rdata = duty_reg[addr];
        end else if (addr == ADDR_ENABLE) begin
            rdata = en_reg;
        end else begin
            rdata = '0;
        end
    end

endmodule
