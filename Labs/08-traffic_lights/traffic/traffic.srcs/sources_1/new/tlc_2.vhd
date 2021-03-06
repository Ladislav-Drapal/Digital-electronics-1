------------------------------------------------------------------------
--
-- Traffic light controller using FSM.
-- Nexys A7-50T, Vivado v2020.1.1, EDA Playground
--
-- Copyright (c) 2020-Present Tomas Fryza
-- Dept. of Radio Electronics, Brno University of Technology, Czechia
-- This work is licensed under the terms of the MIT license.
--
-- This code is inspired by:
-- [1] LBEbooks, Lesson 92 - Example 62: Traffic Light Controller
--     https://www.youtube.com/watch?v=6_Rotnw1hFM
-- [2] David Williams, Implementing a Finite State Machine in VHDL
--     https://www.allaboutcircuits.com/technical-articles/implementing-a-finite-state-machine-in-vhdl/
-- [3] VHDLwhiz, One-process vs two-process vs three-process state machine
--     https://vhdlwhiz.com/n-process-state-machine/
--
------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

------------------------------------------------------------------------
-- Entity declaration for traffic light controller
------------------------------------------------------------------------
entity tlc_2 is
    port(
        clk     : in  std_logic;
        reset   : in  std_logic;
        -- Traffic lights (RGB LEDs) for two directions
        south_o : out std_logic_vector(3 - 1 downto 0);
        west_o  : out std_logic_vector(3 - 1 downto 0)
    );
end entity tlc_2;

------------------------------------------------------------------------
-- Architecture declaration for traffic light controller
------------------------------------------------------------------------
architecture Behavioral of tlc_2 is

    -- Define the states
    type   t_state is (STOP1, SENSOR1, WEST_GO,  WEST_WAIT,
                       STOP2, SENSOR2, SOUTH_GO, SOUTH_WAIT);
    -- Define the signal that uses different states
    signal s_state  : t_state;

    -- Internal clock enable
    signal s_en     : std_logic;
    -- Local delay counter
    signal   s_cnt  : unsigned(5 - 1 downto 0);
    
    signal s_sensor1 : unsigned(5 - 1 downto 0);
    signal s_sensor2 : unsigned(5 - 1 downto 0);
    -- Specific values for local counter
    constant c_DELAY_4SEC   : unsigned(5 - 1 downto 0) := b"1_0000"; -- 4 sec
    constant c_DELAY_2SEC : unsigned(5 - 1 downto 0) := b"0_1000"; -- 2 sec
    constant c_DELAY_1SEC : unsigned(5 - 1 downto 0) := b"0_0100"; -- 1 sec
    constant c_ZERO       : unsigned(5 - 1 downto 0) := b"0_0000"; -- zero
    
    constant c_no_cars            : unsigned(2 - 1 downto 0) := b"00"; 
    constant c_cars_to_west       : unsigned(2 - 1 downto 0) := b"01"; 
    constant c_cars_to_south      : unsigned(2 - 1 downto 0) := b"10"; 
    constant c_cars_both          : unsigned(2 - 1 downto 0) := b"11";

begin

    --------------------------------------------------------------------
    -- Instance (copy) of clock_enable entity generates an enable pulse
    -- every 250 ms (4 Hz). Remember that the frequency of the clock 
    -- signal is 100 MHz.
    
    -- JUST FOR SHORTER/FASTER SIMULATION
    s_en <= '1';  -- takto je to natvrdo připojené
