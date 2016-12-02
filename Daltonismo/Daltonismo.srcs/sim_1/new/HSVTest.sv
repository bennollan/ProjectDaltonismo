`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 11/29/2016 09:44:36 PM
// Design Name: 
// Module Name: HSVTest
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


module HSVTest(

    );
    logic clk = 0;
    always
    begin
    #5 clk = !clk;
    end
    
    logic [8:0] hue;
      logic [7:0] sat;
      logic [7:0] val;
      logic [7:0] HSVred,HSVgreen,HSVblue;
      logic [7:0] redIn = 200;
      logic [7:0] greenIn = 5;
      logic [7:0] blueIn = 127;
      RGBtoHSV filt1(clk, redIn, greenIn, blueIn, hue, sat, val);
      HSVtoRGB filt2(clk, hue,sat, val, HSVred, HSVgreen, HSVblue);
endmodule
