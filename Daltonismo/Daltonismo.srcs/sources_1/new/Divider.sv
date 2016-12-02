`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: DigiPen Institute of Technology
// Engineer: Ben Nollan
//           Cody Anderson
// 
// Module Name: Divider
// Project Name: Daltonismo
// Target Devices: Digilent Nexys Video
// Tool Versions: Vivado 2015.4
// Description: Divides a Number by a number.
//
// 
//////////////////////////////////////////////////////////////////////////////////


module Divider(
      clk,
      dividend,
      divider,
      quotent
      );
      
  parameter DIVIDEND_WIDTH = 1;
  parameter DIVIDER_WIDTH = 1;
  parameter QUOTENT_WIDTH = DIVIDEND_WIDTH;
  
  input clk;
  input [DIVIDEND_WIDTH - 1:0]dividend;
  input [DIVIDER_WIDTH - 1:0]divider;
  output [QUOTENT_WIDTH - 1:0]quotent;
  
  logic [QUOTENT_WIDTH - 1:0]quotentArray[QUOTENT_WIDTH+1];
  logic [DIVIDEND_WIDTH-1:0]dividendArray[QUOTENT_WIDTH+1];
  logic [DIVIDER_WIDTH + QUOTENT_WIDTH-1:0]dividerArray[QUOTENT_WIDTH+1];
  
  assign quotentArray[QUOTENT_WIDTH] = 0;
  assign quotent = quotentArray[0];
  assign dividendArray[QUOTENT_WIDTH] = dividend;
  assign dividerArray[QUOTENT_WIDTH] = divider << (QUOTENT_WIDTH-1);
  
  always@(posedge clk)
  begin
    logic[8:0] i;
    for(i = 0; i  < QUOTENT_WIDTH; i=i+1)
    begin
      if(dividendArray[i+1] >= dividerArray[i+1])
      begin
        dividendArray[i] <= dividendArray[i+1] - dividerArray[i+1];
        quotentArray[i] <= {quotentArray[i+1][QUOTENT_WIDTH - 2:0], 1'b1};
      end
      else
      begin
        dividendArray[i] <= dividendArray[i+1];
        quotentArray[i] <= {quotentArray[i+1][QUOTENT_WIDTH - 2:0], 1'b0};
      end
      dividerArray[i] <= dividerArray[i+1] >> 1;
    end
  end
endmodule
