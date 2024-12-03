----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 03.12.2024 19:39:47
-- Design Name: 
-- Module Name: read_mangment - Behavioral
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

entity read_mangment is
    Port ( clk_ram : in STD_LOGIC; -- operate on 10 MHz
           clk_pipline: in STD_LOGIC; -- operate on 150 MHz
           rst : in STD_LOGIC;
           pixel_read_line1 : in STD_LOGIC_VECTOR (11 downto 0);
           pixel_read_line2 : in STD_LOGIC_VECTOR (11 downto 0);
           pixel_read_line3 : in STD_LOGIC_VECTOR (11 downto 0);
           pixel_read_line4 : in STD_LOGIC_VECTOR (11 downto 0);
           pixel_filtered : out STD_LOGIC_VECTOR (11 downto 0);
           address_read : out STD_LOGIC_VECTOR (9 downto 0);
           valid : out STD_LOGIC);
end read_mangment;

architecture Behavioral of read_mangment is

COMPONENT c_shift_ram_0
  PORT (
    A : IN STD_LOGIC_VECTOR(1 DOWNTO 0);
    D : IN STD_LOGIC_VECTOR(11 DOWNTO 0);
    CLK : IN STD_LOGIC;
    CE : IN STD_LOGIC;
    Q : OUT STD_LOGIC_VECTOR(11 DOWNTO 0) 
  );
END COMPONENT;
signal srl_sel : std_logic_vector(1 downto 0) :="10";
signal pixel_srl_1_in : std_logic_vector(11 downto 0) :=(others=>'0');
signal pixel_srl_2_in : std_logic_vector(11 downto 0) :=(others=>'0');
signal pixel_srl_3_in : std_logic_vector(11 downto 0) :=(others=>'0');

signal pixel_srl_1_out : std_logic_vector(11 downto 0) :=(others=>'0');
signal pixel_srl_2_out: std_logic_vector(11 downto 0) :=(others=>'0');
signal pixel_srl_3_out : std_logic_vector(11 downto 0) :=(others=>'0');

signal matrix_ready : std_logic :='0';


signal counter_read : std_logic_vector(11 downto 0):=(others=>'1');
begin


-- counter read process
process(clk_ram) begin
    if(rising_edge(clk_ram)) then
        if(rst='1') then
            counter_read<=(others=>'1');
        elsif (counter_read=2560) then 
            counter_read<=(others=>'0');
        else
            counter_read<=counter_read+1;
        end if;
    end if;
end process;


--- read lines from where mux 
process(clk_ram) begin
    if(rising_edge(clk_ram)) then
        if(rst='1') then 
            pixel_srl_1_in<=(others=>'0');
            pixel_srl_2_in<=(others=>'0');
            pixel_srl_3_in<=(others=>'0');
        else
            if(counter_read<640) then --read from line buffers 1,2,3
                pixel_srl_1_in<=pixel_read_line1;
                pixel_srl_2_in<=pixel_read_line2;
                pixel_srl_3_in<=pixel_read_line3;
            elsif (counter_read>=640 and counter_read<1280) then -- read from line buffers 2,3,4
                pixel_srl_1_in<=pixel_read_line2;
                pixel_srl_2_in<=pixel_read_line3;
                pixel_srl_3_in<=pixel_read_line4;
            elsif (counter_read>=1280 and counter_read<1920) then -- read from line buffers 3,4,1
                pixel_srl_1_in<=pixel_read_line3;
                pixel_srl_2_in<=pixel_read_line4;
                pixel_srl_3_in<=pixel_read_line1;
            elsif (counter_read>=1920 and counter_read<2560) then -- read from line buffers 4,1,2
                pixel_srl_1_in<=pixel_read_line4;
                pixel_srl_2_in<=pixel_read_line1;
                pixel_srl_3_in<=pixel_read_line2;
            end if;            
        end if;
    end if;
end process;

process(clk_pipline) begin
    if(rising_edge(clk_pipline)) then
        if(rst='1') then
            srl_sel<="10";
            matrix_ready<='0';
        elsif (srl_sel=0) then 
            srl_sel<="10";
            matrix_ready<='1';
        else
            srl_sel<=srl_sel-1;
            matrix_ready<='0';
        end if;
    end if;
end process;




srl_comp_1 : c_shift_ram_0
  PORT MAP (
    A => srl_sel,
    D =>  pixel_srl_1_in,
    CLK => clk_pipline,
    CE => '1',
    Q => pixel_srl_1_out
  );
srl_comp_2 : c_shift_ram_0
  PORT MAP (
    A => srl_sel,
    D =>  pixel_srl_2_in,
    CLK => clk_pipline,
    CE => '1',
    Q => pixel_srl_2_out
  );
srl_comp_3 : c_shift_ram_0
  PORT MAP (
    A => srl_sel,
    D =>  pixel_srl_3_in,
    CLK => clk_pipline,
    CE => '1',
    Q => pixel_srl_3_out
  );






end Behavioral;
