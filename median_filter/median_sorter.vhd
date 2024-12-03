library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity MedianSorter is
    Port (
        clk      : in  std_logic;                       -- Clock signal
        pixels   : in  std_logic_vector(4*9-1 downto 0); -- Input 9 pixels, each 4 bits
        median   : out std_logic_vector(3 downto 0);     -- Median output
        valid     : out std_logic
    );
end MedianSorter;

architecture Behavioral of MedianSorter is
    type pixel_array is array(0 to 8) of std_logic_vector(3 downto 0);
    signal pixel_reg : pixel_array;                     -- Array to hold input pixels
    signal sorted    : pixel_array;                     -- Array to hold sorted pixels
    signal done      : std_logic := '1';                -- Sorting completion flag
    signal operation_counter : std_logic_vector(3 downto 0) :=(others=>'0');
    signal even_odd_flag : std_logic:='0'; --'0'->even '1'->odd
--    signal change,previous_change : std_logic;
    signal start_sorting: std_logic :='0';
    signal first_round  : std_logic :='1';
begin

    -- Unpack pixels from input vector
    unpack_process: process(clk)
    begin
        if rising_edge(clk) then
            if(start_sorting='0') then -- get new data before sorting
                pixel_reg(0) <= pixels(7 downto 0);
                pixel_reg(1) <= pixels(15 downto 8);
                pixel_reg(2) <= pixels(23 downto 16);
                pixel_reg(3) <= pixels(31 downto 24);
                pixel_reg(4) <= pixels(39 downto 32);
                pixel_reg(5) <= pixels(47 downto 40);
                pixel_reg(6) <= pixels(55 downto 48);
                pixel_reg(7) <= pixels(63 downto 56);
                pixel_reg(8) <= pixels(71 downto 64);
            else
--                
                if(even_odd_flag='0') then
                    for i in 0 to 3 loop
                        if(pixel_reg(2*i)>pixel_reg(2*i+1)) then
                            pixel_reg(2*i)<=pixel_reg(2*i+1);
                            pixel_reg(2*i+1)<=pixel_reg(2*i);
                        else
                            pixel_reg(2*i)<=pixel_reg(2*i);
                            pixel_reg(2*i+1)<=pixel_reg(2*i+1);
                        end if;
                    end loop;
       
                    pixel_reg(8)<=pixel_reg(8);
               else  --- odd sorting
                    pixel_reg(0)<=pixel_reg(0);          
               
                     for i in 0 to 3 loop
                            if(pixel_reg(2*i+1)>pixel_reg(2*i+2)) then
                                pixel_reg(2*i+1)<=pixel_reg(2*i+2);
                                pixel_reg(2*i+2)<=pixel_reg(2*i+1);
                            else
                                pixel_reg(2*i+1)<=pixel_reg(2*i+1);
                                pixel_reg(2*i+2)<=pixel_reg(2*i+2);
                            end if;
                     end loop;
               
               end if;            
            end if;
        end if;
    end process;
   
   
   
    control_1 : process(clk) begin
        if(rising_edge(clk)) then
            if (operation_counter=0 ) then
                start_sorting<='1';
--                first_round<='1';
                operation_counter<=operation_counter+1;
                done<='0';
            elsif(operation_counter=8) then
                start_sorting<='0';
                operation_counter<=(others=>'0');
--                first_round<='0';
                done<='1';
            else
                operation_counter<=operation_counter+1;
--                first_round<='0';
                done<='0';
            end if;
           valid<=done;
        end if;
    end process;
   
    even_odd_process : process(operation_counter,even_odd_flag) begin
--        if(rising_edge(clk)) then
            if( not operation_counter(0)='0') then
                even_odd_flag<='0';
            else
                even_odd_flag<='1';
            end if;
--        end if;
    end process;


    -- Extract median after sorting is complete
    median_process: process(clk)
    begin
        if rising_edge(clk) then
            if done = '1' then
                median <= pixel_reg(4); -- Median is the 5th element
            else 
                median <=(others=>'0');
            end if;
        end if;
    end process;

end Behavioral;