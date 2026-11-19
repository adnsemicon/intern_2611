# Round Robin Arbiter Verification Environment

This repository contains the SystemVerilog RTL and verification testbench for an $N$-input Round Robin Arbiter, configured for simulation with the Xilinx Vivado Simulator (`xvlog`, `xelab`, `xsim`).

## Project Layout

```text
source/
  ├── grant_generator.sv          # Combinational grant arbiter logic
  ├── priority_generator.sv       # Priority sequence rotator
  └── round_robin_arbiter.sv      # Top-level arbiter module
interface/
  └── round_robin_arbiter_if.sv   # Interface connecting DUT & TB
testbench/
  ├── tb_round_robin_arbiter.sv   # Top-level testbench & common task definitions
  └── Round_robin_tb/             # Modular test case task files
      ├── tc1.sv                  # Reset verification
      ├── tc2.sv                  # Single request grant
      ├── tc3.sv                  # Two-core contention
      ├── tc4.sv                  # All-core rotating priority
      ├── tc5.sv                  # Priority retention during idle
      ├── tc6.sv                  # Wrap-around rotation
      ├── tc7.sv                  # Dropping request handling
      └── tc8.sv                  # Starvation prevention
```

---

## Common Testbench Tasks

All teammates can call the following common tasks directly inside their test case files:

| Task | Parameters | Description |
| :--- | :--- | :--- |
| `apply_reset(cycles)` | `int cycles = 2` | Asserts active-low reset, clears requests, and releases reset synchronously after `cycles` negative clock edges. |
| `apply_and_check(req, exp, msg)` | `logic [N-1:0] req, exp; string msg` | Drives request at negative edge, verifies combinational grant against expected value, and waits for positive edge to update priority state. |
| `check(ok, msg)` | `logic ok; string msg` | Self-checking assertion helper; increments pass/fail counters. |

---

## How Teammates Add and Run Their Test Case

1. **Write your test task** in `testbench/Round_robin_tb/tc1.sv`:
   ```systemverilog
   task automatic tc1();
       $display("\n--- Running TC1 ---");
       apply_reset();
       apply_and_check(4'b0001, 4'b0001, "Core 0 request wins");
   endtask
   ```

2. **Uncomment your test in [tb_round_robin_arbiter.sv](testbench/tb_round_robin_arbiter.sv)**:
   - Uncomment the include:
     ```systemverilog
     `include "Round_robin_tb/tc1.sv"
     ```
   - Uncomment the call in `initial begin`:
     ```systemverilog
     tc1();
     ```

3. **Run Simulation**:
   - In Vivado: Click **Run Simulation**.
   - Or from terminal: `make simulate`
