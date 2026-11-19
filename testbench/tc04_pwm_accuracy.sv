// TC04 – PWM Duty-Cycle Accuracy
task automatic tc04_pwm_accuracy();
    $display("\n--- TC04: PWM Duty-Cycle Accuracy ---");
    reset_dut();

    // TODO: Program a duty value and enable the selected channel.
    // Note: align/check sampling to the counter phase as needed to avoid
    // counting a partial PWM period.
    write_reg(4'd0, 8'd64);       // CH0 duty = 64
    write_reg(4'd8, 8'b00000001); // Enable CH0
    check_pwm_period(0, 64);
endtask
