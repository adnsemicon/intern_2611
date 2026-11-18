task automatic tc6();
    apply_reset();
    apply_and_check(4'b0100, 4'b0100, "Rotation: Core 2 wins");
    apply_and_check(4'b1100, 4'b1000, "Rotation: Core 3 wins");
    apply_and_check(4'b1100, 4'b0100, "Rotation: Wrap around, Core 2 wins again");
endtask
