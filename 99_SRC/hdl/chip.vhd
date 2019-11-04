library IEEE;

use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity AES_CHIP is
    Port ( reset : in  STD_LOGIC;
           clock : in  STD_LOGIC;
           start : in  STD_LOGIC;
			     rx : in STD_LOGIC;
           tx : out STD_LOGIC;
           busy : out STD_LOGIC;
           ready : out STD_LOGIC);
end AES_CHIP;

architecture Behavioral of AES_CHIP is

  component AES128 is
      port (    reset : in  STD_LOGIC;
                clock : in  STD_LOGIC;
                ce : in  STD_LOGIC;
  			        input : in STD_LOGIC_VECTOR(127 downto 0);
  			        key : in STD_LOGIC_VECTOR(127 downto 0);
                output : out STD_LOGIC_VECTOR(127 downto 0);
                done : out STD_LOGIC);
  end component;

  component completeUART is
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
  end component;

  type tState is (sIdle, sLoad, sEncrypt, sReadResult, sSend, sDone);
  signal curState, nxtState : tState;

  signal clock_i, reset_i, start_i, ready_i : std_logic;
  signal rx_pin_i, tx_pin_i : STD_LOGIC;
  signal rx_req_i, tx_req_i : STD_LOGIC;
  signal tx_data_i, rx_data_i : std_logic_vector(7 downto 0);
  signal aes_ce_i, aes_done_i : std_logic;

  signal shift_in, load_in, shift_out : std_logic;

  signal pt_key_reg : std_logic_vector(255 downto 0);
  signal plaintext_i, key_i : std_logic_vector(127 downto 0);
  signal ciphertext_i : std_logic_vector(127 downto 0);

  signal load_counter : integer range 0 to 31;
  signal send_counter : integer range 0 to 15;

  signal send_counter_en, load_counter_en : std_logic;

begin

clock_i <= clock;
reset_i <= reset;

start_i <= start;
busy <= aes_ce_i;
ready <= ready_i;

rx_pin_i <= rx;
tx <= tx_pin_i;
tx_data_i <= pt_key_reg(255 downto 248);

shift_in <= load_counter_en; --load_pt_key;
shift_out <= send_counter_en;
plaintext_i <= pt_key_reg(255 downto 128);
key_i <= pt_key_reg(127 downto 0);

-- load_counter_en <= '1' when curState = sLoad else '0';
-- send_counter_en <= '1' when curState = sSend else '0';

PSHIFT : process( clock_i, reset_i )
begin
  if( reset_i = '1' ) then
    pt_key_reg <= (others => '0');
    load_counter <= 0;
  elsif( rising_edge(clock_i) ) then
    if shift_in = '1' then
      pt_key_reg <= pt_key_reg(247 downto 0) & rx_data_i;
    elsif shift_out = '1' then
      pt_key_reg <= pt_key_reg(247 downto 0) & "00000000";
    elsif load_in = '1' then
      pt_key_reg(255 downto 128) <= ciphertext_i;
      pt_key_reg(127 downto 0) <= (others => '0');
    end if;

    if load_counter_en = '1' then
      if load_counter < 31 then
        load_counter <= load_counter + 1;
      else
        load_counter <= 0;
      end if;
    end if;

    if send_counter_en = '1' then
      if send_counter < 15 then
        send_counter <= send_counter + 1;
      else
        send_counter <= 0;
      end if;
    end if;
  end if ;
end process ; --PCTR


-- FSM STATE REGISTER
P_FSM_STATEREG: process(clock_i, reset_i)
begin
  if rising_edge(clock_i) then
    if reset_i = '1' then
      curState <= sIdle;
    else
      curState <= nxtState;
    end if;
  end if;
end process;

-- FSM NEXT STATE FUNCTION
P_FSM_NSF: process(curState, start_i, load_counter, aes_done_i, send_counter)
begin
  nxtState <= curState;

  ready_i <= '0';
  rx_req_i <= '0';
  aes_ce_i <= '0';
  load_in <= '0';
  tx_req_i <= '0';
  load_counter_en <= '0';
  send_counter_en <= '0';

  case curState is
    when sIdle =>
      ready_i <= '1';
      if start_i = '1' then
        nxtState <= sLoad;
      end if;

    when sLoad =>
      rx_req_i <= '1';
      load_counter_en <= '1';
      if load_counter = 31 then
        nxtState <= sEncrypt;
      end if;

    when sEncrypt =>
      aes_ce_i <= '1';
      if aes_done_i = '1' then
        nxtState <= sReadResult;
      end if;

    when sReadResult =>
      load_in <= '1';
      nxtState <= sSend;

    when sSend =>
      tx_req_i <= '1';
      send_counter_en <= '1';
      if send_counter = 15 then
        nxtState <= sIdle;
      end if;


    when others => nxtState <= sIdle;
  end case;
end process;

AESCORE : component AES128
PORT MAP (
  reset => reset_i,
  clock => clock_i,
  ce => aes_ce_i,
  input => plaintext_i,
  key => key_i,
  output => ciphertext_i,
  done => aes_done_i
);

UARTCORE : component completeUART
port map(
  reset   => reset_i,
  clock   => clock_i,
  rx_req  => rx_req_i,
  rx_data => rx_data_i,
  rx_pin  => rx,
  tx_req  => tx_req_i,
  tx_data => tx_data_i,
  tx_pin  => tx_pin_i
);

end Behavioral;
