`timescale 1ns / 1ps

module uart_command_processor_tb;

    localparam time CLK_PERIOD = 10ns;
    localparam time BIT_TIME   = 8680ns; // 868 clocks at 100 MHz

    logic clk;
    logic rst;
    logic uart_rx;
    logic uart_tx;
    logic led0;

    uart_command_processor dut (
        .clk(clk),
        .rst(rst),
        .uart_rx(uart_rx),
        .uart_tx(uart_tx),
        .led0(led0)
    );

    // 100 MHz clock
    always #(CLK_PERIOD / 2) clk = ~clk;

    // Sends one UART byte: start bit, 8 data bits, stop bit
    task automatic send_byte(input logic [7:0] data);
        integer i;
        begin
            uart_rx = 1'b0; // Start bit
            #(BIT_TIME);

            for (i = 0; i < 8; i = i + 1) begin
                uart_rx = data[i]; // UART sends least-significant bit first
                #(BIT_TIME);
            end

            uart_rx = 1'b1; // Stop bit
            #(BIT_TIME);
        end
    endtask

    initial begin
        clk     = 1'b0;
        rst     = 1'b1;
        uart_rx = 1'b1; // UART idle is high

        #100;
        rst = 1'b0;

        // Send "1": LED should turn on
        send_byte("1");
        #(BIT_TIME * 2);

        if (led0 !== 1'b1)
            $error("Test failed: LED0 should be ON after command 1");

        // Send "0": LED should turn off
        send_byte("0");
        #(BIT_TIME * 2);

        if (led0 !== 1'b0)
            $error("Test failed: LED0 should be OFF after command 0");

        // Send "T": LED should toggle on
        send_byte("T");
        #(BIT_TIME * 2);

        if (led0 !== 1'b1)
            $error("Test failed: LED0 should toggle ON after command T");

        $display("All UART command tests passed.");
        $finish;
    end

endmodule