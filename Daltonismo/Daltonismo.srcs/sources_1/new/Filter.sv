`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: DigiPen Institute of Technology
// Engineer: Ben Nollan
//           Cody Anderson
// 
// Module Name: Filter
// Project Name: Daltonismo
// Target Devices: Digilent Nexys Video
// Tool Versions: Vivado 2015.4
// Description: Applies a filter to the video data that is passed in.
// 
// 
//////////////////////////////////////////////////////////////////////////////////


module Filter(
    input clk,
    input [2:0]switcher,
    input [2:0] syncIn,
    input [7:0] redIn,
    input [7:0] greenIn,
    input [7:0] blueIn,
    output logic [2:0] syncOut,
    output logic [7:0] redOut,
    output logic [7:0] greenOut,
    output logic [7:0] blueOut
    );
  logic [2:0]filterStage;
  logic [8:0] frames;
  logic [8:0] hue;
  logic [8:0] correctedHue;
  always_comb
  begin
    if(switcher > 3'b100)
    begin
      if(frames + hue > 383)
        correctedHue = (hue + frames) - 384;
      else
        correctedHue = hue + frames;
    end
    else
      correctedHue = hue;
  end
  
    
  
  logic [7:0] sat;
  logic [7:0] correctedSat;
  logic [7:0] satDelayed;
  logic [7:0] val;
  logic [7:0] correctedVal;
  logic [7:0] HSVred,HSVgreen,HSVblue;
  RGBtoHSV filt1(clk, redIn, greenIn, blueIn, hue, sat, val);
  Daltonizer colorCorrect(clk, hue, sat, val, correctedSat, correctedVal);
  logic[8:0] hueDelayed;
  logic[7:0] valDelayed;
  DelaySignal #(.DATA_WIDTH(9),.DELAY_CYCLES(9)) HueDelay(clk,correctedHue, hueDelayed);
  DelaySignal #(.DATA_WIDTH(8),.DELAY_CYCLES(8)) ValueDelay(clk,val, valDelayed);
  DelaySignal #(.DATA_WIDTH(8),.DELAY_CYCLES(8)) SatDelay(clk,sat, satDelayed);
  
  logic [7:0] satRGB;
  logic [7:0] valRGB;
  HSVtoRGB filt2(clk, hueDelayed,satRGB, valRGB, HSVred, HSVgreen, HSVblue);
    
  DelaySignal #(.DATA_WIDTH(3),.DELAY_CYCLES(20)) SyncDelay(clk,syncIn, syncOut);
  logic [2:0]currentFilter;
  always@(posedge clk)
  begin
    case(currentFilter)
      0:begin
        satRGB <= satDelayed;
        valRGB <= valDelayed;
        redOut <= HSVred;
        greenOut <= HSVgreen;
        blueOut <= HSVblue;
      end
      1:begin
        satRGB <= satDelayed;
        valRGB <= valDelayed;
        redOut <= (HSVred + HSVgreen)/2;
        greenOut <= (HSVred + HSVgreen)/2;
        blueOut <= HSVblue;
      end
      2:begin
        satRGB <= correctedSat;
        valRGB <= correctedVal;
        redOut <= HSVred;
        greenOut <= HSVgreen;
        blueOut <= HSVblue;
      end
      3:begin
        satRGB <= correctedSat;
        valRGB <= correctedVal;
        redOut <= (HSVred + HSVgreen)/2;
        greenOut <= (HSVred + HSVgreen)/2;
        blueOut <= HSVblue;
      end
      4:begin
        satRGB <= satDelayed;
        valRGB <= valDelayed;
        redOut <= ~HSVred;
        greenOut <= ~HSVgreen;
        blueOut <= ~HSVblue;
      end
      default:begin
        satRGB <= satDelayed;
        valRGB <= valDelayed;
        redOut <= HSVred;
        greenOut <= HSVgreen;
        blueOut <= HSVblue;
      end
      endcase
  end
  
  
  logic [19:0]count;
  logic lSwitchState;
  logic [15:0]hPos;
  logic [15:0]hSize;
  logic [15:0]vPos;
  logic [15:0]vSize;
  always@(posedge clk)
  begin
    if(!syncOut[0])
    begin
      hPos <= hPos + 1;
    end
    if(syncOut[0] && syncOut[1] && hPos)
    begin
      vPos <= vPos + 1;
      hSize <= hPos;
      hPos <= 0;
    end
    if(syncOut[0] && syncOut[2] && vPos)
    begin
      if(frames  >= 9'h17F)
          frames <= 0;
      else
        frames <= frames + 1;
      vSize <= vPos;
      vPos <= 0;
    end
      
    case(switcher)
      0:begin
        currentFilter <= switcher;
      end
      1:begin
        currentFilter <= switcher;
      end
      2:begin
        currentFilter <= switcher;
      end
      3:begin
        currentFilter <= switcher;
      end
      4:begin
        currentFilter[2] <= 0;
        if(hPos < hSize / 2)
          currentFilter[0] <= 0;
        else
          currentFilter[0] <= 1;
          
        if(vPos < vSize / 2)
          currentFilter[1] <= 0;
        else
          currentFilter[1] <= 1;
      end
      6:begin
        currentFilter <= 4;
      end
      default:begin
        currentFilter <= 0;
      end
    endcase
    
  end
    
endmodule


module Daltonizer(
       input clk, 
       input [8:0]hue, 
       input [7:0]sat, 
       input [7:0]val,
       output [7:0]correctedSat,
       output [7:0]correctedVal
       );
       
  logic [7:0]satDivisor;
  logic [7:0]valDivisor;
  always_comb
  begin
    if(hue < 64)
      satDivisor = 128 - hue;
    else if(hue > 320)
      satDivisor = hue - 256;
    else
      satDivisor = 64;
      
    if(hue >= 64 && hue < 128)
      valDivisor = hue;
    else if(hue >= 128 && hue < 192)
      valDivisor = 256 - hue;
    else
      valDivisor = 64;
  end
  Divider #(.DIVIDEND_WIDTH(14), .DIVIDER_WIDTH(8), .QUOTIENT_WIDTH(8)) 
             DaltSatDivide(clk, (sat * 64), satDivisor, correctedSat);
  Divider #(.DIVIDEND_WIDTH(14), .DIVIDER_WIDTH(8), .QUOTIENT_WIDTH(8)) 
             DaltValDivide(clk, (val * 64), valDivisor, correctedVal);
endmodule

module RGBtoHSV(
    input  logic       clk,
    input  logic [7:0] red,
    input  logic [7:0] green,
    input  logic [7:0] blue,
    output logic [8:0] hue,
    output logic [7:0] sat,
    output logic [7:0] val
    );
    
    logic [13:0]hueDividend;
    logic [7:0]hueDivisor;
    logic [6:0]huequotient;
    
    logic [15:0]satDividend;
    logic [7:0]satDivisor;
    logic [7:0]satquotient;
    
    logic [7:0]delayVal;
    logic [2:0]delayedSwitch;
    
    logic [2:0]switcher = 0;
    
  always@(posedge clk)
  begin
    logic [7:0]delta;
    logic [7:0]max;
    logic [7:0]mid;
    logic [7:0]min;
    
    //0-63 red to yellow
    // 320-383 magenta to red
    // 64 - 128 yellow to green
    // 128-192 green to cyan
    // 192-256 cyan to blue
    // 256-320 blue to magenta

    if(red >= green && red >= blue)
    begin
      if(green > blue)
      begin //0-63 red to yellow
        mid = green;
        min = blue;
        switcher <= 0;
      end
      else
      begin // 320-383 magenta to red
        mid = blue;
        min = green;
        switcher <= 1;
      end
      max = red;
    end
    else if(green >= red && green >= blue)
    begin
      if(red > blue)
      begin  // 64 - 128 yellow to green
        min = blue;
        mid = red;
        switcher <= 2;
      end
      else
      begin  // 128-192 green to cyan
        min = red;
        mid = blue;
        switcher <= 3;
      end
      max = green;      
    end
    else
    begin
      if(green > red)
      begin  // 192-256 cyan to blue
        min = red;
        mid = green;
        switcher <= 4;
      end
      else
      begin  // 256-320 blue to magenta
        min = green;
        mid = red;
        switcher <= 5;
      end
      max = blue;
    end
    
    hueDividend <= ((mid - min) * 64);
    hueDivisor <= max-min;
    
    satDividend <= ((max-min) * 255);
    satDivisor <= max;
    
    delayVal <= max;
    
    case(delayedSwitch)
      0:      hue <=       huequotient;//   0- 63 red to yellow
      1:      hue <= 383 - huequotient;// 320-383 magenta to red
      2:      hue <= 127 - huequotient;//  64-127 yellow to green
      3:      hue <= 128 + huequotient;// 128-191 green to cyan
      4:      hue <= 255 - huequotient;// 192-255 cyan to blue
      default:hue <= 256 + huequotient;// 256-319 blue to magenta
    endcase
    
  end
  //hue <= ((mid - min) * 64) / (max-min);
  Divider #(.DIVIDEND_WIDTH(14), .DIVIDER_WIDTH(8), .QUOTIENT_WIDTH(7)) 
      HueDivide(clk ,hueDividend, hueDivisor, huequotient);
  //sat <= ((max-min) * 255) / max;
  Divider #(.DIVIDEND_WIDTH(16), .DIVIDER_WIDTH(8), .QUOTIENT_WIDTH(8)) 
      SatDivide(clk, satDividend, satDivisor, sat);
      
  DelaySignal #(.DATA_WIDTH(8),.DELAY_CYCLES(8)) ValueDelay(clk,delayVal, val);
  DelaySignal #(.DATA_WIDTH(3),.DELAY_CYCLES(7)) SwitchDelay(clk,switcher, delayedSwitch);
  
endmodule

module HSVtoRGB(
    input  logic       clk,
    input  logic [8:0] hue,
    input  logic [7:0] sat,
    input  logic [7:0] val,
    output logic [7:0] red,
    output logic [7:0] green,
    output logic [7:0] blue
    );
    
  always@(posedge clk)
  begin
    logic [6:0] f;
    logic [7:0] p;
    logic [7:0] q;
    logic [7:0] t;
    if (sat == 0)
    begin
      // achromatic (grey)
      red <= val;
      green <= val;
      blue <= val;
    end
    else
    begin
      f = hue[5:0];      // factorial part of h
      p = (val * (255 - sat))/256;
      q = (val * (255*64 - sat * f))/(256*64);
      t = (val * (255*64 - sat * (64 - f)))/(256*64);
      case (hue[8:6])
      0:begin
          red <= val;
          green <= t;
          blue <= p;
        end
      1:begin
          red <= q;
          green <= val;
          blue <= p;
        end
      2:begin
          red <= p;
          green <= val;
          blue <= t;
        end
      3:begin
          red <= p;
          green <= q;
          blue <= val;
        end
      4:begin
          red <= t;
          green <= p;
          blue <= val;
        end
      default: begin
          red <= val;
          green <= p;
          blue <= q;
        end
      endcase
    end
  end
    
endmodule