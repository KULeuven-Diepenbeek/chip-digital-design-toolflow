--------------------------------------------------------------------------------
-- KU Leuven - ESAT/COSIC- Embedded Systems & Security
--------------------------------------------------------------------------------
-- Module Name:     <entity> - <structural - behavioral - RTL - mixed>
-- Project Name:    <optional>
-- Description:     <Describe the (black box) function of each entity / package in the file>
--                  <More info>
--
-- Revision     Date       Author     Comments
-- v0.1         20190101   VlJo       Initial version
--
--------------------------------------------------------------------------------

library IEEE;
  use IEEE.std_logic_1164.ALL;
  -- use IEEE.numeric_std.ALL;
  use IEEE.std_logic_arith.ALL;
--use ieee.std_logic_misc.or_reduce;

entity fifo_fallthrough is
  generic (
    G_DATAWIDTH : integer := 8;
    G_DEPTH : integer := 32
  );
  port (
    clk : in STD_LOGIC;
    rst : in STD_LOGIC;
    din : in STD_LOGIC_VECTOR(G_DATAWIDTH-1 downto 0);
    wr_en : in STD_LOGIC;
    rd_en : in STD_LOGIC;
    dout : out STD_LOGIC_VECTOR(G_DATAWIDTH-1 downto 0);
    full : out STD_LOGIC;
    empty : out STD_LOGIC
  );
end entity fifo_fallthrough;

architecture Behavioural of fifo_fallthrough is

  -- (de-)localising
  signal reset_i, clock_i : STD_LOGIC;
  signal data_in_i : STD_LOGIC_VECTOR(G_DATAWIDTH-1 downto 0);
  signal we_i : STD_LOGIC;
  signal data_out_i : STD_LOGIC_VECTOR(G_DATAWIDTH-1 downto 0);
  signal re_i : STD_LOGIC;
  signal full_i, full_ii : STD_LOGIC;
  signal empty_i, empty_ii : STD_LOGIC;

  signal readcounter, writecounter : integer range 0 to G_DEPTH-1;



  type T_REGFILE is array (0 to G_DEPTH-1) of STD_LOGIC_VECTOR(G_DATAWIDTH-1 downto 0);
  signal regfile : T_REGFILE;
  signal regfile_ld: STD_LOGIC_VECTOR(0 to G_DEPTH-1);

  signal filling_reset, filling_set, filling : STD_LOGIC;

begin

  -------------------------------------------------------------------------------
  -- (DE-)LOCALISING IN/OUTPUTS
  -------------------------------------------------------------------------------
  reset_i <= rst;
  clock_i <= clk;
  data_in_i <= din;
  we_i <= wr_en;
  re_i <= rd_en;
  dout <= data_out_i;
  full <= full_i;
  empty <= empty_i;


  data_out_i <= regfile(readcounter);

  -------------------------------------------------------------------------------
  -- FIFO COUNTERS
  -------------------------------------------------------------------------------
  PCTR : process( clock_i )
  begin
    if( rising_edge(clock_i) ) then
      if( reset_i = '1' ) then
        readcounter <= 0;
        writecounter <= 0;
        full_i <= '1';
        empty_i <= '1';
      else
        if we_i = '1' and full_i = '0' then
          writecounter <= (writecounter + 1) mod G_DEPTH;
        end if;
        if re_i = '1' and empty_i = '0' then
          readcounter <= (readcounter + 1) mod G_DEPTH;
        end if;
        full_i <= full_ii;
        empty_i <= empty_ii;
      end if;
    end if ;
  end process ; --PCTR

  -------------------------------------------------------------------------------
  -- FIFO FLAGS
  -------------------------------------------------------------------------------
  filling_reset <= re_i and not (we_i);
  filling_set <= we_i and not(re_i);

  PSRFF_filling : process( clock_i )
  begin
    if( rising_edge(clock_i) ) then
      if( reset_i = '1' ) then
        filling <= '0';
      else
        if filling_reset = '1' then
          filling <= '0';
        elsif filling_set = '1' then
          filling <= '1';
        end if;
      end if;
    end if ;
  end process ; -- PSRFF_filling

  PFLAGS : process(readcounter, writecounter, filling)
  begin
    full_ii <= '0';
    empty_ii <= '0';

    if readcounter = writecounter then
      if filling = '1' then
        full_ii <= '1';
      else
        empty_ii <= '1';
      end if;
    end if;
  end process;

  -------------------------------------------------------------------------------
  -- FIFO STORAGE
  -------------------------------------------------------------------------------
  REGFILE_LOADSIGNALS : for i in 0 to G_DEPTH-1 generate
    regfile_ld(i) <= we_i when writecounter = i else '0';

    PREGS : process( clock_i )
    begin
      if( rising_edge(clock_i) ) then
        if( reset_i = '1' ) then
          regfile(i) <= (others => '0');
        else
          if regfile_ld(i) = '1' then
            regfile(i) <= data_in_i;
          end if;
        end if;
      end if ;
    end process ; --PREGS

  end generate ; --REGFILE_LOADSIGNALS

end Behavioural;
