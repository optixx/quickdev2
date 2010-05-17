
module sreg #(
    parameter DWIDTH = 21
)(
    input                   clk,
    input                   in,
    output  [DWIDTH-1:0]    out
);
    
    reg [20:0] buffer;
    always @(posedge clk)
    begin
        buffer = {buffer[DWIDTH-2:0], in};
    end
    assign out = buffer;
endmodule

module quickdev (

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
    
assign sram_data = avr_data;
assign sram_oe_n = avr_oe;
assign sram_we_n = avr_we;
assign sram_ce_n = avr_ce;
wire avr_oe_n;
assign avr_oe_n = ~avr_oe;

sreg sreg0 (
	.clk( avr_clk ),
	.in( avr_si ),
	.out( sram_addr )
);


endmodule

