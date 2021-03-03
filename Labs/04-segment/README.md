## 1. Preparation tasks

### Figure or table with connection of 7-segment displays on Nexys A7 board
								
| **IO** | **Vývod** | **Vst.Báze** | **Tranzistor** | **Nap. do emitoru** | **Výst. Kolektor** | **Výst. 7-seg.** | **Rezistor** | **Vývod** |
| :-: | :-: | :-: | :-: | :-: | :-: | :-: | :-: | :-: |
|Artix-7|U13|Rezistor|AN7|3,3V|7-seg. Display|CA, CB|Rezistor|T10|
|Artix-7|K2|Rezistor|AN6|3,3V|7-seg. Display|CC, CD|Rezistor|R10|
|Artix-7|T14|Rezistor|AN5|3,3V|7-seg. Display|CE, CF|Rezistor|K16|
|Artix-7|P14|Rezistor|AN4|3,3V|7-seg. Display|CG, DP|Rezistor|K13|
|Artix-7|J14|Rezistor|AN3|3,3V|7-seg. Display|CA, CB|Rezistor|P15|
|Artix-7|T9|Rezistor|AN2|3,3V|7-seg. Display|CC, CD|Rezistor|T11|
|Artix-7|J18|Rezistor|AN1|3,3V|7-seg. Display|CE, CF|Rezistor|L18|
|Artix-7|J17|Rezistor|AN0|3,3V|7-seg. Display|CG, DP|Rezistor|H15|


### Decoder truth table for common anode 7-segment display

| **Hex** | **Inputs** | **A** | **B** | **C** | **D** | **E** | **F** | **G** |
| :-: | :-: | :-: | :-: | :-: | :-: | :-: | :-: | :-: |
| 0 | 0000 | 0 | 0 | 0 | 0 | 0 | 0 | 1 |
| 1 | 0001 | 1 | 0 | 0 | 1 | 1 | 1 | 1 |
| 2 | 0010 | 0 | 0 | 1 | 0 | 0 | 1 | 0 |
| 3 | 0011 | 0 | 0 | 0 | 0 | 1 | 1 | 0 |
| 4 | 0100 | 1 | 0 | 0 | 1 | 1 | 0 | 0 |
| 5 | 0101 | 0 | 1 | 0 | 0 | 1 | 0 | 0 |
| 6 | 0110 | 0 | 1 | 0 | 0 | 0 | 0 | 0 |
| 7 | 0111 | 0 | 0 | 0 | 1 | 1 | 1 | 1 |
| 8 | 1000 | 0 | 0 | 0 | 0 | 0 | 0 | 0 |
| 9 | 1001 | 0 | 0 | 0 | 0 | 1 | 0 | 0 |
| A | 1010 | 0 | 0 | 0 | 1 | 0 | 0 | 0 |
| b | 1011 | 1 | 1 | 0 | 0 | 0 | 0 | 0 |
| C | 1100 | 0 | 1 | 1 | 0 | 0 | 0 | 1 |
| d | 1101 | 1 | 0 | 0 | 0 | 0 | 1 | 0 |
| E | 1110 | 0 | 1 | 1 | 0 | 0 | 0 | 0 |
| F | 1111 | 0 | 1 | 1 | 1 | 0 | 0 | 0 |


## 2.Seven-segment display decoder
### Listing of VHDL architecture

