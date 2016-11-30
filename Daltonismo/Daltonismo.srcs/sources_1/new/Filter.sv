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
    input switcher,
    input [2:0] syncIn,
    input [7:0] redIn,
    input [7:0] greenIn,
    input [7:0] blueIn,
    output logic [2:0] syncOut,
    output logic [7:0] redOut,
    output logic [7:0] greenOut,
    output logic [7:0] blueOut
    );
    
  logic [8:0] frames;
  logic [8:0] hue;
  logic [8:0] correctedHue;
  always_comb
  begin
    if(frames + hue > 383)
      correctedHue = (hue + frames) - 384;
    else
      correctedHue = hue + frames;
  end
  
    
  
  logic [7:0] sat;
  logic [7:0] val;
  logic [7:0] HSVred,HSVgreen,HSVblue;
  RGBtoHSV filt1(clk, redIn, greenIn, blueIn, hue, sat, val);
  HSVtoRGB filt2(clk, correctedHue,sat, val, HSVred, HSVgreen, HSVblue);
    
    
  logic [2:0]filterStage;
  logic [2:0]currentFilter;
  always@(posedge clk)
  begin
    case(currentFilter)
      0:begin
        syncOut <= syncIn;
        redOut <= redIn;
        greenOut <= greenIn;
        blueOut <= blueIn;
      end
      1:begin
        syncOut <= syncIn;
        redOut <= (redIn + greenIn)/2;
        greenOut <= (redIn + greenIn)/2;
        blueOut <= blueIn;
      end
      2:begin
        syncOut <= syncIn;
        redOut <= greenIn;
        greenOut <= blueIn;
        blueOut <= redIn;
      end
      3:begin
        syncOut <= syncIn;
        redOut <= (greenIn + redIn + blueIn)/3;
        greenOut <= (greenIn + redIn + blueIn)/3;
        blueOut <= (greenIn + redIn + blueIn)/3;
      end
      4:begin
        syncOut <= syncIn;
        redOut <= ~redIn;
        greenOut <= ~greenIn;
        blueOut <= ~blueIn;
      end
      5:begin
        syncOut <= syncIn;
        foreach(redIn[idx]) 
        begin
          redOut[idx] <= redIn[7-idx];
          greenOut[idx] <= greenIn[7-idx];
          blueOut[idx] <= blueIn[7-idx];
        end
      end
      6:begin
        syncOut <= syncIn;
        redOut <= HSVred;
        greenOut <= HSVgreen;
        blueOut <= HSVblue;
      end
      default:
      begin
        syncOut <= syncIn;
        if(redIn > greenIn && redIn > blueIn)
        begin
          redOut <= 255;
        end
        else
          redOut <= redIn;
        greenOut <= greenIn;
        blueOut <= blueIn;
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
    if(!syncIn[0])
    begin
      hPos <= hPos + 1;
    end
    if(syncIn[0] && syncIn[1] && hPos)
    begin
      vPos <= vPos + 1;
      hSize <= hPos;
      hPos <= 0;
    end
    if(syncIn[0] && syncIn[2] && vPos)
    begin
      if(frames  >= 9'h17F)
          frames <= 0;
      else
        frames <= frames + 1;
      vSize <= vPos;
      vPos <= 0;
    end
      
    
    if(hPos < hSize / 2 && 0)
      currentFilter <= 0;
    else
      currentFilter <= filterStage;
      
    if(count == 0)
    begin
      if(switcher && !lSwitchState)
        filterStage <= filterStage + 1;
        
      lSwitchState <= switcher;
    end
    count <= count + 1;
  end
    
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
    
  always@(posedge clk)
  begin
  
    logic [7:0]delta;
    if(red == green && green == blue)
    begin
      hue <= 0;
      sat <= 0;
      val <= red;
    end
    else
    begin
      if(red >= green && red >= blue)
      begin
        if(green > blue)
        begin
          delta = red - blue;
          hue <= ((green - blue) * 64) / delta; //0-64 red to yellow
        end
        else
        begin
          delta = red - green;
          hue <= 383 - ((blue - green) * 64) / delta; // 320-383 magenta to red
        end
         val <= red;
         sat <= (delta * 255) / red;
        
      end
      else if(green >= red && green >= blue)
      begin
        if(red > blue)
        begin
          delta = green - blue;
          hue <= 128 - ((red - blue) * 64) / delta;	// 64 - 128 yellow to green
        end
        else
        begin
          delta = green - red;
          hue <= 128 + ((blue - red) * 64) / delta;	// 128-192 green to cyan
        end
        val <= green;
        sat <= (delta * 255) / green;
        
      end
      else
      begin
        if(green > red)
        begin
          delta = blue - red;
          hue <= 256 - ((green - red) * 64) / delta;  // 192-256 cyan to blue
        end
        else
        begin
          delta = blue - green;
          hue <= 256 + ((red - green) * 64) / delta;  // 256-320 blue to magenta
        end
        val <= blue;
        
        sat <= (delta * 255) / blue;
        
      end
    end
  end
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