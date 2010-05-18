
module sreg #(
    parameter DWIDTH = 21
)(
    input                   clk,
    input                   in,
    output  [DWIDTH-1:0]    out
);
    reg [DWIDTH-1:0] buffer;
    
    initial 
    buffer = 21'b0;
    
    always @(posedge clk)
    begin
        //buffer = {buffer[DWIDTH-2:0], in};
        buffer = buffer << 1;
        buffer[0] = in; 
    end
    
    assign out = buffer;

endmodule
