`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////


module sdram_auto_ref_gen(
    input wire sys_clk, 
    input wire sys_rst_n,
    input wire init_end,
    input wire aref_en, // auto refresh enable 
    
    output reg aref_req, ///auto refresh request
    output reg [3:0] aref_cmd_out , // auto refresh command to sdram 
    output reg [1:0] aref_ba_out, // bank address 
    output reg [12:0] aref_addr_out, // address bus 
    output reg aref_end  
    );
    
    parameter AREF_IDLE =3'b000,
              AREF_PRECHARGE = 3'b001,
              AREF_WAIT_TRP = 3'b011,
              AREF_AUTO_REF = 3'b010,
              AREF_WAIT_TRFC=3'b100,
              AREF_END = 3'b101;
    reg [2:0] aref_state;
    
    //auto refresh request signal
    parameter SINGLE_ROW_COUNT=11'd1550;
    reg [10:0] clk_count;
    
    /// clock cycle counter for each row once init end 
    always @(posedge sys_clk or negedge sys_rst_n ) begin
        if(sys_rst_n==1'b0)
            clk_count<=1'b0;
        else if(clk_count >=SINGLE_ROW_COUNT)
            clk_count<=1'b0;
        else if(init_end==1'b1)
            clk_count<=clk_count+1;

    end
    
    //send auto refresh request 
    always @(posedge sys_clk or negedge sys_rst_n) begin
        if(sys_rst_n==1'b0)
            aref_req<=1'b0;
        else if(clk_count == (SINGLE_ROW_COUNT-1'b1))
            aref_req <=1'b1; // asert auto regresh request when refresh timer expire
        else if(aref_state==AREF_PRECHARGE)
            aref_req<=1'b0;
    end
    
    ////track end of TRP and TRFC 
    wire trp_end, trfc_end;
    reg [2:0] wait_count;
    reg wait_count_rst;
    
    always @(*) begin
        case (aref_state)
            AREF_IDLE,AREF_PRECHARGE,AREF_AUTO_REF : wait_count_rst<=1'b1; 
            AREF_WAIT_TRP : wait_count_rst<=(trp_end==1'b1)?1'b1 :1'b0;
            
            AREF_WAIT_TRFC : wait_count_rst<=(trfc_end==1'b1)?1'b1 :1'b0;
            
            AREF_END: wait_count_rst<=1'b1;
            default : wait_count_rst<=1'b0;
        
        endcase

    end
    
    
    always @(posedge sys_clk or negedge sys_rst_n)
    begin 
        if(sys_rst_n==1'b0)
            wait_count<=3'd0;
        else if(wait_count_rst ==1'b1)
            wait_count<=3'd0;
        else
            wait_count<=wait_count+1;
    end
    
    parameter TRP_COUNT =2'd2;
    parameter TRFC_COUNT= 3'd7;
    
    assign trp_end=((aref_state==AREF_WAIT_TRP)&&(wait_count==TRP_COUNT)) ? 1'b1:1'b0;
    assign trfc_end=((aref_state==AREF_WAIT_TRFC)&&(wait_count==TRFC_COUNT)) ? 1'b1:1'b0;
    
    reg [1:0] count_auto_ref;
    always @(posedge sys_clk or negedge sys_rst_n) begin
        if(sys_rst_n ==1'b0) begin 
            aref_state<=AREF_IDLE;
            count_auto_ref<=0;
        end
        else begin 
            case (aref_state)
                AREF_IDLE: begin
                    if((aref_en==1'b1) && (init_end==1'b1))
                        aref_state<=AREF_PRECHARGE; // start auto refresh if enabled and initialized 
                    else
                        aref_state<=AREF_IDLE; 
                end
                AREF_PRECHARGE:
                    aref_state<=AREF_WAIT_TRP;
                AREF_WAIT_TRP:
                    if(trp_end==1'b1)
                        aref_state<=AREF_AUTO_REF; // move to auto refresh after precharge 
                     else
                        aref_state<=AREF_WAIT_TRP;
                AREF_AUTO_REF:
                    aref_state<=AREF_WAIT_TRFC;
                AREF_WAIT_TRFC:
                    begin 
                        if(trfc_end==1'b1)
                            aref_state<=AREF_END;
                        else 
                            aref_state<=AREF_WAIT_TRFC;
                    end
                AREF_END: 
                    aref_state<=AREF_IDLE;
                default :
                    aref_state<=AREF_IDLE;
                    
            endcase
        end 
    end
    
    /// COMMANDS
    parameter PRECHARGE =4'B0010,
               AUTOREFRESH =4'b0001,
               NOP =4'b0111;
               
    always @(posedge sys_clk or negedge sys_rst_n)
    begin
        if(sys_rst_n==1'b0)
        begin  
            aref_cmd_out<=NOP;
            aref_ba_out<=2'b11;
            aref_addr_out <=12'hfff;
            
        end
        else 
        case (aref_state)
            AREF_IDLE,AREF_WAIT_TRP,AREF_WAIT_TRFC:
            begin
                 aref_cmd_out<=NOP;
                aref_ba_out<=2'b11;
                aref_addr_out <=12'hfff;
            end
            AREF_PRECHARGE:
            begin  
                 aref_cmd_out<=PRECHARGE;
                aref_ba_out<=2'b11;
                aref_addr_out <=12'hfff;
            end
            AREF_AUTO_REF:
            begin
                aref_cmd_out<=AUTOREFRESH;
                aref_ba_out<=2'b11;
                aref_addr_out <=12'hfff;
            
            end
            AREF_END:
            begin  
                 aref_cmd_out<=NOP;
                aref_ba_out<=2'b11;
                aref_addr_out <=12'hfff;
            end
            
            default:
            begin  
                 aref_cmd_out<=NOP;
                aref_ba_out<=2'b11;
                aref_addr_out <=12'hfff;
            end
        
        endcase 
    
    end
    
endmodule
