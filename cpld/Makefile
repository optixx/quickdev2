OBJDIR = build/obj
SCRIPTDIR = build/scripts
PROJECTROOT = $(shell pwd)

TARGET = system
TARGETCPLD = xc95144xl-5-TQ144
BOARD = prototype01

CONSTRAINTS = $(BOARD)_constraints.ucf
XSTSCRIPT = build/scripts/system.xst

#--------------------------------------------------------------------

#root of your xilinx binaries
XILINXROOT = /opt/Xilinx/11.1/ISE/bin/lin
#XILINXROOT = /home/david/Data/devel/apps/Xilinx/11.1/ISE/bin/lin


#ISE
XST = $(XILINXROOT)/xst
NGDBUILD = $(XILINXROOT)/ngdbuild
FIT=$(XILINXROOT)/cpldfit
XSLT=$(XILINXROOT)/XSLTProcess
TSIM=$(XILINXROOT)/tsim
TA=$(XILINXROOT)/taengine
HPREP=$(XILINXROOT)/hprep6
IMPACT=$(XILINXROOT)/impact
#Simulation
IVERILOG=iverilog
VVP=vvp
GTKWAVE=gtkwave

#--------------------------------------------------------------------

SIM_SRC=                                  \
	system_tb.v                           \
	system.v 							  \
	sreg.v                           	  \
	bus.v                                 \
	clock_divider.v                       \
	command_muxer.v 

SRC=                                      \
	system.v 							  \
	sreg.v                           	  \
	bus.v                                 \
	clock_divider.v                       \
	command_muxer.v 

all: $(TARGET).jed
sim: $(TARGET)_tb.vvp $(TARGET)_tb.vcd
view: $(TARGET)_tb.view

#--------------------------------------------------------------------

$(TARGET)_tb.vvp:
	rm -f $(OBJDIR)/$@.list
	@for i in `echo $(SIM_SRC)`; do \
	    echo "../../hdl/$$i" >> $(OBJDIR)/$@.list; \
	done
	 cd $(OBJDIR); $(IVERILOG) -o $@  -c $@.list -s $(@:.vvp=)

%.vcd: $(OBJDIR)/$(TARGET)_tb.vvp
	cd $(OBJDIR); $(VVP) $(TARGET)_tb.vvp

$(TARGET)_tb.view:  $(OBJDIR)/$(TARGET)_tb.vcd
	$(GTKWAVE) $<


#--------------------------------------------------------------------

$(TARGET).xst:
	rm -rf  $(SCRIPTDIR)/$(TARGET).xst
	@echo "run" 							>> $(SCRIPTDIR)/$(TARGET).xst
	@echo "-ifn ../scripts/system.prj"  	>> $(SCRIPTDIR)/$(TARGET).xst 
	@echo "-ifmt mixed" 					>> $(SCRIPTDIR)/$(TARGET).xst
	@echo "-ofn $(TARGET)" 					>> $(SCRIPTDIR)/$(TARGET).xst
	@echo "-ofmt NGC" 						>> $(SCRIPTDIR)/$(TARGET).xst
	@echo "-p xc9500xl" 					>> $(SCRIPTDIR)/$(TARGET).xst
	@echo "-top $(TARGET)" 					>> $(SCRIPTDIR)/$(TARGET).xst
	@echo "-opt_mode Speed" 				>> $(SCRIPTDIR)/$(TARGET).xst
	@echo "-opt_level 1" 					>> $(SCRIPTDIR)/$(TARGET).xst
	@echo "-iuc NO" 						>> $(SCRIPTDIR)/$(TARGET).xst
	@echo "-keep_hierarchy YES" 			>> $(SCRIPTDIR)/$(TARGET).xst
	@echo "-netlist_hierarchy as_optimized" >> $(SCRIPTDIR)/$(TARGET).xst
	@echo "-rtlview Yes" 					>> $(SCRIPTDIR)/$(TARGET).xst
	@echo "-hierarchy_separator /" 			>> $(SCRIPTDIR)/$(TARGET).xst
	@echo "-bus_delimiter <>" 				>> $(SCRIPTDIR)/$(TARGET).xst
	@echo "-case maintain" 					>> $(SCRIPTDIR)/$(TARGET).xst
	@echo "-verilog2001 YES" 				>> $(SCRIPTDIR)/$(TARGET).xst
	@echo "-fsm_extract YES" 				>> $(SCRIPTDIR)/$(TARGET).xst
	@echo "-fsm_encoding Auto" 				>> $(SCRIPTDIR)/$(TARGET).xst
	@echo "-safe_implementation No" 		>> $(SCRIPTDIR)/$(TARGET).xst
	@echo "-mux_extract YES" 				>> $(SCRIPTDIR)/$(TARGET).xst
	@echo "-resource_sharing YES" 			>> $(SCRIPTDIR)/$(TARGET).xst
	@echo "-iobuf YES" 						>> $(SCRIPTDIR)/$(TARGET).xst
	@echo "-pld_mp YES" 					>> $(SCRIPTDIR)/$(TARGET).xst
	@echo "-pld_xp YES" 					>> $(SCRIPTDIR)/$(TARGET).xst
	@echo "-pld_ce YES" 					>> $(SCRIPTDIR)/$(TARGET).xst
	@echo "-wysiwyg NO" 					>> $(SCRIPTDIR)/$(TARGET).xst
	@echo "-equivalent_register_removal YES" >> $(SCRIPTDIR)/$(TARGET).xst

$(TARGET).prj: 
	rm -f $(SCRIPTDIR)/$(TARGET).prj
	@for i in `echo $(SRC)`; do \
	    echo "verilog work ../../hdl/$$i" >> $(SCRIPTDIR)/$(TARGET).prj; \
	done

synthesize: $(TARGET).prj $(TARGET).xst
	cd $(OBJDIR); $(XST) -ifn $(PROJECTROOT)/$(XSTSCRIPT) -ofn $(TARGET).srp 

translate:
	cd $(OBJDIR); $(NGDBUILD) -nt timestamp -p $(TARGETCPLD) -uc $(PROJECTROOT)/$(CONSTRAINTS) $(TARGET).ngc $(TARGET).ngd  

fit:
	cd $(OBJDIR); $(FIT) -p $(TARGETCPLD) \
			-ofmt verilog \
			-optimize speed \
			-htmlrpt \
			-loc on  \
			-slew fast \
			-init low  \
			-inputs 54 \
			-pterms 25 \
			-unused float \
			-power std  \
			-terminate keeper $(TARGET).ngd 

stats: 
	cd $(OBJDIR); $(TSIM) $(TARGET) $(TARGET).nga
	cd $(OBJDIR); $(XSLT) $(TARGET)_build.xml
	cd $(OBJDIR); $(TA)  -f $(TARGET)  --format html1 -l timing_report.htm 

generate:
	cd $(OBJDIR); $(HPREP) -s IEEE1149 -n $(TARGET) -i $(TARGET)

$(TARGET).jed: synthesize translate fit stats generate
	mv $(OBJDIR)/$@ $(PROJECTROOT)

upload: $(TARGET).jed 
	$(IMPACT) -batch prototype01_impact.rc

clean:
	rm -rf $(OBJDIR)/*
	rm -rf _impact*
	rm -rf $(TARGET).jed
	rm -rf auto_project*.ipf
	rm -rf auto_project_xdb 
	rm -rf ._impact 

.PHONY: all clean

