`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: DigiPen Institute of Technology
// Engineer: Ben Nollan
//           Cody Anderson
// 
// Module Name: HdmiInputChannel
// Project Name: Daltonismo
// Target Devices: Digilent Nexys Video
// Tool Versions: Vivado 2015.4
// Description: Handles the reception of one of the channels of HDMI
// 
// 
//////////////////////////////////////////////////////////////////////////////////


module HdmiInputChannel(
    input clk100,
    input clk,
    input clkx5,
    input hdmi_rx_p,
    input hdmi_rx_n,
    input reset,
    output logic dataValid,
    output logic [2:0] syncOut,
    output [7:0] dataOut,
    output [9:0] symbol
    );
    
    //////////////////
    // Input Buffer
    //////////////////
    logic SerIn;
    IBUFDS #(.IOSTANDARD("TMDS_33")) 
        SerialBufIn  (  .O(serIn),   .I(hdmi_rx_p),  .IB(hdmi_rx_n));
        
    /////////////////////////////
    //  InputDelay/Deserializer
    /////////////////////////////
    logic slip;
    logic [4:0]autoDelay;
    Deserializer Deserial(clk100,clk,clkx5,reset,slip,autoDelay,serIn,symbol);
    
    /////////////////////////
    //  TMDS Symbol Decoder
    /////////////////////////
    logic symbolGood;
    TmdsDecoder Decode(clk,symbol,symbolGood,dataOut,syncOut);
    

    logic [23:0]goodCount;
    logic [3:0]bitSlips;
    logic [2:0]validWait;
    logic oneExtra;
    
    always@(posedge clk)
    begin
      if(reset)
      begin
        autoDelay <= 0;
        bitSlips <= 0;
      end

      if(bitSlips == 11)
      begin
        autoDelay <= autoDelay + 1;
        bitSlips <= 0;
      end
      if(validWait == 0)
      begin
        if(symbolGood == 0)
        begin
          slip <= 1;
          bitSlips <= bitSlips + 1;
        end
      end //if(validWait == 0)
      else
        slip <= 0;
      validWait <= validWait + 1;
      
      if(symbolGood)
      begin
        if(goodCount < 24'hFFFFFF)
          goodCount <= goodCount + 1;
        else
          dataValid <= 1;
      end
      else
      begin
        dataValid <= 0;
        goodCount <= 0;
        oneExtra <= 0;
      end

      if(dataValid && !oneExtra && !validWait)
      begin
        autoDelay <= autoDelay + 1;
        oneExtra <= 1;
      end

      
    end //always@(posedge HdmiClk)
    
endmodule



//////////////////////////////////////////////////////////////////////////////////
// Company: DigiPen Institute of Technology
// Engineer: Ben Nollan
//           Cody Anderson
// 
// Module Name: HdmiOutputChannel
// Project Name: Daltonismo
// Target Devices: Digilent Nexys Video
// Tool Versions: Vivado 2015.4
// Description: Handles the process of outputting one HDMI channel.
// 
// 
//////////////////////////////////////////////////////////////////////////////////

module HdmiOutputChannel(
    input clk,
    input clkx5,
    output hdmi_tx_p,
    output hdmi_tx_n,
    input reset,
    input [2:0] syncs,
    input [7:0] dataIn,
    input [9:0] symbolIn,
    input useSymbol
    );
    
  logic [9:0]encodedSym;
  TmdsEncoder EncodeBlue(clk,dataIn,encodedSym,syncs);
  
  logic [9:0]symOut;
  Serializer SerialOut(clk,clkx5,symOut,reset,serOut);
    
  OBUFDS #(.IOSTANDARD("TMDS_33"),.SLEW("FAST")) 
    SerialBufOut  (.O(hdmi_tx_p), .OB(hdmi_tx_n), .I(serOut));  
    
    
  always_comb
  begin
    if(useSymbol)
      symOut = encodedSym;
    else
      symOut = symbolIn;
  end
    
endmodule
