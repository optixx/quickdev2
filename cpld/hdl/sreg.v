
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
    always @(posedge clk)
    begin
        //if ( en == 1'b0 ) begin
        //    buffer <= buffer << 1;
        //    buffer[0] <= in;
        //end
        if ( en == 1'b0 ) begin
            buffer = 21'b0;
        end else begin
            buffer = 21'h100;
        end
    end
    
    assign out = buffer;

endmodule
