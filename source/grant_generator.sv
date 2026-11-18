module grant_generator #(
    parameter int N,
    parameter int PTR_W
)(
    input  logic [N-1:0] req_i,

    input  logic [PTR_W-1:0] master_order_i [0:N-1],

    output logic [N-1:0] gnt_o,

    output logic found_o,

    output logic [PTR_W-1:0] gnt_idx_o
);

    always_comb begin

        gnt_o        = '0;
        found_o      = 1'b0;
        gnt_idx_o = '0;

        // Check masters according to priority
        for (int i = 0; i < N; i++) begin

            if (!found_o && req_i[master_order_i[i]]) begin

                gnt_o[master_order_i[i]] = 1'b1;

                gnt_idx_o = i;

                found_o = 1'b1;

            end

        end

    end

endmodule