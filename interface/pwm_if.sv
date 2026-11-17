`timescale 1ns / 1ps

interface pwm_if #(
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

    // DUT Modport
    modport dut (
        input  clk_i, arst_ni, addr_i, wdata_i, wen_i,
        output rdata_o, pwm_o
    );

    // Synchronous bus idle task
    task automatic idle();
        @(posedge clk_i);
        addr_i  <= '0;
        wdata_i <= '0;
        wen_i   <= 1'b0;
    endtask

    // Synchronous write task
    task automatic write_reg(input logic [ADDR_WIDTH-1:0] a, input logic [DATA_WIDTH-1:0] d);
        @(posedge clk_i);
        addr_i  <= a;
        wdata_i <= d;
        wen_i   <= 1'b1;
        @(posedge clk_i);
        wen_i   <= 1'b0;
    endtask

    // Synchronous read task
    task automatic read_reg(input logic [ADDR_WIDTH-1:0] a, output logic [DATA_WIDTH-1:0] d);
        @(posedge clk_i);
        addr_i <= a;
        wen_i  <= 1'b0;
        @(posedge clk_i);
        d = rdata_o;
    endtask

endinterface
