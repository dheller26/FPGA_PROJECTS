`timescale 1ns / 1ps

module sdram_init(
    input sys_clk,
    input sys_rst_n,
    output reg [3:0] init_cmd_out, ///SDRAM command
    output reg [1:0] init_bank_out, ///bank selection
    output reg [11:0] init_addr_out, /// Address output
    output wire init_done
    );
    
    //// we know we need to apply delay of 150usec
    ///150e-6/10e-9=15000 => log(15000)/log(2) = 13.86=14bits
    parameter count_power_on=14'd15000;
    wire power_on_wait_done;
    reg [$clog2(count_power_on)-1:0] count_150us;// counter to keep track of 150us period
    
    always @(posedge sys_clk or negedge sys_rst_n) begin
        if(sys_rst_n==1'b0)
           count_150us<=1'b0;
        else if(count_150us==count_power_on)
           count_150us<=1'b0;
        else 
            count_150us<=count_150us+1'b1;
    end
    
    
    ////compelition of a 150us power-up wait required for SDRAM initialization
    assign power_on_wait_done=(count_150us==count_power_on) ? 1'b1 : 1'b0;
    
    /////// state machine for initialization 
    // FSM state eencoding using parameters
    parameter INIT_POWER_ON_WAIT = 3'd0, //initial state - 150us
              INIT_PRECHARGE     = 3'd1,//precharge state
              INIT_WAIT_TRP      =3'd2, // precharge wait state
              INIT_AUTO_REF      =3'd3, // Auto-refresh state
              INIT_WAIT_TRFC     =3'd4 , //Auto-refresh wait state
              INIT_MODE_REG      =3'd5, //Mode register setting state
              INIT_WAIT_TMRD     =3'd6 , //Mode register wait state
              INIT_END           =3'd7; // Initialization complete state
              
    reg [2:0] init_state; //// initialization tate variable
    reg [2:0] count_clock;
    
    ////keep track of clock cycle for wait 
    reg rst_clock_count;
    always @(posedge sys_clk or negedge sys_rst_n) begin
        if(!sys_rst_n)
            count_clock<=3'd0; // Reset counter
        else if (rst_clock_count)
            count_clock<=3'd0;
        else if (count_clock != 3'd7) // prevent overflow if max cycle is 7
            count_clock<=count_clock+1'b1;
    end
    
    /// flag to denote waiting period for precharge , autorefresh and mode register finish
    wire trp_end, trfc_end, tmrd_end;
    
    //SDRAM Timing constraints (clock cycles ) -- by datasheet
    parameter TRP_COUNT = 3'd2 ; // precharge wait period (in clock cycles )
    parameter TRFC_COUNT =3'd7 ; // auto refresh wait period (in clock cycles )
    parameter TMRD_COUNT =3'd2 ; // Mode register wait period (in clock cycles)
    
    assign trp_end = ((init_state==INIT_WAIT_TRP) && (count_clock==TRP_COUNT)) ? 1'b1 : 1'b0;
    assign trfc_end =((init_state == INIT_WAIT_TRFC) && (count_clock==TRFC_COUNT))? 1'b1 : 1'b0;
    assign tmrd_end =((init_state == INIT_WAIT_TMRD) && (count_clock==TMRD_COUNT))? 1'b1 : 1'b0;
    
    always @(*) begin
        rst_clock_count=1'b1;// reset counter unless a wait state requires counting 
        case (init_state) 
            INIT_POWER_ON_WAIT : rst_clock_count=1'b1; // reset counter at idle state
            INIT_WAIT_TRP: rst_clock_count=trp_end ? 1'b1:1'b0; // reset when TRP wait is done 
            INIT_WAIT_TRFC: rst_clock_count=trfc_end? 1'b1:1'b0; // reset when TRFC wait is done 
            INIT_WAIT_TMRD: rst_clock_count=tmrd_end? 1'b1:1'b0; // reset when TMRD wait is done 
            default : rst_clock_count=1'b1;
        endcase 
    
    end
    /// initialization seq 
    reg [2:0] cnt_auto_ref;
    always @(posedge sys_clk or negedge sys_rst_n ) begin
        if(sys_rst_n==1'b0) begin
            init_state<= INIT_POWER_ON_WAIT; // Reset to idle state
            cnt_auto_ref<=0;
         end
         else begin
            case(init_state) 
                INIT_POWER_ON_WAIT:  // wait for 150us before precharge 
                begin 
                    cnt_auto_ref<=0;
                    if(power_on_wait_done)
                        init_state<=INIT_PRECHARGE;
                end
                INIT_PRECHARGE: // move to precharge wait state
                    init_state <=INIT_WAIT_TRP;
                INIT_WAIT_TRP: // wait for precharge to complete
                    if(trp_end)
                        init_state<=INIT_AUTO_REF;
                INIT_AUTO_REF: // Directly move to auto refresh wait state
                    init_state<=INIT_WAIT_TRFC;
                INIT_WAIT_TRFC: // wait for auto refresh to complete
                    if(trfc_end) begin 
                        if(cnt_auto_ref==3'd7)
                            init_state<=INIT_MODE_REG; // move to mode register config after 8 refreshers 
                        else begin
                            init_state <=INIT_AUTO_REF; // repeat auto refresh 
                            cnt_auto_ref<= cnt_auto_ref+1;
                        end
                    end
                 INIT_MODE_REG :
                    init_state<=INIT_WAIT_TMRD;
                 INIT_WAIT_TMRD : // wait for moder register configuration to complete
                    if(tmrd_end)
                        init_state<=INIT_END;
                 INIT_END: // Remain in intialization complete state
                    init_state<=INIT_END; // lock our initalization 
                 default :
                    init_state<=INIT_POWER_ON_WAIT;
            endcase
         
         end
    end
    
    assign init_done =(init_state==INIT_END) ? 1'b1:1'b0;

    /////sending command , bank and address 
    /// SDRAM COMMAND DEFINTION (4-bit command codes )
    
    localparam P_CHARGE =4'b0010; // Precharge command
    localparam AUTO_REF =4'b0001; // auto regresh command
    localparam NOP      =4'b0111; //NO OPERATION
    localparam M_REG_SET=4'b0000; // Mode register set command
    
    always @(posedge sys_clk or negedge sys_rst_n) begin 
        if(!sys_rst_n)begin
           init_cmd_out<=NOP;
           init_bank_out<=2'b11;
           init_addr_out <=12'hfff;
        end
        else begin
            case(init_state)
                INIT_POWER_ON_WAIT,INIT_WAIT_TRP,INIT_WAIT_TRFC, INIT_WAIT_TMRD , INIT_END : begin
                    //NOP command during idle/wait states and after initialization
                    init_cmd_out<=NOP;
                    init_bank_out <=2'b11;
                    init_addr_out <=12'hfff;
                
                end
                INIT_PRECHARGE : begin 
                    init_cmd_out<=P_CHARGE;
                    init_bank_out <=2'b11;
                    init_addr_out <= 12'hfff;
                    
                end
                INIT_AUTO_REF : begin
                    init_cmd_out<=AUTO_REF;
                    init_bank_out <=2'b11;
                    init_addr_out <= 12'hfff;
                
                end
                INIT_MODE_REG: begin
                    init_cmd_out<=M_REG_SET;
                    init_bank_out <=2'b00; // bank address 00 for mode register
                    init_addr_out <={
                        2'b00,//A11-A10 :Reseved
                        1'b0, //A9: Read/write burst mode 
                        2'b00, //A8-A7 : operating mode (00: standard)
                        3'b011, //A6-A4 : CAS latency (010:2,011:3,others:)
                        1'b0, //A3: burst type (0:sequential, 1:interleave)
                        3'b111//A2-A0: burst length (000: single , 001:2 , 010:4)
                    };
                   
                
                end
                default : begin
                    init_cmd_out<=NOP;
                    init_bank_out <=2'b11;
                    init_addr_out <=12'hfff;
                end
            endcase
        end
    
    end
endmodule
