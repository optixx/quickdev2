
module command_muxer (
    input  [6:0] avr_ctrl,
    input  avr_clk,
    output avr_snes_mode,
    output avr_counter_n,
    output avr_we_n,
    output avr_oe_n,
    output avr_si,
    output avr_sreg_en_n,
    output avr_reset
);

parameter IDLE              =  7'b0000001;
parameter AVR_RESET_LO      =  7'b0000010;
parameter AVR_RESET_HI      =  7'b0000011;
parameter AVR_SREG_EN_LO    =  7'b0000100;
parameter AVR_SREG_EN_HI    =  7'b0000101;
parameter AVR_SI_LO         =  7'b0000110;
parameter AVR_SI_HI         =  7'b0000111;
parameter AVR_OE_LO         =  7'b0001000;
parameter AVR_OE_HI         =  7'b0001001;
parameter AVR_WE_LO         =  7'b0001010;
parameter AVR_WE_HI         =  7'b0001100;
parameter AVR_COUNTER_LO    =  7'b0001101;
parameter AVR_COUNTER_HI    =  7'b0001110;
parameter AVR_SNES_MODE_LO  =  7'b0001111;
parameter AVR_SNES_MODE_HI  =  7'b0010000;

reg reg_avr_snes_mode;
reg reg_avr_counter_n;
reg reg_avr_we_n;
reg reg_avr_oe_n;
reg reg_avr_si;
reg reg_avr_sreg_en_n;
reg reg_avr_reset;


assign avr_snes_mode =  reg_avr_snes_mode;
assign avr_counter_n =  reg_avr_counter_n;
assign avr_we_n =  reg_avr_we_n;
assign avr_oe_n = reg_avr_oe_n;
assign avr_si =  reg_avr_si;
assign avr_sreg_en_n = reg_avr_sreg_en_n;
assign avr_reset = reg_avr_reset;

initial 
begin
    reg_avr_snes_mode <= 0;
    reg_avr_counter_n <= 1;
    reg_avr_we_n      <= 1;
    reg_avr_oe_n      <= 1;
    reg_avr_si        <= 0;
    reg_avr_sreg_en_n <= 1;
    reg_avr_reset     <= 0;
end

always @(avr_ctrl)
begin : COMMAND_MUXER
    case(avr_ctrl)
        AVR_RESET_LO: begin
            reg_avr_reset <= 0'b0;
        end
        AVR_RESET_HI: begin
            reg_avr_reset <= 1'b1;
        end
        AVR_SREG_EN_LO: begin
            reg_avr_sreg_en_n  <= 1'b0;
        end
        AVR_SREG_EN_HI: begin
            reg_avr_sreg_en_n <= 1'b1;
        end
        AVR_SI_LO: begin
            reg_avr_si  <= 1'b0;
        end
        AVR_SI_HI: begin
            reg_avr_si <= 1'b1;
        end
        AVR_OE_LO: begin
            reg_avr_oe_n  <= 1'b0;
        end
        AVR_OE_HI: begin
            reg_avr_oe_n <= 1'b1;
        end
        AVR_WE_LO: begin
            reg_avr_we_n  <= 1'b0;
        end
        AVR_WE_HI: begin
            reg_avr_we_n <= 1'b1;
        end
        AVR_COUNTER_LO: begin
            reg_avr_counter_n <= 1'b0;
        end
        AVR_COUNTER_HI: begin
            reg_avr_counter_n <= 1'b1;
        end
    endcase
end
endmodule

