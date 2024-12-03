----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 12/02/2024 01:34:45 PM
-- Design Name: 
-- Module Name: write_buffer_manager - Behavioral
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

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
use IEEE.NUMERIC_STD.ALL;
use IEEE.std_logic_unsigned.ALL;
-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity write_buffer_manager is
    Port ( clk : in STD_LOGIC;
           pixel_in : in STD_LOGIC_VECTOR (11 downto 0);
           rst : in STD_LOGIC;
           we_1 : out STD_LOGIC;
           we_2 : out STD_LOGIC;
           we_3 : out STD_LOGIC;
           we_4 : out STD_LOGIC;
           address : out STD_LOGIC_VECTOR (9 downto 0); -- for 640 columns 
           pixel_w : out STD_LOGIC_VECTOR (11 downto 0));
--           pixel_w_1 : out STD_LOGIC_VECTOR (7 downto 0);
--           pixel_w_2 : out STD_LOGIC_VECTOR (7 downto 0);
--           pixel_w_3 : out STD_LOGIC_VECTOR (7 downto 0);
--           pixel_w_4 : out STD_LOGIC_VECTOR (7 downto 0));
end write_buffer_manager;

architecture Behavioral of write_buffer_manager is
signal pixel_counter : std_logic_vector (11 downto 0) :=(others=>'1'); -- 640 * 4 
signal addr_counter  :std_logic_vector (9 downto 0) :=(others=>'1');
signal pixel_sample :std_logic_vector (11 downto 0) :=(others=>'0');
type RAM_W is (RAM1,RAM2,RAM3,RAM4) ;
signal line_buf : RAM_W :=RAM1;

begin
--COUNTER AND ADDRESS PROCESS 
process(clk) begin 
    if(rising_edge (clk)) then 
        if(rst='1') then 
--            pixel_counter<=(others=>'1');
            addr_counter<=(others=>'1');
        elsif  addr_counter=639 then
--            pixel_counter<=pixel_counter+1;
             addr_counter<=(others=>'0');
        else
            addr_counter<=addr_counter+1;
        end if;
    end if;
end process ;


process(clk) begin
    if(rising_edge(clk)) then 
        if(rst='1') then 
            line_buf<=RAM1;
            pixel_sample<=(others=>'0');
        else 
            pixel_sample<=pixel_in;
            case line_buf is 
                when RAM1 =>
                        if(addr_counter=639) then 
                            line_buf<=RAM2;
                        else 
                            we_1<='1';
                            we_2<='0';
                            we_3<='0';
                            we_4<='0';
                        end if;
                when RAM2 =>
                        if(addr_counter=639) then 
                            line_buf<=RAM3;
                        else 
                            we_1<='0';
                            we_2<='1';
                            we_3<='0';
                            we_4<='0';
                        end if;
                when RAM3 =>
                        if(addr_counter=639) then 
                            line_buf<=RAM4;
                        else 
                            we_1<='0';
                            we_2<='0';
                            we_3<='1';
                            we_4<='0';
                        end if;
                when RAM4 =>
                        if(addr_counter=639) then 
                            line_buf<=RAM1;
                        else 
                            we_1<='0';
                            we_2<='0';
                            we_3<='0';
                            we_4<='1';
                        end if;
            
            end case;
        end if;
    end if;
end process;

pixel_w<=pixel_sample;
address<=addr_counter;


end Behavioral;
