
`timescale 10 ns / 1 ns

module system_tb;

//----------------------------------------------------------------------------
// Parameter (may differ for physical synthesis)
//----------------------------------------------------------------------------
//parameter tck      = 20;                // clock period in ns
//parameter clk_freq = 1000000000 / tck;   // Frequenzy in HZ
//----------------------------------------------------------------------------
//
//----------------------------------------------------------------------------


reg          clk;
wire [7:0]   sram_data;
reg  [7:0]   sram_data_reg = 0;
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
reg [7:0]    avr_data_reg = 0;
assign       avr_data = avr_data_reg;
reg [2:0]    avr_ctrl;

reg          avr_ce;
reg         avr_we;
reg         avr_oe;
reg         avr_si;


initial begin
    clk <= 0;
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


always #5 clk <= ~clk;

/* Simulation setup */
initial begin
	
    $dumpfile("system_tb.vcd");
	$dumpvars(0, dut);

	// send select value
    avr_oe = 1;
    avr_si = 1;
    avr_data_reg = 8'hff;
	#10
    avr_oe = 0;
    avr_si = 1;
	#10
    avr_si = 0;
	#10
    avr_si = 0;
	#10
    avr_si = 1;
    #10
    avr_si = 1;
	#10
    avr_si = 0;
	#10
    avr_si = 0;
	#10
    avr_si = 1;
    #10
    avr_si = 1;
	#10
    avr_si = 0;
	#10
    avr_si = 0;
	#10
    avr_si = 1;
    #10
    avr_si = 1;
    #10
    avr_si = 1;
    #10
    avr_si = 1;
    #10
	$finish;
end

//------------------------------------------------------------------
// Monitor Wishbone transactions
//------------------------------------------------------------------
always @(posedge clk)
begin
		$display( "avr: oe=%b si=%b clk=%b data=%h sram: addr=%h data=%h sreg=%b %b %b",
            dut.avr_oe,
            dut.avr_si,
            dut.avr_clk,
            dut.avr_data,
            dut.sram_addr, 
            dut.sram_data,
            dut.sreg0.buffer,
            dut.sreg0.in,
            dut.sreg0.out);

end
endmodule
