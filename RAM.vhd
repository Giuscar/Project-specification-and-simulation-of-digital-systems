library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;

entity RAM is
generic(	width:	integer:=16;
			depth:	integer:=1024;
			addr:	integer:=11);
port(	Clock:  in std_logic;	
		Error : in std_logic;
		W:		in std_logic;
		Address:	in std_logic_vector(addr-1 downto 0);
		Data_in: 	in std_logic_vector(width-1 downto 0);
		Data_out: 	out std_logic_vector(width-1 downto 0);
		WriteRAMError : in std_logic
		);
end RAM;

architecture behav of RAM is

-- use array to define the bunch of internal temparary signals

type ram_type is array (0 to depth-1) of 
	std_logic_vector(width-1 downto 0);
signal tmp_ram: ram_type;
signal tmp_error : ram_type;
signal cntError : integer := 0;
signal k : integer := 0;
signal cntTmp : integer := 0;
begin	
			   
    -- Write Functional Section
  process(Clock,W)
    begin
			if (Clock'event and Clock='1') then
				if (W='1') then
					tmp_ram(conv_integer(Address)) <= Data_in;
				if(Error = '1') then
					tmp_error(cntError) <= Data_in;
					cntError <= cntError + 1;
				end if;
				end if;
			end if;
   end process;
	 	 
	 --Write Output error RAM
   process(Clock,WriteRAMError)
	begin
		if(WriteRAMError = '1') then
		  Data_out <= tmp_error(conv_integer(Address)); --chiedere cosa deve riportare in output la RAM (gli errori o i dati memorizzati)
		end if;
	end process;
	
end behav;
