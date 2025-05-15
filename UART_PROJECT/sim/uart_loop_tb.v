`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// This testbench will exercise both the UART Tx and Rx on LOOPBACK MODE
//////////////////////////////////////////////////////////////////////////////////


module uart_loop_tb();

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
wire rx_serial;
wire [7:0] rx_byte;
wire rx_valid;

assign rx_serial = tx_serial_data ;
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
      
      // Wait until TX is done

      //@(posedge tx_done);
       
       // Wait for RX to finish receiving
      wait (rx_valid == 1'b1);
      @(posedge clk);  // Wait for stable rx_byte
    
      // Check that the correct command was received
      if (rx_byte == 8'hAB)
        $display("Test Passed - Correct Byte Received");
      else
        $display("Test Failed - Incorrect Byte Received");
       
    end
   
endmodule

