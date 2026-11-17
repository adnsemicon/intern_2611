
interface pwm_if #(
    parameter int NUM_CHANNELS = 8,
    parameter int ADDR_WIDTH   = 4,
    parameter int DATA_WIDTH   = 8
)(
    input logic clk_i
);


    // Global Signals

    logic arst_ni;


    // Register Interface Signals
    

    logic [ADDR_WIDTH-1:0] addr_i;
    logic [DATA_WIDTH-1:0] wdata_i;
    logic                  wen_i;
    logic [DATA_WIDTH-1:0] rdata_o;



    // PWM Output Interface Signals


    logic [NUM_CHANNELS-1:0] pwm_o;


    
    // Modport: DUT
    

    modport DUT (
        input  clk_i,
        input  arst_ni,
        input  addr_i,
        input  wdata_i,
        input  wen_i,
        output rdata_o,
        output pwm_o
    );


    
    // Modport: Testbench
    

    modport TB (
        input  clk_i,
        input  rdata_o,
        input  pwm_o,
        output arst_ni,
        output addr_i,
        output wdata_i,
        output wen_i
    );

endinterface
