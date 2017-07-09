library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_TEXTIO.ALL;
use std.textio.all;

entity ROM is
 generic( addr : integer := 11;
			 depth : integer := 1024;
			 width : integer := 16
			); 
 Port ( 
	        clk : in STD_LOGIC;
			  Address : in  STD_LOGIC_VECTOR (addr-1 downto 0);
           OutA : out  STD_LOGIC_VECTOR (width-1 downto 0);
           OutB : out  STD_LOGIC_VECTOR (width-1 downto 0);
           Golden : out  STD_LOGIC_VECTOR (width-1 downto 0);
			  EnableW : in std_logic --tale valore è gestito da ECU
        );
end ROM;

architecture Behavioral of ROM is

type rom_type is array (0 to depth-1) of STD_LOGIC_VECTOR(width-1 downto 0);
signal romA,romB,romG: rom_type;

begin

 insert1: process(clk,EnableW) 
		variable j: integer:=0;
		file f1 : text;	
		variable l: line;
		variable a,b : std_logic_vector(width-1 downto 0);
  begin
		if(clk = '1' and clk'event) then
			if(EnableW = '0') then
				file_open(f1,"dati.txt",read_mode);
					while( (j < depth) and (not endfile(f1))) loop
						readline(f1,l);
						read(l,b);
						romA(j) <= b;
						readline(f1,l);
						read(l,a);
						romB(j) <= a;
						j := j+1;
					end loop;
						file_close(f1); 
			end if;
		end if;
  end process insert1;

  insert2: process(clk,EnableW)
			file f2 : text;
			variable j: integer:=0;
			variable l: line;
			variable ris : std_logic_vector(width-1 downto 0);
	begin
	  if(clk = '1' and clk'event) then
		if(EnableW = '0') then
			file_open(f2,"out.txt",read_mode);
				while( (j < depth) and (not endfile(f2))) loop
					readline(f2,l);
					read(l,ris);
					romG(j) <= ris;
					j := j+1;
				end loop;
		 end if;
		end if;
			file_close(f2);
   end process insert2;

   scrittura: process(Address)
		variable k: integer:=0;
	begin
		if(EnableW = '1') then
		   k := conv_integer(Address);
			OutA <= romA(k);
			OutB <= romB(k);
			Golden <= romG(k);	
		end if;
	end process scrittura;
	  
end Behavioral;

