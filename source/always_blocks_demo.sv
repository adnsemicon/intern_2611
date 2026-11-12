module always_blocks_demo (

    // Inputs
    input logic [3:0] a, b,
    input logic clk,
    input logic rst_n,
    input logic d,
    input logic en,

    // Outputs
    output logic [3:0] sum,
    output logic [3:0] carry,
    output logic q_ff,
    output logic q_latch

);

    // 1. COMBINATIONAL BLOCK
    always_comb begin
        sum = a + b;
        carry = a & b;
    end


    // 2. SEQUENTIAL BLOCK (Positive Edge)
    always_ff @(posedge clk or negedge rst_n) begin

        if (!rst_n)
            q_ff <= 1'b0;
        else
            q_ff <= d;

    end


    // 3. LATCH BLOCK
    always_latch begin

        if (en)
            q_latch = d;

    end

endmodule
