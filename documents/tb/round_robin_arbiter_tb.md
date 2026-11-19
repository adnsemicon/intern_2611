# Round Robin Arbiter Testbench

## Document Information

| Item               | Description                                               |
| :----------------- | :-------------------------------------------------------- |
| DUT Name           | `round_robin_arbiter`                                     |
| Design Type        | Parameterized $N$-input Round Robin Arbiter               |
| Verification Level | Module-level / Block-level                                |
| Language           | SystemVerilog                                             |
| Verification Style | Structured Self-Checking Testbench (Modular Tasks, Vivado)|

---

## Target DUT Description

### RTL Interface

```systemverilog
module round_robin_arbiter #(
    parameter int N = 4  // Number of requester ports
) (
    input  logic         clk_i,    // Clock signal
    input  logic         arst_ni,  // Asynchronous active-low reset
    input  logic [N-1:0] req_i,    // Request vector from N masters/cores
    output logic [N-1:0] gnt_o     // One-hot grant vector
);
```

### Port Definitions

| Port      | Direction | Width   | Description                                                           |
| :-------- | :-------: | :-----: | :-------------------------------------------------------------------- |
| `clk_i`   | Input     | 1       | System clock; arbiter priority pointer updates on posedge             |
| `arst_ni` | Input     | 1       | Asynchronous active-low reset; resets priority to Master 0            |
| `req_i`   | Input     | `N`     | Bitmask of active requests (`req_i[i] = 1` indicates Master $i$ wants bus) |
| `gnt_o`   | Output    | `N`     | One-hot grant output (`gnt_o[i] = 1` indicates Master $i$ won grant)  |

### Parameter Definitions

| Parameter | Type  | Default | Description                                              |
| :-------- | :---: | :-----: | :------------------------------------------------------- |
| `N`       | `int` | `4`     | Number of participating masters/cores to arbitrate among |

---

## Functional Description

### Overview
`round_robin_arbiter` arbitrates bus or resource access among $N$ requesting agents using a fair round-robin scheduling scheme. It consists of:
1. **Combinational Grant Generation**: An internal grant generator immediately computes the grant vector `gnt_o` based on current `req_i` and the current highest-priority agent pointer.
2. **Dynamic Priority Rotation**: When an agent $i$ is granted access during a cycle, the priority pointer rotates on the next positive edge of `clk_i` so that agent $(i+1) \pmod N$ receives top priority.
3. **Priority Preservation**: If no requests are asserted (`req_i == '0`), the priority pointer retains its state without spurious rotation.
4. **Starvation Prevention**: Every requesting agent is guaranteed access within at most $N-1$ grant cycles, preventing any single agent from monopolizing the shared resource.

---

## Verification Environment

The testbench is structured into a modular, self-checking SystemVerilog environment with separated concern layers:

- **Interface (`round_robin_arbiter_if`)**: Encapsulates `clk_i`, `arst_ni`, `req_i`, and `gnt_o`.
- **Top Testbench (`tb_round_robin_arbiter`)**:
  - Instantiates DUT and interface.
  - Implements reusable verification tasks (`apply_reset`, `apply_and_check`, `check`, `report_summary`).
  - Dispatches testcases via top-level module parameter `TEST` (no plusargs required).
  - Supports global fault injection via top-level parameter `ERROR_INJECT`.
- **Modular Test Cases (`Round_robin_tb/`)**:
  - `tc1.sv`: Priority Selection
  - `tc2.sv`: Priority Preservation
  - `tc3.sv`: Full Rotation & Wrap-Around
  - `tc4.sv`: Starvation Prevention & Fairness
  - `tc5.sv`: Fault Injection & Checker Validation

---

## Test Cases Summary

| Test ID | Testcase Name | Verification Goal / Description | Checks | Command to Run | Expected Status |
| :---: | :--- | :--- | :---: | :--- | :---: |
| **TC1** | **Priority Selection** | Verifies single-master requests and multi-master conflicts against initial priority hierarchy ($M_0 > M_1 > M_2 > M_3$). | 10 | `make simulate TEST=tc1` | **PASS (10/10)** |
| **TC2** | **Priority Preservation** | Verifies priority state holds steady during idle cycles after reset, after $M_0$ grant, and after $M_2$ grant. | 18 | `make simulate TEST=tc2` | **PASS (18/18)** |
| **TC3** | **Full Rotation & Wrap-Around** | Drives continuous simultaneous requests across 2 full round-robin rotations ($0 \to 1 \to 2 \to 3 \to 0 \dots$) to confirm wrap-around. | 8 | `make simulate TEST=tc3` | **PASS (8/8)** |
| **TC4** | **Starvation Prevention & Fairness** | Competes aggressive Master 0 against victim Master 3; verifies Master 3 is serviced within 1 cycle. | 2 | `make simulate TEST=tc4` | **PASS (2/2)** |
| **TC5** | **Fault Injection & Checker Validation** | Deliberately corrupts expected grant value to verify that the self-checker flags `[FAIL]` and halts simulation via `$fatal`. | 2 | `make simulate TEST=tc5` | **1 PASS, 1 FAIL** (halts on `$fatal`) |
| **ALL** | **Full Regression Suite** | Executes all functional testcases (`tc1` through `tc4`) sequentially. | 40 | `make simulate TEST=all` | **PASS (40/40)** |

---

## Simulation Commands

All simulations run through the unified `Makefile` using AMD Vivado simulator (`xvlog`, `xelab`, `xsim`). Dynamic pattern matching converts any `tc<N>` input directly to generic integer parameter `TEST=<N>` without modifying the Makefile.

### Run Individual Test Cases

