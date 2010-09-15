module system (

    inout [7:0] sram_data,
    output [20:0] sram_addr,
    output sram_oe_n,
    output sram_we_n,
    output sram_ce_n,


    output [7:0] snes_data,
    input [20:0] snes_addr,

    inout [7:0] avr_data,
    input [7:0] avr_ctrl,
    input avr_clk,
    output [7:0] debug
);

// ctrl wires
wire avr_si;
wire avr_sreg_en_n;
wire avr_counter_n;
wire avr_reset;
wire avr_we_n;
wire avr_oe_n;
wire avr_snes_mode;

// sram address
reg [20:0] avr_sram_addr_reg;
wire [20:0] avr_sram_addr;
assign avr_sram_addr = avr_sram_addr_reg;
// internal clocks
wire sreg_clk;
wire fsm_clk;

// dummy debug reg to which be used for 
// currently not debug modules 
wire [7:0]  debug_disabled01;
wire [7:0]  debug_disabled02;

// forward ctrl to sram
assign sram_oe_n = avr_oe_n;
assign sram_we_n = avr_we_n;
assign sram_ce_n = (avr_oe_n && avr_we_n) ? 1'b1 : 1'b0 ;

assign debug = { avr_clk,avr_sreg_en_n,avr_si,sram_addr[4:0]};

// command muxer

command_muxer cmd0 (
    .avr_ctrl ( avr_ctrl ),
    .avr_clk ( avr_clk ),
    .avr_snes_mode( avr_snes_mode ),
    .avr_counter_n( avr_counter_n ),
    .avr_we_n( avr_we_n ),
    .avr_oe_n( avr_oe_n ),
    .avr_si( avr_si ),
    .avr_sreg_en_n( avr_sreg_en_n ),
    .avr_reset( avr_reset )
);

// divide external clock by 2 for the sreg clk 
clock_divider dcm0 ( 
    .reset ( avr_reset ), 
    .clk ( avr_clk ), 
    .enable ( 1 ), 
    .n( 2 ),
    .clk_out ( sreg_clk ) 
);

// divide external clock by 2 for the fsm clk 
clock_divider dcm1 ( 
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
    .debug( debug_disabled01  )
);

// bus 
bus_fsm bus_fsm0(
    .clk( fsm_clk ),
    .reset( avr_reset ),
    .we_n( avr_we_n ),
    .oe_n( avr_oe_n ),
    .avr( avr_data ),
    .sram( sram_data ),
    .debug( debug_disabled02 )
);

endmodule

