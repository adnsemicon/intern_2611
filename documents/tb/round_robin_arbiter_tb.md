# Round Robin Arbiter Testbench

## Document Information

| Item               | Description                                                |
| :----------------- | :--------------------------------------------------------- |
| DUT Name           | `round_robin_arbiter`                                      |
| Design Type        | Parameterized $N$-input Round Robin Arbiter                |
| Verification Level | Module-level / Block-level                                 |
| Language           | SystemVerilog                                              |
| Verification Style | Structured Self-Checking Testbench (Modular Tasks, Vivado) |

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

| Port      | Direction | Width | Description                                                                |
| :-------- | :-------: | :---: | :------------------------------------------------------------------------- |
| `clk_i`   |   Input   |   1   | System clock; arbiter priority pointer updates on posedge                  |
| `arst_ni` |   Input   |   1   | Asynchronous active-low reset; resets priority to Master 0                 |
| `req_i`   |   Input   |  `N`  | Bitmask of active requests (`req_i[i] = 1` indicates Master $i$ wants bus) |
| `gnt_o`   |  Output   |  `N`  | One-hot grant output (`gnt_o[i] = 1` indicates Master $i$ won grant)       |

### Parameter Definitions

| Parameter | Type  | Default | Description                                              |
| :-------- | :---: | :-----: | :------------------------------------------------------- |
| `N`       | `int` |   `4`   | Number of participating masters/cores to arbitrate among |

---

## Functional Description

### Overview

`round_robin_arbiter` arbitrates bus or resource access among $N$ requesting agents using a fair round-robin scheduling scheme:
1. **Combinational Grant Generation**: An internal grant generator immediately computes the grant vector `gnt_o` based on current `req_i` and the current highest-priority agent pointer.
2. **Dynamic Priority Rotation**: When an agent $i$ is granted access during a cycle, the priority pointer rotates on the next positive edge of `clk_i` so that agent $(i+1) \pmod N$ receives top priority.
3. **Priority Preservation**: If no requests are asserted (`req_i == '0`), the priority pointer retains its state without spurious rotation.
4. **Starvation Prevention**: Every requesting agent is guaranteed access within at most $N-1$ grant cycles, preventing any single agent from monopolizing the shared resource.

---

## Verification Environment

The testbench is structured into a modular, self-checking SystemVerilog environment:

- **Interface (`round_robin_arbiter_if`)**: Encapsulates `clk_i`, `arst_ni`, `req_i`, and `gnt_o`.
- **Top Testbench (`tb_round_robin_arbiter`)**:
  - Instantiates DUT and interface.
  - Implements reusable verification tasks (`apply_reset`, `apply_reset_cycles`, `apply_and_check`, `check`, `tc_drive`, `tc_idle`, `tc_onehot`, `tc_chk`, `report_summary`).
  - Supports dynamic test dispatching via command-line plusarg: `+TEST=<test_name>` (e.g. `TEST=tc1`, `TEST=tc6`, `TEST=all`).
  - Supports global fault injection via top-level parameter `ERROR_INJECT`.
- **Modular Test Cases (`Round_robin_tb/`)**:
  - `tc1.sv`: Full Rotation & Wrap-Around
  - `tc2.sv`: Starvation Prevention & Fairness
  - `tc3.sv`: Priority Selection
  - `tc4.sv`: Priority Preservation
  - `tc5.sv`: Fault Injection & Checker Validation
  - `tc6.sv`: Request Glitch Between Edges
  - `tc7.sv`: Back-to-Back Resets
  - `tc8.sv`: No X/Z on Grant Output
  - `tc9.sv`: Random Stress Test with Reference Model
  - `tc10.sv`: Asynchronous Reset Mid-Operation
  - `tc11.sv`: Exhaustive Pattern and State Verification

---

## Test Cases Summary

| Test ID | Testcase Name | Verification Goal / Description | Checks | Command to Run | Expected Status |
| :---: | :--- | :--- | :---: | :--- | :---: |
| **TC1** | **Full Rotation & Wrap-Around** | Drives continuous simultaneous requests across 2 full round-robin rotations ($0 \to 1 \to 2 \to 3 \to 0 \dots$) to confirm wrap-around. | 8 | `make simulate TEST=tc1` | **PASS (8/8)** |
| **TC2** | **Starvation Prevention & Fairness** | Competes aggressive Master 0 against victim Master 3; verifies Master 3 is serviced within 1 cycle. | 2 | `make simulate TEST=tc2` | **PASS (2/2)** |
| **TC3** | **Priority Selection** | Verifies single-master requests and multi-master conflicts against initial priority hierarchy ($M_0 > M_1 > M_2 > M_3$). | 10 | `make simulate TEST=tc3` | **PASS (10/10)** |
| **TC4** | **Priority Preservation** | Verifies priority state holds steady during idle cycles after reset, after $M_0$ grant, and after $M_2$ grant. | 20 | `make simulate TEST=tc4` | **PASS (20/20)** |
| **TC5** | **Fault Injection & Checker Validation** | Deliberately corrupts expected grant value to verify that the self-checker flags `[FAIL]` and halts simulation via `$fatal`. | 2 | `make simulate TEST=tc5` | **1 PASS, 1 FAIL** (halts on `$fatal`) |
| **TC6** | **Request Glitch Between Edges** | Verifies short request pulses between clock edges do not cause premature priority rotation. | 2 | `make simulate TEST=tc6` | **PASS (2/2)** |
| **TC7** | **Back-to-Back Resets** | Verifies arbiter recovers cleanly from multiple back-to-back reset cycles. | 2 | `make simulate TEST=tc7` | **PASS (2/2)** |
| **TC8** | **No X/Z on Grant Output** | Verifies grant bus is fully defined (no high-impedance or uninitialized bits) across states. | 1 | `make simulate TEST=tc8` | **PASS (1/1)** |
| **TC9** | **Random Stress Test** | 21,000 cycles of mixed low/medium/high request density checked against golden reference model. | 21,000 | `make simulate TEST=tc9` | **PASS (21000/21000)** |
| **TC10** | **Async Reset Mid-Operation** | Verifies asynchronous reset asserted mid-cycle restores priority immediately without waiting for clock edge. | 3 | `make simulate TEST=tc10` | **PASS (3/3)** |
| **TC11** | **Exhaustive Priority Verification** | Exercises all $2^N$ request patterns across every cyclic table permutation state ($N \le 10$). | 64 | `make simulate TEST=tc11` | **PASS (64/64)** |
| **ALL** | **Full Regression Suite** | Executes all functional testcases (`tc1`–`tc4`, `tc6`–`tc11`) sequentially. | 21,112 | `make simulate TEST=all` | **PASS (21112/21112)** |

---

## Simulation Commands

All simulations run through the unified `Makefile` using AMD Vivado simulator (`xvlog`, `xelab`, `xsim`) via test plusargs (`+TEST=<name>`).

### Run Individual Test Cases

```bash
# Run individual test cases
make simulate TEST=tc1
make simulate TEST=tc2
make simulate TEST=tc3
make simulate TEST=tc4
make simulate TEST=tc5    # Fault injection test (intentionally exits with $fatal)
make simulate TEST=tc6
make simulate TEST=tc7
make simulate TEST=tc8
make simulate TEST=tc9
make simulate TEST=tc10
make simulate TEST=tc11
```

### Run Full Regression Suite

```bash
# Run all functional test cases (tc1-tc4, tc6-tc11)
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
make clean
```