```bash
# Run Testcase 1 (Priority Selection)
make simulate TEST=tc1

# Run Testcase 2 (Priority Preservation)
make simulate TEST=tc2

# Run Testcase 3 (Full Rotation & Wrap-Around)
make simulate TEST=tc3

# Run Testcase 4 (Starvation Prevention & Fairness)
make simulate TEST=tc4

# Run Testcase 5 (Fault Injection Validation - Halts with $fatal)
make simulate TEST=tc5
```

### Run Full Regression Suite

```bash
# Run all functional test cases (tc1 -> tc4)
make simulate TEST=all
# or simply:
make simulate
```

### Run with Global Fault Injection

```bash
# Invert expected values across any testcase to test checker robustness
make simulate TEST=tc1 ERROR_INJECT=1
```

### Clean Simulation Artifacts

```bash
# Clean temporary build directory and log files
make clean
```

---

## Simulation Results

Below is the execution transcript from the full regression suite (`make simulate TEST=all`):

```text
==========================================
      TESTCASE 2: PRIORITY PRESERVATION
==========================================

[TC2] Scenario A: Idle after reset
[PASS] @ 371.0 ns | TC2.A: No requests during idle (expected=0000, got=0000)
[PASS] @ 381.0 ns | TC2.A: No requests during idle (expected=0000, got=0000)
[PASS] @ 391.0 ns | TC2.A: No requests during idle (expected=0000, got=0000)
[PASS] @ 401.0 ns | TC2.A: No requests during idle (expected=0000, got=0000)
[PASS] @ 411.0 ns | TC2.A: No requests during idle (expected=0000, got=0000)
[PASS] @ 421.0 ns | TC2.A: Priority preserved after idle (expected=0001, got=0001)

[TC2] Scenario B: Idle after Master 0 grant
[PASS] @ 451.0 ns | TC2.B: Master 0 receives grant (expected=0001, got=0001)
[PASS] @ 461.0 ns | TC2.B: No requests during idle (expected=0000, got=0000)
[PASS] @ 471.0 ns | TC2.B: No requests during idle (expected=0000, got=0000)
[PASS] @ 481.0 ns | TC2.B: No requests during idle (expected=0000, got=0000)
[PASS] @ 491.0 ns | TC2.B: No requests during idle (expected=0000, got=0000)
[PASS] @ 501.0 ns | TC2.B: No requests during idle (expected=0000, got=0000)
[PASS] @ 511.0 ns | TC2.B: Priority preserved, Master 1 wins (expected=0010, got=0010)

[TC2] Scenario C: Idle after Master 2 grant
[PASS] @ 541.0 ns | TC2.C: Master 2 receives grant (expected=0100, got=0100)
[PASS] @ 551.0 ns | TC2.C: No requests during idle (expected=0000, got=0000)
[PASS] @ 561.0 ns | TC2.C: No requests during idle (expected=0000, got=0000)
[PASS] @ 571.0 ns | TC2.C: No requests during idle (expected=0000, got=0000)
[PASS] @ 581.0 ns | TC2.C: No requests during idle (expected=0000, got=0000)
[PASS] @ 591.0 ns | TC2.C: No requests during idle (expected=0000, got=0000)
[PASS] @ 601.0 ns | TC2.C: Priority preserved, Master 3 wins (expected=1000, got=1000)

[TC2] Priority Preservation Test Completed.


==========================================
  TESTCASE 3: FULL ROTATION & WRAP-AROUND
==========================================
[TC3] Verifying 2 complete round-robin rotations for N=4 cores...
[PASS] @ 631.0 ns | Rotation round 0: expected core 0 grant (0001), got 0001
[PASS] @ 641.0 ns | Rotation round 0: expected core 1 grant (0010), got 0010
[PASS] @ 651.0 ns | Rotation round 0: expected core 2 grant (0100), got 0100
[PASS] @ 661.0 ns | Rotation round 0: expected core 3 grant (1000), got 1000
[PASS] @ 671.0 ns | Rotation round 1: expected core 0 grant (0001), got 0001
[PASS] @ 681.0 ns | Rotation round 1: expected core 1 grant (0010), got 0010
[PASS] @ 691.0 ns | Rotation round 1: expected core 2 grant (0100), got 0100
[PASS] @ 701.0 ns | Rotation round 1: expected core 3 grant (1000), got 1000

[TC3] Full Rotation & Wrap-Around Test Completed.


==========================================
TESTCASE 4: STARVATION PREVENTION & FAIRNESS
==========================================
[TC4] Testing starvation prevention: Core 0 (aggressive) vs Core 3 (victim)...
[PASS] @ 741.0 ns | Aggressive core 0 receives initial grant
[INFO] Victim core 3 granted after 1 cycle(s) of waiting.
[PASS] @ 751.0 ns | Fairness verified: Core 3 granted within 1 cycles (no starvation)

[TC4] Starvation Prevention & Fairness Test Completed.


========================================================
                TESTBENCH EXECUTION SUMMARY
========================================================
 Tests PASSED  : 40
 Tests FAILED  : 0
========================================================
[SUCCESS] All checks completed successfully!

$finish called at time : 761 ns : File "Z:/dv/intern_2611/testbench/tb_round_robin_arbiter.sv" Line 154
```

### Fault Injection Verification Output (`make simulate TEST=tc5`)

```text
==========================================
   TESTCASE 5: FAULT INJECTION CHECK
==========================================
[PASS] @ 71.0 ns | TC5.1: Valid check (core 0 granted) (expected=0001, got=0001)
[FAIL] @ 81.0 ns | TC5.2: Injected fault check (expected=1000, got=0010)
[TC5] Fault Injection Test Completed.

========================================================
                TESTBENCH EXECUTION SUMMARY
========================================================
 Tests PASSED  : 1
 Tests FAILED  : 1
========================================================
Fatal: [FATAL] tb_round_robin_arbiter finished with 1 failures!
```
