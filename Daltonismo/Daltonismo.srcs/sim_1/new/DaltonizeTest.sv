`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 12/06/2016 02:51:22 PM
// Design Name: 
// Module Name: DaltonizeTest
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


module DaltonizeTest(

    );
    
    logic [8:0] hue;
    logic [7:0] sat;
    logic [7:0] val;
    logic [7:0] HSVred,HSVgreen,HSVblue;
    logic [7:0] redIn = 234;
    logic [7:0] greenIn = 33;
    logic [7:0] blueIn = 30;
    logic clk = 1;
    logic [3:0]counter = 1;
    always
    begin
    #5 clk = !clk;
    end
    
    always@(posedge clk)
    begin
      counter <= counter + 1;
      //if(counter == 0)
        //greenIn <= greenIn + 10;
    end
    
      RGBtoHSV filt1(clk, redIn, greenIn, blueIn, hue, sat, val);
      logic[7:0] correctedSat;
      Daltonizer colorCorrect(clk, hue, sat, correctedSat);
      logic[8:0] hueDelayed;
      logic[7:0] valDelayed;
      DelaySignal #(.DATA_WIDTH(9),.DELAY_CYCLES(8)) HueDelay(clk,hue, hueDelayed);
      DelaySignal #(.DATA_WIDTH(8),.DELAY_CYCLES(8)) ValueDelay(clk,val, valDelayed);
      
      HSVtoRGB filt2(clk, hueDelayed,correctedSat, valDelayed, HSVred, HSVgreen, HSVblue);
endmodule
