# PWM Controller Testbench



## Document Information

| Item | Description |
|---|---|
| Testbench | `pwm_tb` |
| DUT | `pwm_top` |
| Verification Level | Module-level wrapper |
| Language | SystemVerilog |
| Verification Style | Directed self-checking |

## Target DUT

`pwm_top` is the top-level PWM controller module. It instantiates `pwm_registers` and `pwm_generator`, provides the register configuration interface, and generates eight independently controlled PWM output signals.

The register block supports address-based write access to eight duty-cycle registers and one enable register. The PWM generator uses a shared free-running counter and parallel comparators to generate the PWM outputs based on the configured duty-cycle values and channel enable bits.



## Test Environment

The testbench instantiates:

- **DUT**: `pwm_top`
- **Stimulus**: Direct control of `clk_i`, `arst_ni`, `addr_i`, `wdata_i`, and `wen_i`
- **Register access tasks**: Local `write_reg()` and `read_reg()` helpers
- **Reset stimulus**: `reset_dut()` task to assert and release asynchronous active-low reset
- **PWM checker**: `check_pwm_period()` task to count HIGH output cycles over a complete PWM period
- **Enable checker**: Checks that disabled PWM channels remain LOW
- **Checker**: Self-checking comparisons that accumulate pass/fail counts and report test results

The testbench verifies register access functionality, read-multiplexer behavior, PWM duty-cycle generation, channel enable control, channel independence, counter wraparound, and reset behavior.

## Register Map Under Test

| Address | Register | Description |
|---|---|---|
| `0x0` | `duty_reg[0]` | PWM channel 0 duty-cycle configuration |
| `0x1` | `duty_reg[1]` | PWM channel 1 duty-cycle configuration |
| `0x2` | `duty_reg[2]` | PWM channel 2 duty-cycle configuration |
| `0x3` | `duty_reg[3]` | PWM channel 3 duty-cycle configuration |
| `0x4` | `duty_reg[4]` | PWM channel 4 duty-cycle configuration |
| `0x5` | `duty_reg[5]` | PWM channel 5 duty-cycle configuration |
| `0x6` | `duty_reg[6]` | PWM channel 6 duty-cycle configuration |
| `0x7` | `duty_reg[7]` | PWM channel 7 duty-cycle configuration |
| `0x8` | `en_reg` | PWM channel enable configuration |

Addresses `0x9` through `0xF` are not implemented. Reads from these addresses return zero, and writes are ignored by the current RTL implementation.

## PWM Output Behavior Under Test

Each PWM channel is generated using the following logic:

```systemverilog
pwm_o[i] = en_reg[i] & (cnt < duty_reg[i]);
```

The shared counter is an 8-bit free-running counter that increments on each rising clock edge and wraps around after reaching `255`.

| Duty Register Value | Expected HIGH Cycles | Expected Duty Cycle |
|---|---:|---:|
| `0` | 0 | 0% |
| `1` | 1 | 0.39% |
| `64` | 64 | 25% |
| `128` | 128 | 50% |
| `192` | 192 | 75% |
| `255` | 255 | 99.61% |

The PWM period is 256 clock cycles for the default 8-bit resolution.


## Helper Tasks

| Task | Purpose |
|---|---|
| `write_reg(address, data)` | Writes configuration data to the selected duty-cycle or enable register |
| `read_reg(address, data)` | Selects a register address and extracts the combinational read data |
| `check_reg(address, expected)` | Verifies the selected register's read data against the expected value |
| `reset_dut()` | Initializes stimulus, asserts asynchronous reset, and releases reset |
| `check_pwm_period(channel, expected_high)` | Counts PWM HIGH cycles over 256 clock cycles and compares against the expected count |
| `check_disabled_mask(enable_mask)` | Verifies that channels disabled by the enable mask remain LOW |
| `check()` | Reports individual test results and accumulates pass/fail counts |

# PWM Controller Test Cases

## Test Cases

### TC01 – Reset Functionality (Ashiqur Rahman Anik)

#### Objective
Verify that the PWM controller resets the duty-cycle registers, enable register, and counter to their default values, resulting in all PWM outputs being LOW.

#### Steps
- Assert active-low reset (`arst_ni = 0`) and hold it for a few clock cycles.
- Verify that all duty-cycle registers and the enable register are cleared.
- Check that the PWM counter is reset to zero and all PWM outputs are LOW.
- Release reset and verify that the counter resumes normal operation.

#### Pass Criteria

| Check | Expected |
|---|---|
| Duty-cycle registers after reset | All duty registers = `0x00` |
| Enable register after reset | `en_reg = 0x00` |
| Counter after reset | `cnt = 0x00` |
| PWM outputs after reset | `pwm_o = 0x00` |
| Reset behavior | Asynchronous reset is effective |
| After reset release | Counter resumes incrementing |

---

### TC02 – Duty-Cycle Register Write Read Operation (Asadul Akther)

#### Objective
Verify that duty-cycle values can be written to individual channel registers and read back correctly through the address interface.

#### Steps
- Reset the DUT.
- Write different duty-cycle values to registers at addresses `0x0` through `0x7`.
- Read back each register and compare the returned data with the written value.
- Overwrite one duty-cycle register and verify that the updated value is returned.

#### Pass Criteria

