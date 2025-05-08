`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    14:59:03 08/19/2024 
// Design Name: 
// Module Name:    FIFO_homemade 
// Project Name: 
// Target Devices: 
// Tool versions: 
// Description: 
//
// Dependencies: 
//
// Revision: 
// Revision 0.01 - File Created
// Additional Comments: 
//
//////////////////////////////////////////////////////////////////////////////////
module RAM #(parameter WIDTH=16, DEPTH=128)
	(
	//write signals 
	input                     i_Wr_Clk,
	input [$clog2(DEPTH)-1:0] i_Wr_Addr,
	input                     i_Wr_DV,
	input [WIDTH-1:0]         i_Wr_Data,
	//Read signals 
	input                     i_Rd_Clk,
	input [$clog2(DEPTH)-1:0] i_Rd_Addr,
	input                     i_Rd_En,
	output reg                o_Rd_DV=0,
	output reg [WIDTH-1:0]    o_Rd_Data=0
	
    );
		  // Declare the Memory variable
	  reg [WIDTH-1:0] r_Mem[DEPTH-1:0];
	  integer i;

	  initial begin
		for(i=0;i<=(DEPTH-1);i=i+1) begin
			r_Mem[i]=32'h00000000;
		end
	  end
	  
	  // Handle writes to memory
	  always @ (posedge i_Wr_Clk)
	  begin
		 if (i_Wr_DV)
		 begin
			r_Mem[i_Wr_Addr] <= i_Wr_Data;
		 end
	  end

	  // Handle reads from memory
	  always @ (posedge i_Rd_Clk)
	  begin
		if(i_Rd_En) begin
		 o_Rd_Data <= r_Mem[i_Rd_Addr];
		 o_Rd_DV   <= i_Rd_En;
		end
		else begin
		 o_Rd_Data <= 0;
		 o_Rd_DV   <= i_Rd_En;
		end
	  end


endmodule
