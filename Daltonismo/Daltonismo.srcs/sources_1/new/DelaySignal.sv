`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: DigiPen Institute of Technology
// Engineer: Ben Nollan
//           Cody Anderson
// 
// Module Name: DelaySignal
// Project Name: Daltonismo
// Target Devices: Digilent Nexys Video
// Tool Versions: Vivado 2015.4
// Description: Delays Signal for a number of clock cycles
// 
//////////////////////////////////////////////////////////////////////////////////

module DelaySignal(
      clk,
      dataIn,
      dataOut
      );
  parameter DATA_WIDTH = 1;
  parameter DELAY_CYCLES = 1;
  
  input clk;
  input [DATA_WIDTH - 1:0]dataIn;
  output logic [DATA_WIDTH - 1:0]dataOut;
  
  logic [DATA_WIDTH - 1:0]delayReg[DELAY_CYCLES];
  assign delayReg[0] = dataIn;
  logic [8:0]i;
  always@(posedge clk)
  begin
    for(i=1; i < DELAY_CYCLES; i=i+1)
    begin
      delayReg[i] <= delayReg[i-1];
    end
    dataOut <= delayReg[DELAY_CYCLES - 1];
  end

endmodule


