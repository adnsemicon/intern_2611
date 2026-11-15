`timescale 1ns / 1ps

interface pwm_if #(
    parameter int NUM_CHANNELS = 8,
    parameter int ADDR_WIDTH   = 4,
    parameter int DATA_WIDTH   = 8
)(
    input logic clk,
    input logic arst_n
);
    logic [ADDR_WIDTH-1:0]   addr;
    logic [DATA_WIDTH-1:0]   wrdata;
    logic                    wen;
    logic [DATA_WIDTH-1:0]   rdata;
    logic [NUM_CHANNELS-1:0] pwm_out;

    // Clocking block for synchronous testbench driving and sampling
    clocking cb @(posedge clk);
        default input #1step output #1ns;
        output addr, wrdata, wen;
        input  rdata, pwm_out;
    endclocking

    // Modports
    modport dut (
        input  clk, arst_n, addr, wrdata, wen,
        output rdata, pwm_out
    );

    modport tb (
        clocking cb,
        input    arst_n
    );

    // Synchronous bus helper tasks
    task automatic write_reg(input logic [ADDR_WIDTH-1:0] a, input logic [DATA_WIDTH-1:0] d);
        @(cb);
        cb.addr   <= a;
        cb.wrdata <= d;
        cb.wen    <= 1'b1;
        @(cb);
        cb.wen    <= 1'b0;
    endtask

    task automatic read_reg(input logic [ADDR_WIDTH-1:0] a, output logic [DATA_WIDTH-1:0] d);
        @(cb);
        cb.addr <= a;
        cb.wen  <= 1'b0;
        @(cb);
        d       = cb.rdata;
    endtask

endinterface