```vhdl
architecture Behavioral of hex_7seg is

begin
--------------------------------------------------------------------
    -- p_7seg_decoder:
    -- A combinational process for 7-segment display decoder. 
    -- Any time "hex_i" is changed, the process is "executed".
    -- Output pin seg_o(6) corresponds to segment A, seg_o(5) to B, etc.
    --------------------------------------------------------------------
    p_7seg_decoder : process(hex_i)
    
    begin
        case hex_i is
            when "0000" =>
                seg_o <= "0000001";     -- 0
                
            when "0001" =>
                seg_o <= "1001111";     -- 1
                
            when "0010" =>
                seg_o <= "0010010";     -- 2 
                   
            when "0011" =>
                seg_o <= "0000110";     -- 3
                
            when "0100" =>
                seg_o <= "1001100";     -- 4 
                
            when "0101" =>
                seg_o <= "0100100";     -- 5    
                
            when "0110" =>
                seg_o <= "0100000";     -- 6   
                 
            when "0111" =>
                seg_o <= "0001111";     -- 7 
                   
            when "1000" =>
                seg_o <= "0000000";     -- 8  
                     
            when "1001" =>
                seg_o <= "0000100";     -- 9
             
            when "1010" =>
                seg_o <= "0001000";     -- A    
    
            when "1011" =>
                seg_o <= "1100000";     -- B      
    
            when "1100" =>
                seg_o <= "0110001";     -- C
                
            when "1101" =>
                seg_o <= "1000010";     -- D
                                
            when "1110" =>
                seg_o <= "0110000";     -- E                
                
            when others =>
                seg_o <= "0111000";     -- F
        end case;
    end process p_7seg_decoder;
end Behavioral
```

### Listing of VHDL stimulus process from testbench

```vhdl
p_stimulus : process
    begin
        -- Report a note at the begining of stimulus process
        report "Stimulus process started" severity note;

        s_hex <= "0000"; wait for 100 ns;
        s_hex <= "0001"; wait for 100 ns;
        s_hex <= "0010"; wait for 100 ns; 
        s_hex <= "0011"; wait for 100 ns; 
        s_hex <= "0100"; wait for 100 ns; 
        s_hex <= "0101"; wait for 100 ns; 
        s_hex <= "0110"; wait for 100 ns;
        s_hex <= "0111"; wait for 100 ns;
        s_hex <= "1000"; wait for 100 ns;
        s_hex <= "1001"; wait for 100 ns;
        s_hex <= "1010"; wait for 100 ns; 
        s_hex <= "1011"; wait for 100 ns;
        s_hex <= "1100"; wait for 100 ns;
        s_hex <= "1101"; wait for 100 ns;
        s_hex <= "1110"; wait for 100 ns;
        s_hex <= "1111"; wait for 100 ns;        

        

        -- Report a note at the end of stimulus process
        report "Stimulus process finished" severity note;
        wait;
    end process p_stimulus;
```

### Screenshot with simulated time waveforms

![min](pictures/segment.png)


### Listing of VHDL code from source file

```vhdl
    -- Instance (copy) of hex_7seg entity
    hex2seg : entity work.hex_7seg
        port map(
            hex_i    => SW,
            seg_o(6) => CA,
            seg_o(5) => CB,
            seg_o(4) => CC,
            seg_o(3) => CD,
            seg_o(2) => CE,
            seg_o(1) => CF,
            seg_o(0) => CG
        );
```

## 3. LED(7:4) indicators

### Truth table and listing of VHDL code for LEDs(7:4)

| **Hex** | **Inputs** | **LED4** | **LED5** | **LED6** | **LED7** |
| :-: | :-: | :-: | :-: | :-: | :-: |
| 0 | 0000 |  |  |  |  |
| 1 | 0001 |  |  |  |  |
| 2 | 0010 |  |  |  |  |
| 3 | 0011 |  |  |  |  |
| 4 | 0100 |  |  |  |  |
| 5 | 0101 |  |  |  |  |
| 6 | 0110 |  |  |  |  |
| 7 | 0111 |  |  |  |  |
| 8 | 1000 |  |  |  |  |
| 9 | 1001 |  |  |  |  |
| A | 1010 |  |  |  |  |
| b | 1011 |  |  |  |  |
| C | 1100 |  |  |  |  |
| d | 1101 |  |  |  |  |
| E | 1110 |  |  |  |  |
| F | 1111 |  |  |  |  |

### Screenshot with simulated time waveforms
