`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: private project 
// Engineer: DROR HELLER 
// 
// Create Date: 05/14/2025 12:49:07 PM
// Design Name: 
// Module Name: uart_rx
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


module uart_rx
    #(parameter BAUD_RATE,
      parameter CLK_HZ)
    (
    input source_clk,
    input i_rx_serial,
    output o_rx_valid,
    output [7:0] o_RX_message
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
    
    // initialized to 1 because start bit need to toggle to 0 in order to start recieving
    reg rx_data_reg=1'b1;  // temp register for metastability reasons 
    reg rx_data =1'b1; 
    
    reg [$clog2(CLKS_PER_BIT)-1:0] clock_count =0;
    reg [2:0] bit_index = 0 ; // for 8 bits message 
    reg [7:0] rx_byte=0;
    reg       rx_valid =0;
    reg [2:0] states =s_IDLE ;
    
    // using double flip_flop in order to deal with metastability problem incoming from external data 
    always @(posedge source_clk) begin
        rx_data_reg<=i_rx_serial;
        rx_data<=rx_data_reg;
    end
    
    always @(posedge source_clk) begin
        
        case (states)
        s_IDLE :
                begin 
                    rx_valid<=0;
                    clock_count<=0;
                    bit_index<=0;
                    if(rx_data==1'b0) //we detected start bit 1->0 
                    begin
                        states<=s_START_BIT ;
                    end else begin
                        states <=s_IDLE ;
                    end
                end
        s_START_BIT :
                begin 
                    rx_valid<=0;
                    bit_index<=0;
                    if(clock_count ==(CLKS_PER_BIT -1)/2) //need to get to the middle of the bit 
                    begin
                        if(rx_data ==1'b0) begin// need to asser that the when we get to the middle of the bit we still in 0 
                            clock_count <=0;
                            states <=s_DATA_BITS ;
                        end
                        else begin
                            clock_count <=0;
                            states<=s_IDLE ;
                        end
                    end else begin 
                        clock_count<=clock_count+1;
                        states<=s_START_BIT ;
                    end
                end
         s_DATA_BITS :
                begin 
                   rx_valid<=0;
                   if(clock_count <CLKS_PER_BIT -1)begin
                    clock_count <=clock_count +1;
                    states <=s_DATA_BITS ;
                   end 
                   else begin
                    clock_count <=0;
                    rx_byte [bit_index] <= rx_data;
                    if(bit_index<7) begin 
                       bit_index <=bit_index +1;
                       states <=s_DATA_BITS ; 
                    end else begin
                        bit_index <=0;
                        state<=s_STOP_BIT ;
                    end                    
                   end                
                end 
       s_STOP_BIT : ///preapre to recive the stop bit 
                   begin
                    if(clock_count <CLKS_PER_BIT -1)begin
                        clock_count<=clock_count+1;
                        states <=s_STOP_BIT ;
                    end else begin
                        rx_valid <=1'b1;
                        clock_count <=0;
                        states <=s_CLEANUP ;
                    end 
                   end
       s_CLEANUP : 
                   begin 
                    rx_valid <=1'b0;
                    states <=s_IDLE ;
                   end 
        
        default:
                states <=s_IDLE ;
        
        endcase
        
        assign o_rx_valid =rx_valid;
        assign o_RX_message =rx_byte;
        
    end
    
endmodule
