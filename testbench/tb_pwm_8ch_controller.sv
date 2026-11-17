`timescale 1ns / 1ps

module tb_pwm_8ch_controller;

    // Parameters
    localparam int NUM_CHANNELS = 8;
    localparam int ADDR_WIDTH   = 4;
    localparam int DATA_WIDTH   = 8;
    localparam int RESOLUTION   = 8;
    localparam int COUNTER_MAX  = 255;
    localparam time CLK_PERIOD  = 20ns; // 50 MHz

    // Clock and Reset signals
    logic clk_i = 0;
    logic arst_ni = 0;

    // Clock generation
    always #(CLK_PERIOD / 2) clk_i = ~clk_i;

    // Interface instantiation
    pwm_if #(
        .NUM_CHANNELS (NUM_CHANNELS),
        .ADDR_WIDTH   (ADDR_WIDTH),
        .DATA_WIDTH   (DATA_WIDTH)
    ) vif (
        .clk_i   (clk_i),
        .arst_ni (arst_ni)
    );

    // DUT instantiation
    pwm_8ch_controller #(
        .NUM_CHANNELS (NUM_CHANNELS),
        .ADDR_WIDTH   (ADDR_WIDTH),
        .DATA_WIDTH   (DATA_WIDTH),
        .RESOLUTION   (RESOLUTION),
        .COUNTER_MAX  (COUNTER_MAX)
    ) dut (
        .clk_i   (vif.clk_i),
        .arst_ni (vif.arst_ni),
        .addr_i  (vif.addr_i),
        .wdata_i (vif.wdata_i),
        .wen_i   (vif.wen_i),
        .rdata_o (vif.rdata_o),
        .pwm_o   (vif.pwm_o)
    );

    // Test stimulus duties
    logic [7:0] TEST_DUTIES[0:NUM_CHANNELS-1];

    // Error counter
    int err_count = 0;

    // Helper check task
    task automatic check_val(string name, logic [DATA_WIDTH-1:0] actual, logic [DATA_WIDTH-1:0] expected);
        if (actual !== expected) begin
            $display("[FAIL] %s: Expected 0x%02h, Got 0x%02h at %0t ps", name, expected, actual, $time);
            err_count++;
        end else begin
            $display("[PASS] %s: 0x%02h", name, actual);
        end
    endtask

    // Waveform dump for GTKWave or Vivado
    initial begin
        $dumpfile("tb_pwm_8ch_controller.vcd");
        $dumpvars(0, tb_pwm_8ch_controller);
    end

    // Main test sequence
    initial begin
        logic [DATA_WIDTH-1:0] rdata;
        int high_counts[NUM_CHANNELS];

        // Populate test duties
        TEST_DUTIES[0] = 8'd0;
        TEST_DUTIES[1] = 8'd32;
        TEST_DUTIES[2] = 8'd64;
        TEST_DUTIES[3] = 8'd96;
        TEST_DUTIES[4] = 8'd128;
        TEST_DUTIES[5] = 8'd160;
        TEST_DUTIES[6] = 8'd192;
        TEST_DUTIES[7] = 8'd255;

        $display("\n========================================================");
        $display("   Starting 8-Channel PWM Controller Testbench (8-bit)");
        $display("========================================================\n");

        // Initialize signals
        vif.addr_i  <= '0;
        vif.wdata_i <= '0;
        vif.wen_i   <= 1'b0;
        arst_ni     <= 1'b0;

        // ----------------------------------------------------
        // TEST 1: Asynchronous Reset Check
        // ----------------------------------------------------
        $display("--- TEST 1: Reset Check ---");
        #(CLK_PERIOD * 3);
        if (vif.pwm_o !== '0) begin
            $display("[FAIL] Outputs not zero during reset!");
            err_count++;
        end else begin
            $display("[PASS] Reset successfully clears pwm_o.");
        end

        // Deassert reset
        @(posedge clk_i);
        #(CLK_PERIOD / 4);
        arst_ni <= 1'b1;
        @(posedge clk_i);

        // ----------------------------------------------------
        // TEST 2: Register Write & Readback
        // ----------------------------------------------------
        $display("\n--- TEST 2: Register Write and Readback ---");
        for (int ch = 0; ch < NUM_CHANNELS; ch++) begin
            vif.write_reg(ch[ADDR_WIDTH-1:0], TEST_DUTIES[ch]);
        end

        for (int ch = 0; ch < NUM_CHANNELS; ch++) begin
            vif.read_reg(ch[ADDR_WIDTH-1:0], rdata);
            check_val($sformatf("DUTY_CH%0d Readback", ch), rdata, TEST_DUTIES[ch]);
        end

        // Test CH_EN register (Address 0x8)
        vif.write_reg(4'h8, 8'hFF); // All channels enabled
        vif.read_reg(4'h8, rdata);
        check_val("CH_EN Register Readback (0xFF)", rdata, 8'hFF);

        // Test Reserved Register (Address 0x9)
        vif.write_reg(4'h9, 8'hA5);
        vif.read_reg(4'h9, rdata);
        check_val("Reserved Addr 0x9 Readback (Should be 0)", rdata, 8'h00);

        // ----------------------------------------------------
        // TEST 3: Output Gating (All Channels Disabled)
        // ----------------------------------------------------
        $display("\n--- TEST 3: Output Gating (CH_EN = 8'h00) ---");
        vif.write_reg(4'h8, 8'h00); // Disable all channels
        repeat (100) @(posedge clk_i);
        if (vif.pwm_o !== '0) begin
            $display("[FAIL] pwm_o non-zero while all channels disabled: 0x%02h", vif.pwm_o);
            err_count++;
        end else begin
            $display("[PASS] All pwm_o lines held at 0 when CH_EN=8'h00.");
        end

        // ----------------------------------------------------
        // TEST 4: Channel Enable Gating (Individual ch_en)
        // ----------------------------------------------------
        $display("\n--- TEST 4: Channel Enable Gating ---");
        // Enable only CH1 (bit 1) and CH4 (bit 4) -> 8'b0001_0010 = 8'h12
        vif.write_reg(4'h8, 8'h12);
        repeat (50) @(posedge clk_i);
        if (vif.pwm_o[0] !== 1'b0 || vif.pwm_o[2] !== 1'b0 || vif.pwm_o[3] !== 1'b0 ||
            vif.pwm_o[5] !== 1'b0 || vif.pwm_o[6] !== 1'b0 || vif.pwm_o[7] !== 1'b0) begin
            $display("[FAIL] Disabled channels emitted pulses: 0x%02h", vif.pwm_o);
            err_count++;
        end else begin
            $display("[PASS] Disabled channels remain 0 while selected channels operate.");
        end

        // ----------------------------------------------------
        // TEST 5: Duty-Cycle Quantization & Accuracy Verification
        // ----------------------------------------------------
        $display("\n--- TEST 5: Duty-Cycle Accuracy Verification ---");
        // Re-enable all channels
        vif.write_reg(4'h8, 8'hFF);

        // Synchronize to the start of a new PWM period (cnt == 0)
        do @(posedge clk_i); while (dut.u_generator.cnt != '0);

        // Sample for exactly one full period (256 clock cycles)
        for (int ch = 0; ch < NUM_CHANNELS; ch++) high_counts[ch] = 0;

        for (int cycle = 0; cycle < 256; cycle++) begin
            @(posedge clk_i);
            for (int ch = 0; ch < NUM_CHANNELS; ch++) begin
                if (vif.pwm_o[ch] === 1'b1) high_counts[ch]++;
            end
        end

        // Check high counts against expected duty cycles
        for (int ch = 0; ch < NUM_CHANNELS; ch++) begin
            if (high_counts[ch] !== int'(TEST_DUTIES[ch])) begin
                $display("[FAIL] CH%0d: Expected %0d high cycles, Counted %0d", 
                         ch, TEST_DUTIES[ch], high_counts[ch]);
                err_count++;
            end else begin
                $display("[PASS] CH%0d (Duty %3d/256 = %5.2f%%): Exactly %0d high cycles measured.",
                         ch, TEST_DUTIES[ch], (TEST_DUTIES[ch] * 100.0) / 256.0, high_counts[ch]);
            end
        end

        // ----------------------------------------------------
        // TEST 6: Direct Immediate Dynamic Duty Update
        // ----------------------------------------------------
        $display("\n--- TEST 6: Immediate Dynamic Duty Update ---");
        // Synchronize to start of period
        do @(posedge clk_i); while (dut.u_generator.cnt != '0);
        // Advance to mid-period cnt ~ 50
        repeat (50) @(posedge clk_i);

        // At cnt ~ 50:
        // CH4 currently has duty = 128 (cnt < 128 -> pwm_o[4] is 1)
        // Dynamically update CH4 duty to 32 (immediate update)
        vif.write_reg(4'h4, 8'd32);

        // Since cnt > 32, pwm_o[4] must immediately transition to 0 without waiting for next period
        @(posedge clk_i);
        if (vif.pwm_o[4] !== 1'b0) begin
            $display("[FAIL] CH4 did not update immediately to 0 when duty was lowered below current count! Got %0b", vif.pwm_o[4]);
            err_count++;
        end else begin
            $display("[PASS] CH4 immediate update verified: output dropped to 0 as soon as duty was updated below count.");
        end

        // Verify next full period reflects the updated duty (32)
        do @(posedge clk_i); while (dut.u_generator.cnt != '0);
        high_counts[4] = 0;
        for (int cycle = 0; cycle < 256; cycle++) begin
            @(posedge clk_i);
            if (vif.pwm_o[4] === 1'b1) high_counts[4]++;
        end

        if (high_counts[4] !== 32) begin
            $display("[FAIL] CH4 post-update period: Expected 32 high cycles, Got %0d", high_counts[4]);
            err_count++;
        end else begin
            $display("[PASS] CH4 steady-state verified: Exactly 32 high cycles in subsequent period.");
        end

        // ----------------------------------------------------
        // Summary Banner
        // ----------------------------------------------------
        $display("\n========================================================");
        if (err_count == 0) begin
            $display("   ALL TESTS PASSED SUCCESSFULLY! (0 Errors)");
        end else begin
            $display("   TESTS COMPLETED WITH %0d ERROR(S)!", err_count);
        end
        $display("========================================================\n");

        $finish;
    end

endmodule
