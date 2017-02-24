module UartTransmit(input clk, newData, [7:0]dataIn, 
            output logic tx = 1, done = 1
            );

parameter BAUD_RATE = 250_000;
parameter CLOCK_DIVIDE = 100_000_000/BAUD_RATE;


logic [26:0]divider = 0;

always_ff@(posedge clk)
begin
  static logic [7:0]internalData = 0;
  static logic[9:0] tempData = 0;

  //if module is not sending and new data has been loaded in
  if(newData && done == 1)
  begin
    tempData <= {1'b1, dataIn, 1'b0};
    done <= 0;
  end
  //if module is currently transmitting
  if(!done && divider < CLOCK_DIVIDE - 1)
    divider <= divider + 1;
  else
  begin
    divider <= 0;
    if(tempData != 0)
    begin
      tx <= tempData[0];
      if(tempData == 1)
        done <= 1;
      tempData <= tempData >> 1;
    end
  end
end

endmodule

module UartReceive(input clk, readData, rx,  
            output logic ready = 1, [7:0]dataOut
            );

parameter BAUD_RATE = 250_000;
parameter CLOCK_DIVIDE = 100_000_000/BAUD_RATE;

logic [26:0]divider = 0;
logic prevReceive;
logic receiving = 0;
logic [8:0]internalData = ~9'b0;
always_ff@(posedge clk)
begin
  if(readData)
    ready <= 0;

  if(prevReceive && !rx && !receiving)
  begin
    receiving <= 1;
    divider <= CLOCK_DIVIDE/2;
  end
      
  if(divider && divider < CLOCK_DIVIDE)
    divider <= divider + 1;
  else
  begin
    divider <= 1;
    if(internalData[0])
      internalData <= {rx,internalData[8:1]};
    else
    begin
      dataOut <= internalData[8:1];
      internalData <= ~9'b0;
      ready <= 1;
      receiving <= 0;
      divider <= 0;
    end
  end
end
endmodule

module MatrixReceiver(
        input clk, rx, 
        output tx, logic[NUMBER_OF_BITS-1:0] matrix [9] =  {65536,0,0,
                                                            0,65536,0,
                                                            0,0,65536}
        );

parameter NUMBER_OF_BITS = 32;

logic [7:0] UARTbyte;
logic readData = 0;
logic ready;
logic [9:0] superCase = 0;
logic [3:0] matrixIterator = 0;

UartReceive RX(clk, readData, rx, ready, UARTbyte);
UartTransmit TX(clk, ready, UARTbyte, tx,  );

always_ff @(posedge clk)
begin
  if(ready && readData == 0)
  begin
    readData <= 1;

    casez(superCase)
      0 :begin
          if(UARTbyte == "0") 
            superCase <= superCase + 1;
          else if(UARTbyte == "\r" || UARTbyte == "\n")
            matrixIterator <= 0;
        end

      1 :begin
          if(UARTbyte == "x") 
          begin
            superCase <= superCase + 1;
            matrix[matrixIterator] <= 0;
          end
          else 
            superCase <= 0;
        end

      2 :begin
          if(UARTbyte >= "0" && UARTbyte <= "9")
            matrix[matrixIterator] <= (matrix[matrixIterator] << 4) | (UARTbyte - "0");
          else if(UARTbyte >= "A" && UARTbyte <= "F")
            matrix[matrixIterator] <= (matrix[matrixIterator] << 4) | (UARTbyte - ("A" - 10));
          else
          begin
            superCase <= 0;
            matrixIterator <= matrixIterator + 1;
          end
        end

      default: superCase <= 0;

    endcase

  end
  else
    readData <= 0;
end


endmodule