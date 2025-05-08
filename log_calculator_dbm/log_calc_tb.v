`timescale 1ns / 1ps

////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer:
//
// Create Date:   13:09:40 09/30/2024
// Design Name:   log_calc
// Module Name:   /home/vboxuser/fpga_proj/fpga/log_calculator/log_calc_tb.v
// Project Name:  log_calculator
// Target Device:  
// Tool versions:  
// Description: 
//
// Verilog Test Fixture created by ISE for module: log_calc
//
// Dependencies:
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
////////////////////////////////////////////////////////////////////////////////

module log_calc_tb;

	// Inputs
	reg clk=0;
	reg valid_in=0;
	reg [31:0] power=0;

	// Outputs
	wire valid_out;
	wire [31:0] dbm_value;

	// Instantiate the Unit Under Test (UUT)
	log_calc uut (
		.clk(clk), 
		.valid_in(valid_in), 
		.power(power), 
		.valid_out(valid_out), 
		.dbm_value(dbm_value)
	);
	// Clock generation
   always #5 clk = ~clk;  // 10 ns clock period (100 MHz clock)
	
	initial begin
        // Start the test
        valid_in = 1;  // Set valid input high to start processing
        
        // Apply stimuli: Increment power every clock cycle
        repeat(5000) begin  // Adjust the number of cycles as needed (currently runs for 50 cycles)
            @(posedge clk);  // Wait for the rising edge of the clock
            //power = power + 1;  // Increment power by 1
				//power={{16{1'b0}},16'd32760};
				power=32'd1_073_217_600;
        end

        // Deactivate valid_in after the stimulus ends
        valid_in = 0;

        // Finish the simulation
        #50;  // Wait for 50 ns for outputs to stabilize
        $stop;  // Stop the simulation

	end
      
endmodule

