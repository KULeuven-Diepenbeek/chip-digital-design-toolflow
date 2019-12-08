library ieee;
use ieee.std_logic_1164.all;
use std.textio.all;
use work.txt_util.all;
use ieee.std_logic_textio.all;

entity CHIP_tb is
end CHIP_tb;

architecture behavior of CHIP_tb is

  -- component declaration for the unit under test (uut)
  component AES_CHIP
      Port ( reset : in STD_LOGIC;
             core_reset : in STD_LOGIC;
             clock : in  STD_LOGIC;
             start : in  STD_LOGIC;
  			     rx : in STD_LOGIC;
             tx : out STD_LOGIC;
             busy : out STD_LOGIC;
             ready : out STD_LOGIC;
             sleep_in : in STD_LOGIC; -- CPF related input
             sleep_out : out STD_LOGIC); -- CPF related output
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

  -- clock period definitions
  constant clk_period : time := 10 ns;

  --cs
  signal clock   : std_logic                    := '0';
  signal reset_i   : std_logic;

  signal start, busy, ready : std_logic;
  signal chip_rx, chip_tx, rx, tx : std_logic;
  signal rx_req, tx_req : std_logic;
  signal rx_data, tx_data : std_logic_vector(7 downto 0);
  signal sleep_in, sleep_out : std_logic;
  signal core_reset_i : std_logic;

shared variable endsim : boolean := false;

begin

chip_rx <= tx;
rx <= chip_tx;

-- instantiate the unit under test (uut)
uut : AES_CHIP
Port map (
  reset => reset_i,
  core_reset => core_reset_i,
  clock => clock,
  start => start,
	rx => chip_rx,
  tx => chip_tx,
  busy => busy,
  ready => ready,
  sleep_in => sleep_in,
  sleep_out => sleep_out
);

uart : component completeUART
port map(
  reset   => reset_i,
  clock   => clock,
  rx_req  => rx_req,
  rx_data => rx_data,
  rx_pin  => rx,
  tx_req  => tx_req,
  tx_data => tx_data,
  tx_pin  => tx
);

-- clock process definitions
clk_process : process
begin
if endsim=false then
clock <= '0';
wait for clk_period/2;
clock <= '1';
wait for clk_period/2;
else
wait;
end if;
end process;


-- stimulus process
stim_proc : process

procedure check_cyphertext(
    constant p            : in std_logic_vector(127 downto 0);
    constant k            : in std_logic_vector(127 downto 0);
    constant c_expected   : in std_logic_vector(127 downto 0)) is
    variable c            :    std_logic_vector(127 downto 0);

  begin
    for I in 0 to 15 loop
      tx_data <= p(127-8*I downto 128-8*(I+1));
      tx_req <= '1';
      wait for clk_period;
    end loop;
    for I in 0 to 15 loop
      tx_data <= k(127-8*I downto 128-8*(I+1));
      tx_req <= '1';
      wait for clk_period;
  	end loop;
    tx_req <= '0';
    wait for 3000000 ns;
    start <= '1';
    wait for clk_period;
    start <= '0';

    wait until busy = '1';
    wait until ready = '1';

    wait for clk_period;
    wait for 1500000 ns;

    for I in 0 to 15 loop
      rx_req <= '1';
      wait for clk_period;
      c(127-8*I downto 128-8*(I+1)) := rx_data;
    end loop;
    rx_req <= '0';

    wait for clk_period;

    assert c /= c_expected
      report "*** SUCCESS *** correct result" & " - " & "ciphertext: " & hstr(c)
      severity note;

    assert c = c_expected
      --report "unexpected failure"
      report "*** FAIL *** unexpected result : " & lf &
      " plaintext = " & hstr(p) & "; " & lf &
      " key = " & hstr(k) & "; " & lf &
      " ciphertext = " & hstr(c) & "; " & lf &
      " ciphertext expected = " & hstr(c_expected)
    severity failure;

    wait for clk_period*2;

    end procedure check_cyphertext;

  begin
    -- hold reset_i state.
    tx_data <= (others => '0');
    rx_req <= '0';
    tx_req <= '0';
    reset_i <= '1';
    core_reset_i <= '1';
    start <= '0';
    sleep_in <= '0';
    wait for 100 ns;

    wait for clk_period;
    reset_i <= '0';
    core_reset_i <= '0';

    wait for clk_period*4;

    --[extra_tests]
 		check_cyphertext(x"7da7abd6b16631a07a6cc186b3e79949", x"85e6e72f5709b97e7035e5f43bd59e86", x"94e0c31ea7fef750f5d78bee111cbef0");

    endsim := true;
    report "*** SUCCESS *** end of simulation";
    wait;

    end process;

    end;
