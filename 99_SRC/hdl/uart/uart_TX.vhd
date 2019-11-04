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

entity uart_tx is
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
end uart_tx;

architecture RTL of uart_tx is

  type tTxState is (sIdle, sStart, sData, sStop, sDone);
  signal TxState, next_TxState : tTxState;

  signal tick : std_logic;

  signal ClrTxBitSampleCntr : std_logic;
  signal TxBitSampleCntr : natural range 0 to 7;
  signal TxSampleTick : std_logic;

  signal TxBitCntr : natural range 0 to DATA_BITS; -- one more as start bit has to be taken into account
  signal ClrTxBitCntr : std_logic;

  signal TxShiftData : std_logic_vector (DATA_BITS downto 0);

  signal TxFull_i : std_logic;


begin
  tick <= BitClkX8;

p_TxBitSampleCntr : process(Rst, Clk)
begin
  if Clk'event and Clk = '1' then
    if ClrTxBitSampleCntr = '1' then
      TxBitSampleCntr <= 7;
    elsif tick = '1' then
      if TxBitSampleCntr = 0 then
        TxBitSampleCntr <= 7;
      else
        TxBitSampleCntr <= TxBitSampleCntr - 1;
      end if;
    end if;
  end if;
end process p_TxBitSampleCntr;

  TxSampleTick <= '1' when (TxBitSampleCntr = 0 and tick ='1') else '0';

p_TxBitCntr : process(Clk)
begin
  if Clk'event and Clk = '1' then
    if ClrTxBitCntr = '1' then
      TxBitCntr <= 0;
    elsif TxSampleTick = '1' then
      if TxBitCntr < DATA_BITS then
        TxBitCntr <= TxBitCntr + 1;
      else
        TxBitCntr <= 0;
      end if;
    end if;
  end if;
end process p_TxBitCntr;

p_TxFSMNext : process (TxState, TxWrite, TxSampleTick, TxBitCntr)
begin
  next_TxState <= TxState;
  case TxState is
    when sIdle =>
      if TxWrite = '1' then
        next_TxState <= sStart;
      end if;
    when sStart =>
      if TxSampleTick = '1' then
        next_TxState <= sData;
      end if;
    when sData =>
      if TxSampleTick = '1' and TxBitCntr = (DATA_BITS) then
        next_TxState <= sStop;
      end if;
    when sStop =>
     if TxSampleTick = '1' then
        next_TxState <= sDone;
      end if;
    when sDone =>
        next_TxState <= sIdle;
    when others =>
      next_TxState <= sIdle;
  end case;
end process p_TxFSMNext;

p_TxFSMClk : process(Rst, Clk)
begin
  if Rst = '1' then
    TxState <= sIdle;
  elsif Clk'event and Clk = '1' then
    TxState <= next_TxState;
  end if;
end process p_TxFSMClk;

p_TxFSMOut : process (TxState)
begin
  case TxState is
    when sIdle =>
	   ClrTxBitSampleCntr <= '1';
      ClrTxBitCntr  <= '1';
      TxFull_i <= '0';
    when sStart =>
      ClrTxBitSampleCntr <= '0';
		ClrTxBitCntr  <= '0';
      TxFull_i <= '1';
    when sData =>
      ClrTxBitSampleCntr <= '0';
		ClrTxBitCntr  <= '0';
      TxFull_i <= '1';
    when sStop =>
      ClrTxBitSampleCntr <= '0';
		ClrTxBitCntr  <= '0';
      TxFull_i <= '1';
    when sDone =>
	   ClrTxBitSampleCntr <= '1';
      ClrTxBitCntr  <= '1';
      TxFull_i <= '1';
    when others =>
	   ClrTxBitSampleCntr <= '1';
      ClrTxBitCntr  <= '1';
      TxFull_i <= '0';
  end case;
end process p_TxFSMOut;

p_TxShiftReg : process(Rst, Clk)
begin
  if Rst = '1' then
    TxShiftData <= (others => '1');
  elsif Clk'event and Clk = '1' then
    if TxWrite = '1' and TxFull_i = '0' then
      TxShiftData <= TxData & '0'; -- data & start
    elsif ClrTxBitCntr = '0' and TxSampleTick = '1' then
      TxShiftData <= '1' & TxShiftData((DATA_BITS) downto 1); -- LSBit first
    end if;
  end if;
end process p_TxShiftReg;

  Tx <= TxShiftData(0);
  TxFull <= TxFull_i;


p_FF_TxOFl : process (Rst, Clk)
begin
  if Rst ='1' then
    TxOFl <= '0';
  elsif Clk'event and Clk = '1' then
      TxOFl <= TxFull_i and TxWrite;
  end if;
end process p_FF_TxOFl;
end RTL;
