TOP := tb_pwm_8ch_controller

XVLOG ?= $(shell which xvlog.bat 2>/dev/null || which xvlog 2>/dev/null || echo xvlog)
XELAB ?= $(shell which xelab.bat 2>/dev/null || which xelab 2>/dev/null || echo xelab)
XSIM  ?= $(shell which xsim.bat 2>/dev/null || which xsim 2>/dev/null || echo xsim)

FILES += -i $(CURDIR)/include
FILES += -i $(CURDIR)/interface
FILES += -i $(CURDIR)/testbench
FILES += $(shell [ -d $(CURDIR)/source ] && find $(CURDIR)/source -maxdepth 1 -mindepth 1 -name "*.sv" 2>/dev/null)
FILES += $(shell [ -d $(CURDIR)/interface ] && find $(CURDIR)/interface -maxdepth 1 -mindepth 1 -name "*.sv" 2>/dev/null)
FILES += $(shell [ -d $(CURDIR)/testbench ] && find $(CURDIR)/testbench -maxdepth 1 -mindepth 1 -name "*.sv" 2>/dev/null)

.DEFAULT_GOAL = help

.PHONY: simulate
simulate:
	@make -s clean
	@mkdir -p build
	@echo "*" > build/.gitignore
	@cd build && $(XVLOG) -sv $(FILES)
	@cd build && $(XELAB) $(TOP) -s snap_$(TOP) -debug all
	@cd build && $(XSIM) snap_$(TOP) -R

.PHONY: clean
clean:
	@rm -rf build

.PHONY: help
help:
	@echo ""
	@echo "8-Channel PWM Controller Simulation Makefile (Xilinx Vivado Simulator)"
	@echo -e "\033[1;34m  make simulate\033[0m \033[1;35mTOP=\033[0m\033[1;31m<TOP_MODULE_NAME>\033[0m\033[39G\033[1;32m# Simulate top module (default: tb_pwm_8ch_controller)\033[0m"
	@echo -e "\033[1;34m  make clean\033[0m\033[39G\033[1;32m# Remove all temporary simulation files\033[0m"
	@echo "Please read README.md and documents/ folder for further details."
	@echo ""
