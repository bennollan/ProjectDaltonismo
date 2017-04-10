`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 04/09/2017 11:11:25 PM
// Design Name: 
// Module Name: MatrixMultiplyTest
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


module MatrixMultiplyTest();
    logic clk = 0;
    logic [15:0]matrix[16] = {1,1,1,1,
                              1,1,1,1,
                              1,1,1,1,
                              1,1,1,1};
    logic [15:0]vectorIn[4] = {1,2,3,4};
    logic [31:0]vectorOut[4];
    always #5 clk = !clk;
VectorMatrixMultiplier Multer(clk,vectorIn,matrix,vectorOut);
endmodule
