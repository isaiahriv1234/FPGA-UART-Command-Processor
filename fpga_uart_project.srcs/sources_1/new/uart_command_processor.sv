`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 10/27/2026 08:26:37 PM
// Design Name: 
// Module Name: uart_command_processor
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


module uart_command_processor (
    input  logic clk,
    input  logic rst,
    input  logic uart_rx,
    output logic uart_tx,
    output logic led0
);

    // Synchronizes the incoming asynchronous UART signal
    logic rx_meta;
    logic rx_sync;

    logic [7:0] received_data;
    logic       received_valid;

    logic [7:0] tx_data;
    logic       tx_start;
    logic       tx_busy;

    // Two-flip-flop synchronizer for the UART receive line
    always_ff @(posedge clk) begin
        if (rst) begin
            rx_meta <= 1'b1;
            rx_sync <= 1'b1;
        end else begin
            rx_meta <= uart_rx;
            rx_sync <= rx_meta;
        end
    end

    // UART receiver: gets characters sent from the computer
    uart_rx receiver (
        .clk(clk),
        .rst(rst),
        .rx(rx_sync),
        .rx_data(received_data),
        .rx_valid(received_valid)
    );

    // UART transmitter: echoes received characters back to the computer
    uart_tx transmitter (
        .clk(clk),
        .rst(rst),
        .tx_start(tx_start),
        .tx_data(tx_data),
        .tx(uart_tx),
        .tx_busy(tx_busy)
    );

    // Command decoder
    always_ff @(posedge clk) begin
        if (rst) begin
            led0     <= 1'b0;
            tx_data  <= 8'h00;
            tx_start <= 1'b0;
        end else begin
            tx_start <= 1'b0;

            if (received_valid && !tx_busy) begin
                case (received_data)
                    "1": led0 <= 1'b1;   // Send 1: LED turns on
                    "0": led0 <= 1'b0;   // Send 0: LED turns off
                    "T": led0 <= ~led0;  // Send T: LED toggles
                    "t": led0 <= ~led0;
                    default: led0 <= led0;
                endcase

                // Echo received character to serial terminal
                tx_data  <= received_data;
                tx_start <= 1'b1;
            end
        end
    end

endmodule