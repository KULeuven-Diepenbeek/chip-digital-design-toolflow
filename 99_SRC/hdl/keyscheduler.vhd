library IEEE;

use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity Keyscheduler is 
	port( roundcounter:	 	in STD_LOGIC_VECTOR(3 downto 0);
			clock:            in std_logic; 
			reset:            in std_logic;
			ce:            in std_logic;
			key:    	 			in std_logic_vector(127 downto 0);
			key_out:				out std_logic_vector(127 downto 0)
	);
end Keyscheduler;

architecture Behavioral of Keyscheduler is

	component ByteSub is
		port( BS_in :in std_logic_vector( 7 downto 0 );
				BS_out :out std_logic_vector( 7 downto 0 )
	);
	end component;
	
	signal roundkey: std_logic_vector(127 downto 0) := (others => '0');
	signal key_reg: std_logic_vector(127 downto 0):= (others => '0');
	signal out_rotbytes, out_BS_key, out_rcon: std_logic_vector(31 downto 0);
	signal rcon: std_logic_vector(7 downto 0);
	signal address : std_logic_vector(5 downto 0):= "000000";
	signal done_s: std_logic;
	signal we_internal: std_logic;
	signal bigcounter: std_logic_vector(31 downto 0);

begin

	key_out <= key_reg;

	out_rotbytes(7 downto 0) <= key_reg(31 downto 24);
	out_rotbytes(15 downto 8) <= key_reg(7 downto 0);
	out_rotbytes(23 downto 16) <= key_reg(15 downto 8);
	out_rotbytes(31 downto 24) <= key_reg(23 downto 16);
	
	gen_ByteSub_key: for i in 3 downto 0 generate
	inst_ByteSub: component ByteSub
		port map(out_rotbytes(8*i+7 downto 8*i), out_BS_key(8*i+7 downto 8*i));
	end generate;

	p_rcon: process(roundcounter)
	begin
		case roundcounter is
			when "0000" =>
				rcon <= "00000000";
			when "0001" =>
				rcon <= "00000001";
			when "0010" =>
				rcon <= "00000010";
			when "0011" =>
				rcon <= "00000100";
			when "0100" =>
				rcon <= "00001000";
			when "0101" =>
				rcon <= "00010000";
			when "0110" =>
				rcon <= "00100000";
			when "0111" =>
				rcon <= "01000000";
			when "1000" =>
				rcon <= "10000000";
			when "1001" =>
				rcon <= "00011011";
			when "1010" =>
				rcon <= "00110110";
			when "1011" =>
				rcon <= "00000000";
			when "1100" =>
				rcon <= "00000000";
			when others =>
				rcon <= "00000000";
		end case;
	end process;
		
	out_rcon(31 downto 24) <= rcon xor out_BS_key(31 downto 24);
	out_rcon(23 downto 0) <= out_BS_key(23 downto 0);

	roundkey(127 downto 96) <= out_rcon xor key_reg(127 downto 96);
	roundkey(95 downto 64) <= roundkey(127 downto 96) xor key_reg(95 downto 64);
	roundkey(63 downto 32) <= roundkey(95 downto 64) xor key_reg(63 downto 32);
	roundkey(31 downto 0) <= roundkey(63 downto 32) xor key_reg(31 downto 0);
	
	keyProc: process(reset, clock)
	begin
		if reset ='1' then
			key_reg <= (others => '0');
		else
			if rising_edge(clock) then
				if ce = '1' then 
					if roundcounter < "0001" then 
						key_reg <= key;
					else 
						key_reg <= roundkey;
					end if;
				end if;
			end if;
		end if;
	end process;
	
end Behavioral;

