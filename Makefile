TOP ?= tb_round_robin_arbiter
TEST ?= 0
ERROR_INJECT ?= 0

# Support both numeric (1, 2, 3, 4, 5, 0) and name (tc1, tc2, tc3, tc4, tc5, all)
ifeq ($(TEST),tc1)
  TEST_VAL = 1
else ifeq ($(TEST),tc2)
  TEST_VAL = 2
else ifeq ($(TEST),tc3)
  TEST_VAL = 3
else ifeq ($(TEST),tc4)
  TEST_VAL = 4
else ifeq ($(TEST),tc5)
  TEST_VAL = 5
else ifeq ($(TEST),fault)
  TEST_VAL = 5
else ifeq ($(TEST),err)
  TEST_VAL = 5
else ifeq ($(TEST),all)
  TEST_VAL = 0
else
  TEST_VAL = $(TEST)
endif

XVLOG ?= $(shell which xvlog.bat 2>/dev/null || which xvlog 2>/dev/null || echo xvlog)
XELAB ?= $(shell which xelab.bat 2>/dev/null || which xelab 2>/dev/null || echo xelab)
XSIM  ?= $(shell which xsim.bat 2>/dev/null || which xsim 2>/dev/null || echo xsim)

FILES += -i $(CURDIR)/interface
FILES += -i $(CURDIR)/testbench
FILES += $(shell [ -d $(CURDIR)/source ] && find $(CURDIR)/source -maxdepth 1 -mindepth 1 -name "*.sv" 2>/dev/null)
FILES += $(shell [ -d $(CURDIR)/interface ] && find $(CURDIR)/interface -maxdepth 1 -mindepth 1 -name "*.sv" 2>/dev/null)
FILES += $(shell [ -d $(CURDIR)/testbench ] && find $(CURDIR)/testbench -maxdepth 1 -mindepth 1 -name "*.sv" 2>/dev/null)

.DEFAULT_GOAL = help

.PHONY: all simulate run clean help

all: simulate
simulate:
	@make -s clean
	@mkdir -p build
	@echo "*" > build/.gitignore
	@cd build && $(XVLOG) -sv $(FILES)
	@printf "%s\n" "-generic_top TEST=$(TEST_VAL)" "-generic_top ERROR_INJECT=$(ERROR_INJECT)" "-s snap_$(TOP)" "-debug all" > build/xelab_args.txt
	@cd build && $(XELAB) $(TOP) -f xelab_args.txt
	@cd build && $(XSIM) snap_$(TOP) -R

.PHONY: clean
clean:
	@rm -rf build

.PHONY: help
help:
	@echo ""
	@echo "This repository is a SystemVerilog project for Round Robin Arbiter verification."
	@echo -e "\033[1;34m  make simulate\033[0m \033[1;35m[TOP=<TB>]\033[0m \033[1;35m[TEST=<tc1|tc2|tc3|tc4|tc5|all>]\033[0m \033[1;35m[ERROR_INJECT=<0|1>]\033[0m\033[55G\033[1;32m# Run simulation\033[0m"
	@echo -e "\033[1;34m  make clean\033[0m\033[55G\033[1;32m# Remove all temporary build files\033[0m"
	@echo "Please read the README.md for further details"
	@echo ""
