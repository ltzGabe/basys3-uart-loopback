# UART receiver and transmitter (Basys3 loopback)

UART RX and TX written in SystemVerilog, running on a Basys3 at 115200 baud, 8N1, from the 100 MHz board clock. Characters typed into a serial terminal on the PC are shown on the LEDs and then sent back to the terminal.

## Trying it

1. Program the board and open a serial terminal (PuTTY, Tera Term etc.) on the Basys3's USB-UART COM port at 115200, 8 data bits, no parity, 1 stop bit.
2. Type a character. Its ASCII code shows up in binary on LED0 to LED7.
3. About 3 seconds later it's echoed back to the terminal.

BTNC (the middle button) is reset.

## Modules

- `uartRX.sv` - receiver. Waits for the start bit, samples the 8 data bits LSB first, holds the byte on the LEDs for 3 s, then checks for the stop bit and raises `dataValid`.
- `uartTX.sv` - transmitter. Latches the byte when `tx_start` goes high so it can't change mid-frame, then sends the start bit, 8 data bits and the stop bit. `tx_busy` is high while it's sending.
- `baudTickGen.sv` - counts 100 MHz / 115200 = 868 cycles and outputs a one-cycle tick per bit, used by the transmitter.
- `topBasys3.sv` - connects the receiver's output straight into the transmitter for the loopback.
- `UARTcon.xdc` - pins for the clock, BTNC, USB-UART RX/TX and the 8 LEDs.

Both FSMs use the three-block style (state register, combinational next-state logic, then a block for outputs and the datapath). I originally wrote them differently and refactored them to this because it was easier to follow.

## Building

The Vivado project file isn't committed (it's in the .gitignore), so:

1. Create a new Vivado project for the Basys3 (part xc7a35tcpg236-1).
2. Add the four `.sv` files from `UART_desgin_sources` as design sources and `UARTcon.xdc` as a constraint.
3. Set `topBasys3` as top, generate the bitstream and program the board.

## Known issues

- The receiver ignores the line for the whole 3 s it spends showing a byte on the LEDs, so if you type quickly characters get missed or garbled. One at a time works.
- The RX baud counter runs freely instead of restarting on the start bit, so where it samples within each bit depends on when the character arrives. It's worked in testing, but the proper fix is to restart the counter on the start bit's falling edge and sample half a bit in.
- `rx` isn't passed through a two flip-flop synchroniser in this version. The receiver in my [sensor pipeline project](https://github.com/ltzGabe/basys3-esp32-ultrasensor-pipeline) has one.
- RX has its own baud counter instead of using `baudTickGen`.
- No testbench, this was tested directly on the board.
