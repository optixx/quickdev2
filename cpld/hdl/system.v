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
    input avr_clk
);
    
//assign sram_oe_n = avr_oe;
//assign sram_we_n = avr_we;
//assign sram_ce_n = avr_ce;

sreg sreg0 (
	.clk( avr_clk ),
	.in( avr_si ),
	.out( sram_addr )
);

/*
bi_direct_bus sram0(
//    .clk( avr_clk ),
    .sram_dir( avr_oe ),
    .sram_data( sram_data ),
    .avr_data( avr_data )
);
*/
endmodule

