
TOP := hello

FILES += -i $(CURDIR)/include
FILES += -i $(CURDIR)/testbench

FILES += $(shell find $(CURDIR)/source -maxdepth 1 -mindepth 1 -name "*.sv")

# Exclude test case files because they are included inside pwm_tb.sv
FILES += $(filter-out $(wildcard $(CURDIR)/testbench/tc*.sv),$(shell find $(CURDIR)/testbench -maxdepth 1 -mindepth 1 -name "*.sv"))

.DEFAULT_GOAL = help

.PHONY: simulate
simulate:
	@make -s clean
	@mkdir -p build
	@echo "*" > build/.gitignore
	@cd build && xvlog -sv $(FILES)
	@cd build && xelab $(TOP) -s snap_$(TOP) -debug all
	@cd build && xsim snap_$(TOP) -R

.PHONY: clean
clean:
	@rm -rf build

.PHONY: help
help:
	@echo ""
	@echo "This repository is a small SystemVerilog project that compiles and runs with the Xilinx Vivado Simulator command-line tools."
	@echo -e "\033[1;34m  make simulate\033[0m \033[1;35mTOP=\033[0m\033[1;31m<TOP_MODULE_NAME>\033[0m"
	@echo -e "\033[1;34m  make clean\033[0m"
	@echo "Please read the README.md for further details"
	@echo ""
