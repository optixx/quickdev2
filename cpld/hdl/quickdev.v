
module quickdev (

    inout [7:0] sram_dat,
    output [20:0] sram_addr,
    output sram_oe_n,
    output sram_we_n,
    output sram_ce_n
);
    
assign sram_ce_n = 'b0;

endmodule
