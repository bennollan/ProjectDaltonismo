`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: DigiPen Institute of Technology
// Engineer: Ben Nollan
//           Cody Anderson
// 
// Module Name: edid_rom
// Project Name: Daltonismo
// Target Devices: Digilent Nexys Video
// Tool Versions: Vivado 2015.4
// Description: Acts as an I2c slave for monitor Identification data.
// 
// 
//////////////////////////////////////////////////////////////////////////////////

module edid_rom( 
          input logic clk,
          input logic sclk_raw,
          inout logic sdat_raw
  );



   logic [7:0]edid_rom[0:255] = {
      //// BASE EDID Bytes 0 to 35 ////////////////////
      // Header
      8'h00,8'hFF,8'hFF,8'hFF,8'hFF,8'hFF,8'hFF,8'h00,
      // EISA ID - Manufacturer, Product,
      8'h04,8'h43, 8'h07,8'hf2, 
      // EISA ID -Serial
      8'h01,8'h00,8'h00,8'h00,
      // Model/year
      8'hFF, 8'h11,
      // EDID Version
      8'h01, 8'h04,
      //////////////////////////////////////
      //////////////////////////////////////
      // Digital Video using DVI, 8 bits
      //    8'h81,   // Checksum 0xB6 
      //////////////////////////////////////
      // Digital Video using HDMI, 8 bits
      8'hA2, // Checksum 0x95 
      // ////////////////////////////////////
      // Aspect ratio, flag, gamma
      8'h4f, 8'h00, 8'h78, 
      //////////////////////////////////////      
      // Features 
      8'h3E,
      // Display x,y Chromaticity V Breaks here!
      8'hEE, 8'h91, 8'ha3, 8'h54, 8'h4c, 8'h99, 8'h26, 8'h0f, 8'h50, 8'h54,
      // Established timings
      8'h20, 8'h00, 8'h00,
      // Standard timings
      8'h01, 8'h01, 8'h01, 8'h01, 8'h01, 8'h01, 8'h01, 8'h01, 
      8'h01, 8'h01, 8'h01, 8'h01, 8'h01, 8'h01, 8'h01, 8'h01, 
      /////////// End of BASE EDID ////////////////////////////

      ///// 18 byte data block 1080p //////
      // Pixel clock
      8'h02,8'h3A,
      // Horizontal 1920 with 280 blanking
      8'h80, 8'h18, 8'h71,
      // Vertical 1080 with 45 lines blanking
      8'h38, 8'h2D, 8'h40,
      // Horizontal front porch
      8'h58,8'h2C,
      // Vertical front porch
      8'h04,8'h05,
      // Horizontal and vertical image size
      8'h0f, 8'h48, 8'h42,
      // Horizontal and vertical boarder
      8'h00, 8'h00,
      // Options (non-interlaces, not 3D, syncs...)
      8'h1E,

      ///// 18 byte data block 1080i /////////
      // Pixel clock
      8'h01,8'h1D,
      // Horizontal 1920 with 280 blanking
      8'h80, 8'h18, 8'h71,
      // Vertical 1080 with 45 lines blanking
      8'h1C, 8'h16, 8'h20,
      // Horizontal front porch
      8'h58,8'h2C,
      // Vertical front porch // SEEMS WRONG!
      8'h25,8'h00,
      // Horizontal and vertical image size
      8'h0f, 8'h48, 8'h42,
      // Horizontal and vertical boarder
      8'h00, 8'h00,
      // Options (non-interlaces, not 3D, syncs...)
      8'h9E,

      ///// 18 byte data block 720p ////////
      // Pixel clock
      8'h01,8'h1D,
      // Horizontal 1920 with 280 blanking
      8'h00, 8'h72, 8'h51,
      // Vertical 1080 with 45 lines blanking
      8'hD0, 8'h1E, 8'h20,
      // Horizontal front porch
      8'h6E,8'h28,
      // Vertical front porch
      8'h55,8'h00,
      // Horizontal and vertical image size
      8'h0f, 8'h48, 8'h42,
      // Horizontal and vertical boarder
      8'h00, 8'h00,
      // Options (non-interlaces, not 3D, syncs...)
      8'h1E,

      ///// 18 byte data block 720p //////
      // Monitor name ASCII descriptor
      8'h00, 8'h00, 8'h00, 8'hFC, 8'h00,
      // ASCII name - Daltonismo
      8'h44, 8'h61, 8'h6C, 8'h74, 8'h6F, 8'h6E, 8'h69, 8'h73,
      8'h6D, 8'h6F, 8'h20, 8'h20, 8'h20,

      /////// End of EDID block
      // Extension flag & checksum
      8'h01, 8'h16,
      
       8'h02, 8'h03, 8'h18, 8'h72, 8'h47, 8'h90, 8'h85, 8'h04, 8'h03, 8'h02, 8'h07, 8'h06, 8'h23, 8'h09, 8'h07, 8'h07,
       8'h83, 8'h01, 8'h00, 8'h00, 8'h65, 8'h03, 8'h0C, 8'h00, 8'h10, 8'h00, 8'h8E, 8'h0A, 8'hD0, 8'h8A, 8'h20, 8'hE0,
       8'h2d, 8'h10, 8'h10, 8'h3E, 8'h96, 8'h00, 8'h1F, 8'h09, 8'h00, 8'h00, 8'h00, 8'h18, 8'h8E, 8'h0A, 8'hD0, 8'h8A,
       8'h20, 8'hE0, 8'h2D, 8'h10, 8'h10, 8'h3E, 8'h96, 8'h00, 8'h04, 8'h03, 8'h00, 8'h00, 8'h00, 8'h18, 8'h8E, 8'h0A,
       8'hA0, 8'h14, 8'h51, 8'hF0, 8'h16, 8'h00, 8'h26, 8'h7C, 8'h43, 8'h00, 8'h1F, 8'h09, 8'h00, 8'h00, 8'h00, 8'h98,
       8'h8E, 8'h0A, 8'hA0, 8'h14, 8'h51, 8'hF0, 8'h16, 8'h00, 8'h26, 8'h7C, 8'h43, 8'h00, 8'h04, 8'h03, 8'h00, 8'h00,
       8'h00, 8'h98, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00,
       8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'hC9
      
      };

   logic [2:0]sclk_delay;
   logic [6:0]sdat_delay;
   
   typedef enum logic   [5:0]{state_idle, 
                     // States to support writing the device's address
                     state_start,
                     state_dev7,
                     state_dev6,
                     state_dev5,
                     state_dev4,
                     state_dev3,
                     state_dev2,
                     state_dev1,
                     state_dev0,
                     // States to support writing the address
                     state_ack_device_write,
                     state_addr7,
                     state_addr6,
                     state_addr5,
                     state_addr4,
                     state_addr3,
                     state_addr2,
                     state_addr1,
                     state_addr0,
                     state_addr_ack,
                     // States to support the selector device 
                     state_selector_ack_device_write,
                     state_selector_addr7,
                     state_selector_addr6,
                     state_selector_addr5,
                     state_selector_addr4,
                     state_selector_addr3,
                     state_selector_addr2,
                     state_selector_addr1,
                     state_selector_addr0,
                     state_selector_addr_ack,
                     // States to support reading from the the EDID ROM
                     state_ack_device_read,
                     state_read7,
                     state_read6,
                     state_read5,
                     state_read4,
                     state_read3,
                     state_read2,
                     state_read1,
                     state_read0,
                     state_read_ack}t_state;

   t_state state = state_idle;
   logic [7:0]data_out_sr     = 'hFF;
   logic [7:0]data_shift_reg  = 0;
   logic [7:0]addr_reg        = 0;
   logic [7:0]selector_reg    = 0;
   logic [7:0]data_to_send    = 0;
   logic [7:0]data_out_delay  = 0;
   logic sdat_input;
   logic sdat_delay_last = 0;

   assign sdat_raw = data_out_sr[7] ? 1'bz : 1'b0;
   assign sdat_input = sdat_raw;

always@(posedge clk)
   begin   
         // falling edge on SDAT while sclk is held high = START condition
         if (sclk_delay[1] == 1 && sclk_delay[0] == 1 && sdat_delay_last  == 1 && sdat_delay[6] == 0)
         begin
            state <= state_start;
         end
         
         // rising edge on SDAT while sclk is held high = STOP condition
         if (sclk_delay[1] == 1 && sclk_delay[0] == 1 && sdat_delay_last == 0 && sdat_delay[6] == 1)
         begin
            state <= state_idle;
            selector_reg <= 0;
         end

         // rising edge on SCLK - usually a data bit 
         if (sclk_delay[1] == 1 && sclk_delay[0] == 0)
         begin
            // Move data into a shift register
            data_shift_reg <= {data_shift_reg[6:0], sdat_delay[6]};
         end
         
         // falling edge on SCLK - time to change state
         if (sclk_delay[1] == 0 && sclk_delay[0] == 1)
         begin
            data_out_sr <= {data_out_sr[6:0], 1'b1}; // Add Pull up   
            case (state) 
               state_start:               state <= state_dev7;
               state_dev7:                state <= state_dev6;
               state_dev6:                state <= state_dev5;
               state_dev5:                state <= state_dev4;
               state_dev4:                state <= state_dev3;
               state_dev3:                state <= state_dev2;
               state_dev2:                state <= state_dev1;
               state_dev1:                state <= state_dev0;
               state_dev0:                begin
                                            if (data_shift_reg == 8'hA1)
                                            begin
                                              state <= state_ack_device_read;
                                              data_out_sr[7] <= 0; // Send Slave ACK
                                            end
                                            else if (data_shift_reg == 8'hA0)
                                            begin
                                              state <= state_ack_device_write;
                                              data_out_sr[7] <= 0; // Send Slave ACK
                                            end
                                            else if (data_shift_reg == 8'h60)
                                            begin
                                              state <= state_selector_ack_device_write;
                                              data_out_sr[7] <= 0; // Send Slave ACK
                                            end
                                            else
                                            begin
                                              state <= state_idle;
                                            end  
                                          end             
               state_ack_device_write:    state <= state_addr7;
               state_addr7:               state <= state_addr6;
               state_addr6:               state <= state_addr5;
               state_addr5:               state <= state_addr4;
               state_addr4:               state <= state_addr3;
               state_addr3:               state <= state_addr2;
               state_addr2:               state <= state_addr1;
               state_addr1:               state <= state_addr0;
               state_addr0:               begin
                                            state <= state_addr_ack;
                                            addr_reg  <= data_shift_reg;
                                            data_out_sr[7] <= 0; // Send Slave ACK
                                          end
               state_addr_ack:            state <= state_idle;   // SLave ACK and ignore any written data
                //////////////////////////////////////
                // Process the write to the selector
                //////////////////////////////////////
               state_selector_ack_device_write:    state <= state_selector_addr7;
               state_selector_addr7:               state <= state_selector_addr6;
               state_selector_addr6:               state <= state_selector_addr5;
               state_selector_addr5:               state <= state_selector_addr4;
               state_selector_addr4:               state <= state_selector_addr3;
               state_selector_addr3:               state <= state_selector_addr2;
               state_selector_addr2:               state <= state_selector_addr1;
               state_selector_addr1:               state <= state_selector_addr0;
               state_selector_addr0:               begin
                                                     state <= state_selector_addr_ack;
                                                     selector_reg  <= data_shift_reg[7:0];
                                                     data_out_sr[7] <= 0; // Send Slave ACK
                                                   end
               state_selector_addr_ack:            state <= state_idle;   // SLave ACK and ignore any written data

               state_ack_device_read:   begin
                                          state <= state_read7;
                                          data_out_sr <=  addr_reg;
                                        end
               state_read7:             state <= state_read6;
               state_read6:             state <= state_read5;
               state_read5:             state <= state_read4;
               state_read4:             state <= state_read3;
               state_read3:             state <= state_read2;
               state_read2:             state <= state_read1;
               state_read1:             state <= state_read0;
               state_read0:             state <= state_read_ack; 
               state_read_ack:          begin
                                          if (sdat_delay[6] == 0)
                                          begin 
                                            state <= state_read7;
                                            data_out_sr <=  edid_rom[addr_reg+1];
                                          end
                                          else 
                                            state <= state_idle;                   
                                          addr_reg <= addr_reg+1;
                                        end
               default:                 state <= state_idle;
            endcase
         end
        sdat_delay_last <= sdat_delay[6];
         // Synchronisers for SCLK and SDAT
         sclk_delay <= {sclk_raw , sclk_delay[2:1]};
         
         if (sdat_input == 0) 
         begin
            if (sdat_delay[6] == 1) 
                sdat_delay <= sdat_delay - 1;
            else
                sdat_delay <= 0;
         end
         else
         begin
            if (sdat_delay[6] == 0) 
                 sdat_delay <= sdat_delay + 1;
             else
                 sdat_delay <= ~0;

         end
      end

endmodule
