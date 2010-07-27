
`timescale 10 ns / 1 ns

module system_tb;

parameter tck      = 10;                // clock period in ns
parameter clk_freq = 1000000000 / tck;   // Frequenzy in HZ
parameter sck      = 10;                // sreg clock period in ns


reg          clk;
reg  [15:0]  cycle;
reg          clk_sreg;
reg          clk_sreg_en;
wire [7:0]   sram_data;
reg  [7:0]   sram_data_reg;
assign       sram_data = sram_data_reg;

wire [20:0]  sram_addr;

wire         sram_oe_n;
reg          sram_oe_n_reg;
assign       sram_oe_n = sram_oe_n_reg;

wire         sram_we_n;
reg          sram_we_n_reg;
assign       sram_we_n = sram_we_n_reg;

wire         sram_ce_n;
reg          sram_ce_n_reg;
assign       sram_ce_n = sram_ce_n_reg;

wire [7:0]   avr_data;
reg [7:0]    avr_data_reg;
assign       avr_data = avr_data_reg;
reg [2:0]    avr_ctrl;

reg          avr_ce;
reg          avr_we;
reg          avr_oe;
reg          avr_si;
reg          avr_reset;


initial begin
    clk <= 0;
    cycle <=0;
    clk_sreg <= 0;
    clk_sreg_en <= 1;
end

system dut (
	.sram_data( sram_data ),
    .sram_addr( sram_addr ),
    .sram_oe_n( sram_oe_n ),
    .sram_we_n( sram_we_n ),
    .sram_ce_n( sram_ce_n ),

    .avr_data( avr_data ),
    .avr_ctrl( avr_ctrl ),

    .avr_ce( avr_ce ),
    .avr_we( avr_we ),
    .avr_oe( avr_oe ),
    .avr_si( avr_si ),
    .avr_clk( clk ),
    .avr_sreg_clk( clk_sreg ),
    .avr_reset( avr_reset )
);


always begin
    #(tck/2) 
    clk <= ~clk;
    if (clk)
        cycle = cycle + 1;
end

always begin
    #(sck/2)
    if (clk_sreg_en == 1'b1) begin
        clk_sreg <= ~clk_sreg;
    end
end

/* Simulation setup */
initial begin
	
    $dumpfile("system_tb.vcd");
	$dumpvars(0, dut);

    sram_data_reg = 8'bz;
    avr_oe = 1;
    avr_we = 1;
    avr_si = 1;
    avr_data_reg = 8'bz;
    clk_sreg_en = 1;

    #tck
    avr_si = 1;
	#tck
    avr_si = 0;
	#tck
    avr_si = 0;
	#tck
    avr_si = 1;
    #tck
    avr_si = 1;
	#tck
    avr_si = 0;
	#tck
    avr_si = 0;
	#tck
    avr_si = 1;
    #tck
    avr_si = 1;
	#tck
    avr_si = 0;
	#tck
    avr_si = 0;
	#tck
    avr_si = 1;
    #tck
    avr_si = 1;
    #tck
    avr_si = 1;
    #tck
    avr_si = 1;
    #tck
    clk_sreg_en = 0;
    sram_data_reg = 8'haa;
    avr_oe = 0;
    #tck
    #tck
    #tck
    #tck
    #tck
    avr_oe = 1;
    sram_data_reg = 8'hbb;
    #tck
    avr_oe = 0;
    #tck
    #tck
    #tck
    #tck

    avr_oe = 1;
    avr_we = 0;
    sram_data_reg = 8'hzz;
    avr_data_reg = 8'hee;
    #tck
    #tck
    #tck
    #tck

	$finish;
end



always @(clk)
begin
		$display( "cycle: %d avr: oe=%b si=%b clk=%b data=%h sram: addr=%h data=%h sreg=%b fsm: state=%b bavr=%h (%h) bsram=%h (%h) buf=%h",
            cycle,
            dut.avr_oe,
            dut.avr_si,
            dut.avr_clk,
            dut.avr_data,
            dut.sram_addr, 
            dut.sram_data,
            dut.sreg0.buffer,
            dut.bus_fsm0.state,
            dut.bus_fsm0.buffer_avr,
            dut.bus_fsm0.avr,
            dut.bus_fsm0.buffer_sram,
            dut.bus_fsm0.sram,
            dut.bus_fsm0.buffer

        );

end
endmodule
