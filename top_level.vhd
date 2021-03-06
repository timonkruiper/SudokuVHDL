LIBRARY IEEE;
USE IEEE.std_logic_1164.ALL;
USE IEEE.numeric_std.ALL;

ENTITY top_level IS
  PORT (
        reset_btn: IN std_logic;
        reset_rpi: IN std_logic;
        clk : IN std_logic;

        sclk : IN std_logic;
        ss_n : IN std_logic;
        mosi : IN std_logic;
        miso : OUT std_logic;

        btn_state: IN std_logic;
        led_state: OUT std_logic_vector(2 downto 0);
        sw_debug: IN std_logic;
        sw_mode: IN std_logic;

        raspi_receive: IN std_logic;
        raspi_send: OUT std_logic;

        sw_location: IN unsigned(7 downto 0);
        HEX0, HEX1, HEX2, HEX5: OUT std_logic_vector(6 downto 0)
    );		
END ENTITY top_level;

ARCHITECTURE bhv of top_level IS

    COMPONENT sudoku IS
  PORT (
            clk: IN std_logic;
            reset_btn: IN std_logic;
            reset_rpi: IN std_logic;

            spi_data_receive: IN std_logic_vector(7 downto 0);
            spi_data_valid: IN std_logic;

            spi_data_send: OUT std_logic_vector(7 downto 0);
            spi_write_enable: OUT std_logic;
            spi_data_request: IN std_logic;

            btn_state: IN std_logic;
            led_state: OUT std_logic_vector(2 downto 0);

            sw_debug: IN std_logic;
            sw_mode: IN std_logic;

            raspi_receive: IN std_logic;
            raspi_send: OUT std_logic;

            sw_location: IN unsigned(7 downto 0);
            HEX0, HEX1, HEX2, HEX5: OUT std_logic_vector(6 downto 0)
    );    
    END COMPONENT sudoku;

    COMPONENT spi_slave is
        Generic (   
            N : positive := 32;                                             -- 32bit serial word length is default
            CPOL : std_logic := '0';                                        -- SPI mode selection (mode 0 default)
            CPHA : std_logic := '0';                                        -- CPOL = clock polarity, CPHA = clock phase.
            PREFETCH : positive := 3);                                      -- prefetch lookahead cycles
        Port (  
            clk_i : in std_logic := 'X';                                    -- internal interface clock (clocks di/do registers)
            spi_ssel_i : in std_logic := 'X';                               -- spi bus slave select line
            spi_sck_i : in std_logic := 'X';                                -- spi bus sck clock (clocks the shift register core)
            spi_mosi_i : in std_logic := 'X';                               -- spi bus mosi input
            spi_miso_o : out std_logic := 'X';                              -- spi bus spi_miso_o output
            di_req_o : out std_logic;                                       -- preload lookahead data request line
            di_i : in  std_logic_vector (N-1 downto 0) := (others => 'X');  -- parallel load data in (clocked in on rising edge of clk_i)
            wren_i : in std_logic := 'X';                                   -- user data write enable
            wr_ack_o : out std_logic;                                       -- write acknowledge
            do_valid_o : out std_logic;                                     -- do_o data valid strobe, valid during one clk_i rising edge.
            do_o : out  std_logic_vector (N-1 downto 0);                    -- parallel output (clocked out on falling clk_i)
            --- debug ports: can be removed for the application circuit ---
            do_transfer_o : out std_logic;                                  -- debug: internal transfer driver
            wren_o : out std_logic;                                         -- debug: internal state of the wren_i pulse stretcher
            rx_bit_next_o : out std_logic;                                  -- debug: internal rx bit
            state_dbg_o : out std_logic_vector (3 downto 0);                -- debug: internal state register
            sh_reg_dbg_o : out std_logic_vector (N-1 downto 0)              -- debug: internal shift register
        );                      
    end COMPONENT spi_slave;

    SIGNAL spi_data_receive_wire: std_logic_vector(7 downto 0);
    SIGNAL spi_data_send_wire: std_logic_vector(7 downto 0);

    SIGNAL spi_data_valid_wire: std_logic;
    SIGNAL spi_write_enable_wire: std_logic;
    SIGNAL spi_data_request_wire: std_logic;

BEGIN

    sud: sudoku PORT MAP(
        clk => clk,
        reset_btn => reset_btn,
        reset_rpi => reset_rpi,

        spi_data_receive => spi_data_receive_wire,
        spi_data_send => spi_data_send_wire,

        spi_data_valid => spi_data_valid_wire,

        spi_write_enable => spi_write_enable_wire,
        spi_data_request => spi_data_request_wire,

        btn_state => btn_state,
        led_state => led_state,
        sw_location => sw_location,
        sw_debug => sw_debug,
        sw_mode => sw_mode,

        raspi_send => raspi_send,
        raspi_receive => raspi_receive,
        HEX0 => HEX0,
        HEX1 => HEX1,
        HEX2 => HEX2,
        HEX5 => HEX5
        );

    sp_s: spi_slave GENERIC MAP(N => 8) PORT MAP(
            clk_i => clk,
            spi_ssel_i => ss_n,
            spi_sck_i => sclk,
            spi_mosi_i => mosi,
            spi_miso_o => miso,
            di_req_o => spi_data_request_wire,
            di_i => spi_data_send_wire,
            wren_i => spi_write_enable_wire,
            wr_ack_o => open,
            do_valid_o => spi_data_valid_wire,
            do_o => spi_data_receive_wire
        );



END bhv;