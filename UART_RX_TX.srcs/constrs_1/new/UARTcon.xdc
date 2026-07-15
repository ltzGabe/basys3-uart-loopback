## Basys 3 constraints - full UART loopback demo (topBasys3)
## Verified against Basys3_Master.xdc

## Clock 100 MHz
set_property PACKAGE_PIN W5 [get_ports clk]
set_property IOSTANDARD LVCMOS33 [get_ports clk]
create_clock -period 10.000 -name sys_clk_pin -waveform {0 5} -add [get_ports clk]

## Reset - center pushbutton (BTNC)
set_property PACKAGE_PIN U18 [get_ports BTNC]
set_property IOSTANDARD LVCMOS33 [get_ports BTNC]

## UART RX <- USB-UART bridge (RsRx)
set_property PACKAGE_PIN B18 [get_ports rx]
set_property IOSTANDARD LVCMOS33 [get_ports rx]

## UART TX -> USB-UART bridge (RsTx)
set_property PACKAGE_PIN A18 [get_ports tx] 
set_property IOSTANDARD LVCMOS33 [get_ports tx]

## led[7:0] - debug display of last received byte (driven inside uart_rx)
## NOTE: RX module's led port is 8 bits wide, not 16 - matched here accordingly
set_property PACKAGE_PIN U16 [get_ports {led[0]}]
set_property PACKAGE_PIN E19 [get_ports {led[1]}]
set_property PACKAGE_PIN U19 [get_ports {led[2]}]
set_property PACKAGE_PIN V19 [get_ports {led[3]}]
set_property PACKAGE_PIN W18 [get_ports {led[4]}]
set_property PACKAGE_PIN U15 [get_ports {led[5]}]
set_property PACKAGE_PIN U14 [get_ports {led[6]}]
set_property PACKAGE_PIN V14 [get_ports {led[7]}]
set_property IOSTANDARD LVCMOS33 [get_ports {led[*]}]

