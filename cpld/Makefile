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

XST = $(XILINXROOT)/xst
NGDBUILD = $(XILINXROOT)/ngdbuild
FIT=$(XILINXROOT)/cpldfit
XSLT=$(XILINXROOT)/XSLTProcess
TSIM=$(XILINXROOT)/tsim
TA=$(XILINXROOT)/taengine
HPREP=$(XILINXROOT)/hprep6
CVER=cver
GTKWAVE=gtkwave
IVERILOG=iverilog
VVP=vvp

#--------------------------------------------------------------------

SIM_SRC=                                  \
	system_tb.v                           \
	system.v 							  \
	sreg.v                           	  \
	bus.v

SRC=                                      \
	system.v 							  \
	sreg.v                           	  \
	bus.v

all: $(TARGET).jed
sim: $(TARGET)_tb.vcd
view: $(TARGET)_tb.view
# main rule

#--------------------------------------------------------------------

system_tb.vvp:
	rm -f $@.list
	@for i in `echo $(SIM_SRC)`; do \
	    echo "hdl/$$i" >> $@.list; \
	done
	$(IVERILOG) -o $@  -c $@.list -s $(@:.vvp=)

%.vcd: %.vvp
	$(VVP) $<

#--------------------------------------------------------------------

$(TARGET).prj: 
	rm -f $(SCRIPTDIR)/$(TARGET).prj
	@for i in `echo $(SRC)`; do \
	    echo "verilog work ../../hdl/$$i" >> $(SCRIPTDIR)/$(TARGET).prj; \
	done

synthesize: $(TARGET).prj 
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

upload: 
	$(FLASHTOOL) -v $(TARGET).bit  

clean:
	rm -rf $(OBJDIR)/*
	rm -rf _impact*
	rm -rf $(TARGET).jed
.PHONY: all clean

