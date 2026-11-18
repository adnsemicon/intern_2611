/* 

## Purpose:
    Implements a round-robin arbiter with N requesters. The arbiter grants access to one of the requesters based on a round-robin priority scheme.
  
## Use cases:
    - Arbitration in shared resources (e.g., buses, memory controllers) where fairness is required among multiple requesters.
    - Systems where multiple masters need to access a single slave resource without starvation.

| REVISION | DATE        | AUTHOR               | DESCRIPTION          |
|----------|------------|-----------------------|----------------------|
| 1.0      | 2026-11-18 | Ashiqur Rahman Anik   | Top module added     |

Author : Ashiqur Rahman Anik (anikr4392@gmail.com)
This file is part of adnsemicon/adn_common
Copyright (c) 2026 ADN Semiconductors
Licensed under the MIT License
See LICENSE file in the project root for full license information

*/

module round_robin_arbiter #(
    parameter int N = 8,
    parameter int PTR_W = (N <= 1) ? 1 : $clog2(N)
)(
    input  logic clk_i,
    input  logic arst_ni,

    input  logic [N-1:0] req_i,

    output logic [N-1:0] gnt_o
);

    // Internal signals

    logic [PTR_W-1:0] master_order [0:N-1];

    logic found;
    logic [PTR_W-1:0] gnt_idx;



    priority_generator #(
        .N(N),
        .PTR_W(PTR_W)
    ) priority_gen (

        .clk_i(clk_i),
        .arst_ni(arst_ni),

        .update_i(found),
        .gnt_idx_i(gnt_idx),

        .master_order_o(master_order)

    );



    grant_generator #(
        .N(N),
        .PTR_W(PTR_W)
    ) grant_gen (

        .req_i(req_i),
        .master_order_i(master_order),

        .gnt_o(gnt_o),
        .found_o(found),
        .gnt_idx_o(gnt_idx)

    );

endmodule

