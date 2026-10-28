## Basys 3 100 MHz clock
set_property PACKAGE_PIN W5 [get_ports {clk}]
set_property IOSTANDARD LVCMOS33 [get_ports {clk}]
create_clock -add -name sys_clk_pin -period 10.00 -waveform {0 5} [get_ports {clk}]

## Center pushbutton: reset
set_property PACKAGE_PIN U18 [get_ports {rst}]
set_property IOSTANDARD LVCMOS33 [get_ports {rst}]

## USB-UART connection
## Computer -> FPGA receive input
set_property PACKAGE_PIN B18 [get_ports {uart_rx}]
set_property IOSTANDARD LVCMOS33 [get_ports {uart_rx}]

## FPGA -> Computer transmit output
set_property PACKAGE_PIN A18 [get_ports {uart_tx}]
set_property IOSTANDARD LVCMOS33 [get_ports {uart_tx}]

## Basys 3 LED0
set_property PACKAGE_PIN U16 [get_ports {led0}]
set_property IOSTANDARD LVCMOS33 [get_ports {led0}]