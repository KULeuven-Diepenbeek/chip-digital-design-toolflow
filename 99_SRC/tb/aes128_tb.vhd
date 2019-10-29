library ieee;
use ieee.std_logic_1164.all;
use std.textio.all;
use work.txt_util.all;
use ieee.std_logic_textio.all;

entity AES128_tb is
end AES128_tb;

architecture behavior of AES128_tb is

  -- component declaration for the unit under test (uut)
  component AES128
    port(
      reset : in  std_logic;
      clock   : in  std_logic;
      ce  : in  std_logic;
      input : in std_logic_vector(127 downto 0);
      key  : in std_logic_vector(127 downto 0);
      output : out std_logic_vector(127 downto 0);
      done : out std_logic
    );
  end component;

  -- clock period definitions
  constant clk_period : time := 10 ns;

  --cs
  signal key     : std_logic_vector(127 downto 0) := (others => '0');
  signal clock   : std_logic                    := '0';
  signal reset   : std_logic                    := '1';
  signal ce      : std_logic                    := '0';
  signal done    : std_logic;

  signal input  : std_logic_vector(127 downto 0) := (others => '0');
  signal output : std_logic_vector(127 downto 0) := (others => '0');

shared variable endsim : boolean := false;

begin

-- instantiate the unit under test (uut)
uut : AES128 port map (
  reset => reset,
  clock   => clock,
  ce  => ce,
  input   => input,
  key => key,
  output => output,
  done => done
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
    input <= p;
    key <= k;
    ce  <= '1';
    wait for clk_period;
    wait until done = '1';
    wait for clk_period;
    ce <= '0';

    c := output;

    wait for clk_period*1.5;

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

    end procedure check_cyphertext;

  begin
    -- hold reset state.
    reset <= '1';
    wait for 100 ns;

    wait for clk_period;
    reset <= '0';

    wait for clk_period*4;

    --[extra_tests]
 		check_cyphertext(x"40e899fa4be39d309b28c7a9e8abeae2", x"1c7bb5c535c43fb53fed8728687ed0bd", x"829c2f58e4a2340e13cfb36212be0da9");
 		check_cyphertext(x"dba4085fc11f82a11d6093fccaa4a502", x"55249a389aefef06964531f9f59f3767", x"807126c992039e84f8e245762a696d49");
 		check_cyphertext(x"0818196306709106e80fa8b8df0c2459", x"34b697633873827bd7ce2acb5368003f", x"36b649afd65c69c5cb169918e811392e");
 		check_cyphertext(x"d77f2fd5e0ee4c21c4f7ed8ab2ba9b88", x"81f33591764a9e3884f4baeb784fb753", x"d67234078b60b2a92187067f4e2e4af4");
 		check_cyphertext(x"c5ad872a62b416cdd6101e2bb73865a4", x"0fb9d2779269949d0a80b06657ab93ab", x"e11597ead6fbe40e3d3c722bafd39eb2");
 		check_cyphertext(x"f96885369b31995cb2c0151baeca1378", x"d2537bcdfa2b6b89b3fbb5240531f6a9", x"3f94ee78de3b9a27d7a6d9304b7dfd4d");
 		check_cyphertext(x"ad410233d686a4f7ddf7523a1fb35d6f", x"d06d9bd6333b5f14b6c08abfb151828a", x"6503a31661a5302e972d8f608f2affb4");
 		check_cyphertext(x"298974fe94639ba71da6793b6a9f6d6e", x"66e6d0e9552cbd2950a9d1f2ae6bcc98", x"4377833821bb8033466cee583fbe1ab4");
 		check_cyphertext(x"7bfcf6da91b91f5bf3c74949f590c631", x"212df894be52caa3a7d8a4b0467a0a98", x"9b9c8eac90d30e2ea403f3f1799ce7bc");
 		check_cyphertext(x"94b3cd684fb60beef54dd7b4a3670df2", x"ef8f915143aa26afcbcdac64315dd6ed", x"ee52ab4107b2df90473a0c4773da4808");
 		check_cyphertext(x"09a34db65c43a270e9686ad00b7caab1", x"ec2c634d57b21cf0f2eac1a1b8eb4575", x"f5602ac3dc7663978b275e9a43775949");
 		check_cyphertext(x"c03eef6253340912d9c0543d7ce4934c", x"36e811933eee920a7382a32a7cdb98d4", x"0bb1a067f013e9e75aec4dc8855d7292");
 		check_cyphertext(x"04414df594ee1f3247382daf2bee2d56", x"f3b8c4f5b180e0386a35804f572f4a66", x"e0c5d752ffa55f187a23cbee907d796f");
 		check_cyphertext(x"80d90d227a9986ef781b9fb5fad47f9a", x"db84acb596d51fc2e081c85da70bc90e", x"483f9afbcbd3ef28d06a0cb41b8b9e64");
 		check_cyphertext(x"bd7e98ea85754779db97522dd9ca0b16", x"c48cfb8aa977a69bac5a0a8c7c6e3bc4", x"7eeb8f2a2ad09f2ea9895ec530bc86ec");
 		check_cyphertext(x"75c407fee8c095df825dd7a6a0940186", x"c645db53a16a6b8ab4864a6c4459a9ea", x"124750ef6137f647af542f69339b5448");
 		check_cyphertext(x"61bcced03aeb9ca375111c7a6dad07ee", x"79418bc3998991055a9748f257c6b72a", x"573fb0283d02f239f2aaafbd495faca5");
 		check_cyphertext(x"edc33c4eab145bf2e4edfcd153deb128", x"0a6ad87a3176aabef8330f943e62776f", x"f6b8d3fd2ad2c699012dd2cff97b25cb");
 		check_cyphertext(x"aa9104afdfacebd85893778d6d5065b2", x"20d3e15a6574ebcf621fcdcad085bac8", x"55b9dda62299abb754d124025ae5a1c8");
 		check_cyphertext(x"b6fdac1c98cadefc60bcf73b11c36e3c", x"c35c80129038e0ab861900e7f8b6df07", x"fc840c37aac7a90bb811729c00ae1dbf");
 		check_cyphertext(x"193e09a65f713a42514eedc7efce77dc", x"56b2587e964da0775f5f435d6e4a51d0", x"fe3a65fe7d84904697515c4f5eb6bfe2");
 		check_cyphertext(x"010213307821b86881a7ea8fd34a27e6", x"8e02b0349edddd9cca90bd929e2f636c", x"e536c8db67949d3b57aebb191066fdb6");
 		check_cyphertext(x"e7072ee86a25d0342925db0e828b6d9c", x"81ecca06ae246cef33f99e215de7357c", x"864a2b220b85ab40c5fb42359fa80c93");
 		check_cyphertext(x"f188819496103dab294c76f575d079db", x"d5ebff162d973fcc5906b92b1c9f6984", x"c4f9f136be22b3dfac35234469809a50");
 		check_cyphertext(x"ddcd4df6a1c979a4b4d81761d4d7a1a3", x"caafe7d4c2c7083710df6832fe239254", x"2d21d4fd0e4b597714e7a2b278031fbd");
 		check_cyphertext(x"396fcd176e82914fb0c67bd141d8d272", x"faa1e82f71ec4f6f56969820b26d9817", x"786a37f702984b782fab440ffa7bc71c");
 		check_cyphertext(x"fbccbdfe28d4b1b3aaace099f3da02b8", x"ef67bbc1cb39997fdbe5e95d30c0f9c1", x"e64bcd2be971db3228406c7089c381ed");
 		check_cyphertext(x"359682952787ac6ee9b5d63c4f0584c4", x"1e1a8ae42032789228cd139ef04f133e", x"30f4ecc1e047b8ba87a5225a9a493aac");
 		check_cyphertext(x"e4ca20b54cbcdcfc401b8dc144c8288c", x"0faa4ee6dfef16497a043dfe1b036e4a", x"4a9c10e82613a3897854e4cb1e5216f5");
 		check_cyphertext(x"3f525aa4e1df638df65f40029381f6fa", x"4cae1c7d398d35299efb2ae8d4ba4264", x"a9076d4ff75596a38bffaa4d33b2ccf6");
 		check_cyphertext(x"295a01be0536d1661aee3de6b3afd98c", x"b355df54a564911884792e8ed583f6e0", x"d9b95667291e7220b699c1fe63393f95");
 		check_cyphertext(x"878f4eb97324f1070693772825bb8546", x"2a6499897243b103d1e466c3d8e05f75", x"be94327292af71656927ac859e699a74");
 		check_cyphertext(x"aea460b7392ba9dd9afe25cf2aaec9db", x"1747e07991b1db4ab8969dccf3cbf3d2", x"f9adcd6da49ef719347f46c50153170e");
 		check_cyphertext(x"d39afa6a7413c47fb9487c8feeeb20a6", x"a6445d18f65753d6e905688d1d7b54cb", x"d3f1e96edd31b587550edbe1a76f0001");
 		check_cyphertext(x"4aa64c24103fcd89e4bd27b2ec3094da", x"f6e0f52caea633ebe1b03693b23c8d6d", x"ade56e0e214409382ace16bb951dbd29");
 		check_cyphertext(x"ba2d6f4698d987c3e4b4701a62724b0c", x"4fcf4d00d9302854196d7a076a1672b3", x"08d026d4432a8bc7c82b6553eafb0aac");
 		check_cyphertext(x"e91f7c5f71f51797bae155e4bce9cfd1", x"16cc945f3914cbecdca7f46ca43c4021", x"da88c9c46d48596d93987f3196190795");
 		check_cyphertext(x"08a22e3761c6f05f868fbecfd689fd90", x"5ee7becbd0fc100f2a8d734b2d181bbc", x"551a0e74903750ad6308992f1f4c995b");
 		check_cyphertext(x"617955aefdf2e4e2950ee3172f524866", x"36ebcf0780a9fb9a6fa2f0d193f97596", x"348dfee8622430f7e128b4264a011495");
 		check_cyphertext(x"b68cf7c0c1050ddd547293f5ef3ccccf", x"12884d73412d7f10f608327b7b02a08a", x"0076217a3fbc516d112ff8f1d16a8a5c");
 		check_cyphertext(x"557e6a1484a19a8b5c9896000b099d44", x"1d19ff763e25f4140baf92ecaa8c0237", x"10cd6d6623a728951b7e802dee432e6d");
 		check_cyphertext(x"0168a87952afe98b8322e4142870f118", x"32a7252ad76a0202c3c8dca1678a6be3", x"98d2ef929f7d7e0e7ec9b2d3b207a13d");
 		check_cyphertext(x"b9089a2fed394ef104d8ae9744bd8f1c", x"a195d2bba2802e11a0398b2daa6f6f1c", x"e3ef1e5ace730d0e1b521fe30af9a993");
 		check_cyphertext(x"81691bd39baa0e0240e812f737c9c167", x"83872e58dc02270d85d576496f5e8fba", x"4e09e775f9f58d231baea255c8dcd1a3");
 		check_cyphertext(x"c00d5102dd1380b2799db76713bf59c3", x"90977c3e9c514ab22650541a8e2e4400", x"55a1cc3ac0f8c1d2fbbbf58950b75d44");
 		check_cyphertext(x"62f553355da3b956a2b6968b3040fdbc", x"8179878425ae9dc797c38fce32f100ae", x"e41403622a43026f940f6b877976e58d");
 		check_cyphertext(x"3d02b3f3e37e0827a6fc52ea5152ded0", x"dd753baf5c710525d5d7e47433bc69e0", x"8bcb814a46d251c88a40fbfe94b0a04f");
 		check_cyphertext(x"c09312640aa84a576d55ed001ea0f6b8", x"7995530ce74a81baf2ae28ac12364d4a", x"5041152b65363ffae87b5c9d3dd4a73f");
 		check_cyphertext(x"0168157fd8ae6cdf1970a6e3cbdef4b6", x"b1ea6ff20cd92001f6fdb475dbf446b6", x"608e5594cdc2003765970281ab67895f");
 		check_cyphertext(x"743e8073e8f6bf48d17a31c17ef16510", x"eb0e184c2f186441db8255647fdfcfe3", x"f4d5809b8750ab6d4c4dc2751d232968");
 		check_cyphertext(x"88e2e24523a07f65718f9599c150a051", x"5d77152a3a97d6e354d307abe33adca7", x"03af26292a4290e6be0edd80d6fd9a1e");
 		check_cyphertext(x"872b141b0133cc1613ea14a5069a31e6", x"f1f299ddd6001c7c8205e385a7c6f8c9", x"4a0b0b2b197a0a71c113f08c33f1e9b1");
 		check_cyphertext(x"9c144bd753e5a4ea9cf22064c88c1793", x"041223c7f4c467af4d77d1917d98229a", x"546d001e1443ae5cf4b9f22f3b40007c");
 		check_cyphertext(x"863f9d951c84c2135956c5db0f8ce9e3", x"5fc745b1d92a7096c0ebea16a5cd8635", x"58ff2e82fbed809e5dbfbd39da30a88b");
 		check_cyphertext(x"119f95ea79bf1335ef52e37e032f255e", x"c45ea7eaeb41404be63de58c8041d7a9", x"2872fbf3936b76cd9e2718142615fcb7");
 		check_cyphertext(x"bb219981917f5eabe2d8009f891c17c4", x"4ade9403e75dd616620bd0bdfb85c457", x"d0dd04c9f0f13e643d6c0eef798b016b");
 		check_cyphertext(x"b4bd8a9d70dd0592334c2f9b3e5beb06", x"fe719e1f895a9278b78615069ddcbc3b", x"7fa2832824bd5248af7e0682e5d77d91");
 		check_cyphertext(x"c592cdfe56d01cbca91d4d0b62ca0ffc", x"3fd8ebb188aa62ffcaf3a184b230b899", x"06dae11eaac3fd66e0167187224b2f53");
 		check_cyphertext(x"552a706f6f7b088a5940f9ba5bb5b9ce", x"bd7890d2ea5d9318501ab99b4fa479be", x"1a4b0e15da9b4f7bf03a242ed911f794");
 		check_cyphertext(x"bc2309986c20a4436ca18ce6d8b7a780", x"243ec7279c39856c851f9c7b533679fc", x"ca41320686575abdc1bbc3a2bf191320");
 		check_cyphertext(x"bf94fbf7d6824e88eb4d9d033d845d2a", x"3692456bd55dc60b27a59eb9e38f97c2", x"3253eac6a6ca0a1dbf216e6703d1aa63");
 		check_cyphertext(x"e310072261a4ba92270e9f12faaee127", x"ccfcb253833920e81ed736fa36407b6b", x"c6711d0184e47ccc12653609b7cb0368");
 		check_cyphertext(x"72bcef4fda7a4c0d35f866f4c07489d3", x"ad4be6a9f604bae6932ecba5e52cbaa4", x"837dfbf4b9871db23a652d9f64912fc8");
 		check_cyphertext(x"39adf1845e4c3e054e99022519ac57ef", x"238a6033498dec043a00096da0d8d16f", x"4a97091d1fd1304bb40b521fbf617d40");
 		check_cyphertext(x"e14b26ae1987528e7c2d68d16a269317", x"68c4a417cd3ad138b71d046a5c0280d6", x"022c99db918d0a293f02ecde957a313f");
 		check_cyphertext(x"31e0dc67cbb29cd943a8f0d4cfac20dc", x"4489f31090c893004f366fcfe4d20418", x"e2a8e23c3aab696de5eda1e67f67662d");
 		check_cyphertext(x"afc1c6ef92bd18b1bdcafd0c13fe20a6", x"dc7100af0cae853317927c14fe4ea173", x"0825fd2ba72bd1a55bc29e0f5563ccca");
 		check_cyphertext(x"e11e83ccba153db35502708bf28da530", x"ae2723637768720acdb3b04087a55d07", x"ead223b114b82499d308e2f58588ad20");
 		check_cyphertext(x"d5d4c62b65f083b11ca48f95f0c69589", x"a5ce7aa491613acb6f2ba5fc2a11deb6", x"694fd7a32642c6f967c3140456d28da7");
 		check_cyphertext(x"20abb275e555ea976969e7cbba7e5738", x"110be09003a4338e895a982ebe73d31a", x"7e7403273f67ead89c176276afcc381d");
 		check_cyphertext(x"68c432a7da50910b08a890c46f8f3ae7", x"04790ad5e6b2146f2a3e144926acec29", x"2009ccb0e35a247f3780fb2ea7ed15ec");
 		check_cyphertext(x"0ff062fd00896c0c101379668d98b690", x"db1ef50b2357acc9a6e1993762a18135", x"8c5a0db26d431f141302bc0d64c747da");
 		check_cyphertext(x"128cdfd85ffc36df5400fce3af90dc8e", x"ca3edd1bd6fe7c6a3400018fb3f50751", x"08710dc12f985d70319ba29511415750");
 		check_cyphertext(x"c03b0d160d4682c03c3366f3455a3166", x"58ef7133e33275c818f251faf651aa52", x"0d1e7e0f688003357ae9b66d1d39485a");
 		check_cyphertext(x"72e266bc1a1c823e8eea7f11fe96ea18", x"bf1a5e8024e4c689c72bd004938bab73", x"7ac13f3a1f036c8dc7ee482084ecc79a");
 		check_cyphertext(x"a650ef400ba6ae83fc9b98d9c7b1702c", x"f9b6672fc1483a4fcc199b5d0cbeb505", x"ce4a9ad79eda9361199c6f8bbdd9119f");
 		check_cyphertext(x"f681c145e27f803faec079ce83986e3c", x"3e2db860b35066f421a0c2665043b63a", x"9ad83617008aadc06e87a5d9176010d4");
 		check_cyphertext(x"8aae1a364e38b12500f05901daf3177e", x"933d40d0d46b9bdcb03c6f4ee34a6356", x"f35007fddc462b24cbe587e158bbdd6a");
 		check_cyphertext(x"ab9f013c54503f88721ed986d7b9c412", x"52bce54616f7bd9a3585e9aafc83053d", x"077acbc31ba4d2ffd78a43ea600dbcea");
 		check_cyphertext(x"62c8fc16086d429b8afb111010de72d4", x"443458ae9521f2cd92f8a82d657fa98c", x"45f7c9dc372b8fb1f0ad9aa1e67b317a");
 		check_cyphertext(x"b6db19ade01fdaed3b9daba11003dbed", x"59237082f26e3fc69d580c28afbc6345", x"9fd6e8a3bb65e983b1c02422d5c97f1f");
 		check_cyphertext(x"ed4493edc99f8ef41baa3095e7ade86f", x"3a8a9a87ec168297e353e0bf8feb2862", x"74c6eb8474f3eca98b9aa4e016b0e13e");
 		check_cyphertext(x"08989650d482f86e292d949e99e1d7b2", x"7b51afcbb77f353f07e8939b52ce3ece", x"aa71bb241d24f3787155d2a4abdffac6");
 		check_cyphertext(x"c597fac22d75ddb91a2f7ca86ae20847", x"0f8aaa52cf09a193d248d595d1ed5367", x"fe0daf6f259dfe5015d88c149345416b");
 		check_cyphertext(x"46f93e55359e2387f7d50c120366b5d2", x"c0ec4f2ec8466ba7f91e7af606b87960", x"907fbe7ac1b628e620786492100092c1");
 		check_cyphertext(x"7f387e3c0f6adea2bb50e6feba22051a", x"3a6d3115b631b15d23362f710d9d0086", x"6bc9cf8c6746ce8b0e581c01c3eef217");
 		check_cyphertext(x"f984434dab540b8fff7150e1efb7d73d", x"3e8730abd58e0bf55d40de7405a8d6ed", x"aec15f35fc7da2013ef21ce3768063fa");
 		check_cyphertext(x"b24786c1f1083bc96a30470913cedac1", x"bf158edb761fb9c79821aa9fb038dbdd", x"61d958b9957a8559122fe3a62f7b44f9");
 		check_cyphertext(x"997980cfa150b3e045faffea69a7af60", x"30f3d7534c1ae6456b66ab652e6ab86a", x"2f239e0c11d5e8a4c813f6448cffa12b");
 		check_cyphertext(x"93fbfd76f42b68ef3c8c4175b0978ed4", x"67868d3957cd5f4ab3a09df9f3ecdf61", x"2da7c9da6462c3e253009ac2953f9ca0");
 		check_cyphertext(x"82286724f4859c16b2632575a9d4e7e2", x"0465d2964b89d6fe9f1d43ef33705383", x"05ba8816d5fd8ca21bd52258aad35ae9");
 		check_cyphertext(x"65fc08db71ded2ff6ce6a60e8c0f8037", x"a483883554d73c98192b2930c8a43576", x"a95ac177db1ac7bcb7a4adf7cd2c3abf");
 		check_cyphertext(x"52a4c638785e8021e9d2526f3f63b9b0", x"a6ea4c372c203443001e28cd8b896b09", x"305f3647cfdd8a23ed13220f01a0dc78");
 		check_cyphertext(x"f3b4c80c4929ad3073277141a85bda70", x"ec76824c090fb69853b43c8fd72e1018", x"3c08abebdedbe2aaf05d452cd892742e");
 		check_cyphertext(x"1069c3dea7825563ef11667a415b4ea5", x"41ba41c2a773e5382a0676ae53bec983", x"58efebb8e04c23e2865b740f90c5312c");
 		check_cyphertext(x"e5e143b7b0f5bba354e8ccbb91016f59", x"1fe22da08acd25f7ac2022ef2059e2e8", x"170dfd841d33e6b1e216dc28e6e3e8de");
 		check_cyphertext(x"c7c6ab091c2dc09fa67f2ccf5c6a3ff0", x"008de05c8326652eb932999fae864706", x"54ff501742b0d0b8fa6312f4fc863684");
 		check_cyphertext(x"5c4c4f1686c34e690bd3e980aa6c7c98", x"b6c86f5bbe4338fd75a2db8d10eb9249", x"74a6698dc539903584b033b7125ab6fe");
 		check_cyphertext(x"6203f807331bc4462b964a8b6df4a5ec", x"aa4eed362d09826dd949e5c100e467ff", x"dbd10389417aa139bb71ce586ba93bd2");
 		check_cyphertext(x"6600fc69916b76db9df8b696f1a6d064", x"aae285f915c9eb68b319c69c32a1795a", x"79aaed2c117026176d692e0ef22bc50c");
 		check_cyphertext(x"35e9029e3af0ccd66c20121d227b1b49", x"59b58b341ea49e128ae99f4be6fc3c43", x"0117ff5c89e60afbb6446dd957a652ca");
 		check_cyphertext(x"a1e2a3966a36810e633b09b1bfe9e9b3", x"84dc2f7e642ab9809b4176836faec653", x"5887c9b86addf314361df0a9c57877bb");
 		check_cyphertext(x"bb7ddc357357658ee2e3cd31fa3a4b28", x"8328b8ce72be90da9706246ce44d1d0c", x"3fe5c7d47db109eac34e6bdb9a2c89a9");
 		check_cyphertext(x"bb9fda1413e7bf25f8cce8064a0f24a4", x"a215fe53983841c923c98907ee962a77", x"f21086f499e09baeabf4f24d4cead900");
 		check_cyphertext(x"1ddcdd84ed8d5996460f9469d8f62a75", x"f47990d20db54b2264cc487f6f5694b3", x"2c2e35e143831cb9d5d12b0e21f0354d");
 		check_cyphertext(x"7a840aeb1f892cc1d4d68328ab9ffceb", x"33fcdc2b0c0e2fcc6326f3f0818de913", x"cd688c695c7929a7ef07b80f05c68c0a");
 		check_cyphertext(x"ae9de74bd2fac6eede0966ece320b681", x"9a61be7fca3243d26eeaf6952575e98f", x"103713bb58b71f5bd3a52a072727cddc");
 		check_cyphertext(x"f5a477c1d38ef12e639e9f5cd9e9e0a9", x"74cdfadce0bb0b9d2a8eeca375951e52", x"c50db20cdf781161126402bffedbc9e5");
 		check_cyphertext(x"9089eaabbad4057eb5f53d8380fbe6a3", x"9286e8f59dc6f96567d6f63927b1b194", x"938a3c5eeb8f0ce75d44e6123d0f298b");
 		check_cyphertext(x"02cb8f71e866e56ec752b8910427a685", x"c524f4afbc37b3c528a4dce0d84eec50", x"b5ba3a59c4781462dd09215768cd73f0");
 		check_cyphertext(x"020c4b402d0588c453a91d29ca646a3f", x"7181538beb83f9cd80ee1f121148b10a", x"aa0715ee8ae9f82f71b63b4f8964a3b0");
 		check_cyphertext(x"046f32929f1f82841a4905868be5dc8c", x"0460efbfd11a275c938f2e0d85fcc807", x"42ee3bf6d83f4c6a67d5584ceb57fa7e");
 		check_cyphertext(x"1703fc06b452579949c3d961287dff73", x"4f8fdceb4aa6eb0f0739762193833477", x"78ebfd4eb67d8e50d6c864f15450f07e");
 		check_cyphertext(x"ef7e0b77f77ea5620869136bc4874b46", x"36de1ccae2a2b4d5564a128e2540e88f", x"2887240da84831f3be5a846277d5fd8b");
 		check_cyphertext(x"e23cd7d2f32d75a12833f32b930de8bf", x"8d70a9916c62b7d7ee7b3db8056e529a", x"2c9acc9d48b8dc2395c76a05cc5fdc06");
 		check_cyphertext(x"b1ce09d52c68efcf1621f8c01baeb013", x"3fd6c165eaea96f49eec2d31f1ecc310", x"81aba3c281e01711ffe79ae036f0cc7d");
 		check_cyphertext(x"ff26f707bd120619d40d94e4cafafcf6", x"3b588327a5e2fd67b1b4a8d47d3243d8", x"cdf5a4021b118fb962098ebcb9092981");
 		check_cyphertext(x"cfe66d763827b26ca32142853b1b78bd", x"3d6d699c662f512784571ef68d7f2887", x"bae75b68e2a7854ec5369606c2717c15");
 		check_cyphertext(x"555f9cd49d3db2fbb44dc1ca7ed39923", x"3574567d19e58c6a17ddcfb2e93c1c71", x"0fa37a102c042b9cb84611d1743a3b89");
 		check_cyphertext(x"39763937d3ca3c91ecd0dec08033e130", x"f2de75b99b839d03f2526865d7f23adc", x"3c2e1717411da0b22eba39cb7792b051");
 		check_cyphertext(x"0ad6ea1cf11ffb87ff67efccc5830f0f", x"eb7650c01ffca7f52c5727854a80a3bb", x"b5c180dcc12cc685aae874af17dd3b24");
 		check_cyphertext(x"3aa717b433e0035864c0d97f3dae9271", x"12d044a506f194c90b32d249b057bfc3", x"61672365144b3cba919f3ddc8dcb33e9");
 		check_cyphertext(x"ccd0bf9aa9a14cb92bb2aae6ef070b65", x"1ee52f485c0980847cc9d0a32f6fde96", x"1ca8a247facb6a3030b54a9944afcac3");
 		check_cyphertext(x"063f278ac2aa0888f06a84add3b1a053", x"90d1b3132defe9ff7ea8411c35e66365", x"482a62a92897d764cdf875ccfe503c12");
 		check_cyphertext(x"a50c0b4b37020677ce83fb75aa03c64c", x"11fd05b6254d49cf93a102b0acd1d45c", x"215af2948fa139f9d41752b6ef36e5e7");
 		check_cyphertext(x"e2fb0db9b514fd8a54974b9f95edcf72", x"74af0c312d4d843066f47b9816eddcf9", x"969e677454ea64bb0b6dac343e8969a2");
 		check_cyphertext(x"bee77e55add3d93e3dfaacc3e1e7c490", x"f93ca3d78368bb3f6dbcc0ffff482eb5", x"8c0f480cb53a1673221b4f83dc0ece39");
 		check_cyphertext(x"aed4ec57328351704139e2d6d31fc01a", x"640ec75309b8405d18eb2ba6e713394d", x"f6c2505151da0beb5182e4e7183b431a");
 		check_cyphertext(x"9367b9a681e96ac96b7817f9e9117b5e", x"7f9a46386abd47670b992b93573b1ed2", x"a19c41a3947f426d6b3e0020dcf6fb4c");
 		check_cyphertext(x"2865dde77d04dc429c8ad85f0a9aab98", x"1e41933075b61e28849c57a22b40813d", x"bd01fa17952a939ac2f6562bb9603ec8");
 		check_cyphertext(x"b3ee199dc177b75cc2c8971d812b256b", x"e233a7328438bc772bf134165169177a", x"5faaac67f3eba4bf814ede7e531791b7");
 		check_cyphertext(x"3f1c0d00928fac76b8c175b1f5e2c97e", x"825bc91caa89c78fe35fe881394fd66a", x"9c601853a92920656c2d6f18a8a47653");
 		check_cyphertext(x"a5b2d389917b63c1875d397bbd0113a2", x"b4688b4abfb2e631d7e97e6cfc63618f", x"b5535a1e6d2db19a7fcbe348eb6bc836");
 		check_cyphertext(x"c49f4c2bf6fa60e64ed0e1ff91e50780", x"1d5ddeee4fbbb08d0bfa2e95727dd7a1", x"7bc730bf05b7bdcbd09d13e79d8a00bd");
 		check_cyphertext(x"08d250e1f3b671ffdcd42c6c296b0f29", x"a47eca2f5ff08689ce214b8a8d9b27ca", x"ac72e53bcdd263eef83651e7039b947f");
 		check_cyphertext(x"11e2a47f42469151d809f6ba805dc8bf", x"9b3d09afe5e6934c2e5413aa8dd7ed24", x"f4317a3ac588ca0b8836fad3deb78569");
 		check_cyphertext(x"0ff2bab870e3e817c04505e7b20ec30c", x"33bcd84eb2ceff2a26df1d29b9c1e656", x"ab160d4bab5bcf750b77c5f70cb53e06");
 		check_cyphertext(x"db780dd5a1300a094cb7c86116c13e8d", x"9015bc6d0c03c291897ef3a1950266ce", x"febd1f82189074ea46fad4de9a41ac1e");
 		check_cyphertext(x"0df5ff3eca5fc1b178c75c190802f84f", x"a2975fc56b3f5e3a27269f7de2486a07", x"4976b70d38b2b9e6a2f14b7c5b29d89e");
 		check_cyphertext(x"38b1c39e51721d7fa657a0d6d72d6887", x"42d3a92f86400c9b956f9e2d0ca2f355", x"08aec39642b3c4aaf1e4781705a46c23");
 		check_cyphertext(x"ed88098badd909d8922d67ec2937badb", x"ce415642ce6c69ec56cf0c927816332b", x"4220e50bbc7043a46370b834f476062f");
 		check_cyphertext(x"196c275530dfe10fb2a9f58ef0965278", x"42b4de4f270e8a806d84b841d4f7cf93", x"35e233e34b686d99e4af8d0a3e65f85e");
 		check_cyphertext(x"57281cf8f418321d73d3ff2e6daaeb3f", x"ef2912608e59c7c4f8759b7eac083618", x"475b306eb325c9a987c4450722b990f7");
 		check_cyphertext(x"5e63f480ac77ee5d626c7d32f74699ff", x"26f7a1e586a88407fed6adc2a21f13ba", x"c2df28f6bf681fd9198ae79474f94232");
 		check_cyphertext(x"b7b1c30a156adb32fa9dbd3de07cc961", x"a79bd1abd7b2891f4507919fc3414eac", x"2bbebfc32b4b98e04b5183d8a4a80f2e");
 		check_cyphertext(x"cab2e725586c7a12fcad72486d4ce8e5", x"2e77d53fdd97a47801ecc2fc497295b3", x"fddd36cf11752e5acbb34e0635ffa8ac");
 		check_cyphertext(x"5aa5d8c099b76c40bc4ae707da0ab67e", x"960eb89a0b4bc8e4f7851f4086830e14", x"13281036a66b640eeb9392cdf3143366");
 		check_cyphertext(x"abbecbbc01e896d0298bbf2426e8e716", x"be39c4b5015780d20a5973778cbed4b3", x"b006cfe6d8146c8442d4a74ca96d560f");
 		check_cyphertext(x"c1f7ab0cc8436580f4ffdd90d267f406", x"4143543a821347325af3b45226b2c568", x"a5cb84736cbf79c0fef45e8b3d183841");
 		check_cyphertext(x"5d83d1588a9ac524512fdf9c296368ea", x"8c66be774f72ed2cbd9b178547a1919d", x"52dacf805d62ab01d785b4ec06230b26");
 		check_cyphertext(x"6f6d45194fc000bb779b0119cedfa7ed", x"0546daaa95f47a964b4cc74c374128d0", x"3de316a29f432b68c3cacabee05269c3");
 		check_cyphertext(x"d31dcaeeaebfda3a9db111cb369129bd", x"744ad69ddf8c6866bafc5823341e7bbf", x"47b6960a4592f4d3228468afe4a10677");
 		check_cyphertext(x"83fc51a76a411713257c22b22d435037", x"02d5d750de86a74b4d9f716e1cd08152", x"8bc2b7640651d861d1804bfa5954298c");
 		check_cyphertext(x"376e3fab3fe0d7593c4c1116ab9ee381", x"48d56a2b5def620c0a94dd24227d5aa9", x"64fbc3170d9b044cf9b33d3c2b6d55e7");
 		check_cyphertext(x"cb49ec623d3ad962dd6fd9297ef57781", x"6ff588ad4177d9a45026a7aac2a7dbb8", x"aafee0ba42bea955ba9c4f1a396de188");
 		check_cyphertext(x"6666816f414e3a387e70d0f7358f8545", x"feacb756b2f7f8162b4986c7b5bb036d", x"9b41df989f019435206d5fc2bbd7c054");
 		check_cyphertext(x"b9e0af15ca7416b2f6a2f4bcb77b9749", x"47c2a0938c969cb411b9afeddc46fa8e", x"0b5f9aa131f129b9e3c5ab700b91748f");
 		check_cyphertext(x"3f71b23493e9236bef40029b3595293a", x"bc0e6707ae6c5dcbc0cdfd94addfa0d5", x"e2c8d6c750a7ca14d074aef6a453261c");
 		check_cyphertext(x"95fecade9d79d3d23032d99578e275b8", x"08ab7e446897225099ecf47fc82fa833", x"dde247acf1c515f7650ef874509b680f");
 		check_cyphertext(x"ed0f0a4d2f0ae07d1060e914403d4710", x"aa7da672a102ba10c5a7c0580ae27dab", x"3211499466be3d2e49382b3129a35d91");
 		check_cyphertext(x"9e701541daaccd7ccb77235f1e505411", x"5648b001401c6bf95cdd0f90f590cc01", x"76adeaa20e02adbb615f8ddc5e89c638");
 		check_cyphertext(x"056ef5c18a42720652bc274c56cb3c20", x"b188f158fd3b211beb728fa4275bcd14", x"de30cd126320a0d0385a4f6448aa4345");
 		check_cyphertext(x"cf6cfbb0e471caebdc88476f0f9d3924", x"d11c62691ba08ba2ef49af79c06ff434", x"8099b2cdac019beeb28c4b7aade5547f");
 		check_cyphertext(x"353c0ad5c1af62394a5bc1d51393a04c", x"a56c2c0675fe3648200fda7c4dd8413b", x"900a13cd752549197b6a9de8d832e65e");
 		check_cyphertext(x"5f67ede52b2c738d6ca00d3c6af43ae0", x"28bf93ad6260b81ff1205b485f4dcca8", x"89ccd381932138024d4ca94bbf589ead");
 		check_cyphertext(x"a29265f02cb84208e778e0296e7d659c", x"db999ffd680bff62bb09f56dbfdfec97", x"d1bc0687e65b1c07dde25c1094064ba4");
 		check_cyphertext(x"48fa06c6f440848f535c4cf0af97b342", x"8183313dbe389c3e2b2eb2a4372d7ac1", x"7877b477bd70c86072b07ed503ab8a6d");
 		check_cyphertext(x"b5024c953d06f88afdaef7379dcd852d", x"33ba3307cf2bb3d8506a09ea711441ec", x"3ba67e159a0ca08fd667ce02ce00bb01");
 		check_cyphertext(x"1144e4550a2c052bb8617dac45b6648b", x"5a21a8399810f03ec420559bb38ac1c3", x"6073819621385c7c02ab0de006af9cff");
 		check_cyphertext(x"11831097cf0300c8ef6b23c52de33358", x"484bcf7abddce3973ecddcf3d854a367", x"418e80a19ef865efb2f4ed995507d113");
 		check_cyphertext(x"e6b96835956cebd87941136aa2ea2324", x"6fb235e8fa3b843d9ffdf48f2307e557", x"fa44b883f849695018d04485556670ad");
 		check_cyphertext(x"1629a46bd11156f9d7de6ad6bc17e37e", x"82dcf1bdf17b9369591d042b422abc84", x"3bf5b86921fac930e7736a540164bce3");
 		check_cyphertext(x"7d7198dd38da8848e66b11b5d7faf484", x"54032c7e8e62ac2e0d1d318bd4e9ab9e", x"b037cd64cb95139dff4e180f5fc18334");
 		check_cyphertext(x"35b0e4ed076d98a57c9fe44fdb756b80", x"20eb3b773b2138bf68f5c439b852d8be", x"b99c3bde06283997f59b07f8b08e78de");
 		check_cyphertext(x"63606f761e2dfd6d033138959b06d480", x"1fc510f7391b0a1891452d7d7fa75847", x"27e1fc0c47b9b1c444d3c24166620aef");
 		check_cyphertext(x"c85278f4eb4a964ffa5fcc4f88530685", x"0d1443402f22840f8d3d705f037f2dac", x"182ce920df398cceda5af31c4402c963");
 		check_cyphertext(x"2a7005a134e1503b8893eee29821826b", x"0823291fdfd1c08d23bceabd17e99b78", x"9fee37b5282c5a1980f5f4e3a2949529");
 		check_cyphertext(x"f5d1966747e7112e5045a28d35c8346c", x"185a810ca0dfb589fe52a4d2926c5f2d", x"5d8202b263bf8bf17abc11bef4180bc4");
 		check_cyphertext(x"a2a9126af0eb0a6f21d69a8646e56ec9", x"13f42e3c23731b892a52a9c470dfef06", x"32312564abda777b4628f3c705a746b2");
 		check_cyphertext(x"23d1e4ef4a60abde8d658511e9681a28", x"161476071a86d29023950123257c7ceb", x"184381b75ec373cce9297b7b4a594107");
 		check_cyphertext(x"97e49e2561343a6cdc254132d6a24040", x"2ca2aa3ada0e7ffda78ab1bc682ee09f", x"6c583a4a1d0efeac7fa9091b625c7b59");
 		check_cyphertext(x"541130633de742b1a24672726362cf98", x"052494a7d42d40af57aacb5580110b6c", x"025566d487dc89283259b644a0fb40c3");
 		check_cyphertext(x"5a2898a13864f880aa6d401f274641d9", x"7a061674611ef1c59a80cabbceba4765", x"74d4500c481ce5788f61e8b20d69d86f");
 		check_cyphertext(x"1737b26f2f3729f89d7edad6a5f207f0", x"08a6155b58bcbfecf2c7d6d331cd29e7", x"ca7a9abcdba250644e4cf6108fe17075");
 		check_cyphertext(x"b916559e4a3d4f8a0731ed3aa2951dfc", x"6ffd419ba29609771e30b7ce2d45e455", x"a919c69fa49b45dcbf330b74b5532777");
 		check_cyphertext(x"a7b437a60ab3ce7757fc5549da6ef39f", x"b38b59e24ff4ba01fd3b0c18f9a84a05", x"c6cf503dbcda3bafe5ebf9192d6b20a2");
 		check_cyphertext(x"e9485a45ecd503af304647ec991f4510", x"bf145393a54e70edfe3a1be190c131bc", x"784da749d6f72721b2353f39cd3af0cc");
 		check_cyphertext(x"a98062389930840e01bf5468e43b8487", x"90ceef34ae9da484d6d81d58862f1f52", x"6c001dab1afd8f4f9797607077c915f2");
 		check_cyphertext(x"5fdaf840a369cd3e8c0a37013fd376cb", x"15cf177b2003d23e2276d6d79dc246e9", x"88135b5e80d669312b27d2ca43daf069");
 		check_cyphertext(x"321dc029ecc190d48fbbcb1a7bab7e59", x"944eff8a8d925f086e633471d0da1458", x"2f36a09a9467e214526409e5173567b9");
 		check_cyphertext(x"b5d803335f36e07c5cdd1662c2038433", x"ea0c2f900f8266a44de9b4fa1fd3a1dd", x"756cc497d50e18e0bf9679ee90ddd635");
 		check_cyphertext(x"d9edcd0b540199d90506b8e077b0b69f", x"0008279ec528906e131b4a0ee54dfa93", x"7e8084f7ef3d99083d655028b7f0ac04");
 		check_cyphertext(x"06e54ae2b6e5b3818e0c9dd3c7b2e780", x"be94fff5ea5be0af70bbf59ce2cff428", x"1cbc398e011614d46d1651f8bc0baca8");
 		check_cyphertext(x"6a9d6aeb4258f32ca5df4751a2635054", x"5cb5b5d4647dd09a3d2a7c143e8f76f6", x"31c5e72cd74c33bbb46aa7c56a90a47f");
 		check_cyphertext(x"6c7f9926ca0fd82f6a738a7bbda85fab", x"7eb9537b87ee85fcac89cbf98af57319", x"65bc81422177187cac12de80dc7f2463");
 		check_cyphertext(x"bf54dacce44ed746b7351f5da7a48fe3", x"03722da39955d3ef26dc82f78aa1c180", x"10ed8ade1bb9298d42d751647d49fa42");
 		check_cyphertext(x"8a095598103fc4a6ad713ec7a3970cac", x"770664792d0a068b071412179a65dc20", x"1b11d5071c564322276530f3b936a2ec");
 		check_cyphertext(x"cb8f651cf127541f2349fc9a1189211f", x"3e6fe52ffc903a7058a339b8ce5d542b", x"aac3fb7b2ed05aa208bbdfa8f66359ef");
 		check_cyphertext(x"54a96c601ca0da437cd255171aef9513", x"0555ae858d5b7f5de70b0b0b9fd9a699", x"344f62735d12925a228481541f023ddb");
 		check_cyphertext(x"c47e953576d8af219c3355d91434d4e9", x"bfcc00f96ab6c53535575fef0279f897", x"0ccc579f18b126c816fb0254b29e339a");
    check_cyphertext(x"1d41ec719bf6dcae614a36107c6bd474", x"5428a46899408d13ba5b2ded8558c0e2", x"9e65e4e9d2d92f02dbdd21cbc6360de6");

    endsim := true;
    report "*** SUCCESS *** end of simulation";
    wait;

    end process;

    end;
