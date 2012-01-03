QUICKDEV2 NOTES
===============

### 20100808

## AVR ISP
* quickdev standart cable that has isp as serial 
* connect avr dragon isp to isp header at combo cable
* avr dragon isp
    * vcc has to be connected
    * vcc:  red
    * gnd:  black
    * sck:  yellow
    * mosi: green
    * rst:  black
* works on os x

## AVR JTAG
* connects to the xilinx jtag cable
* AVR ISP has to be disconnected
* jtag header
    * vcc: red
    * gnd: black
    * tdi: yellow
    * tdo: green
    * tms: white
    * sck: red
* last test on linux and osx with avarice (2.09,2.10) didn't work, starting up a 
  gdb yields and 'cant access memory' error
  

## CPLD JTAG
* runs under linx in vmware
* preload usbdriver
* export LD_PRELOAD=/home/david/Devel/arch/fpga/tools/usb-driver
* check usb vendor id, has to be 03fd:0008
* otherwise fxload the firmware by hand
* start impact, it should find the cable automatically, if not reboot
* the cpld gets dedecteted by it self, if not run boundairy scan
* run 'program' from context menu

## QUICKDEV DEBUG HEADER
* then head pins located at the reset button
* connect to saleae LA:
    * gnd:    grey
    * debug0: black
    * debug1: brown
    * debug2: red
    * debug3: orange
    * debug4: yellow
    * debug5: green
    * debug6: blue
    * debug7: violet
    

## POC MASSSTORAGE
* makefile include 'programm' for avrdude with dragon_isp
* uart uses the quickdev combo cabel and runs at 115200
* compile works on os x
* serial screen works on os x
* masstorage device should pop in finder


## POC SREG
* makefile include 'programm' for avrdude with dragon_isp
* uart uses the quickdev combo cabel and runs at 115200
* compile works on os x
* serial screen works on os x
* to debug the sreg or the fsm reduce the speed of the avr
    * program fuse divide clock by 8 internally
    * set uart baud speed to 9600 by setting UBRR1=25
    * change speed in screen session

