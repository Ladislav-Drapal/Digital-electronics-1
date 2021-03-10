# Lab. 5

# 1. Preparation tasks
## Figure or table with connection of push buttons on Nexys A7 board

| **Napájení** | **Tlačítko** | **Odpor. dělič** | **Vývod** | **IO** |
| :-: | :-: | :-: | :-: | :-: |
|3,3V|BTNL|dělič|P17|Artix-7|
|3,3V|BTNR|dělič|M17|Artix-7|
|3,3V|BTNU|dělič|M18|Artix-7|
|3,3V|BTND|dělič|P18|Artix-7|
|3,3V|BTNC|dělič|N17|Artix-7|

IO (Artix-7) – port (C12) – +3,3V – resisitor – TL. (BTNRES) – ground ... this is CPU RESET


The LEDs are iluminated when the corresponding switch is placed in the on position.
BTNL, BTNC, BTNR causes them to illuminate either red, blue or green.
Pressing BTND causes them to begin cycling through many colors.
Repeatedly pressing BTND will turn the two LEDs on or off.
Pressing BTNU will trigger a 5 second recording from the onboard PDM microphone.


## Table with calculated values

   | **Time interval** | **Number of clk periods** | **Number of clk periods in hex** | **Number of clk periods in binary** |
   | :-: | :-: | :-: | :-: |
   | 2&nbsp;ms | 200 000 | `x"3_0d40"` | `b"0011_0000_1101_0100_0000"` |
   | 4&nbsp;ms |400 000|`x"6_1A80"`|`b"0110_0001_1010_1000_0000"`|
   | 10&nbsp;ms | 1 000 000|`x"F_4240"`|`b"1111_0100_0010_0100_0000"`|
   | 250&nbsp;ms |25 000 000|`x"17D_7840"`|`b"0001_0111_1101_0111_1000_0100_0000"`|
   | 500&nbsp;ms |50 000 000|`x"2FA_F080"`|`b"0010_1111_1010_1111_0000_1000_0000"`|
   | 1&nbsp;sec | 100 000 000 | `x"5F5_E100"` | `b"0101_1111_0101_1110_0001_0000_0000"` |

# 2. Bidirectional counter
## Listing of VHDL code of the process p_cnt_up_down: 

```vhdl
    p_cnt_up_down : process(clk)
    begin
        if rising_edge(clk) then
        
            if (reset = '1') then       -- Synchronous reset, (pokud bychom chtěli asynchronní, pak by podmínka musela být nad rising..)
                s_cnt_local <= (others => '0'); -- Clear all bits (nevíme, jakou šířku má ten vektor)

            elsif (en_i = '1') then       -- Test if counter is enabled (kdyby byl v 0, pak by se nic nědělo..)


                -- TEST COUNTER DIRECTION HERE


                s_cnt_local <= s_cnt_local + 1;


            end if;
        end if;
    end process p_cnt_up_down;
```


## Listing of VHDL reset and stimulus processes from testbench file tb_cnt_up_down.vhd:

```vhdl
   p_reset_gen : process
    begin
        s_reset <= '0';
        wait for 28 ns;
        
        -- Reset activated
        s_reset <= '1';
        wait for 153 ns;

        -- Reset deactivated
        s_reset <= '0';

        wait;
    end process p_reset_gen;

    --------------------------------------------------------------------
    -- Data generation process
    --------------------------------------------------------------------
    p_stimulus : process
    begin
        report "Stimulus process started" severity note;

        report "Stimulus process finished" severity note;
        wait;
    end process p_stimulus;
```

## Screenshot with simulated time waveforms

![min](pictures/obr.1.png)
![min](pictures/obr.2.png)


# 3. Top level
## Listing of VHDL code from source file top.vhd:

```vhdl
architecture Behavioral of top is

    -- Internal clock enable
    signal s_en  : std_logic;
    -- Internal counter
    signal s_cnt : std_logic_vector(4 - 1 downto 0);

begin

    --------------------------------------------------------------------
    -- Instance (copy) of clock_enable entity
    clk_en0 : entity work.clock_enable
        generic map(
        
        g_MAX => 100000000
            --- WRITE YOUR CODE HERE
        )
        port map(
        
           clk     =>   CLK100MHZ,
           reset   =>   BTNC,
           ce_o    =>   s_en
            --- WRITE YOUR CODE HERE
        );

    --------------------------------------------------------------------
    -- Instance (copy) of cnt_up_down entity
    bin_cnt0 : entity work.cnt_up_down
        generic map(
        
        g_CNT_WIDTH => 4
            --- WRITE YOUR CODE HERE
        )
        port map(
        
        clk        =>   CLK100MHZ,
        reset      =>   BTNC,
        en_i       =>   s_en,
        cnt_up_i   =>   SW(0),
        cnt_o      =>   s_cnt
        
            --- WRITE YOUR CODE HERE
        );

    -- Display input value on LEDs
    LED(3 downto 0) <= s_cnt;

    --------------------------------------------------------------------
    -- Instance (copy) of hex_7seg entity
    hex2seg : entity work.hex_7seg
        port map(
            hex_i    => s_cnt,
            seg_o(6) => CA,
            seg_o(5) => CB,
            seg_o(4) => CC,
            seg_o(3) => CD,
            seg_o(2) => CE,
            seg_o(1) => CF,
            seg_o(0) => CG
        );

    -- Connect one common anode to 3.3V
    AN <= b"1111_1110";

end architecture Behavioral;

```

## Image of the top layer including both counters

![min](pictures/schema.jpeg)






