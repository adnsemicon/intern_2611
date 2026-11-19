// TC05 – Counter Operation and PWM Frequency
task automatic tc05_counter_frequency();

    int cycles;

    $display("\n--- TC05: Counter / PWM Period ---");

    reset_dut();

    // Configure CH0 with 50% duty cycle
    write_reg(4'h0, 8'd128);

    // Enable CH0
    write_reg(4'h8, 8'h01);

    // Wait for the first rising edge of PWM output
    @(posedge pwm_o[0]);

    cycles = 0;

    // Wait until PWM goes LOW
    do begin
        @(posedge clk_i);
        #1;
        cycles++;
    end while (pwm_o[0] !== 1'b0);

    // Continue counting until PWM becomes HIGH again
    do begin
        @(posedge clk_i);
        #1;
        cycles++;
    end while (pwm_o[0] !== 1'b1);

    // Verify PWM period
    check(cycles == PWM_PERIOD,
          $sformatf("PWM period expected=%0d cycles, actual=%0d cycles",
                    PWM_PERIOD, cycles));

    // Verify 50% duty cycle
    check_pwm_period(0, 128);

endtask