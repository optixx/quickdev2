module bus_fsm #(
    parameter DWIDTH= 8
)(
    input                   clk,
    input                   reset,
    input                   we_n,
    input                   oe_n,
    inout   [DWIDTH-1:0]    avr,
    inout   [DWIDTH-1:0]    sram,
    inout   [7:0]           debug
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

always @ (state or we_n or oe_n)
begin : FSM_COMBO
    next_state = 3'b000;
    case(state)
    IDLE : if (we_n == 1'b0) begin
            next_state = BUFAVR;
        end else if (oe_n == 1'b0) begin
            next_state= BUFSRAM;
        end else begin
            next_state = IDLE;
        end
    BUFAVR: if (we_n == 1'b0) begin
            next_state = WE;
        end else begin
            next_state = IDLE;
        end
    BUFSRAM: if (oe_n == 1'b0) begin
            next_state = OE;
        end else begin
            next_state = IDLE;
        end
    OE : if (oe_n == 1'b0) begin
            next_state = BUFSRAM;
        end else begin
            next_state = IDLE;
        end
    WE : if (we_n == 1'b0) begin
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

assign debug = { clk,we_n,oe_n,state,2'bz};
endmodule
