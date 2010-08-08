
module sreg #(
    parameter DWIDTH = 21
)(
    input                   clk,
    input                   in,
    output  [DWIDTH-1:0]    out,
    input                   en,
    output [3:0]            debug
);
    reg [DWIDTH-1:0] buffer;
   
    assign debug = {buffer[3:0]};
    initial
    begin
        buffer = 21'b0;
    end
    always @(posedge clk)
    begin
        if ( en == 1'b0 ) begin
            buffer <= buffer << 1;
            buffer[0] <= in;
        end
    end
    
    assign out = buffer;

endmodule