--    clk_en0 : entity work.clock_enable
--        generic map(
--            g_MAX =>        -- g_MAX = 250 ms / (1/100 MHz)
--        )
--        port map(
--            clk   => clk,
--            reset => reset,
--            ce_o  => s_en
--        );

    --------------------------------------------------------------------
    -- p_traffic_fsm:
    -- The sequential process with synchronous reset and clock_enable 
    -- entirely controls the s_state signal by CASE statement.
    --------------------------------------------------------------------

    p_smart_traffic_fsm : process(clk)
    begin
        if rising_edge(clk) then
            if (reset = '1') then       -- Synchronous reset
                s_state   <= WEST_GO ;      -- Set initial state
                s_cnt     <= c_ZERO;      -- Clear all bits
                s_SENSOR1 <= c_ZERO;
                s_SENSOR2 <= c_ZERO;

            elsif (s_en = '1') then
                -- Every 250 ms, CASE checks the value of the s_state 
                -- variable and changes to the next state according 
                -- to the delay value.
                case s_state is
                        
                    when WEST_GO =>
                    -- Count up to c_DELAY_4SEC
                        if (s_cnt < c_DELAY_4SEC) then
                            s_cnt <= s_cnt + 1;
                            
                        elsif (s_sensor1 = c_no_cars) then
                            s_state <= WEST_GO;
                            s_cnt   <= c_ZERO;
                            
                        elsif (s_sensor1 = c_cars_to_west) then
                            s_state <= WEST_GO;
                            s_cnt   <= c_ZERO;  
                             
                        elsif (s_sensor1 = c_cars_both) then
                            s_state <= WEST_WAIT;
                            s_cnt   <= c_ZERO;                                                      
                                                        
                        else
                            -- Move to the next state
                            s_state <= WEST_WAIT;
                            -- Reset local counter value
                            s_cnt   <= c_ZERO;
                        end if;

                    when WEST_WAIT =>
                    -- Count up to c_DELAY_2SEC
                        if (s_cnt < c_DELAY_2SEC) then
                            s_cnt <= s_cnt + 1;
                        else
                            -- Move to the next state
                            s_state <= SOUTH_GO;
                            -- Reset local counter value
                            s_cnt   <= c_ZERO;
                        end if;

                    when SOUTH_GO =>
                    -- Count up to c_DELAY_1SEC
                        if (s_cnt < c_DELAY_4SEC) then
                            s_cnt <= s_cnt + 1;
                            
                        elsif (s_sensor2 = c_no_cars) then
                            s_state <= SOUTH_GO;
                            s_cnt   <= c_ZERO;                            
                            
                        elsif (s_sensor2 = c_cars_to_south) then
                            s_state <= SOUTH_GO;
                            s_cnt   <= c_ZERO;                            
                            
                        elsif (s_sensor2 = c_cars_both) then
                            s_state <= SOUTH_WAIT;
                            s_cnt   <= c_ZERO;   
                                                        
                        else
                            -- Move to the next state
                            s_state <= SOUTH_WAIT;
                            -- Reset local counter value
                            s_cnt   <= c_ZERO;
                        end if; 
                        
                        
                    when SOUTH_WAIT =>
                    -- Count up to c_DELAY_2SEC
                        if (s_cnt < c_DELAY_2SEC) then
                            s_cnt <= s_cnt + 1;
                        else
                            -- Move to the next state
                            s_state <= WEST_GO;
                            -- Reset local counter value
                            s_cnt   <= c_ZERO;
                        end if;                         


                    -- It is a good programming practice to use the 
                    -- OTHERS clause, even if all CASE choices have 
                    -- been made. 
                    when others =>
                        s_state <= WEST_GO;

                end case;
            end if; -- Synchronous reset
        end if; -- Rising edge
    end process p_smart_traffic_fsm;

    --------------------------------------------------------------------
    -- p_output_fsm:
    -- The combinatorial process is sensitive to state changes, and sets
    -- the output signals accordingly. This is an example of a Moore 
    -- state machine because the output is set based on the active state.
    --------------------------------------------------------------------
    p_output_fsm : process(s_state)
    begin
        case s_state is
            when STOP1 =>
                south_o <= "100";   -- Red (RGB = 100)
                west_o  <= "100";   -- Red (RGB = 100)
            when WEST_GO =>
                south_o <= "100";   -- Red 
                west_o  <= "010";   -- Green
            when WEST_WAIT =>
                south_o <= "100";   -- Red 
                west_o  <= "110";   -- Yellow
            when STOP2 =>
                south_o <= "100";   -- Red (RGB = 100)
                west_o  <= "100";   -- Red (RGB = 100)
            when SOUTH_GO =>
               south_o <= "010";   -- Green
               west_o  <= "100";   -- Red              
            when SOUTH_WAIT =>
                south_o <= "110";   -- Yellow
                west_o  <= "100";   -- Red               
                
                -- WRITE YOUR CODE HERE


            when others =>
                south_o <= "100";   -- Red
                west_o  <= "100";   -- Red
        end case;
    end process p_output_fsm;

end architecture Behavioral;
