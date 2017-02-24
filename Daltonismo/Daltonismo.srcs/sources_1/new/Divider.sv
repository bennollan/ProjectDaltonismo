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
      quotient
      );
      
  parameter DIVIDEND_WIDTH = 1;
  parameter DIVIDER_WIDTH = 1;
  parameter QUOTIENT_WIDTH = DIVIDEND_WIDTH;
  
  input clk;
  input [DIVIDEND_WIDTH - 1:0]dividend;
  input [DIVIDER_WIDTH - 1:0]divider;
  output [QUOTIENT_WIDTH - 1:0]quotient;
  
  logic [QUOTIENT_WIDTH - 1:0]quotientArray[QUOTIENT_WIDTH+1];
  logic [DIVIDEND_WIDTH-1:0]dividendArray[QUOTIENT_WIDTH+1];
  logic [DIVIDER_WIDTH + QUOTIENT_WIDTH-1:0]dividerArray[QUOTIENT_WIDTH+1];
  
  assign quotientArray[QUOTIENT_WIDTH] = 0;
  assign quotient = quotientArray[0];
  assign dividendArray[QUOTIENT_WIDTH] = dividend;
  assign dividerArray[QUOTIENT_WIDTH] = divider << (QUOTIENT_WIDTH-1);
  
  always@(posedge clk)
  begin
    logic[8:0] i;
    for(i = 0; i  < QUOTIENT_WIDTH; i=i+1)
    begin
      if(dividendArray[i+1] >= dividerArray[i+1] && dividerArray[i+1])
      begin
        dividendArray[i] <= dividendArray[i+1] - dividerArray[i+1];
        quotientArray[i] <= {quotientArray[i+1][QUOTIENT_WIDTH - 2:0], 1'b1};
      end
      else
      begin
        dividendArray[i] <= dividendArray[i+1];
        quotientArray[i] <= {quotientArray[i+1][QUOTIENT_WIDTH - 2:0], 1'b0};
      end
      dividerArray[i] <= dividerArray[i+1] >> 1;
    end
  end
endmodule
