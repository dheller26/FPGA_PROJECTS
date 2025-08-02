`timescale 1ns / 1ps


module fir_tb();

   parameter N1=8; //FIR COEFF WORD WIDTH
   parameter N2=16; //input data word width 
   parameter N3=32;// output data word width 
   
   reg CLK;
   reg RST;
   reg ENABLE;
   
   reg [N2-1:0] input_data;
   
   reg [N2-1:0] data [99:0];
   wire [N3-1:0] output_data;
   wire [N2-1:0] sample_T;
   
   fir_filter #(.N1(N1),.N2(N2),.N3(N3)) 
              DUT (.CLK(CLK),
                   .RST(RST),
                   .ENABLE(ENABLE),
                   .input_data(input_data),
                   .filtered_data(output_data),
                   .sample_T(sample_T));
   
   
   integer k;
   integer FILE_IN;
   integer FILE_OUT;
   
   always #10 CLK=~CLK;
   
   initial begin
    k=0;
//    FILE_IN=$fopen("input_signal.txt","r");
    $readmemb("D:/fpga_dror/fir_filter_implementation/input_signal.txt",data);
    $display("try to read from file ");
//    $fclose(FILE_IN);
    FILE_OUT=$fopen("filtered.txt","w");
    //reset phase 
    CLK=0;
    #20
    RST=1'b1;
    #40
    //enable the filter 
    RST=1'b0;
    ENABLE=1'b1;
    input_data<=data[0];
    #10
    for(k=1;k<100;k=k+1)
    begin
        @(posedge CLK);
        $fdisplay(FILE_OUT,"%b",output_data);
        input_data<=data[k];
        if(k==99) begin
            $fclose(FILE_OUT);
        end   
    end
    
   
   
   
   
   end
   
                   
   
endmodule
