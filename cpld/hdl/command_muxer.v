
module command_muxer (
    input  [7:0] avr_ctrl,
    input  avr_clk,
    output avr_snes_mode,
    output avr_counter_n,
    output avr_we_n,
    output avr_oe_n,
    output avr_si,
    output avr_sreg_en_n,
    output avr_reset
);

parameter IDLE              =  8'b00000001;
parameter AVR_RESET_LO      =  8'b00000010;
parameter AVR_RESET_HI      =  8'b00000011;
parameter AVR_SREG_EN_LO    =  8'b00000100;
parameter AVR_SREG_EN_HI    =  8'b00000101;
parameter AVR_SI_LO         =  8'b00000110;
parameter AVR_SI_HI         =  8'b00000111;
parameter AVR_OE_LO         =  8'b00001000;
parameter AVR_OE_HI         =  8'b00001001;
parameter AVR_WE_LO         =  8'b00001010;
parameter AVR_WE_HI         =  8'b00001100;
parameter AVR_COUNTER_LO    =  8'b00001101;
parameter AVR_COUNTER_HI    =  8'b00001110;
parameter AVR_SNES_MODE_LO  =  8'b00001111;
parameter AVR_SNES_MODE_HI  =  8'b00010000;

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
    /*
    reg_avr_snes_mode <= 0;
    reg_avr_counter_n <= 1;
    reg_avr_we_n      <= 1;
    reg_avr_oe_n      <= 1;
    reg_avr_si        <= 0;
    reg_avr_sreg_en_n <= 1;
    reg_avr_reset     <= 0;
    */

    reg_avr_snes_mode <= 0;
    reg_avr_counter_n <= 0;
    reg_avr_we_n      <= 0;
    reg_avr_oe_n      <= 0;
    reg_avr_si        <= 0;
    reg_avr_sreg_en_n <= 0;
    reg_avr_reset     <= 0;
end

always @(posedge avr_clk or negedge avr_clk)
begin : COMMAND_MUXER
    case(avr_ctrl)
        AVR_RESET_LO: begin
            reg_avr_reset <= 1'b0;
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

