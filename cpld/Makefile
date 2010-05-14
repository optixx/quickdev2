OBJDIR = build/obj
PROJECTROOT = $(shell pwd)

TARGET = quickdev
TARGETCPLD = xc95144xl-5-TQ144
TARGETCPLD2 = xc95144xl-TQ144-5

BOARD = prototype01

CONSTRAINTS = $(TARGET)_$(BOARD)_constraints.ucf
XSTSCRIPT = build/scripts/$(TARGET).scr
UTFILE = build/scripts/$(TARGET).ut

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

#--------------------------------------------------------------------

# main rule
all: $(TARGET).jed

synthesize: 
	cd $(OBJDIR); $(XST) -ifn $(PROJECTROOT)/$(XSTSCRIPT) -ofn $(TARGET).srp 

translate:
	cd $(OBJDIR); $(NGDBUILD) -nt timestamp -p $(TARGETCPLD2) -uc $(PROJECTROOT)/$(CONSTRAINTS) $(TARGET).ngc $(TARGET).ngd  

fit:
	cd $(OBJDIR); $(FIT) -p $(TARGETCPLD) \
			-ofmt vhdl \
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

sim: 
	cd $(OBJDIR); $(TSIM) $(TARGET) $(TARGET).nga

time:
	cd $(OBJDIR); $(TA)  -f $(TARGET)  --format html1 -l timing_report.htm 

xslt:
	cd $(OBJDIR); $(XSLT) $(TARGET)_build.xml

generate:
	cd $(OBJDIR); $(HPREP) -s IEEE1149 -n $(TARGET) -i $(TARGET)

$(TARGET).jed: synthesize translate fit xslt sim time generate
	mv $(OBJDIR)/$@ $(PROJECTROOT)

upload: 
	$(FLASHTOOL) -v $(TARGET).bit  

clean:
	rm -rf $(OBJDIR)/*
	rm -rf _impact*
	rm -rf $(TARGET).jed
.PHONY: all clean

