
module sreg #(
    parameter DWIDTH = 21
)(
    input                   clk,
    input                   in,
    output  [DWIDTH-1:0]    out,
    input                   en_n,
    input                   counter_n,
    output [7:0]            debug
);
    reg [DWIDTH-1:0] buffer;
   
    initial
    begin
        buffer = 21'b0;
    end
    always @(posedge clk)
    begin
        if ( en_n == 1'b0 ) begin
            buffer <= buffer << 1;
            buffer[0] <= in;
        end else if ( en_n == 1'b1 &&  counter_n == 1'b0) begin
            buffer = buffer + 1;
        end
    end
    
    assign out = buffer;
    assign debug = buffer[7:0];
endmodule
