

interface pwm_if #(
    parameter int NUM_CHANNELS = 8,
    parameter int ADDR_WIDTH   = 4,
    parameter int DATA_WIDTH   = 8
)(
    input logic clk_i,
    input logic arst_ni
);

    // Signals
    logic [ADDR_WIDTH-1:0]   addr_i;
    logic [DATA_WIDTH-1:0]   wdata_i;
    logic                    wen_i;
    logic [DATA_WIDTH-1:0]   rdata_o;
    logic [NUM_CHANNELS-1:0] pwm_o;

    // Write one register
    task automatic write_reg(input logic [ADDR_WIDTH-1:0] addr,
                             input logic [DATA_WIDTH-1:0] data);
        @(posedge clk_i);
        addr_i  <= addr;
        wdata_i <= data;
        wen_i   <= 1'b1;
        @(posedge clk_i);
        wen_i   <= 1'b0;
    endtask

    // Read one register (rdata_o is combinational on addr_i)
    task automatic read_reg(input  logic [ADDR_WIDTH-1:0] addr,
                            output logic [DATA_WIDTH-1:0] data);
        @(posedge clk_i);
        addr_i <= addr;
        wen_i  <= 1'b0;
        #1;
        data = rdata_o;
    endtask

endinterface