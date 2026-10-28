`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 10/27/2026 08:19:16 PM
// Design Name: 
// Module Name: uart_rx
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////

module uart_rx #(
    parameter int CLKS_PER_BIT = 868   // 100 MHz / 115200 baud
) (
    input  logic       clk,
    input  logic       rst,
    input  logic       rx,
    output logic [7:0] rx_data,
    output logic       rx_valid
);

    typedef enum logic [1:0] {IDLE, START, DATA, STOP} state_t;
    state_t state = IDLE;

    logic [9:0] counter = 0;
    logic [2:0] bit_index = 0;
    logic [7:0] shift_reg = 0;

    always_ff @(posedge clk) begin
        if (rst) begin
            state    <= IDLE;
            counter  <= 0;
            bit_index <= 0;
            rx_valid <= 0;
            rx_data  <= 0;
        end else begin
            rx_valid <= 0;

            case (state)
                IDLE: begin
                    counter <= 0;
                    if (rx == 1'b0)
                        state <= START;
                end

                START: begin
                    if (counter == CLKS_PER_BIT/2) begin
                        counter <= 0;
                        if (rx == 1'b0)
                            state <= DATA;
                        else
                            state <= IDLE;
                    end else
                        counter <= counter + 1;
                end

                DATA: begin
                    if (counter == CLKS_PER_BIT - 1) begin
                        counter <= 0;
                        shift_reg[bit_index] <= rx;

                        if (bit_index == 3'd7) begin
                            bit_index <= 0;
                            state <= STOP;
                        end else
                            bit_index <= bit_index + 1;
                    end else
                        counter <= counter + 1;
                end

                STOP: begin
                    if (counter == CLKS_PER_BIT - 1) begin
                        counter  <= 0;
                        rx_data  <= shift_reg;
                        rx_valid <= 1'b1;
                        state    <= IDLE;
                    end else
                        counter <= counter + 1;
                end
            endcase
        end
    end
endmodule
