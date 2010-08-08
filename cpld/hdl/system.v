module system (

    inout [7:0] sram_data,
    output [20:0] sram_addr,
    output sram_oe_n,
    output sram_we_n,
    output sram_ce_n,

    inout [7:0] avr_data,
    input [2:0] avr_ctrl,

    input avr_ce,
    input avr_we,
    input avr_oe,
    input avr_si,
    input avr_clk,
    input avr_sreg_en,
    input avr_reset,
    output [7:0] debug
);


assign sram_oe_n = avr_oe;
assign sram_we_n = avr_we;
assign sram_ce_n = avr_ce;
//assign debug[0]  = avr_clk;
//assign debug[1]  = avr_oe;
//assign debug[2]  = avr_we;

sreg sreg0 (
	.clk( avr_clk ),
	.in( avr_si ),
	.out( sram_addr ),
    .en( avr_sreg_en )
);


bus_fsm bus_fsm0(
    .clk( avr_clk ),
    .reset( avr_reset ),
    .we( avr_we ),
    .oe( avr_oe ),
    .avr( avr_data ),
    .sram( sram_data ),
    .debug ( debug[2:0] )
);

endmodule

