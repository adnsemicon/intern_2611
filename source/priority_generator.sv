module priority_generator #(
    parameter int N,
    parameter int PTR_W
)(
    input  logic clk_i,
    input  logic arst_ni,
    input  logic update_i,

    input  logic [PTR_W-1:0] gnt_idx_i,

    output logic [PTR_W-1:0] master_order_o [0:N-1]
);

    always_ff @(posedge clk_i or negedge arst_ni) begin

        if (!arst_ni) begin

            // Initialize priority sequence
            for (int i = 0; i < N; i++) begin
                master_order_o[i] <= i;
            end

        end

        else if (update_i) begin

            // Rotate priority after winner
            for (int i = 0; i < N; i++) begin

                master_order_o[i] <=
                    master_order_o[(i + gnt_idx_i + 1) % N];

            end

        end

    end

endmodule