`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    08:44:51 09/30/2024 
// Design Name: 
// Module Name:    log_position_detector 
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
module log_position_detector(
		input clk,
		input valid_in,
		input [31:0] power_in ,
		output [4:0] position_integer,
		output [3:0] precision,
		output valid_out
    );
	////REGISTERS DEFINITIONS 
	reg [7:0] batch_4_or =0; // need to contain the or results of 4 bits in the power_in signal 
	reg [31:0] power_in_sample=0;
	reg [31:0] power_phase1=0;
	reg valid_in_sample=0;
	reg valid_phase1=0;
	reg [31:0] power_phase2=0;
	reg valid_phase2=0;
	reg [3:0] priority_approx_position=0;
	reg [3:0] priority_position_phase3=0;
	reg valid_phase3=0;
	reg [7:0] sliced_power =0;
	reg [4:0] least_msb=0;
	reg [4:0] correct_msb =0;
	reg valid_phase4=0;
	reg [3:0] precision_reg=0;
	/////////////////////////
	integer i;
///sample the power in order to stable the batch_4_or[i] in given clock cycle
	always @(posedge clk) begin
		if(valid_in) begin
			power_in_sample<=power_in;
			valid_in_sample<=valid_in;
		end
		else begin
			power_in_sample<=0;
			valid_in_sample<=0;
		end
	end
	//// preform bitwise or operation on each of the 4 bits of the power_in_sample operation  
	always @(posedge clk) begin
//			for(i=0;i<8;i=i+1) begin
//				batch_4_or[i]<=|power_in_sample[(i*4)+3:i*4];
//			end
			batch_4_or[0]<=|power_in_sample[3:0];
			batch_4_or[1]<=|power_in_sample[7:4];
			batch_4_or[2]<=|power_in_sample[11:8];
			batch_4_or[3]<=|power_in_sample[15:12];
			batch_4_or[4]<=|power_in_sample[19:16];
			batch_4_or[5]<=|power_in_sample[23:20];
			batch_4_or[6]<=|power_in_sample[27:24];
			batch_4_or[7]<=|power_in_sample[31:28];
			
			power_phase1<=power_in_sample;
			valid_phase1<=valid_in_sample;
	end
	//// find integer position phase
	always @(posedge clk) begin
		casex (batch_4_or)
			8'b1xxxxxxx : priority_approx_position<=8;
			8'b01xxxxxx : priority_approx_position<=7;
			8'b001xxxxx : priority_approx_position<=6;
			8'b0001xxxx : priority_approx_position<=5;
			8'b00001xxx : priority_approx_position<=4;
			8'b000001xx : priority_approx_position<=3;
			8'b0000001x : priority_approx_position<=2;
			8'b00000001 : priority_approx_position<=1;
			default: priority_approx_position<=0;
		endcase
		power_phase2<=power_phase1;
		valid_phase2<=valid_phase1;
		
		
	end

	////WE NOW HAVE THE APPROXIMATE POSITION WHERE OUR MSB IS 
	always @(posedge clk) begin
		case (priority_approx_position)
		8'd8: begin
				sliced_power<=power_phase2[31:24];
				least_msb<=28;
				end
		8'd7: begin
				sliced_power<=power_phase2[27:20];
				least_msb<=24;
				end
		8'd6: begin
				sliced_power<=power_phase2[23:16];
				least_msb<=20;
				end
		8'd5: begin
				sliced_power<=power_phase2[19:12];
				least_msb<=16;
				end
		8'd4: begin
				sliced_power<=power_phase2[15:8];
				least_msb<=12;
				end
		8'd3: begin
				sliced_power<=power_phase2[11:4];
				least_msb<=8;
				end
		8'd2: begin
				sliced_power<=power_phase2[7:0];
				least_msb<=4;
				end
		8'd1: begin
				sliced_power<={power_phase2[3:0],4'b0000};
				least_msb<=0;
				end
		default :begin 
					sliced_power<=0;
					least_msb<=0;
					end
		endcase
		priority_position_phase3<=priority_approx_position;
		valid_phase3<=valid_phase2;
	
	end
	//// in this stage we now have the approximate position and sliced power signal  
	always@(posedge clk) begin
		casex(sliced_power[7:4]) 
			4'b1xxx : begin 
						 correct_msb<=least_msb+3;
						 precision_reg<=sliced_power[6:3];
						 end
			4'b01xx : begin
						 correct_msb<=least_msb+2;
						 precision_reg<=sliced_power[5:2];
						 end
			4'b001x : begin
						 correct_msb<=least_msb+1;
						 precision_reg<=sliced_power[4:1];
						 end
			4'b0001 : begin
						 correct_msb<=least_msb;
						 precision_reg<=sliced_power[3:0];
						 end
			default :begin 
						correct_msb<=0;
						precision_reg<=0;
						end
		endcase 
		valid_phase4<=valid_phase3;
	end
	assign position_integer=correct_msb;
	assign valid_out=valid_phase4;
	assign precision=precision_reg;

endmodule
