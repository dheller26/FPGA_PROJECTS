`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: private project 
// Engineer: DROR HELLER 
// 
// Create Date: 05/14/2025 12:49:07 PM
// Design Name: 
// Module Name: uart_tx
// Project Name: 
// Target Devices: NEXYS A7 
// Tool Versions: 2021-2024
// Description: 
// This module handle recived data from python script or PUTTY
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////

module uart_tx
    #(parameter BAUD_RATE=9600,
      parameter CLK_HZ=10_000_000)
    (
        input source_clk,
        input i_tx_valid,
        input [7:0] tx_message,
        output tx_active,
        output tx_serial,
        output done
    );
    
     // Set Parameter CLKS_PER_BIT as follows:
    // CLKS_PER_BIT = (Frequency of i_Clock)/(Frequency of UART)
    // Example: 10 MHz Clock, 115200 baud UART(BAUD RATE OF 9600 MEANS 9600 BITS PER SECOND)
    // (10000000)/(115200) = 87
  
    localparam CLKS_PER_BIT= CLK_HZ/BAUD_RATE;
    
    //state machine parameters 
    localparam s_IDLE = 3'b000;
    localparam  s_START_BIT = 3'b001;
    localparam  s_DATA_BITS = 3'b010;
    localparam s_STOP_BIT = 3'b011;
    localparam  s_CLEANUP = 3'b100;
    //   start+8bit+stop 
    //--\______________/----
    reg [2:0] states =s_IDLE ;
    reg [$clog2(CLKS_PER_BIT)-1:0] clock_count=0;
    reg [2:0] bit_index =0;
    reg [7:0] tx_byte=0;
    reg       tx_done=0;
    reg       tx_active_reg=0;
    reg tx_serial_reg=1'b1;
    
    always@(posedge source_clk ) begin 
        case(states) 
            s_IDLE : ///wait to recieve DATA VALID 
                begin
                    tx_serial_reg<=1'b1;
                    tx_done <=1'b0;
                    clock_count <=0;
                    if(i_tx_valid) begin
                        states <=s_START_BIT ;
                        tx_active_reg <=1'b1;
                        tx_byte <=tx_message;
                    end else begin
                        states <=s_IDLE ;
                    end 
                end
           s_START_BIT : /// send to start bit toggle it to 0 
                begin
                    tx_serial_reg<=1'b0;
                    
                    //wait for CLKS_PER_BIT 
                    if(clock_count < CLKS_PER_BIT -1) begin
                        clock_count <=clock_count +1;
                        states <=s_START_BIT ;
                    end else begin
                        clock_count <=0;
                        states <=s_DATA_BITS ;
                    end
                
                end
           s_DATA_BITS : 
                begin
                    tx_serial_reg<= tx_byte[bit_index];
                    
                    if(clock_count <CLKS_PER_BIT -1) begin
                        clock_count <= clock_count +1;
                        states <= s_DATA_BITS  ;
                    end else begin
                        clock_count <=0;             
                        if(bit_index <7) begin
                            bit_index <=bit_index +1;
                            states <= s_DATA_BITS ;
                        end else begin 
                            bit_index <=0;
                            states <=s_STOP_BIT ;
                        end
                    
                    end 
                end
                
          s_STOP_BIT : 
                begin 
                    tx_serial_reg<=1'b1;
                    //wait for CLKS_PER_BIT 
                    if(clock_count < CLKS_PER_BIT -1) begin
                        clock_count <=clock_count +1;
                        states <=s_STOP_BIT  ;
                    end else begin
                        clock_count <=0;
                        states <=s_CLEANUP ;
                        tx_done <=1'b1;
                        tx_active_reg<=1'b0;
                    end
 
                end
          s_CLEANUP : 
                begin
                    states <=s_IDLE ;
                    tx_done <=1'b0;
                end
        endcase
        

    end
        assign tx_active=tx_active_reg;
        assign done=tx_done;
        assign tx_serial=tx_serial_reg;    
    
endmodule
