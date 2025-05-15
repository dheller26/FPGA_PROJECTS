`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// This testbench will exercise both the UART Tx and Rx.
// It sends out byte 0xAB over the transmitter
// It then exercises the receive by receiving byte 0x3F
//////////////////////////////////////////////////////////////////////////////////


module uart_simple_tb();

parameter  PERIOD_NS = 100;// <==> 10MHZ 
parameter BAUD_RATE =9600 ;
parameter FREQ_HZ =10_000_000; 

parameter WAIT_DELAY= (FREQ_HZ /BAUD_RATE )*PERIOD_NS;

///register inputs 
reg clk =0;

//for uart tx 
reg i_tx_valid=0;
reg [7:0] tx_message=0;
wire tx_done;
wire tx_active;
wire tx_serial_data;
// for uart rx 
reg rx_serial=1;
wire [7:0] rx_byte;
wire rx_valid;

 // Takes in input byte and serializes it 
  task UART_WRITE_BYTE;
    input [7:0] i_Data;
    integer     ii;
    begin
       
      // Send Start Bit
      rx_serial <= 1'b0;
      #(WAIT_DELAY);
//      #(BAUD_RATE);
//      #1000;
       
       
      // Send Data Byte
      for (ii=0; ii<8; ii=ii+1)
        begin
          rx_serial <= i_Data[ii];
          #(WAIT_DELAY);
        end
       
      // Send Stop Bit
      rx_serial <= 1'b1;
      #(WAIT_DELAY);
     end
  endtask // UART_WRITE_BYTE
  
  uart_rx
    #( .BAUD_RATE(BAUD_RATE),
       .CLK_HZ(FREQ_HZ))
    uart_rx_inst
    (
    .source_clk(clk),
    .i_rx_serial(rx_serial),
    .o_rx_valid(rx_valid),
    .o_RX_message(rx_byte)
    );
    
  uart_tx
    #( .BAUD_RATE(BAUD_RATE),
       .CLK_HZ(FREQ_HZ))
    uart_tx_inst
    (
        .source_clk(clk),
        .i_tx_valid(i_tx_valid),
        .tx_message(tx_message),
        .tx_active(tx_active),
        .tx_serial(tx_serial_data),
        .done(tx_done)
    );
    always #(PERIOD_NS/2) clk<=!clk;
    
    initial
    begin
       
      // Tell UART to send a command (exercise Tx)
      @(posedge clk);
      @(posedge clk);
      i_tx_valid <= 1'b1;
      tx_message <= 8'hAB;
      @(posedge clk);
      i_tx_valid <= 1'b0;
      @(posedge tx_done);
       
      // Send a command to the UART (exercise Rx)
      @(posedge clk);
      UART_WRITE_BYTE(8'h3F);
      @(posedge clk);
             
      // Check that the correct command was received
      if (rx_byte == 8'h3F)
        $display("Test Passed - Correct Byte Received");
      else
        $display("Test Failed - Incorrect Byte Received");
       
    end
   
endmodule

