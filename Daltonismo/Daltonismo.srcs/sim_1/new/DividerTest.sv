`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 12/01/2016 07:27:22 PM
// Design Name: 
// Module Name: DividerTest
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


module DividerTest(

    );
    
    logic clk = 0;
      logic [7:0] data = 0;
      logic [7:0] dataDelayed;
      logic [7:0] datadivided;
      always
      begin
        #5 clk = !clk;
      end
      
      always@(posedge clk)
      begin
        data <= data+5;
      end
      logic[7:0]div = 2;
      DelaySignal #(.DATA_WIDTH(8),.DELAY_CYCLES('h20)) Delayed(clk,data, dataDelayed);
      Divider #(.DIVIDEND_WIDTH(8), .DIVIDER_WIDTH(8), .QUOTENT_WIDTH(8)) 
          DividerNameHere(clk,data, div, datadivided);
endmodule
