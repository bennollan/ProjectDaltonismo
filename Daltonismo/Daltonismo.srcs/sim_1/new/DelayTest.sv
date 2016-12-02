`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 12/01/2016 06:39:15 PM
// Design Name: 
// Module Name: DelayTest
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


module DelayTest(

    );
    
  logic clk = 0;
  logic [7:0] data = 0;
  logic [7:0] dataDelayed;
  always
  begin
    #5 clk = !clk;
  end
  
  always@(posedge clk)
  begin
    data <= data + 1;
  end
  
  DelaySignal #(.DATA_WIDTH(8),.DELAY_CYCLES(8)) Delayed(clk,data, dataDelayed);
        
endmodule
