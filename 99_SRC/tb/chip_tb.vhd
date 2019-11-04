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
      Port ( reset : in  STD_LOGIC;
             clock : in  STD_LOGIC;
             start : in  STD_LOGIC;
  			     rx : in STD_LOGIC;
             tx : out STD_LOGIC;
             busy : out STD_LOGIC;
             ready : out STD_LOGIC);
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
  signal reset   : std_logic                    := '1';

  signal start, busy, ready : std_logic;
  signal chip_rx, chip_tx, rx, tx : std_logic;
  signal rx_req, tx_req : std_logic;
  signal rx_data, tx_data : std_logic_vector(7 downto 0);

shared variable endsim : boolean := false;

begin

chip_rx <= tx;
rx <= chip_tx;

-- instantiate the unit under test (uut)
uut : AES_CHIP
Port map (
  reset => reset,
  clock => clock,
  start => start,
	rx => chip_rx,
  tx => chip_tx,
  busy => busy,
  ready => ready
);

uart : component completeUART
port map(
  reset   => reset,
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
    -- hold reset state.
    tx_data <= (others => '0');
    rx_req <= '0';
    tx_req <= '0';
    reset <= '1';
    start <= '0';
    wait for 100 ns;

    wait for clk_period;
    reset <= '0';

    wait for clk_period*4;

    --[extra_tests]
 		check_cyphertext(x"7da7abd6b16631a07a6cc186b3e79949", x"85e6e72f5709b97e7035e5f43bd59e86", x"94e0c31ea7fef750f5d78bee111cbef0");
 		check_cyphertext(x"b232977350752e4c1daffff01f86e57f", x"63ed8001cf6d7f29fc36c7e273c5e4b6", x"69512ba97786a8f7b22e0f14f5953bb7");
 		check_cyphertext(x"59efae276a6af1efd4bb3ea2a4abec2f", x"61f8d3b3909a68305e096d699fdfee7a", x"e2bec9e85968a29d31712ce8c1258899");
 		check_cyphertext(x"70499b472c9182ebb040b9e450f22e2f", x"91517f504faf4c42bc7a7324a05e87e1", x"970dd9a66f9f68697efa976ae367d4a7");
 		check_cyphertext(x"a78bfdd231b2c36e298a6365df03fd77", x"79ad2ee633c869212a5ed0404c9b413e", x"6a124102ee09fa5dcd6363e5bea53248");
 		check_cyphertext(x"3dc8943281406a3b9d16a04e8febc666", x"e140f1634a49a264b154587d76e04188", x"283d4b8e49dcf67055645792a42da48c");
 		check_cyphertext(x"b31b171b0e66f655aa149d4e99ea366f", x"77afd1a35da99c455277de768fa97af8", x"b041fa9a9b1bef920974d01810c758ad");
 		check_cyphertext(x"364c0c771ebeda2472107892a732b240", x"329d7ac83dd36a3e85ebeeba96f6bb0a", x"d8f80a4df7bb01ea5f86855b07f54820");
 		check_cyphertext(x"e436fdb6197494e421acf84c6983e896", x"c89569c9a78c9976ed88fb063a756b5f", x"f9df1d9752d61bc62ebb2d16886d64ac");
 		check_cyphertext(x"73f0522030b286b17110e198aeab0f66", x"32628db519e466a6bd62916b41b0dc00", x"b3ce9f27e212358a10e70b612dca816d");
 		check_cyphertext(x"16a63b038ef88832459d2ec98a9ded09", x"33de3d38ab5f6841d609c5ccfefbb3b7", x"f54183ce69ddd47abaa48e3ec03c72e2");
 		check_cyphertext(x"b2ffcc2af827d19b1deea27130cabc64", x"d3e8bffbac949a5b4a23c015e5cd8904", x"1672d41d6a8111a69930f7aec6d7444e");
 		check_cyphertext(x"64094e2967af0c4348f721b84330ed91", x"3ad759ac779d6bb624a0067cadf08a1a", x"9c8aae4fa787afcc2cab4c9d9646e475");
 		check_cyphertext(x"f9157f4e38f389d1b9f83b7ed3c24041", x"33c5d1fc6dbd35bc8d4bb93d8bc59405", x"f874cdf08b36cfe4213c06a1ea164c23");
 		check_cyphertext(x"62b608bc548edf839eb41c40d59c00f9", x"b6169d4c4aa484608593322394933df0", x"4ed9226c6384f6609e8fc203c6353711");
 		check_cyphertext(x"427b2f243617e90ffb6439c78c5d2902", x"27aba22d28757304302cbb90ec758c28", x"2788577ed8f920edd32a8cf581d2f991");
 		check_cyphertext(x"004c0ccda78c059ebc47e0631926b6d4", x"8675811601fa6cf252cc7ed801b9ee38", x"968b108315ee0bcd9f80ca0f6be9a6d8");
 		check_cyphertext(x"49c02e02d0637f1cb85662a8516edfff", x"20667cdaa0996227da68b4fe37b8a325", x"f82264099fa7d9248d5054f01331f631");
 		check_cyphertext(x"aff06f9a55b0b01b12a8396b93955d2b", x"1563b50f5174ffc36086f458ca5ec83e", x"4c48d69b7e4f202cf21f03f3c73b7ce3");
 		check_cyphertext(x"7eb2050859ae2b1e0e4a6c2e1c904127", x"a2385c411e3b184f2a4e13300460e661", x"07fecd04a25d4ca8f4a1f23eb8e11b5b");
 		check_cyphertext(x"f962ec332276c0aece520ff03a24dbcb", x"c156f01fb7a08431caa2f49e96d35b87", x"fe9dc8c07773d6a81d345e051b50ca64");
 		check_cyphertext(x"a02d85e50fc92aa4449df718992969e0", x"c3f3ab0e9fbe9f4913e3434e9730bda1", x"a5c49ceb920075bec53c8c198f46358d");
 		check_cyphertext(x"4e108b9c0391fcc2df03da824b2e61ec", x"5bfd189e58ae14d3536dd05617ede51a", x"7ac2a7a16a43838e50b4e18d256aa91f");
 		check_cyphertext(x"07315bf393bbbb57e65da678ae996a68", x"bc30106644efb8a0077d7bfdc6a34045", x"673abb07bf6357bd0a428368599eb216");
 		check_cyphertext(x"52e2c184e97ca0942faeffdfb40444f3", x"c148f7a5d7c21830de6ca8227d0c4da1", x"fac7df8f6ef9f10628849817ba11ccfc");
 		check_cyphertext(x"40e899fa4be39d309b28c7a9e8abeae2", x"1c7bb5c535c43fb53fed8728687ed0bd", x"829c2f58e4a2340e13cfb36212be0da9");
 		check_cyphertext(x"dba4085fc11f82a11d6093fccaa4a502", x"55249a389aefef06964531f9f59f3767", x"807126c992039e84f8e245762a696d49");

    endsim := true;
    report "*** SUCCESS *** end of simulation";
    wait;

    end process;

    end;
