`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 10/27/2026 08:24:40 PM
// Design Name: 
// Module Name: uart_tx
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

module uart_tx #(
    parameter int CLKS_PER_BIT = 868
) (
    input  logic       clk,
    input  logic       rst,
    input  logic       tx_start,
    input  logic [7:0] tx_data,
    output logic       tx,
    output logic       tx_busy
);

    typedef enum logic [1:0] {IDLE, START, DATA, STOP} state_t;
    state_t state = IDLE;

    logic [9:0] counter = 0;
    logic [2:0] bit_index = 0;
    logic [7:0] data_reg = 0;

    always_ff @(posedge clk) begin
        if (rst) begin
            state   <= IDLE;
            tx      <= 1'b1;
            tx_busy <= 1'b0;
            counter <= 0;
        end else begin
            case (state)
                IDLE: begin
                    tx      <= 1'b1;
                    tx_busy <= 1'b0;
                    counter <= 0;

                    if (tx_start) begin
                        data_reg <= tx_data;
                        tx_busy  <= 1'b1;
                        state    <= START;
                    end
                end

                START: begin
                    tx <= 1'b0;
                    if (counter == CLKS_PER_BIT - 1) begin
                        counter <= 0;
                        state <= DATA;
                    end else
                        counter <= counter + 1;
                end

                DATA: begin
                    tx <= data_reg[bit_index];

                    if (counter == CLKS_PER_BIT - 1) begin
                        counter <= 0;

                        if (bit_index == 3'd7) begin
                            bit_index <= 0;
                            state <= STOP;
                        end else
                            bit_index <= bit_index + 1;
                    end else
                        counter <= counter + 1;
                end

                STOP: begin
                    tx <= 1'b1;

                    if (counter == CLKS_PER_BIT - 1) begin
                        counter <= 0;
                        state <= IDLE;
                    end else
                        counter <= counter + 1;
                end
            endcase
        end
    end
endmodule
