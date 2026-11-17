module pwm_registers #(
    parameter int NUM_CHANNELS = 8,
    parameter int ADDR_WIDTH   = 4,
    parameter int DATA_WIDTH   = 8,
    parameter int RESOLUTION   = 8
)(
    input  logic                                     clk_i,
    input  logic                                     arst_ni,
    input  logic [ADDR_WIDTH-1:0]                    addr_i,
    input  logic [DATA_WIDTH-1:0]                    wdata_i,
    input  logic                                     wen_i,
    output logic [DATA_WIDTH-1:0]                    rdata_o,
    output logic [NUM_CHANNELS-1:0][RESOLUTION-1:0] duty_reg,
    output logic [NUM_CHANNELS-1:0]                  en_reg
);

    localparam logic [ADDR_WIDTH-1:0] ADDR_ENABLE = 4'h8;

    // Synchronous write access via DEMUX (sel = addr_i)
    always_ff @(posedge clk_i or negedge arst_ni) begin
        if (!arst_ni) begin
            duty_reg <= '0;
            en_reg   <= '0;
        end else if (wen_i) begin
            if (addr_i < NUM_CHANNELS) begin
                duty_reg[addr_i] <= wdata_i[RESOLUTION-1:0];
            end else if (addr_i == ADDR_ENABLE) begin
                en_reg <= wdata_i[NUM_CHANNELS-1:0];
            end
        end
    end

    // Address decoder and READ MUX (9:1)
    always_comb begin
        if (addr_i < NUM_CHANNELS) begin
            rdata_o = duty_reg[addr_i];
        end else if (addr_i == ADDR_ENABLE) begin
            rdata_o = en_reg;
        end else begin
            rdata_o = '0;
        end
    end

endmodule