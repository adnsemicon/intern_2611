/* 

## Purpose
This module (Priority generator) generates a priority sequence for a given number of masters (N). The priority sequence is updated based on the index of the granted master (gnt_idx_i). The priority sequence is represented as an array of indices (master_order_o) that indicates the order of priority for the masters.

## Use case
The priority generator is typically used in systems where multiple masters compete for access to a shared resource, such as a bus or memory. The priority sequence determines which master has the highest priority to access the resource at any given time. When a master is granted access, the priority sequence is updated to rotate the priorities, ensuring fair access among all masters.   



 | REVISION | DATE       | AUTHOR                                  | DESCRIPTION                                |
 |----------|------------|-----------------------------------------|--------------------------------------------|
 | 1.0      | 2026-11-18 | Asadul_Rafi                             | Added priority generator                   |

Author : Asadul Akther (rafiasadul27@gmail.com)
This file is part of adnsemicon/intern_2611
Copyright (c) 2026 ADN Semiconductors
Licensed under the MIT License
See LICENSE file in the project root for full license information

*/
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