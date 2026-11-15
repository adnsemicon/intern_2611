`timescale 1ns / 1ps

module pwm_registers #(
    parameter int NUM_CHANNELS = 8,
    parameter int ADDR_WIDTH   = 4,
    parameter int DATA_WIDTH   = 32,
    parameter int RESOLUTION   = 8
)(
    input  logic                                     clk,
    input  logic                                     arst_n,
    input  logic [ADDR_WIDTH-1:0]                    addr,
    input  logic [DATA_WIDTH-1:0]                    wrdata,
    input  logic                                     wen,
    input  logic                                     ren,
    output logic [DATA_WIDTH-1:0]                    rdata,
    output logic [NUM_CHANNELS-1:0][RESOLUTION-1:0] duty_reg,
    output logic                                     global_en,
    output logic [NUM_CHANNELS-1:0]                  ch_en
);

    localparam logic [ADDR_WIDTH-1:0] ADDR_ENABLE = 4'h8;

    // Synchronous write access
    always_ff @(posedge clk or negedge arst_n) begin
        if (!arst_n) begin
            duty_reg  <= '0;
            global_en <= 1'b0;
            ch_en     <= '0;
        end else if (wen) begin
            if (addr < NUM_CHANNELS) begin
                duty_reg[addr] <= wrdata[RESOLUTION-1:0];
            end else if (addr == ADDR_ENABLE) begin
                global_en <= wrdata[0];
                ch_en     <= wrdata[NUM_CHANNELS:1];
            end
        end
    end

    // Address decoder and read MUX
    always_comb begin
        if (ren) begin
            if (addr < NUM_CHANNELS) begin
                rdata = { {(DATA_WIDTH-RESOLUTION){1'b0}}, duty_reg[addr] };
            end else if (addr == ADDR_ENABLE) begin
                rdata = { {(DATA_WIDTH-(NUM_CHANNELS+1)){1'b0}}, ch_en, global_en };
            end else begin
                rdata = '0;
            end
        end else begin
            rdata = '0;
        end
    end

endmodule
