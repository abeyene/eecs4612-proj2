# Compilation and Simulation Makefile

# If ntb_random_seed unspecified, vcs uses 1 as constant seed.
# Set ntb_random_seed_automatic to actually get a random seed
ifdef RANDOM_SEED
SEED_FLAG=+ntb_random_seed=$(RANDOM_SEED)
else
SEED_FLAG=+ntb_random_seed_automatic
endif

URL=https://github.com/abeyene/eecs4612-proj2.git

CLOCK_PERIOD ?= 1.0
RESET_DELAY ?= 777.7

M ?= 2
N ?= 2
k ?= 1

VSRC = vsrc
TEST_HARNESS = TestHarness.v
SIM_DIR = simulation
SIM_EXE = simv-asic
SIM_OPTS = +max-cycles=1000000
VPD_FILE = Proj2.vpd

VCS_NONCC_OPTS = \
  -notice \
  -line \
  +lint=all,noVCDE,noONGS,noUI \
  -error=PCWM-L \
  -error=noZMMCM \
  -timescale=1ns/10ps \
  -quiet \
  -q \
  +rad \
  +vcs+lic+wait \
  +vc+list \
  -sverilog +systemverilogext+.sv+.svi+.svh+.svt -assert svaext +libext+.sv \
  +v2k +verilog2001ext+.v95+.vt+.vp +libext+.v \
  -debug_acc+pp+dmptf -debug_region+cell+encrypt \
  -y $(VSRC) \
  +incdir+$(VSRC) \

PREPROC_DEFINES = \
  +define+VCS \
  +define+CLOCK_PERIOD=$(CLOCK_PERIOD) \
  +define+RESET_DELAY=$(RESET_DELAY) \
  +define+RANDOMIZE_MEM_INIT \
  +define+RANDOMIZE_REG_INIT \
  +define+RANDOMIZE_GARBAGE_ASSIGN \
  +define+RANDOMIZE_INVALID_ASSIGN

.PHONY : all help update setup simulator run clean

all : help

help :
	@echo -e "\n----------------------------- Makefile Options ---------------------------------"
	@echo -e "\na) make setup M=X N=X - Generate a random MxN and Nx1 matrix to store in ExtMem"
	@echo -e "b) make simulator - Build the vcs simulation executable"
	@echo -e "c) make run - Run the simulation"
	@echo -e "d) make view - open the waveform file with DVE"
	@echo -e "e) make update - update repository with remote changes\n"

$(SIM_DIR)/$(SIM_EXE) : clean $(VSRC_PATH) $(SIM_DIR)
	vcs $(VCS_NONCC_OPTS) $(PREPROC_DEFINES) +define+DEBUG -debug_access+all $(VSRC)/$(TEST_HARNESS) -o $@

setup : $(SIM_DIR) update
	python ExtMem.py -M $(M) -N $(N) && mv *.bin $(SIM_DIR) && mv *.mat $(SIM_DIR)
	@sed -i "s/run_test(\([0-1]\), \([0-2]\), \([0-9]\{1,2\}\), \([0-7]\), [0-9]\{1,2\}, [0-9]\{1,2\})/run_test(\1, \2, \3, $(k), $(M), $(N))/" $(VSRC)/$(TEST_HARNESS)

update : 
	git checkout vsrc/TestHarness.v
	git pull

simulator : $(SIM_DIR)/$(SIM_EXE)

run : $(SIM_DIR)/$(SIM_EXE)
	cd $(SIM_DIR) && $(SIM_EXE) $(SIM_OPTS) +verbose +vcdplusfile=$(VPD_FILE)

view : $(SIM_DIR)/$(VPD_FILE)
	cd $(SIM_DIR) && dve -vpd $(VPD_FILE) -script dve-startup.tcl

clean :
	rm -rf csrc vc_hdrs.h $(SIM_DIR)/$(SIM_EXE) $(SIM_DIR)/$(SIM_EXE).daidir $(SIM_DIR)/ucli.key $(SIM_DIR)/$(VPD_FILE) $(SIM_DIR)/DVEfiles
