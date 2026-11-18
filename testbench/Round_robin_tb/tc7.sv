task automatic tc7();
    apply_reset();
    apply_and_check(4'b0110, 4'b0010, "Dropping Request: Core 1 wins");
    apply_and_check(4'b0000, 4'b0000, "Dropping Request: Core 2 drops, no ghost grant");
    apply_and_check(4'b0001, 4'b0001, "Dropping Request: Core 0 wins");
endtask
