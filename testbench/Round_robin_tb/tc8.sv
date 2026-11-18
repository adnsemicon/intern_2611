task automatic tc8();
    apply_reset();
    apply_and_check(4'b0001, 4'b0001, "Starvation Prevention: Core 0 continuous request 1");
    apply_and_check(4'b0001, 4'b0001, "Starvation Prevention: Core 0 continuous request 2");
    apply_and_check(4'b1001, 4'b1000, "Starvation Prevention: Core 3 preempts Core 0");
    apply_and_check(4'b0001, 4'b0001, "Starvation Prevention: Core 3 drops, Core 0 resumes");
endtask
