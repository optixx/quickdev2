
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