| Check | Expected |
|---|---|
| Duty register 0–7 write/read | Correct values returned |
| Register overwrite | Latest written value returned |
| Valid write | Register updates correctly |
| Readback | Matches the stored value |

---

### TC03 – Write Enable and Write Protection (Taseen Israque)

#### Objective
Verify that the PWM registers are updated only when `wen_i` is asserted and that register contents remain unchanged when write enable is LOW.

#### Steps
- Reset the DUT and write a known value to a duty-cycle register with `wen_i = 1`.
- Set `wen_i = 0` and attempt to write a different value to the same register.
- Read back the register and verify that the original value is retained.
- Repeat the procedure for the enable register at address `0x8`.

#### Pass Criteria

| Check | Expected |
|---|---|
| Duty register write (`wen_i = 1`) | Register updates |
| Duty register write (`wen_i = 0`) | Register remains unchanged |
| Enable register write (`wen_i = 1`) | `en_reg` updates |
| Enable register write (`wen_i = 0`) | `en_reg` remains unchanged |
| Write protection | No register modification when `wen_i = 0` |

---



### TC04 – PWM Duty-Cycle Accuracy (Ashiqur Rahman Anik)

#### Objective
Verify that the PWM generator produces the correct number of HIGH clock samples for programmed duty-cycle values over one complete PWM period.

#### Steps
- Reset the DUT and enable the channel under test.
- Program the selected channel's duty-cycle register with the required value.
- Observe the PWM output for one complete 256-clock period and count HIGH samples.
- Repeat the test for duty-cycle values of `0`, `1`, `64`, `128`, `192`, and `255`.

#### Pass Criteria

| Check | Expected HIGH Samples | Expected Duty Cycle |
|---|---:|---:|
| Duty = `0` | 0 | 0% |
| Duty = `1` | 1 | ≈ 0.39% |
| Duty = `64` | 64 | 25% |
| Duty = `128` | 128 | 50% |
| Duty = `192` | 192 | 75% |
| Duty = `255` | 255 | ≈ 99.61% |

---

### TC05 – Counter Operation and PWM Frequency (Taseen Israque)

#### Objective
Verify that the PWM counter increments on every rising clock edge, wraps around after reaching its maximum value, and generates PWM signals with the expected period and frequency.

#### Steps
- Reset the DUT and verify that the counter starts from zero.
- Observe consecutive rising clock edges and verify that the counter increments by one.
- Verify that the counter wraps from `0xFF` to `0x00`.
- Observe a complete PWM period and verify that the waveform repeats after 256 clock cycles.

#### Pass Criteria

| Check | Expected |
|---|---|
| Counter after reset | `cnt = 0x00` |
| Counter increment | Increments by 1 per rising edge |
| Counter maximum value | `cnt = 0xFF` |
| Counter wraparound | `0xFF` transitions to `0x00` |
| PWM period | 256 clock cycles |
| PWM frequency | `f_clk / 256` |
| Counter behavior | Continuous free-running operation |

---

### TC06 – Boundary and Corner-Case Testing (Asadul Akther)

#### Objective
Verify the PWM controller's behavior under boundary conditions and corner cases, including extreme duty-cycle values, enable patterns, simultaneous channel operation, and invalid register accesses.

#### Steps
- Reset the DUT and test all channels with duty-cycle values of `0x00` and `0xFF`.
- Program different duty-cycle values for all channels and enable them simultaneously.
- Test all-disabled and alternating enable patterns (`0xAA` and `0x55`).
- Attempt invalid register writes and verify that valid registers and PWM outputs are not unintentionally affected.

#### Pass Criteria

| Check | Expected |
|---|---|
| Duty = `0x00` | Enabled PWM outputs remain LOW |
| Duty = `0xFF` | 255 HIGH samples per 256-clock period |
| All channels enabled | Channels operate independently |
| All channels disabled | `pwm_o = 0x00` |
| Enable mask = `0xAA` | Only enabled channels can generate PWM |
| Enable mask = `0x55` | Only enabled channels can generate PWM |
| Disabled channels | Outputs remain LOW |
| Invalid address writes | No valid registers are modified |
| Channel independence | Changing one channel does not affect others |

---

## Expected Result

The testbench prints individual test-case results and ends with a summary similar to:

```text
pwm_tb summary: pass=<N> fail=0
```

Any nonzero failure count indicates that one or more test cases failed. The testbench terminates the simulation with `$fatal` if failures are detected.

## Verification Scope

The testbench focuses on verifying the top-level PWM controller functionality, including register configuration, read/write behavior, PWM waveform generation, output enable logic, channel independence, counter operation, and reset behavior.

The verification is performed through the `pwm_top` interface, with hierarchical access to the internal counter only when required for counter-specific checks.

Detailed internal implementation verification of `pwm_registers` and `pwm_generator` is not treated as a separate unit-level verification scope in this testbench.

## Expected Verification Outcome

The testbench is expected to report individual PASS/FAIL results for each directed test case and provide a final verification summary.

A successful simulation indicates that the tested register-access operations, PWM duty-cycle behavior, enable control, channel independence, counter wraparound, and reset functionality conform to the expected behavior of the current RTL implementation.
## Run Command

```bash
make simulate TOP=pwm_tb
```

The testbench generates `pwm_tb.vcd` for waveform inspection.