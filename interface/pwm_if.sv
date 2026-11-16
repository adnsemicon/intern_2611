`timescale 1ns / 1ps

interface pwm_if #(
    parameter int NUM_CHANNELS = 8,
    parameter int ADDR_WIDTH   = 4,
    parameter int DATA_WIDTH   = 8
)(
    input logic clk_i,
    input logic arst_n
);
    logic [ADDR_WIDTH-1:0]   addr;
    logic [DATA_WIDTH-1:0]   wdata;
    logic                    w_en;
    logic [DATA_WIDTH-1:0]   rdata;
    logic [NUM_CHANNELS-1:0] pwm_out;

    // DUT Modport
    modport dut (
        input  clk_i, arst_n, addr, wdata, w_en,
        output rdata, pwm_out
    );

    // Synchronous bus idle task
    task automatic idle();
        @(posedge clk_i);
        addr  <= '0;
        wdata <= '0;
        w_en  <= 1'b0;
    endtask

    // Synchronous write task
    task automatic write_reg(input logic [ADDR_WIDTH-1:0] a, input logic [DATA_WIDTH-1:0] d);
        @(posedge clk_i);
        addr  <= a;
        wdata <= d;
        w_en  <= 1'b1;
        @(posedge clk_i);
        w_en  <= 1'b0;
    endtask

    // Synchronous read task
    task automatic read_reg(input logic [ADDR_WIDTH-1:0] a, output logic [DATA_WIDTH-1:0] d);
        @(posedge clk_i);
        addr <= a;
        w_en <= 1'b0;
        @(posedge clk_i);
        d = rdata;
    endtask

endinterface
