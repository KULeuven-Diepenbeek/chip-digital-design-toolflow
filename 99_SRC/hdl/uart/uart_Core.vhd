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

entity uart_Core is
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
end uart_Core;

architecture RTL of uart_Core is
  constant SAMPLE_RATE : natural := (CLK_FREQ * 1_000_000)  / (BAUD_RATE * 8); -- sample at 8x
  
component uart_RX is
  generic (DATA_BITS : natural := 8);     -- # data bits
  port ( -- System
         Rst : in std_logic; -- active high reset signal
         Clk : in std_logic; -- system clock
         
         -- UART
         Rx  : in std_logic;  -- data receive
         
         -- Interface
         BitClkX8 : in std_logic; -- bit clock at speed 8
        
         RxData : out std_logic_vector(DATA_BITS - 1 downto 0);
         RxRdy  : out std_logic; -- there is data to be read on RxData
         RxRead : in  std_logic; -- signal that data has been read
         RxOFl  : out std_logic; -- Overflow on received data port

         -- debug
         RxSample : out std_logic); -- sample puls on RX
end component;

component uart_TX is
  generic (DATA_BITS : natural := 8);     -- # data bits
  port ( -- System
         Rst : in std_logic; -- active high reset signal
         Clk : in std_logic; -- system clock
         
         -- UART
         Tx  : out std_logic; -- data transmit
         
         -- Interface
         BitClkX8 : in std_logic; -- bit clock at speed 8
         
         TxData  : in  std_logic_vector(DATA_BITS - 1 downto 0);
         TxFull  : out std_logic; -- no more TxData can be written in the UART
         TxWrite : in std_logic;  -- write data into the transmitter
         TxOFl   : out std_logic); -- Overflow on transmitter data port
end component;
  
  signal preScaler : natural range 0 to SAMPLE_RATE - 1;
  signal tick : std_logic;
  
begin
-- preScaler process: will generate the sample frequency
p_preScaler : process (Rst, Clk)
begin
  if Rst = '1' then
    preScaler <= 0;
  elsif Clk'event and Clk = '1' then
    if preScaler = (SAMPLE_RATE - 1) then
      preScaler <= 0;
      tick <= '1';
    else
      preScaler <= preScaler + 1;
      tick <= '0';
    end if;
  end if;
end process p_preScaler;

  BitClkX8 <= tick;

 comp_uart_rx : uart_rx generic map (DATA_BITS => DATA_BITS)
  port map (Rst => Rst,
            Clk => Clk,
            Rx => Rx,
            BitClkX8 => tick,
            RxData => RxData,
            RxRdy => RxRdy,
            RxRead => RxRead,
            RxOFl => RxOFl,
            RxSample => RxSample);

 comp_uart_tx : uart_tx generic map (DATA_BITS => Data_BITS)
  port map (Rst => Rst,
            Clk => Clk,
            Tx => Tx,
            BitClkX8 => tick,
            TxData => TxData,
            TxWrite => TxWrite,
            TxFull => TxFull,
            TxOFl => TxOFl);            
end architecture;
