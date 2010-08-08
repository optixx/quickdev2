module system (

    inout [7:0] sram_data,
    output [20:0] sram_addr,
    output sram_oe_n,
    output sram_we_n,
    output sram_ce_n,

    inout [7:0] avr_data,
    input [2:0] avr_ctrl,

    input avr_counter,
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
assign sram_ce_n = (avr_oe && avr_we) ? 1'b1 : 1'b0 ;

wire sreg_clk;
wire fsm_clk;
wire [7:0]  debug_dummy;

divide_by_N dcm0 ( 
    .reset ( avr_reset ), 
    .clk ( avr_clk ), 
    .enable ( 1 ), 
    .n( 2 ),
    .clk_out ( sreg_clk ) 
);


divide_by_N dcm1 ( 
    .reset ( avr_reset ), 
    .clk ( avr_clk ), 
    .enable ( 1 ), 
    .n( 2 ),
    .clk_out ( fsm_clk ) 
);


sreg sreg0 (
	.clk( sreg_clk ),
	.in( avr_si ),
	.out( sram_addr ),
    .en_n( avr_sreg_en ),
    .counter_n ( avr_counter),
    .debug( debug_dummy )
);


bus_fsm bus_fsm0(
    .clk( fsm_clk ),
    .reset( avr_reset ),
    .we( avr_we ),
    .oe( avr_oe ),
    .avr( avr_data ),
    .sram( sram_data ),
    .debug( debug)
);

endmodule

