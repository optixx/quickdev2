//  sram_dir
//  0 = from avr to sram 
//  1 = from sram to avr)

module bi_direct_bus #(
    parameter DWIDTH = 8
)(
    input                   clk,
    input                   sram_dir,
    inout   [DWIDTH-1:0]    sram_data,
    inout   [DWIDTH-1:0]    avr_data
);

reg [7:0]   read_data;
reg [7:0]   write_data;  

assign  sram_data = (sram_dir) ? 8'bz : write_data;
assign  avr_data =  (sram_dir) ? 8'bz : read_data;

always @(posedge clk) begin
    if (sram_dir == 1'b1)
       read_data <= sram_data;
   else
       write_data <= avr_data;
end
endmodule




module bidir #(
    parameter DWIDTH = 8
)(
    input                   clk,
    input                   oe,
    inout   [DWIDTH-1:0]    bidir,
    input   [DWIDTH-1:0]    inp
);

reg [7:0]   a;

assign bidir = oe ? 8'bz : a;


always @(posedge clk) begin
    if (oe == 1'b1)
       a <= inp;
end

endmodule
