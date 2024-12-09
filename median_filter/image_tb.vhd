----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 09.12.2024 18:39:22
-- Design Name: 
-- Module Name: image_tb - Behavioral
-- Project Name: 
-- Target Devices: 
-- Tool Versions: 
-- Description: 
-- 
-- Dependencies: 
-- 
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
-- 
----------------------------------------------------------------------------------


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use STD.TEXTIO.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
use IEEE.NUMERIC_STD.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
USE ieee.std_logic_arith.all;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity image_tb is
--  Port ( );
end image_tb;

architecture Behavioral of image_tb is
    signal pixel : std_logic_vector(11 downto 0) ;
    signal valid : std_logic ;
    
    COMPONENT design_1_wrapper is
      port (
        filtered_pixel : out STD_LOGIC_VECTOR ( 11 downto 0 );
        pixel_clk : in STD_LOGIC;
        pixel_filtered_valid : out STD_LOGIC;
        pixel_in_0 : in STD_LOGIC_VECTOR ( 11 downto 0 );
        reset : in STD_LOGIC
      );
    end COMPONENT;
    
    
    signal pixel_out_filtered : std_logic_vector(11 downto 0);
    signal clk: std_logic :='0';
    signal dut_valid : std_logic:='0';
    signal rst : std_logic:='0';
    
    constant time_period : time :=100ns;
begin
    process  --
    file source_file : TEXT open READ_MODE is "D:\FPGA_EXPERT\fgga_expert_final_project\yelement102_dirt.txt";
    variable lineOfTextFromFile : line; 
    variable status : boolean :=false;
    variable pixel_val : integer;
    begin
        while (not ENDFILE(source_file)) loop
            readline(source_file,lineOfTextFromFile);
            for I in 1 to 640 loop --lineOfTextFromFile'length loop 
                read(lineOfTextFromFile,pixel_val,status);
                if(status) then
                    pixel<="0000"&conv_std_logic_vector(pixel_val,8);
                    valid<='1';
                else 
                    pixel<=(others=>'0');
                    valid<='0';
                end if;
                wait for 100 ns;
            end loop;
        end loop;
    end process;

rst<='0','0' after time_period*4;
clk<=not clk after time_period/2;
dut: design_1_wrapper 
  port map (
    filtered_pixel=>pixel_out_filtered,
    pixel_clk=>clk,
    pixel_filtered_valid =>dut_valid,
    pixel_in_0 =>pixel,
    reset =>rst
  );


    process  
    file write_file : TEXT open write_mode is "D:\FPGA_EXPERT\fgga_expert_final_project\filtered_pic1.txt";
    variable line_val:line;
    variable i: integer :=0 ;
    variable j: integer :=0;
    
    begin
        
        while (j<480) loop
            while(i<640) loop
               if(dut_valid='1') then
                write(line_val , integer'image(conv_integer(pixel_out_filtered)) & " ");
                i:=i+1;
                end if;
                wait for 10ns;
            end loop;
            writeline(write_file,line_val);
            j:=j+1;
            i:=0;
        end loop;
        wait;        
    end process;



end Behavioral;
