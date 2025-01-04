----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 15.12.2024 20:01:48
-- Design Name: 
-- Module Name: LFSR_NOISE_GEN - Behavioral
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
use IEEE.STD_LOGIC_UNSIGNED.ALL;
-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity LFSR_NOISE_GEN is
    Port ( CLK : in STD_LOGIC;
           PIXEL : in STD_LOGIC_VECTOR (11 downto 0);
           PIXEL_MODIFIED : out STD_LOGIC_VECTOR (11 downto 0)
           );
end LFSR_NOISE_GEN;

architecture Behavioral of LFSR_NOISE_GEN is

signal counter : std_logic_vector(3 downto 0) :="1000";


begin

process(CLK) begin
    if(rising_edge(CLK)) then
        counter(0) <=counter(3) xor counter(1);
        counter(1) <=counter(0);
        counter(2) <=counter(1);
        counter(3) <=counter(2);
        
    end if;
end process;


process(CLK) begin 
    if(rising_edge(CLK)) then
        if(counter>0 and counter<3) then
            PIXEL_MODIFIED<=X"FFF";
        elsif (counter>12 and counter<15) then
            PIXEL_MODIFIED<=X"000";
        else 
            PIXEL_MODIFIED<=PIXEL;
        end if;    
    end if;
end process;
end Behavioral;
