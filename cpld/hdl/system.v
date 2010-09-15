module system (

    inout [7:0] sram_data,
    output [20:0] sram_addr,
    output sram_oe_n,
    output sram_we_n,
    output sram_ce_n,


    output [7:0] snes_data,
    input [20:0] snes_addr,

    inout [7:0] avr_data,
    input [2:0] avr_ctrl,
    
    input avr_snes_mode,
    input avr_counter_n,
    input avr_we_n,
    input avr_oe_n,
    input avr_si,
    input avr_clk,
    input avr_sreg_en_n,
    input avr_reset,
    output [7:0] debug
);



reg [20:0] avr_sram_addr_reg;
wire [20:0] avr_sram_addr;
assign avr_sram_addr = avr_sram_addr_reg;

// internal clocks
wire sreg_clk;
wire fsm_clk;

// dummy debug reg to which be used for 
// currently not debug modules 
wire [7:0]  debug_dummy;

assign sram_oe_n = avr_oe_n;
assign sram_we_n = avr_we_n;
assign sram_ce_n = (avr_oe_n && avr_we_n) ? 1'b1 : 1'b0 ;

// divide external clock by 2 for the sreg clk 
clockdivide dcm0 ( 
    .reset ( avr_reset ), 
    .clk ( avr_clk ), 
    .enable ( 1 ), 
    .n( 2 ),
    .clk_out ( sreg_clk ) 
);

// divide external clock by 2 for the fsm clk 
clockdivide dcm1 ( 
    .reset ( avr_reset ), 
    .clk ( avr_clk ), 
    .enable ( 1 ), 
    .n( 2 ),
    .clk_out ( fsm_clk ) 
);

// sreg to set the sram address
sreg sreg0 (
	.clk( sreg_clk ),
	.in( avr_si ),
	.out( sram_addr ),
    .en_n( avr_sreg_en_n ),
    .counter_n ( avr_counter_n),
    .debug( debug_dummy )
);

// bus 
bus_fsm bus_fsm0(
    .clk( fsm_clk ),
    .reset( avr_reset ),
    .we_n( avr_we_n ),
    .oe_n( avr_oe_n ),
    .avr( avr_data ),
    .sram( sram_data ),
    .debug( debug)
);

endmodule

