`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    16:09:00 08/19/2024 
// Design Name: 
// Module Name:    FFT_shift 
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

`define POWER_SHIFT
//`define IQ_SHIFT

module FFT_shift(
		input clk,
		input rst,
		input valid_in,
		`ifdef IQ_SHIFT
			input [15:0] I_in,
			input [15:0] Q_in,
		`elsif POWER_SHIFT
			input [31:0] power_in,
		`endif
		
		input [12:0] fft_index,
		
		`ifdef IQ_SHIFT
			output wire [15:0] I_out,
			output wire [15:0] Q_out,
		`elsif POWER_SHIFT
			output wire [31:0] power_out,
		`endif
		
		output wire valid_out,
		output wire [12:0] fft_index_out
    );
	 
	 
	 
	 localparam FFT_SIZE=8192;
	 localparam SHIFT_SIZE=4000;
	 localparam GAP_SIZE=FFT_SIZE-2*SHIFT_SIZE; //192
	 localparam BIN_NUM=FFT_SIZE-GAP_SIZE; // 8000
	 localparam RAM_SIZE=(FFT_SIZE-GAP_SIZE)*2;//16000
	 localparam PHASE_FIRST=0 , PHASE_SECOND=1;

	 
	 reg wr_valid=0;
	 wire rd_valid;
	 reg [$clog2(RAM_SIZE)-1:0] write_addr=0;
	 reg [$clog2(RAM_SIZE)-1:0] read_addr=0;
	 
	 `ifdef IQ_SHIFT
		reg [15:0] w_data_I=0;
		reg [15:0] w_data_Q=0;
	 `elsif POWER_SHIFT
		reg [31:0] w_data_power=0;
	 `endif
	 
	 reg [$clog2(BIN_NUM)-1:0] w_xk=0;
	 reg [$clog2(BIN_NUM)-1:0] start_counter=0; 
	 reg [$clog2(BIN_NUM*2)-1:0] phase_counter=0;
	 
	 `ifdef IQ_SHIFT
		wire valid_out_I;
		wire valid_out_Q;
	 `elsif POWER_SHIFT
		wire valid_out_power;
	 `endif
	 
	 wire valid_out_idx;
	 reg rd_start=0;
	 reg phase_write=PHASE_FIRST;
	 
	 `ifdef IQ_SHIFT
		assign valid_out=valid_out_I&&valid_out_Q;//&valid_out_idx;
	 `elsif POWER_SHIFT
		assign valid_out=valid_out_power&valid_out_idx;
	 `endif
	 
	 
	 always @(posedge clk or posedge rst) begin
		if(rst) begin
			wr_valid<=0;
			write_addr<=SHIFT_SIZE;
			`ifdef IQ_SHIFT
				w_data_I<=0;
				w_data_Q<=0;
			`elsif POWER_SHIFT
				w_data_power<=0;
			`endif
			w_xk<=0;
			start_counter<=0;
			phase_counter<=0;
			rd_start<=0;

		end
		else begin
			if(valid_in) begin
				//check fft_index range 
				if(fft_index<=(SHIFT_SIZE-1)) begin //fft_index>=0 and fft_index<=49
					if(phase_write==PHASE_FIRST)
						write_addr<=fft_index+SHIFT_SIZE;// write addr - 50:99 
					else
						write_addr<=fft_index+SHIFT_SIZE*3;//write addr - 150:199 	
				end
				else begin //fft_index>=78 and fft_index<=127
					if(phase_write==PHASE_FIRST)
						write_addr<=fft_index-SHIFT_SIZE-GAP_SIZE;//write addr - 0:49  
					else
						write_addr<=fft_index-GAP_SIZE+SHIFT_SIZE;//write addr - 100:149
				end
				
				`ifdef IQ_SHIFT
					w_data_I<=I_in;
					w_data_Q<=Q_in;
				`elsif POWER_SHIFT
					w_data_power<=power_in;
				`endif
				
				w_xk<=fft_index;
				wr_valid<=valid_in;
				
				// check to which part of buffer we read 
				if(phase_counter<(BIN_NUM-1)) begin //phase < 99
					phase_write<=PHASE_FIRST;
					phase_counter<=phase_counter+1;
				end 
				else if (phase_counter<(2*BIN_NUM-1)) begin //phase < 199
					phase_write<=PHASE_SECOND;
					phase_counter<=phase_counter+1;
				end
				else begin 
					phase_write<=PHASE_FIRST;
					phase_counter<=0;
				end
				
				if(start_counter <(2*SHIFT_SIZE-1)) begin
					start_counter<=start_counter+1;
				end
				else begin
					rd_start<=1;
				end
				
		  end
		  else begin
			wr_valid<=valid_in;
			`ifdef IQ_SHIFT
				w_data_I<=0;
				w_data_Q<=0;
			`elsif POWER_SHIFT
				w_data_power<=0;
			`endif
			w_xk<=0;
		  end
	 end
	 end
	 
	 
	 always @(posedge clk) begin
		if(rd_start & valid_in) begin
			if(read_addr<(4*SHIFT_SIZE-1))
				read_addr<=read_addr+1;
			else
				read_addr<=0;
		end
		
	  end
		
	 assign rd_valid=rd_start&&valid_in;

	`ifdef IQ_SHIFT
		  RAM #(.WIDTH(16), .DEPTH(RAM_SIZE)) FIFO_I 
		 (// Write Port
		  .i_Wr_Clk(clk),   
		  .i_Wr_Addr(write_addr),
		  .i_Wr_DV(wr_valid),
		  .i_Wr_Data(w_data_I),
		  // Read Port
		  .i_Rd_Clk(clk),
		  .i_Rd_Addr(read_addr),
		  .i_Rd_En(rd_valid),
		  .o_Rd_DV(valid_out_I),
		  .o_Rd_Data(I_out)
		  );
		  
			RAM #(.WIDTH(16), .DEPTH(RAM_SIZE)) FIFO_Q 
		 (// Write Port
		  .i_Wr_Clk(clk),   
		  .i_Wr_Addr(write_addr),
		  .i_Wr_DV(wr_valid),
		  .i_Wr_Data(w_data_Q),
		  // Read Port
		  .i_Rd_Clk(clk),
		  .i_Rd_Addr(read_addr),
		  .i_Rd_En(rd_valid),
		  .o_Rd_DV(valid_out_Q),
		  .o_Rd_Data(Q_out)
		  );
	`elsif POWER_SHIFT
		  RAM #(.WIDTH(32), .DEPTH(RAM_SIZE)) FIFO_power 
		 (// Write Port
		  .i_Wr_Clk(clk),   
		  .i_Wr_Addr(write_addr),
		  .i_Wr_DV(wr_valid),
		  .i_Wr_Data(w_data_power),
		  // Read Port
		  .i_Rd_Clk(clk),
		  .i_Rd_Addr(read_addr),
		  .i_Rd_En(rd_valid),
		  .o_Rd_DV(valid_out_power),
		  .o_Rd_Data(power_out)
		  );	
	
	`endif
	`define DEBUG;
	`ifdef DEBUG
	 RAM #(.WIDTH(13), .DEPTH(RAM_SIZE)) FIFO_xk 
    (// Write Port
     .i_Wr_Clk(clk),   
     .i_Wr_Addr(write_addr),
     .i_Wr_DV(wr_valid),
     .i_Wr_Data(w_xk),
     // Read Port
     .i_Rd_Clk(clk),
     .i_Rd_Addr(read_addr),
     .i_Rd_En(rd_valid),
     .o_Rd_DV(valid_out_idx),
     .o_Rd_Data(fft_index_out)
     );
	`endif


endmodule

