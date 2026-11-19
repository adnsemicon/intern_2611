// TC06 – Boundary and Corner-Case Testing
task automatic tc06_corner_cases();

    int i;

    $display("\n--- TC06: Corner Cases ---");

    reset_dut();

    //==================================================
    // TEST 1: ZERO DUTY CYCLE
    //==================================================

    $display("\n[TC06.1] Testing zero duty cycle");

    write_reg(4'h0, 8'd0);     // CH0 duty = 0
    write_reg(4'h8, 8'h01);    // Enable CH0

    check_reg(4'h0, 8'd0);

    check_pwm_period(0, 0);


    //==================================================
    // TEST 2: MAXIMUM DUTY CYCLE
    //==================================================

    $display("\n[TC06.2] Testing maximum duty cycle");

    write_reg(4'h0, 8'd255);

    check_reg(4'h0, 8'd255);

    check_pwm_period(0, 255);


    //==================================================
    // TEST 3: ENABLE REGISTER PATTERNS
    //==================================================

    $display("\n[TC06.3] Testing enable register patterns");

    // Set all channel duty cycles to 128
    for (i = 0; i < NUM_CHANNELS; i++) begin
        write_reg(i, 8'd128);
    end

    // Pattern 0x00: All channels disabled
    write_reg(4'h8, 8'h00);
    @(posedge clk_i);
    #1;

    check_disabled_mask(8'h00);

    // Pattern 0xAA: Odd channels enabled
    write_reg(4'h8, 8'hAA);
    @(posedge clk_i);
    #1;

    check_disabled_mask(8'hAA);

    check_pwm_period(1, 128);

    // Pattern 0x55: Even channels enabled
    write_reg(4'h8, 8'h55);
    @(posedge clk_i);
    #1;

    check_disabled_mask(8'h55);

    check_pwm_period(0, 128);

    // Pattern 0xFF: All channels enabled
    write_reg(4'h8, 8'hFF);

    check_pwm_period(0, 128);


    //==================================================
    // TEST 4: BACK-TO-BACK REGISTER WRITES
    //==================================================

    $display("\n[TC06.4] Testing back-to-back writes");

    write_reg(4'h0, 8'd32);
    write_reg(4'h1, 8'd200);

    check_reg(4'h0, 8'd32);
    check_reg(4'h1, 8'd200);


    //==================================================
    // TEST 5: CHANNEL INDEPENDENCE
    //==================================================

    $display("\n[TC06.5] Testing channel independence");

    write_reg(4'h8, 8'h03);

    // CH0 should have 32 HIGH cycles
    check_pwm_period(0, 32);

    // CH1 should have 200 HIGH cycles
    check_pwm_period(1, 200);

endtask