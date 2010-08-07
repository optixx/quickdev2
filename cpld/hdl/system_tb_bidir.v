
`timescale 10 ns / 1 ns

module system_tb;

parameter tck      = 10;                // clock period in ns
parameter clk_freq = 1000000000 / tck;   // Frequenzy in HZ


reg          clk;
reg  [15:0]  cycle;
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


initial begin
    clk <= 0;
    cycle <=0;
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
    .avr_clk( clk )
);


always begin
    #(tck/2) 
    clk <= ~clk;
    if (clk)
        cycle = cycle + 1;
end
/* Simulation setup */
initial begin
	
    $dumpfile("system_tb.vcd");
	$dumpvars(0, dut);

    sram_data_reg = 8'bz;
    avr_oe = 1;
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
    avr_oe = 0;
    #tck
    #tck
    avr_data_reg = 8'hzz;
    avr_oe = 1;
    #tck
    #tck
    sram_data_reg = 8'haa;
    #tck

	$finish;
end



always @(clk)
begin
		$display( "cycle: %d avr: oe=%b si=%b clk=%b data=%h sram: addr=%h data=%h sreg=%b  bus: oe=%b bidir=%b inp=%b a=%b",
            cycle,
            dut.avr_oe,
            dut.avr_si,
            dut.avr_clk,
            dut.avr_data,
            dut.sram_addr, 
            dut.sram_data,
            dut.sreg0.buffer,
            dut.bidir0.oe,
            dut.bidir0.bidir,
            dut.bidir0.inp,
            dut.bidir0.a,
        );


end
endmodule
