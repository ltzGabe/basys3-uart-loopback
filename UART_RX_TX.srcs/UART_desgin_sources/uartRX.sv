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
    logic [2:0] STATE;

    always_ff@(posedge clk) begin
        if (reset) begin 
         baudCounter <= 0;
         bitcounter <= 0;         
        dataValid <= 0;
         STATE <= IDLE;
          end
     else begin
        if (baudCounter == baudRate) begin 
        case(STATE)
            IDLE: begin 
                      dataValid <= 0;
                if(!rx) begin
                    STATE <= READ;
                end
                    baudCounter <= 0;
                
               end
            READ:   begin
                    if(bitcounter == 4'd8) begin
                        STATE <= DATA;
                        bitcounter <= 0; 
                        end
                     else begin
                        data[bitcounter] <= rx;
                        bitcounter <= bitcounter +1; 
                    end
                     baudCounter <= 0;
          
             end
             DATA: begin
                if(ledCounter == LED_HOLD_TICKS)  begin
                    STATE <= STOP;       
                    ledCounter<=0;
                    end
                 else begin
                    led[7:0] <= data;
                    ledCounter<= ledCounter +1;                  
                   end
                   baudCounter <= 0;
             end
             STOP: begin 
                if(rx) begin 
                 STATE <= IDLE;
                dataValid <= 1;
               end
                 baudCounter <= 0;
             end
            
        endcase
        end
         
        else
            baudCounter <= baudCounter +1 ;
    end
    end
    
    
endmodule