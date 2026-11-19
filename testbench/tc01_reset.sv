// TC01 – Reset Functionality
task automatic tc01_reset();
    $display("\n--- TC01: Reset Functionality ---");
    reset_dut();

    // TODO: Add reset-state checks here.
    // Examples: read duty registers, read enable register, inspect PWM outputs.
    check(pwm_o === '0, "PWM outputs are LOW after reset");
endtask
