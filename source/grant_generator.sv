/* 

## Purpose
This module (Grant generator) selects one master from the active requests (req_i) for a given number of masters (N) and generates a one-hot grant vector (gnt_o). It scans the priority sequence (master_order_i) from the highest-priority position to the lowest and grants the first master whose request is active. It also reports whether a grant was issued (found_o) and the position in the priority sequence at which the granted master was found (gnt_idx_o).

## Use case
The grant generator is typically used in systems where multiple masters compete for access to a shared resource, such as a bus or memory. It works together with the priority generator. The priority generator supplies the current priority sequence, and the grant generator uses it to decide which master is granted access. The found_o and gnt_idx_o outputs are fed back to the priority generator so that the priorities are rotated after each grant, ensuring fair access among all masters. If no master is requesting, gnt_o stays zero and found_o stays low, so the priority sequence is left unchanged.



 | REVISION | DATE       | AUTHOR                                  | DESCRIPTION                                |
 |----------|------------|-----------------------------------------|--------------------------------------------|
 | 1.0      | 2026-11-18 | Taseen Israque                          | Added grant generator                   |

Author : Taseen Israque  (taseenisraque@gmail.com)
This file is part of adnsemicon/intern_2611
Copyright (c) 2026 ADN Semiconductors
Licensed under the MIT License
See LICENSE file in the project root for full license information

*/
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