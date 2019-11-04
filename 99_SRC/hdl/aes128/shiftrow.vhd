library ieee;
use ieee.std_logic_1164.all;

entity ShiftRow is 
	port (	shiftrow_in : in std_logic_vector(127 downto 0);
				shiftrow_out : out std_logic_vector(127 downto 0));
end entity;

architecture ShiftRow_arch of ShiftRow is
begin

	process(shiftrow_in)
	begin
			shiftrow_out(127 downto 120) <= shiftrow_in(127 downto 120); --0 <- 0
			shiftrow_out(119 downto 112) <= shiftrow_in(87 downto 80); --1 <- 5
			shiftrow_out(111 downto 104) <= shiftrow_in(47 downto 40); --2 <- 10
			shiftrow_out(103 downto 96) <= shiftrow_in(7 downto 0); --3 <- 15
			shiftrow_out(95 downto 88) <= shiftrow_in(95 downto 88); --4 <- 4
			shiftrow_out(87 downto 80) <= shiftrow_in(55 downto 48); --5 <- 9
			shiftrow_out(79 downto 72) <= shiftrow_in(15 downto 8); --6 <- 14
			shiftrow_out(71 downto 64) <= shiftrow_in(103 downto 96); --7 <- 3
			shiftrow_out(63 downto 56) <= shiftrow_in(63 downto 56); --8 <- 8
			shiftrow_out(55 downto 48) <= shiftrow_in(23 downto 16); --9 <- 13
			shiftrow_out(47 downto 40) <= shiftrow_in(111 downto 104); --10 <- 2
			shiftrow_out(39 downto 32) <= shiftrow_in(71 downto 64); --11 <- 7
			shiftrow_out(31 downto 24) <= shiftrow_in(31 downto 24); --12 <- 12
			shiftrow_out(23 downto 16) <= shiftrow_in(119 downto 112); --13 <- 1
			shiftrow_out(15 downto 8) <= shiftrow_in(79 downto 72); --14 <- 6
			shiftrow_out(7 downto 0) <= shiftrow_in(39 downto 32); --15 <- 11
	end process;
end;
