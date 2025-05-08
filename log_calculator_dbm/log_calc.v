`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    12:56:04 09/30/2024 
// Design Name: 
// Module Name:    log_calc 
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
module log_calc(
	input clk,
	input valid_in,
	input [31:0] power,
	output valid_out,
	output [31:0] dbm_value
    );
	 
	 wire [4:0] position_integer;
	 wire [3:0] precision;
	 wire valid_detector;
	 
	 
	 log_position_detector log_position_detector(
		.clk(clk),
		.valid_in(valid_in),
		.power_in(power) ,
		.position_integer(position_integer),
		.precision(precision),
		.valid_out(valid_detector)
    );
	 
	 log_luts log_luts(
		.clk(clk),
		.valid_in(valid_detector),
		.position_integer(position_integer),
		.precision(precision),
		.valid_out(valid_out),
		.power_scaled(dbm_value)
    );


endmodule
