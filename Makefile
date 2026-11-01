TOP := hello

FILES += -i $(CURDIR)/include
FILES += -i $(CURDIR)/testbench
FILES += $(shell find $(CURDIR)/source -maxdepth 1 -mindepth 1 -name "*.sv")
FILES += $(shell find $(CURDIR)/testbench -maxdepth 1 -mindepth 1 -name "*.sv")

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
