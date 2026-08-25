`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 11.07.2026 19:14:00
// Design Name: 
// Module Name: UART Receiver
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
module UARTReceiver(
    input clk,
    input rx,
    input BTNC,
    output logic dataValid,
    output logic [7:0] led,
    output logic [7:0] data
    );
    
    
    localparam IDLE = 2'b00;
    localparam READ = 2'b01;
    localparam  DATA = 2'b10;
    localparam STOP = 2'b11;
    
    
    logic[4:0] bitcounter;
    
    logic [18:0] ledCounter; 
    localparam LED_HOLD_TICKS = 345600; //3 second hold
    
    logic reset;
    assign reset = BTNC;
    
    localparam baudRate = 100_000_000 / 115200;
    localparam width =  $clog2(baudRate); 
    logic [width-1:0] baudCounter;
    logic [2:0] STATE, next_state;
    logic tick;
    assign tick = (baudCounter == baudRate);

    always_ff@(posedge clk) begin
        if (reset)
            baudCounter <= 0;
        else if (tick)
            baudCounter <= 0;
        else
            baudCounter <= baudCounter + 1;
    end

    always_ff@(posedge clk) begin
        if (reset)
            STATE <= IDLE;
        else if (tick)
            STATE <= next_state;
    end

    always_comb begin
        next_state = STATE;
        case(STATE)
            IDLE: if (!rx) next_state = READ;
            READ: if (bitcounter == 4'd8) next_state = DATA;
            DATA: if (ledCounter == LED_HOLD_TICKS) next_state = STOP;
            STOP: if (rx) next_state = IDLE;
        endcase
    end

    always_ff@(posedge clk) begin
        if (reset) begin
            bitcounter <= 0;
            dataValid  <= 0;
        end
        else if (tick) begin
            case(STATE)
                IDLE: begin
                    dataValid <= 0;
                end
                READ: begin
                    if (bitcounter == 4'd8)
                        bitcounter <= 0;
                    else begin
                        data[bitcounter] <= rx;
                        bitcounter <= bitcounter + 1;
                    end
                end
                DATA: begin
                    if (ledCounter == LED_HOLD_TICKS)
                        ledCounter <= 0;
                    else begin
                        led[7:0]   <= data;
                        ledCounter <= ledCounter + 1;
                    end
                end
                STOP: begin
                    if (rx)
                        dataValid <= 1;
                end
            endcase
        end
    end
    
    
endmodule
