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



// WE   AVR ==> SRAM
// OE   AVR <== SRAM

module bus_fsm #(
    parameter DWIDTH= 8
)(
    input                   clk,
    input                   reset,
    input                   we,
    input                   oe,
    inout   [DWIDTH-1:0]    avr,
    inout   [DWIDTH-1:0]    sram,
    output  [2:0]           debug
);

parameter SIZE   =  3;
parameter IDLE    = 3'b000;
parameter WE      = 3'b001;
parameter BUFAVR  = 3'b010;
parameter BUFSRAM = 3'b011;
parameter OE      = 3'b100;


reg   [SIZE-1:0]          state;
reg   [SIZE-1:0]          next_state;
reg   [DWIDTH-1:0]        buffer_avr;
reg   [DWIDTH-1:0]        buffer_sram;
reg   [DWIDTH-1:0]        buffer;

assign avr = buffer_avr;
assign sram = buffer_sram;
assign debug = { 5'bz,state } ;

always @ (state or we or oe)
begin : FSM_COMBO
    next_state = 3'b000;
    case(state)
    IDLE : if (we == 1'b0) begin
            next_state = BUFAVR;
        end else if (oe == 1'b0) begin
            next_state= BUFSRAM;
        end else begin
            next_state = IDLE;
        end
    BUFAVR: if (we == 1'b0) begin
            next_state = WE;
        end else begin
            next_state = IDLE;
        end
    BUFSRAM: if (oe == 1'b0) begin
            next_state = OE;
        end else begin
            next_state = IDLE;
        end
    OE : if (oe == 1'b0) begin
            next_state = BUFSRAM;
        end else begin
            next_state = IDLE;
        end
    WE : if (we == 1'b0) begin
            next_state = BUFAVR;
        end else begin
            next_state = IDLE;
        end
  endcase
end

//----------Seq Logic-----------------------------
always @ (posedge clk)
begin : FSM_SEQ
    if (reset == 1'b1) begin
        state <= #1 IDLE;
    end else begin
        state <= #1 next_state;
  end
end

//----------Output Logic-----------------------------
always @ (state)
begin : OUTPUT_LOGIC
  case(state)
    IDLE: begin
        buffer_avr <= 8'bz;
        buffer_sram <= 8'bz;
        buffer <= 8'bz;
    end
    WE: begin
        buffer_sram <= buffer;
    end
    OE: begin
        buffer_avr <= buffer;
    end
    BUFSRAM : begin
        buffer <= sram;
    end
    BUFAVR : begin
        buffer <= avr;
    end
    default : begin
        buffer_avr <= 8'bz;
        buffer_sram <= 8'bz;
    end
  endcase
end
endmodule
