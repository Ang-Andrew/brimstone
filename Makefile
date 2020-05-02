DIR  = $(CURDIR)
SRCS = $(wildcard $(DIR)/src/*.v)
TEST_SRCS = $(wildcard $(DIR)/test/*.v)
TEST = $(basename $(shell basename $(TEST_SRCS)))
GUI ?= 0

.PHONY: $(TEST) clean project

$(TEST):
	xvlog $(SRCS) $(TEST_SRCS)
	xelab $@ -debug typical -s sim -R
ifeq ($(GUI),1)
	xsim sim -gui -wdb simulate_xsim.wdb
endif

project:
	vivado -source scripts/create_vivado_project.tcl

clean:
	rm -rf *.jou *.log xsim.* xelab.* xvlog.* sim.wdb
	rm -rf xsim.dir
	rm -rf .Xil
	rm -rf build

dbg:
	@echo SRCS: $(SRCS) | sed 's/ \+/\n /g'
	@echo TEST: $(TEST) | sed 's/ \+/\n /g'
