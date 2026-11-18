task automatic tc5();
    apply_reset();
    apply_and_check(4'b0001, 4'b0001, "Idle Retention: Core 0 wins first");
    apply_and_check(4'b0000, 4'b0000, "Idle Retention: Idle cycle 1");
    apply_and_check(4'b0000, 4'b0000, "Idle Retention: Idle cycle 2");
    apply_and_check(4'b0000, 4'b0000, "Idle Retention: Idle cycle 3");
    apply_and_check(4'b0011, 4'b0010, "Idle Retention: Priority preserved, Core 1 wins");
endtask
