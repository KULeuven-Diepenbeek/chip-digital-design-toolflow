library IEEE;

use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity AES128 is
    Port ( reset : in  STD_LOGIC;
           clock : in  STD_LOGIC;
           ce : in  STD_LOGIC;
			  input : in STD_LOGIC_VECTOR(127 downto 0);
			  key : in STD_LOGIC_VECTOR(127 downto 0);
           output : out STD_LOGIC_VECTOR(127 downto 0);
           done : out STD_LOGIC);
end AES128;

architecture Behavioral of AES128 is

	component ByteSub is
		port( BS_in :in std_logic_vector(7 downto 0);
				BS_out :out std_logic_vector(7 downto 0));
	end component;

	component ShiftRow is
		port ( shiftrow_in : in std_logic_vector(127 downto 0);
				 shiftrow_out : out std_logic_vector(127 downto 0));
	end component;

	component MixColumn is
		port ( MC_in : in std_logic_vector (127 downto 0);
				 MC_out : out std_logic_vector(127 downto 0));
	end component;

	component Keyscheduler is
		port( roundcounter:	 	in STD_LOGIC_VECTOR(3 downto 0);
				clock:            in std_logic;
				reset:            in std_logic;
				ce:            in std_logic;
				key:    	 			in std_logic_vector(127 downto 0);
				key_out:				out std_logic_vector(127 downto 0));
	end component;

	signal continueRunning, done_d, done_i : STD_LOGIC;
	signal roundcounter: STD_LOGIC_VECTOR(3 downto 0);
	signal roundkey, after_mux, after_ARK0, after_SB0, after_SR0, after_MC0, output_d: STD_LOGIC_VECTOR(127 downto 0);

begin

	output <= output_d xor roundkey;
	done <= done_i;

	done_i <= '1' 				when roundcounter = "1011" and ce = '1' else '0';
	continueRunning <= '1' 	when roundcounter < "1011" and ce = '1'  else '0';

-- COMBINATORIAL ---------------------------------------------------------------
	after_mux <= input when roundcounter = "0000" or roundcounter = "0001" else after_MC0;

	PCTR: process(clock, reset)
	begin
		if reset = '1' then
			done_d <= '0';
			output_d <= (others => '0');
			roundcounter <= "0000";
		elsif clock'event and clock = '1' then
			done_d <= done_i;
			if continueRunning = '1' then
				output_d <= after_SR0;
			end if;

			if (done_i = '1' and done_d = '0') or ce = '0' then
				roundcounter <= "0000";
			elsif continueRunning = '1' then
					roundcounter <= roundcounter + 1;
			end if;
		end if;
	end process;

-- MC --------------------------------------------------------------------------
	MC_inst00: component MixColumn port map ( MC_in => output_d, MC_out => after_MC0);

-- SR --------------------------------------------------------------------------
	SR_inst00: component ShiftRow port map(shiftrow_in => after_SB0, shiftrow_out => after_SR0);

-- SB --------------------------------------------------------------------------
	fg_BS_inst: for i in 15 downto 0 generate
		BS_inst: component ByteSub
			port map(BS_in => after_ARK0(8*i+7 downto 8*i), BS_out => after_SB0(8*i+7 downto 8*i));
	end generate;

-- ARK -------------------------------------------------------------------------
	after_ARK0 <= after_mux XOR roundkey;

	keyscheduler_inst00: component Keyscheduler port map (
		roundcounter => roundcounter,
		clock => clock,
		reset => reset,
		ce => continueRunning,
		key => key,
		key_out => roundkey);

end Behavioral;
