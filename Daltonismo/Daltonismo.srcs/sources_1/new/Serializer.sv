`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: DigiPen Institute of Technology
// Engineer: Ben Nollan
//           Cody Anderson
// 
// Module Name: Serializer
// Project Name: Daltonismo
// Target Devices: Digilent Nexys Video
// Tool Versions: Vivado 2015.4
// Description: Turns a ten bit parallel stream into a serial stream.
// 
// 
//////////////////////////////////////////////////////////////////////////////////


module Serializer(
    input clk,
    input clkx5,
    input [9:0]parallel,
    input reset,
    output serial
    );
  
  logic shift1;
  logic shift2;
  logic clockDelay = 1;
  always_ff@(posedge clk)
  begin
    clockDelay <= ~reset;
  end
  
  OSERDESE2 #(.DATA_RATE_OQ("DDR"),
             .DATA_RATE_TQ("DDR"),
             .DATA_WIDTH(10),
             .INIT_OQ(1'b1),
             .INIT_TQ(1'b1),
             .SERDES_MODE("MASTER"),
             .SRVAL_OQ(1'b0),
             .SRVAL_TQ(1'b0),
             .TBYTE_CTL("FALSE"),
             .TBYTE_SRC("FALSE"),
             .TRISTATE_WIDTH(1)
             )
  OSERDESE2_M(
    .OFB(),
    .OQ(serial),
    .SHIFTOUT1(),
    .SHIFTOUT2(),
    .TBYTEOUT(),
    .TFB(),
    .TQ(),
    .CLK(clkx5),
    .CLKDIV(clk),
    .D1(parallel[0]),
    .D2(parallel[1]),
    .D3(parallel[2]),
    .D4(parallel[3]),
    .D5(parallel[4]),
    .D6(parallel[5]),
    .D7(parallel[6]),
    .D8(parallel[7]),
    .OCE(clockDelay),
    .RST(reset),
    .SHIFTIN1(shift1),
    .SHIFTIN2(shift2),
    .T1(1'b0),
    .T2(1'b0),
    .T3(1'b0),
    .T4(1'b0),
    .TBYTEIN(1'b0),
    .TCE(1'b0)
    );
    
  OSERDESE2 #(.DATA_RATE_OQ("DDR"),
             .DATA_RATE_TQ("DDR"),
             .DATA_WIDTH(10),
             .INIT_OQ(1'b1),
             .INIT_TQ(1'b1),
             .SERDES_MODE("SLAVE"),
             .SRVAL_OQ(1'b0),
             .SRVAL_TQ(1'b0),
             .TBYTE_CTL("FALSE"),
             .TBYTE_SRC("FALSE"),
             .TRISTATE_WIDTH(1)
             )
  OSERDESE2_S(
    .OFB(),
    .OQ(),
    .SHIFTOUT1(shift1),
    .SHIFTOUT2(shift2),
    .TBYTEOUT(),
    .TFB(),
    .TQ(),
    .CLK(clkx5),
    .CLKDIV(clk),
    .D1(1'b0),
    .D2(1'b0),
    .D3(parallel[8]),
    .D4(parallel[9]),
    .D5(1'b0),
    .D6(1'b0),
    .D7(1'b0),
    .D8(1'b0),
    .OCE(clockDelay),
    .RST(reset),
    .SHIFTIN1(),
    .SHIFTIN2(),
    .T1(1'b0),
    .T2(1'b0),
    .T3(1'b0),
    .T4(1'b0),
    .TBYTEIN(1'b0),
    .TCE(1'b0)
    );
    
  
    
endmodule
