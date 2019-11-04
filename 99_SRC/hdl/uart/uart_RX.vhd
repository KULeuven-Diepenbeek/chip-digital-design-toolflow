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

entity uart_rx is
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
end uart_rx;

architecture RTL of uart_rx is

  type tRxState is (sIdle, sStart, sData, sStop, sDone);
  signal RxState, next_RxState : tRxState;

  signal tick : std_logic;

  signal Rx_d, Rx_data : std_logic;

  signal RxBitSampleCntr : natural range 0 to 7;
  signal ClrRxSampleCntr : std_logic;
  signal RxSampleTick : std_logic;

  signal RxBitCntr : natural range 0 to DATA_BITS - 1;
  signal ClrRxBitCntr : std_logic;

  signal RxShiftData : std_logic_vector (DATA_BITS - 1 downto 0);

  signal RxRdy_i : std_logic;
  signal EnRxOutReg : std_logic;


begin
  tick <= BitClkX8;

p_Rx_d : process (Rst, Clk)
begin
  if Rst = '1' then
    Rx_d <= '1';
	 Rx_data <= '1';
  elsif Clk'event and Clk = '1' then
    if tick = '1' then
      Rx_d  <= Rx;
		Rx_data <= Rx_d;
    end if;
  end if;
end process p_Rx_d;

p_RxBitSampleCntr : process(Rst, Clk)
begin
  if Clk'event and Clk = '1' then
    if ClrRxSampleCntr = '1' then
      RxBitSampleCntr <= 2;
    elsif tick = '1' then
      if RxBitSampleCntr = 0 then
        RxBitSampleCntr <= 7;
      else
        RxBitSampleCntr <= RxBitSampleCntr - 1;
      end if;
    end if;
  end if;
end process p_RxBitSampleCntr;

  RxSampleTick <= '1' when (RxBitSampleCntr = 0 and tick ='1') else '0';
  RxSample <= RxSampleTick;

p_RxBitCntr : process(Clk)
begin
  if Clk'event and Clk = '1' then
    if ClrRxBitCntr = '1' then
      RxBitCntr <= 0;
    elsif RxSampleTick = '1' then
      if RxBitCntr < DATA_BITS - 1 then
        RxBitCntr <= RxBitCntr + 1;
      else
        RxBitCntr <= 0;
      end if;
    end if;
  end if;
end process p_RxBitCntr;

p_RxFSMNext : process (RxState, RxSampleTick, Rx_data, RxBitCntr)
begin
  next_RxState <= RxState;
  case RxState is
    when sIdle =>
      if Rx_data = '0' then
        next_RxState <= sStart;
      end if;
    when sStart =>
      if RxSampleTick = '1' then
		  if Rx_data = '0' then -- start conditions
          next_RxState <= sData;
		  else
		    next_RxState <= sIdle;
		  end if;
      end if;
    when sData =>
      if RxSampleTick = '1' and RxBitCntr = (DATA_BITS - 1) then
        next_RxState <= sStop;
      end if;
    when sStop =>
     if RxSampleTick = '1' then
        next_RxState <= sDone;
      end if;
    when sDone =>
        next_RxState <= sIdle;
    when others =>
      next_RxState <= sIdle;
  end case;
end process p_RxFSMNext;

p_RxFSMClk : process(Rst, Clk)
begin
  if Rst = '1' then
    RxState <= sIdle;
  elsif Clk'event and Clk = '1' then
    RxState <= next_RxState;
  end if;
end process p_RxFSMClk;

p_RxFSMOut : process (RxState)
begin
  case RxState is
    when sIdle =>
      ClrRxBitCntr    <= '1';
      ClrRxSampleCntr <= '1';
      EnRxOutReg      <= '0';
    when sStart =>
      ClrRxBitCntr    <= '1';
      ClrRxSampleCntr <= '0';
      EnRxOutReg      <= '0';
    when sData =>
      ClrRxBitCntr    <= '0';
      ClrRxSampleCntr <= '0';
      EnRxOutReg      <= '0';
    when sStop =>
      ClrRxBitCntr    <= '1';
      ClrRxSampleCntr <= '0';
      EnRxOutReg      <= '0';
    when sDone =>
      ClrRxBitCntr    <= '1';
      ClrRxSampleCntr <= '1';
      EnRxOutReg      <= '1';
    when others =>
      ClrRxBitCntr    <= '1';
      ClrRxSampleCntr <= '1';
      EnRxOutReg      <= '0';
  end case;
end process p_RxFSMOut;

p_RxShiftReg : process(Rst, Clk)
begin
  if Rst = '1' then
    RxShiftData <= (others => '0');
  elsif Clk'event and Clk = '1' then
    if ClrRxBitCntr = '0' and RxSampleTick = '1' then
      RxShiftData <= Rx_data & RxShiftData((DATA_BITS - 1) downto 1); -- LSBit first
    end if;
  end if;
end process;

p_RxOutReg : process(Rst, Clk)
begin
  if Rst = '1' then
    RxData <= (others => '0');
  elsif Clk'event and Clk = '1' then
    if EnRxOutReg = '1' then
      RxData <= RxShiftData;
    end if;
  end if;
end process p_RxOutReg;

p_JKFF_RxRdy : process (Rst, Clk)
begin
  if Rst ='1' then
    RxRdy_i <= '0';
  elsif Clk'event and Clk = '1' then
    if EnRxOutReg = '1' then
      RxRdy_i <= '1';
    elsif RxRead = '1' then
      RxRdy_i <= '0';
    end if;
  end if;
end process p_JKFF_RxRdy;

  RxRdy <= RxRdy_i;

p_JKFF_RxOFl : process (Rst, Clk)
begin
  if Rst ='1' then
    RxOFl <= '0';
  elsif Clk'event and Clk = '1' then
    if RxRead = '1' then
      RxOFl <= '0';
    elsif RxRdy_i = '1' and EnRxOutReg = '1' then
      RxOFl <= '1';
    end if;
  end if;
end process p_JKFF_RxOFl;
end architecture;
