`timescale 1ns / 1ps


module fir_filter
#(
   parameter N1=8, //FIR COEFF WORD WIDTH
   parameter N2=16, //input data word width 
   parameter N3=32 // output data word width 
)
(
        input CLK,
        input RST,
        input ENABLE,
        input signed [N2-1:0] input_data,
        output signed [N3-1:0] filtered_data,
        output signed [N3-1:0] sample_T       
);

wire signed [N1-1:0] coeff[0:7];
reg signed [N3-1:0] output_data_reg;
reg signed [N2-1:0] samples[0:6];
//filter coefficents

assign coeff[0]=8'b0010000;
assign coeff[1]=8'b0010000;
assign coeff[2]=8'b0010000;
assign coeff[3]=8'b0010000;
assign coeff[4]=8'b0010000;
assign coeff[5]=8'b0010000;
assign coeff[6]=8'b0010000;
assign coeff[7]=8'b0010000;

always @(posedge CLK)
begin
    if(RST)begin
       samples[0]<=0;
       samples[1]<=0;
       samples[2]<=0;
       samples[3]<=0;
       samples[4]<=0;
       samples[5]<=0;
       samples[6]<=0;
       output_data_reg<=0;
    end 
    else if(ENABLE&&(!RST))
    begin
        output_data_reg<= coeff[0]*input_data
                          +coeff[1]*samples[0]
                          +coeff[2]*samples[1]
                          +coeff[3]*samples[2]
                          +coeff[4]*samples[3]
                          +coeff[5]*samples[4]
                          +coeff[6]*samples[5]
                          +coeff[7]*samples[6];
        samples[0]<=input_data;
        samples[1]<=samples[0];
        samples[2]<=samples[1];
        samples[3]<=samples[2];
        samples[4]<=samples[3];
        samples[5]<=samples[4];
        samples[6]<=samples[5];
    
    end

end

assign filtered_data=output_data_reg;
assign sample_T=samples[0];


endmodule
