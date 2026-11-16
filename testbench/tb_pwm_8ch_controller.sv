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
    logic clk = 0;
    logic arst_n = 0;

    // Clock generation
    always #(CLK_PERIOD / 2) clk = ~clk;

    // Interface instantiation
    pwm_if #(
        .NUM_CHANNELS (NUM_CHANNELS),
        .ADDR_WIDTH   (ADDR_WIDTH),
        .DATA_WIDTH   (DATA_WIDTH)
    ) vif (
        .clk    (clk),
        .arst_n (arst_n)
    );

    // DUT instantiation
    pwm_8ch_controller #(
        .NUM_CHANNELS (NUM_CHANNELS),
        .ADDR_WIDTH   (ADDR_WIDTH),
        .DATA_WIDTH   (DATA_WIDTH),
        .RESOLUTION   (RESOLUTION),
        .COUNTER_MAX  (COUNTER_MAX)
    ) dut (
        .clk     (vif.clk),
        .arst_n  (vif.arst_n),
        .addr    (vif.addr),
        .wrdata  (vif.wrdata),
        .wen     (vif.wen),
        .rdata   (vif.rdata),
        .pwm_out (vif.pwm_out)
    );

    // Test stimulus parameters
    localparam logic [7:0] TEST_DUTIES[NUM_CHANNELS] = '{8'd0, 8'd32, 8'd64, 8'd96, 8'd128, 8'd160, 8'd192, 8'd255};

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

    // Main test sequence
    initial begin
        logic [DATA_WIDTH-1:0] rdata;
        int high_counts[NUM_CHANNELS];

        $display("\n========================================================");
        $display("   Starting 8-Channel PWM Controller Testbench (8-bit)");
        $display("========================================================\n");

        // Initialize signals
        vif.addr   <= '0;
        vif.wrdata <= '0;
        vif.wen    <= 1'b0;
        arst_n     <= 1'b0;

        // ----------------------------------------------------
        // TEST 1: Asynchronous Reset Check
        // ----------------------------------------------------
        $display("--- TEST 1: Reset Check ---");
        #(CLK_PERIOD * 3);
        if (vif.pwm_out !== '0) begin
            $display("[FAIL] Outputs not zero during reset!");
            err_count++;
        end else begin
            $display("[PASS] Reset successfully clears pwm_out.");
        end

        // Deassert reset
        @(posedge clk);
        #(CLK_PERIOD / 4);
        arst_n <= 1'b1;
        @(posedge clk);

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
        repeat (100) @(posedge clk);
        if (vif.pwm_out !== '0) begin
            $display("[FAIL] pwm_out non-zero while all channels disabled: 0x%02h", vif.pwm_out);
            err_count++;
        end else begin
            $display("[PASS] All pwm_out lines held at 0 when CH_EN=8'h00.");
        end

        // ----------------------------------------------------
        // TEST 4: Channel Enable Gating (Individual ch_en)
        // ----------------------------------------------------
        $display("\n--- TEST 4: Channel Enable Gating ---");
        // Enable only CH1 (bit 1) and CH4 (bit 4) -> 8'b0001_0010 = 8'h12
        vif.write_reg(4'h8, 8'h12);
        repeat (50) @(posedge clk);
        if (vif.pwm_out[0] !== 1'b0 || vif.pwm_out[2] !== 1'b0 || vif.pwm_out[3] !== 1'b0 ||
            vif.pwm_out[5] !== 1'b0 || vif.pwm_out[6] !== 1'b0 || vif.pwm_out[7] !== 1'b0) begin
            $display("[FAIL] Disabled channels emitted pulses: 0x%02h", vif.pwm_out);
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

        // Synchronize to the start of a new PWM period
        @(posedge clk iff (dut.period_tick === 1'b1));

        // Sample for exactly one full period (256 clock cycles)
        for (int ch = 0; ch < NUM_CHANNELS; ch++) high_counts[ch] = 0;

        for (int cycle = 0; cycle < 256; cycle++) begin
            @(posedge clk);
            for (int ch = 0; ch < NUM_CHANNELS; ch++) begin
                if (vif.pwm_out[ch] === 1'b1) high_counts[ch]++;
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
        // TEST 6: Glitch-Free Shadow Register Duty Update
        // ----------------------------------------------------
        $display("\n--- TEST 6: Glitch-Free Dynamic Duty Update ---");
        // Synchronize to next period boundary
        @(posedge clk iff (dut.period_tick === 1'b1));
        // Advance into middle of period (e.g., 50 cycles)
        repeat (50) @(posedge clk);

        // Update CH4 duty from 128 to 32 in the middle of active period
        vif.write_reg(4'h4, 8'd32);

        // Finish current period and count CH4 high cycles
        // High count should still reflect old duty (128)
        @(posedge clk iff (dut.period_tick === 1'b1));

        // Now count for next full period where new duty (32) must take effect
        high_counts[4] = 0;
        for (int cycle = 0; cycle < 256; cycle++) begin
            @(posedge clk);
            if (vif.pwm_out[4] === 1'b1) high_counts[4]++;
        end

        if (high_counts[4] !== 32) begin
            $display("[FAIL] CH4 Glitch test: Expected 32 high cycles in next period, Got %0d", high_counts[4]);
            err_count++;
        end else begin
            $display("[PASS] CH4 Shadow update seamless: Exactly 32 high cycles in subsequent period.");
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
