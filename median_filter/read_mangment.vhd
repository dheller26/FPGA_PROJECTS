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
           clk_matrix: in STD_LOGIC; -- operate on 30 MHz
           rst : in STD_LOGIC;
           start_read: in STD_LOGIC;
           pixel_read_line1 : in STD_LOGIC_VECTOR (11 downto 0);
           pixel_read_line2 : in STD_LOGIC_VECTOR (11 downto 0);
           pixel_read_line3 : in STD_LOGIC_VECTOR (11 downto 0);
           pixel_read_line4 : in STD_LOGIC_VECTOR (11 downto 0);
           address_read : out STD_LOGIC_VECTOR (9 downto 0);
           ready : out STD_LOGIC;
           
           matrix_red : out STD_LOGIC_VECTOR(4*9-1 downto 0);
           matrix_blue : out STD_LOGIC_VECTOR(4*9-1 downto 0);
           matrix_green : out STD_LOGIC_VECTOR(4*9-1 downto 0)
           
           );
           
           
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

signal address_count : std_logic_vector(9 downto 0):=(others=>'1');

signal counter_read : std_logic_vector(11 downto 0):=(others=>'1');
signal bus_pixels_R : std_logic_vector(4*9-1 downto 0) :=(others=>'0');
signal bus_pixels_B : std_logic_vector(4*9-1 downto 0) :=(others=>'0');
signal bus_pixels_G : std_logic_vector(4*9-1 downto 0) :=(others=>'0');



begin


-- counter read process
process(clk_ram) begin
    if(rising_edge(clk_ram)) then
        if(rst='1' or start_read='0' ) then
            counter_read<=(others=>'1');
        elsif (counter_read=2560) then 
            counter_read<=(others=>'0');
        else
            counter_read<=counter_read+1;
        end if;
    end if;
end process;

--COUNTER READ ADDRESS
process(clk_ram) begin
    if(rising_edge(clk_ram)) then
        if(rst='1' or start_read='0') then
            address_count<="1001111111"; --639
        elsif (address_count=639) then 
            address_count<=(others=>'0');
        else
            address_count<=address_count+1;
        end if;
    end if;
end process;




--- read lines from where mux 
process(clk_ram) begin
    if(rising_edge(clk_ram)) then
        if(rst='1' or start_read='0') then 
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

process(clk_matrix) begin
    if(rising_edge(clk_matrix)) then
        if(rst='1' or start_read='0') then
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
    CLK => clk_ram,
    CE => '1',
    Q => pixel_srl_1_out --line 1
  );
srl_comp_2 : c_shift_ram_0
  PORT MAP (
    A => srl_sel,
    D =>  pixel_srl_2_in,
    CLK => clk_ram,
    CE => '1',
    Q => pixel_srl_2_out --line 2
  );
srl_comp_3 : c_shift_ram_0
  PORT MAP (
    A => srl_sel,
    D =>  pixel_srl_3_in,
    CLK => clk_ram,
    CE => '1',
    Q => pixel_srl_3_out --line 3
  );


--blue insertion process
process(clk_matrix) begin
    if(rising_edge(clk_matrix)) then 
        case srl_sel is 
            when "10" =>
                bus_pixels_B(3 downto 0) <=pixel_srl_1_out(3 downto 0);
                bus_pixels_B(7 downto 4) <=pixel_srl_2_out(3 downto 0);
                bus_pixels_B(11 downto 8) <=pixel_srl_3_out(3 downto 0);
            when "01" =>
                bus_pixels_B(15 downto 12) <=pixel_srl_1_out(3 downto 0);
                bus_pixels_B(19 downto 16) <=pixel_srl_2_out(3 downto 0);
                bus_pixels_B(23 downto 20) <=pixel_srl_3_out(3 downto 0);
            when "00" =>
                bus_pixels_B(27 downto 24) <=pixel_srl_1_out(3 downto 0);
                bus_pixels_B(31 downto 28) <=pixel_srl_2_out(3 downto 0);
                bus_pixels_B(35 downto 32) <=pixel_srl_3_out(3 downto 0);
        when others=> bus_pixels_B<=(others=>'0');
        end case;
    end if;
end process;

--green insertion process
process(clk_matrix) begin
    if(rising_edge(clk_matrix)) then 
        case srl_sel is 
            when "10" =>
                bus_pixels_G(3 downto 0) <=pixel_srl_1_out(7 downto 4);
                bus_pixels_G(7 downto 4) <=pixel_srl_2_out(7 downto 4);
                bus_pixels_G(11 downto 8) <=pixel_srl_3_out(7 downto 4);
            when "01" =>
                bus_pixels_G(15 downto 12) <=pixel_srl_1_out(7 downto 4);
                bus_pixels_G(19 downto 16) <=pixel_srl_2_out(7 downto 4);
                bus_pixels_G(23 downto 20) <=pixel_srl_3_out(7 downto 4);
            when "00" =>
                bus_pixels_G(27 downto 24) <=pixel_srl_1_out(7 downto 4);
                bus_pixels_G(31 downto 28) <=pixel_srl_2_out(7 downto 4);
                bus_pixels_G(35 downto 32) <=pixel_srl_3_out(7 downto 4);
            when others=> bus_pixels_G<=(others=>'0');

        end case;
    end if;
end process;

--red insertion process
process(clk_matrix) begin
    if(rising_edge(clk_matrix)) then 
        case srl_sel is 
            when "10" =>
                bus_pixels_R(3 downto 0) <=pixel_srl_1_out(11 downto 8);
                bus_pixels_R(7 downto 4) <=pixel_srl_2_out(11 downto 8);
                bus_pixels_R(11 downto 8) <=pixel_srl_3_out(11 downto 8);
            when "01" =>
                bus_pixels_R(15 downto 12) <=pixel_srl_1_out(11 downto 8);
                bus_pixels_R(19 downto 16) <=pixel_srl_2_out(11 downto 8);
                bus_pixels_R(23 downto 20) <=pixel_srl_3_out(11 downto 8);
            when "00" =>
                bus_pixels_R(27 downto 24) <=pixel_srl_1_out(11 downto 8);
                bus_pixels_R(31 downto 28) <=pixel_srl_2_out(11 downto 8);
                bus_pixels_R(35 downto 32) <=pixel_srl_3_out(11 downto 8);
            when others=> bus_pixels_R<=(others=>'0');

        end case;
    end if;
end process;


ready<=matrix_ready;
matrix_red<=bus_pixels_R;
matrix_blue<=bus_pixels_B;
matrix_green<=bus_pixels_G;

address_read<=address_count;
end Behavioral;
