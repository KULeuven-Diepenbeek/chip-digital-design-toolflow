library ieee;
use ieee.std_logic_1164.all;

entity MixColumn is 
	port (	MC_in : in std_logic_vector (127 downto 0);
			MC_out : out std_logic_vector(127 downto 0)
			);
end entity;


architecture MixColumn_arch of MixColumn is

	function MULT(t : std_logic_vector(7 downto 0)) return std_logic_vector is
		variable tmp : std_logic_vector(7 downto 0);
	begin
		if(t(7) = '1') then
			tmp := (t(6 downto 0)&'0') xor x"1b";
		else
			tmp := t(6 downto 0)&'0';
		end if;
		return tmp;
	end MULT;

begin
  MC_out(127 downto 96) <= (MULT(MC_in(127 downto 120)) xor
                             (MULT(MC_in(119 downto 112)) xor
                              MC_in(119 downto 112)) xor
                             MC_in(111 downto 104) xor
                             MC_in(103 downto 96)) &
                            (MC_in(127 downto 120) xor
                             MULT(MC_in(119 downto 112)) xor
                             (MULT(MC_in(111 downto 104)) xor
                              MC_in(111 downto 104)) xor
                             MC_in(103 downto 96)) &
                            (MC_in(127 downto 120) xor
                             MC_in(119 downto 112) xor
                             MULT(MC_in(111 downto 104)) xor
                             (MULT(MC_in(103 downto 96)) xor
                              MC_in(103 downto 96))) &
                            ((MULT(MC_in(127 downto 120)) xor
                              MC_in(127 downto 120)) xor
                             MC_in(119 downto 112) xor
                             MC_in(111 downto 104) xor
                             MULT(MC_in(103 downto 96)));
  MC_out(95 downto 64) <= (MULT(MC_in(95 downto 88)) xor
                            (MULT(MC_in(87 downto 80))xor
                             MC_in(87 downto 80)) xor
                            MC_in(79 downto 72) xor
                            MC_in(71 downto 64)) &
                           (MC_in(95 downto 88) xor
                            MULT(MC_in(87 downto 80)) xor
                            (MULT(MC_in(79 downto 72)) xor
                             MC_in(79 downto 72)) xor
                            MC_in(71 downto 64)) &
                           (MC_in(95 downto 88) xor
                            MC_in(87 downto 80) xor
                            MULT(MC_in(79 downto 72)) xor
                            (MULT(MC_in(71 downto 64))xor
                             MC_in(71 downto 64))) &
                           ((MULT(MC_in(95 downto 88))xor
                             MC_in(95 downto 88)) xor
                            MC_in(87 downto 80) xor
                            MC_in(79 downto 72) xor
                            MULT(MC_in(71 downto 64)));
  MC_out(63 downto 32) <= (MULT(MC_in(63 downto 56)) xor
                            (MULT(MC_in(55 downto 48))xor
                             MC_in(55 downto 48)) xor
                            MC_in(47 downto 40) xor
                            MC_in(39 downto 32)) &
                           (MC_in(63 downto 56) xor
                            MULT(MC_in(55 downto 48)) xor
                            (MULT(MC_in(47 downto 40)) xor
                             MC_in(47 downto 40)) xor
                            MC_in(39 downto 32)) &
                           (MC_in(63 downto 56) xor
                            MC_in(55 downto 48) xor
                            MULT(MC_in(47 downto 40)) xor
                            (MULT(MC_in(39 downto 32))xor
                             MC_in(39 downto 32))) &
                           ((MULT(MC_in(63 downto 56))xor
                             MC_in(63 downto 56)) xor
                            MC_in(55 downto 48) xor
                            MC_in(47 downto 40) xor
                            MULT(MC_in(39 downto 32)));
  MC_out(31 downto 0) <= (MULT(MC_in(31 downto 24)) xor
                           (MULT(MC_in(23 downto 16)) xor MC_in(23 downto 16)) xor
                           MC_in(15 downto 8) xor MC_in(7 downto 0)) &
                          (MC_in(31 downto 24) xor MULT(MC_in(23 downto 16)) xor
                           (MULT(MC_in(15 downto 8)) xor
                            MC_in(15 downto 8)) xor MC_in(7 downto 0)) &
                          (MC_in(31 downto 24) xor
                           MC_in(23 downto 16) xor
                           MULT(MC_in(15 downto 8)) xor
                           (MULT(MC_in(7 downto 0))xor
                            MC_in(7 downto 0))) &
                          ((MULT(MC_in(31 downto 24))xor
                            MC_in(31 downto 24)) xor
                           MC_in(23 downto 16) xor
                           MC_in(15 downto 8) xor
                           MULT(MC_in(7 downto 0)));


end;
