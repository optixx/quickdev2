
module sreg #(
    parameter DWIDTH = 21
)(
    input                   clk,
    input                   in,
    output  [DWIDTH-1:0]    out,
    input                   en
);
    reg [DWIDTH-1:0] buffer;
    
    initial
    begin
        buffer = 21'b0;
    end
    always @(posedge clk && !en)
    begin
        //buffer = {buffer[DWIDTH-2:0], in};
        buffer <= buffer << 1;
        buffer[0] <= in; 
    end
    
    assign out = buffer;

endmodule
