# RTL Simulation Starter

This repository is a small SystemVerilog project that compiles and runs with the
Xilinx Vivado Simulator command-line tools.

## Project layout

```text
source/       RTL design files (.sv)
include/      Files referenced by SystemVerilog `include directives
testbench/    Testbench and simulation top-level files (.sv); also an include search path
build/        Generated simulator files and logs
```

The Makefile currently collects `.sv` files directly inside `source/` and
`testbench/` (not their subdirectories). Both `include/` and `testbench/` are
include search paths. For example, `include/vip/tb_ess.sv` can be included as:

```systemverilog
`include "vip/tb_ess.sv"
```

A file directly inside `testbench/` can likewise be included by its filename:

```systemverilog
`include "helper.sv"
```

The simulation top-level defaults to `hello`, as set by `TOP` in the Makefile.
To use a different top-level module, set `TOP` when invoking make, for example:

```sh
make simulate TOP=my_testbench
```

## Requirements

- GNU Make
- Xilinx Vivado Simulator command-line tools (`xvlog`, `xelab`, and `xsim`)

These tools must be available on your `PATH`. The Makefile also uses common
Unix shell utilities (`find` and `rm`); on Windows, run it from an environment
that provides them, such as Git Bash.

## Make commands

Run the default simulation:

```sh
make simulate
```

This target removes the existing `build/` directory, compiles the RTL and
testbench with `xvlog`, elaborates the selected top-level with `xelab`, and
runs it with `xsim`. Simulator output and generated files are placed in
`build/`.

Remove generated simulator files without running a simulation:

```sh
make clean
```

`make simulate` runs `make clean` automatically before each run.
