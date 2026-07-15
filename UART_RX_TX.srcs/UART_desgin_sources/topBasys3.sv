`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Engineer: Gabriel
//
// Module Name: topBasys3
// Target Devices: Basys 3 (Artix-7 XC7A35T)
// Description: Full UART loopback demo. Anything typed into a PC serial terminal
//              (PuTTY, 115200 8N1) is received by uart_rx, then immediately
//              re-transmitted by uart_tx - so the same character echoes back
//              to the terminal. Proves RX and TX simultaneously on real hardware.
//////////////////////////////////////////////////////////////////////////////////

module topBasys3(
    input  logic clk,
    input  logic BTNC,       // reset
    input  logic rx,         // from USB-UART bridge (RsRx)
    output logic tx,         // to USB-UART bridge (RsTx)
    output logic [7:0] led  // debug: shows last received byte + status
    );

    logic reset;
    assign reset = BTNC;

    // --- Shared baud tick generator, used only by TX ---
    logic baudtick;
    baudTickGen baud_inst (
        .clk(clk),
        .reset(reset),
        .baudtick(baudtick)
    );

    // --- Receiver ---
    logic [7:0] rx_data;
    logic rx_dataValid;

    UARTReceiver rx_inst (
        .clk(clk),
        .rx(rx),
        .BTNC(BTNC),
        .dataValid(rx_dataValid),
        .led(led),
        .data(rx_data)
    );

    // --- Transmitter ---
    logic tx_busy;

    uart_tx tx_inst (
        .clk(clk),
        .reset(reset),
        .tx_start(rx_dataValid),  // dataValid's 1-cycle pulse directly triggers a send
        .data_in(rx_data),
        .baudtick(baudtick),
        .tx(tx),
        .tx_busy(tx_busy)
    );

endmodule
