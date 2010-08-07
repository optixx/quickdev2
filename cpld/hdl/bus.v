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
    inout   [DWIDTH-1:0]    sram
);

parameter SIZE   =  5;
parameter IDLE    = 5'b00001;
parameter WE      = 5'b00010;
parameter BUFAVR  = 5'b00100;
parameter BUFSRAM = 5'b01000;
parameter OE      = 5'b10000;


reg   [SIZE-1:0]          state;
reg   [SIZE-1:0]          next_state;
reg   [DWIDTH-1:0]        buffer_avr;
reg   [DWIDTH-1:0]        buffer_sram;
reg   [DWIDTH-1:0]        buffer;

assign avr = buffer_avr;
assign sram = buffer_sram;


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
        //end else if (we == 1'b0) begin
        //    next_state = BUFAVR;
        end else begin
            next_state = IDLE;
        end
    WE : if (we == 1'b0) begin
            next_state = BUFAVR;
        //end else if ( oe == 1'b0 ) begin
        //    next_state = BUFSRAM;
        end else begin
            next_state = IDLE;
        end
    default : next_state = IDLE;
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
always @ (posedge clk)
begin : OUTPUT_LOGIC
if (reset == 1'b1) begin
    buffer_avr <= 8'bz;
    buffer_sram <= 8'bz;
end
else
begin
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
        //buffer_sram <= 8'bz;
    end
    BUFAVR : begin
        buffer <= avr;
        //buffer_avr <= 8'bz;
    end
    default : begin
        buffer_avr <= 8'bz;
        buffer_sram <= 8'bz;
    end
  endcase
end
end
endmodule
