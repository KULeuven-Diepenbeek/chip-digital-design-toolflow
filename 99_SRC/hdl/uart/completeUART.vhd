--------------------------------------------------------------------------------
-- ACRO - KHLim - Embedded Systems & Security
--------------------------------------------------------------------------------
-- Module Name:     <entity> - <Structural - Behavioral - RTL>
-- Project Name:    <optional>
-- Description:     <Describe the (black box) function of each entity / package in the file>
--                  <More info>
--
-- Revision     Date       Author     Comments
-- v0.1         <yymmdd>   <name>     Initial version
--
--------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity completeUART is
  generic ( CLK_FREQ  : natural := 100;     -- system clock frequency in MHz
            BAUD_RATE : natural := 115200; -- desired baud rate
            DATA_BITS : natural := 8);     -- # data bits)
  port( reset   : in  std_logic;
        clock   : in  std_logic;
        rx_req  : in  std_logic;
        rx_data : out std_logic_vector(7 downto 0);
        rx_pin  : in  std_logic;
        tx_req  : in  std_logic;
        tx_data : in  std_logic_vector(7 downto 0);
        tx_pin  : out  std_logic
  );
end completeUART;

architecture behavior of completeUART is

  component uart_Core is
    generic ( CLK_FREQ  : natural := 50;     -- system clock frequency in MHz
              BAUD_RATE : natural := 115200; -- desired baud rate
              DATA_BITS : natural := 8);     -- # data bits
    port ( -- System
         Rst : in std_logic; -- active high reset signal
         Clk : in std_logic; -- system clock

         -- UART
         Rx  : in std_logic;  -- data receive
         Tx  : out std_logic; -- data transmit

         -- Interface
         RxData : out std_logic_vector(DATA_BITS - 1 downto 0);
         RxRdy  : out std_logic; -- there is data to be read on RxData
         RxRead : in  std_logic; -- signal that data has been read
         RxOFl  : out std_logic; -- Overflow on received data port

         TxData  : in  std_logic_vector(DATA_BITS - 1 downto 0);
         TxFull  : out std_logic; -- no more TxData can be written in the UART
         TxWrite : in std_logic;  -- write data into the transmitter
         TxOFl   : out std_logic; -- Overflow on transmitter data port

         -- debug
         BitClkX8 : out std_logic; -- bit clock at speed 8
         RxSample : out std_logic); -- sample puls on RX
  end component;

  component fifo_fallthrough
  port (
    clk : IN STD_LOGIC;
    rst : IN STD_LOGIC;
    din : IN STD_LOGIC_VECTOR(7 DOWNTO 0);
    wr_en : IN STD_LOGIC;
    rd_en : IN STD_LOGIC;
    dout : OUT STD_LOGIC_VECTOR(7 DOWNTO 0);
    full : OUT STD_LOGIC;
    empty : OUT STD_LOGIC
  );
  end component;

  signal rx_pin_i, tx_pin_i : std_logic;
  signal rx_rd_en, rx_wr_en : std_logic;
  signal rx_din, rx_dout : std_logic_vector(7 downto 0);
  signal tx_rd_en, tx_wr_en, tx_busy, tx_empty : std_logic;
  signal tx_din, tx_dout : std_logic_vector(7 downto 0);

begin

  -- IO interfacing
  rx_rd_en <= rx_req;
  rx_data <= rx_dout;
  rx_pin_i <= rx_pin;

  tx_wr_en <= tx_req;
  tx_din <= tx_data;
  tx_pin <=  tx_pin_i;

  -- combinatorial
  tx_rd_en <= not(tx_empty) AND NOT(tx_busy);

  uart: component uart_Core generic map(CLK_FREQ => CLK_FREQ, BAUD_RATE => BAUD_RATE, DATA_BITS => DATA_BITS) port map(
    Rst => reset,
    Clk => clock,
    Rx => rx_pin_i,
    Tx => tx_pin_i,
    RxData => rx_din,
    RxRdy => rx_wr_en,
    RxRead => rx_wr_en,
    RxOFl => open,
    TxData => tx_dout,
    TxFull => tx_busy,
    TxWrite => tx_rd_en,
    TxOFl => open,
    BitClkX8 => open,
    RxSample => open
  );

  RX_FIFO : component fifo_fallthrough
  PORT MAP (
    clk => clock,
    rst => reset,
    din => rx_din,
    wr_en => rx_wr_en,
    rd_en => rx_rd_en,
    dout => rx_dout,
    full => open,
    empty => open
  );

  TX_FIFO : component fifo_fallthrough
  PORT MAP (
    clk => clock,
    rst => reset,
    din => tx_din,
    wr_en => tx_wr_en,
    rd_en => tx_rd_en,
    dout => tx_dout,
    full => open,
    empty => tx_empty
  );

end architecture;
