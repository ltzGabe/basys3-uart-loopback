`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Engineer: Gabriel
//
// Module Name: uart_tx
// Target Devices: Basys 3 (Artix-7 XC7A35T)
// Description: UART transmitter, 8N1 frame (1 start bit, 8 data bits LSB-first,
//              1 stop bit), 115200 baud @ 100MHz system clock.
//              Takes an external baudtick pulse (from baudTickGen) rather than
//              generating its own timing, since TX controls exactly when a
//              transmission begins and has no need to phase-align to anything
//              external (unlike uart_rx, which uses its own self-resetting
//              counter to sync to an unpredictable incoming start bit).
//              Verified on real hardware: sends a fixed byte over RsTx, visible
//              in a PC serial terminal (PuTTY, 115200 8N1).
//////////////////////////////////////////////////////////////////////////////////

module uart_tx (
    input  logic clk,
    input  logic reset,
    input  logic tx_start,       // 1-cycle pulse: "send data_in now"
    input  logic [7:0] data_in,  // byte to transmit
    input  logic baudtick,       // 1-cycle pulse, once per bit period (from baudTickGen)

    output logic tx,             // serial output line, idles HIGH
    output logic tx_busy         // HIGH while a frame is in progress
    );

    localparam IDLE = 2'b00;
    localparam SEND = 2'b01;  // drives the start bit for exactly one bit period
    localparam DATA = 2'b10;  // shifts out the 8 data bits, LSB first
    localparam STOP = 2'b11;  // bookkeeping only - tx already holds the stop-bit level

    logic [1:0] STATE;
    logic [4:0] counter;   // tracks which data bit (0-7) is currently being sent
    logic [7:0] dataCap;   // latched copy of data_in, so a change to data_in mid-frame
                           // can't corrupt the byte already being transmitted

    always_ff @(posedge clk) begin
        if (reset) begin
            STATE   <= IDLE;
            counter <= 0;
            tx_busy <= 0;
            tx      <= 1;   // idle line level
        end
        else begin
            if (baudtick) begin
                case (STATE)

                    IDLE: begin
                        tx <= 1;  // idle high
                        if (tx_start) begin
                            STATE   <= SEND;
                            dataCap <= data_in;  // latch the byte for the whole frame
                            tx_busy <= 1;
                        end
                    end

                    SEND: begin
                        tx    <= 0;      // start bit
                        STATE <= DATA;
                    end

                    DATA: begin
                        if (counter == 4'd8) begin
                            tx      <= 1;   // stop bit, driven the instant bit 7 completes
                            counter <= 0;
                            STATE   <= STOP;
                        end
                        else begin
                            counter <= counter + 1;
                            tx      <= dataCap[counter];  // LSB first
                        end
                    end

                    STOP: begin
                        // tx is already high from DATA's exit - this state just
                        // holds it for the stop bit's remaining duration and
                        // clears tx_busy before returning to IDLE
                        tx_busy <= 0;
                        STATE   <= IDLE;
                    end

                endcase
            end
        end
    end

endmodule