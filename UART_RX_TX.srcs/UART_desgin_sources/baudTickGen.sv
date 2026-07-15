`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 11.07.2026 19:18:44
// Design Name: 
// Module Name: baudTickGen
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


module baudTickGen(
    input clk,
    input reset,
    output logic baudtick
    );
    
    localparam target = 100_000_000 / 115200;
    localparam width =  $clog2(target); 
    logic [width-1:0] counter;
    always_ff@(posedge clk) begin 
        if (reset) begin 
         counter <= 1'b0;
         baudtick <= 1'b0;
        end
         else begin 
        if (counter == target-1) begin 
            counter <= {width{1'b0}}; 
            baudtick <= 1'b1;
            end
         else begin
            counter <= counter +1;
            baudtick <= 1'b0;
         end   
    end
    end  
   
endmodule
