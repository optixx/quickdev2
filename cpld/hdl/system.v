
module comandmuxer (
    input [7:0] avr_ctrl,
    output avr_snes_mode,
    output avr_counter_n,
    output avr_we_n,
    output avr_oe_n,
    output avr_si,
    output avr_sreg_en_n,
    output avr_reset
}
parameter IDLE              =  7'b0000001;
parameter AVR_RESET_LO      =  7'b0000010;
parameter AVR_RESET_HI      =  7'b0000011;
parameter AVR_SREG_EN_LO    =  7'b0000101;
parameter AVR_SREG_EN_HI    =  7'b0000011
parameter AVR_RESET_LO      =  4;
parameter AVR_RESET_HI      =  0;
parameter AVR_SI_LO         =  0;
parameter AVR_SI_HI         =  0;
parameter AVR_OE_LO         =  0;
parameter AVR_OE_HI         =  0;
parameter AVR_WE_LO         =  0;
parameter AVR_WE_HI         =  0;
parameter AVR_COUNTER_LO    =  0;
parameter AVR_COUNTER_HI    =  0;
parameter AVR_SNES_MODE_LO  =  0;
parameter AVR_SNES_MODE_HI  =  0;


reg   [SIZE-1:0]          state;
reg   [SIZE-1:0]          next_state;
reg   [DWIDTH-1:0]        buffer_avr;
reg   [DWIDTH-1:0]        buffer_sram;
reg   [DWIDTH-1:0]        buffer;


always

endmodule;

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

assign sram_oe_n = avr_oe;
assign sram_we_n = avr_we;
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

