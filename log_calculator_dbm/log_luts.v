`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    11:23:35 09/30/2024 
// Design Name: 
// Module Name:    log_luts 
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
module log_luts(
		input clk,
		input valid_in,
		input [4:0] position_integer,
		input [3:0] precision,
		output valid_out,
		output [31:0] power_scaled
    );
	 integer file=0;
	 reg [31:0] integer_ROM [31:0];
	 reg [31:0] precision_ROM [0:15];
	 
	 reg [31:0] main_value=0;
	 reg [31:0] fine_value=0;
	 reg [31:0] correct_solution=0;
	 reg pipline1_valid=0;
	 reg pipline2_valid=0;

	 
	 initial begin
	 file =$fopen("/home/vboxuser/fpga_proj/fpga/usrp3/top/b2xxmini/b205_sahar_userset_db/integer_lut_no_square.txt","r");
	 $readmemh("/home/vboxuser/fpga_proj/fpga/usrp3/top/b2xxmini/b205_sahar_userset_db/integer_lut_no_square.txt",integer_ROM);
	 $fclose(file);
	 
	 file =$fopen("/home/vboxuser/fpga_proj/fpga/usrp3/top/b2xxmini/b205_sahar_userset_db/precision_lut_no_square.txt","r");
	 $readmemh("/home/vboxuser/fpga_proj/fpga/usrp3/top/b2xxmini/b205_sahar_userset_db/precision_lut_no_square.txt",precision_ROM);
	 $fclose(file);
	 
	 end
	 
	 always @(posedge clk) begin
		if(valid_in) begin
			main_value<=integer_ROM[position_integer];
			fine_value<=precision_ROM[precision];
			pipline1_valid<=valid_in;
		end
		else begin
			main_value<=0;
			fine_value<=0;
			pipline1_valid<=0;
		end
	 end
	 
	 always @(posedge clk) begin
		correct_solution<=main_value+fine_value;
		pipline2_valid<=pipline1_valid;
	 end
	 
	 assign valid_out=pipline2_valid;
	 assign power_scaled=correct_solution;


endmodule
