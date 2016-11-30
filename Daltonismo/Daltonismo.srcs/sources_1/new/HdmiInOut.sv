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
    input [4:0] inputDelay,
    input bitSlip,
    output logic dataValid,
    output [2:0] syncs,
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
    logic [4:0]delay_count;
    logic delay_ce;
    Deserializer Deserial(clk100,clk,clkx5,reset,slip,delay_ce,delay_count,serIn,symbol);
    
    /////////////////////////
    //  TMDS Symbol Decoder
    /////////////////////////
    logic symbolGood;
    TmdsDecoder Decode(clk,symbol,symbolGood,dataOut,syncs);
    
    
    
    logic slipBuf;
    logic [15:0]goodCount;
    logic [3:0]bitSlips;
    logic [2:0]validWait;
    logic slippingActive;
    always@(posedge clk)
    begin
      if(bitSlip)
      begin
        slippingActive <= 1;
        bitSlips <= 0;
      end //if(sw[5])
      if(slippingActive)
      begin
        if(validWait == 0)
        begin
          if(dataValid || bitSlips == 15)
            slippingActive <= 0;
          else if(symbolGood == 0)
          begin
            slip <= 1;
            bitSlips <= bitSlips + 1;
          end
        end //if(validWait == 0)
        else
          slip <= 0;
        validWait <= validWait + 1;
      end //if(slippingActive)
      
      if(symbolGood)
      begin
        if(goodCount < 16'hFFFF)
          goodCount <= goodCount + 1;
        else
          dataValid <= 1;
      end
      else
      begin
        dataValid <= 0;
        goodCount <= 0;
      end
      
    end //always@(posedge HdmiClk)
    
    
    logic [19:0]count;
    always@(posedge clk100)
    begin
      if(count == 0)
      begin
        if(delay_count != inputDelay)
        begin
          delay_count <= inputDelay;
          delay_ce <= 1;
        end
      end
      else
        delay_ce <= 0;
        
      count <= count + 1;
    end
    
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
      symOut = symbolIn;
    else
      symOut = encodedSym;
  end
    
endmodule
