`timescale 10 ns / 1 ns

module system_tb;

parameter tck      = 10;                    // clock period in ns
parameter clk_freq = 1000000000 / tck;      // Frequenzy in HZ
parameter sck      = 10;                    // sreg clock period in ns


reg          clk;
reg  [15:0]  cycle;

// sram storage
reg          sreg_en_n;
wire [7:0]   sram_data;
reg  [7:0]   sram_data_reg;
assign       sram_data = sram_data_reg;

// sram address
wire [20:0]  sram_addr;
wire [20:0]  snes_addr;
reg  [20:0]  snes_addr_reg;
assign       snes_addr = snes_addr_reg;

// snes storage
wire [7:0]   snes_data;
reg  [7:0]   snes_data_reg;
assign       snes_data = snes_data_reg;

// sram ctrl
wire         sram_oe_n;
reg          sram_oe_n_reg;
assign       sram_oe_n = sram_oe_n_reg;

wire         sram_we_n;
reg          sram_we_n_reg;
assign       sram_we_n = sram_we_n_reg;

wire         sram_ce_n;
reg          sram_ce_n_reg;
assign       sram_ce_n = sram_ce_n_reg;

// avr storage
wire [7:0]   avr_data;
reg [7:0]    avr_data_reg;
assign       avr_data = avr_data_reg;

// avr ctrl
reg          avr_counter_n;
reg          avr_we_n;
reg          avr_oe_n;
reg          avr_si;
reg          avr_reset;
reg          avr_snes_mode;
reg [6:0]    avr_ctrl;
// inital values
initial begin
    clk <=  1'b0;
    cycle <= 1'b0;
    avr_reset <= 1'b0;
    avr_ctrl <= 7'b0;
end

// the device under testing
system dut (
	.sram_data( sram_data ),
    .sram_addr( sram_addr ),
    .sram_oe_n( sram_oe_n ),
    .sram_we_n( sram_we_n ),
    .sram_ce_n( sram_ce_n ),

    .snes_data ( snes_data ),
    .snes_addr ( snes_addr ),
    .avr_data( avr_data ),
    .avr_ctrl( avr_ctrl ),

    .avr_counter_n( avr_counter_n ),
    .avr_we_n( avr_we_n ),
    .avr_oe_n( avr_oe_n ),
    .avr_si( avr_si ),
    .avr_clk( clk ),
    .avr_sreg_en_n( sreg_en_n ),
    .avr_reset( avr_reset )
);

// generate clock
always begin
    #(tck/2) 
    clk <= ~clk;
    if (clk)
        cycle = cycle + 1;
end

initial begin
    
    $dumpfile("system_tb.vcd");
	$dumpvars(0, dut);
    // reset dut
    avr_reset = 1'b1;
    #tck
    // setup all function blocks
    avr_snes_mode = 1'b0;
    avr_reset = 1'b0;
    // init data register
    snes_addr_reg = 21'bz;
    avr_data_reg  = 8'bz;
    snes_data_reg = 8'bz;
    sram_data_reg = 8'bz;
    sram_ce_n_reg = 8'bz;
    // disable sram
    avr_oe_n = 1'b1;
    avr_we_n = 1'b1;
    // enable SREG
    sreg_en_n = 1'b0;
    avr_si = 1'b0;
    // disable counter
    avr_counter_n = 1'b1;
    $display("Push address 0x4ccf into sreg"); 
    avr_si = 1'b1;
    #tck
    #tck
    avr_si = 1'b0;
    #tck
    #tck
    avr_si = 1'b0;
    #tck
    #tck
    avr_si = 1'b1;
    #tck
    #tck
    avr_si = 1'b1;
    #tck
    #tck
    avr_si = 1'b0;
    #tck
    #tck
    avr_si = 1'b0;
    #tck
    #tck
    avr_si = 1'b1;
    #tck
    #tck
    avr_si = 1'b1;
    #tck
    #tck
    avr_si = 1'b0;
    #tck
    #tck
    avr_si = 1'b0;
    #tck
    #tck
    avr_si = 1'b1;
    #tck
    #tck
    avr_si = 1'b1;
    #tck
    #tck
    avr_si = 1'b1;
    #tck
    #tck
    avr_si = 1'b1;
    #tck
    #tck
    #tck
    // disable SREG
    sreg_en_n = 1'b1;
    $display("#1 READ byte $aa from SRAM -> AVR");
    // simulate data on SRam side
    sram_data_reg = 8'haa;
    // enabler OE
    avr_oe_n = 1'b0;
    #tck
    #tck
    #tck
    #tck
    #tck
      
    $display("#2 READ byte $bb from SRAM -> AVR");
    // new data on SRAM side
    sram_data_reg = 8'hbb;
    // just wait till it gets thru the FSM
    #tck
    #tck
    #tck 
    #tck 
    #tck 
    
    $display("#3 WRITE byte $ee AVR -> SRAM");
    // enable WE
    avr_oe_n = 1'b1;
    avr_we_n = 1'b0;
    // wait for IDLE state in FSM
    #tck
    #tck
    // simulate data on AVR side
    sram_data_reg = 8'hzz;
    avr_data_reg = 8'hee;
    // wait till it gets thru the FSM
    #tck
    #tck
    #tck
    #tck
    #tck
    
    $display("#4 READ byte $22 from SRAM -> AVR");
    // enable OE
    avr_oe_n = 1'b0;
    avr_we_n = 1'b1;
    // wait for IDLE state in FSM
    #tck
    #tck
    // simulate data on SRAM side 
    sram_data_reg = 8'h22;
    avr_data_reg = 8'hzz;
    // wait till the data travels thru the FSM
    #tck
    #tck
    #tck
    #tck
	
    $display("#5 INC Counter");
    // toggle counter to incremtn SRAM address
    avr_counter_n = 1'b0;
    #tck
    #tck
    avr_counter_n = 1'b1;
    #tck
    #tck
    
    
    $display("#5 Test comand muer");
    avr_ctrl = 7'b0000001; 
    #tck
    avr_ctrl = 7'b0000011; 
    #tck
    avr_ctrl = 7'b0000101; 
    #tck
    avr_ctrl = 7'b0000111; 
    #tck
    avr_ctrl = 7'b0001000; 
    #tck
    $finish;
end



always @(cycle)
begin
		$display( "cycle=%d clk=%b avr: oe=%b we=%b data=%h debug=%b | sram: ce=%b addr=%h data=%h en=%b sreg=%b sclk=%b fsm=%b bavr=%h (%h) bsram=%h (%h) buf=%h | cmd: ctrl=%b -> %b%b%b%b%b%b%b",
            
            cycle,
            dut.avr_clk,
            dut.avr_oe_n,
            dut.avr_we_n,
            dut.avr_data,
            dut.debug,
            
            dut.sram_ce_n,
            dut.sram_addr, 
            dut.sram_data,
            
            dut.sreg0.en_n,
            dut.sreg0.buffer,
            dut.sreg0.clk,
            
            dut.bus_fsm0.state,
            dut.bus_fsm0.buffer_avr,
            dut.bus_fsm0.avr,
            dut.bus_fsm0.buffer_sram,
            dut.bus_fsm0.sram,
            dut.bus_fsm0.buffer,
            dut.cmd0.avr_ctrl,
        
            dut.cmd0.avr_snes_mode,
            dut.cmd0.avr_counter_n,
            dut.cmd0.avr_we_n,
            dut.cmd0.avr_oe_n,
            dut.cmd0.avr_si,
            dut.cmd0.avr_sreg_en_n,
            dut.avr_reset
        );

end
endmodule
