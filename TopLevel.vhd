library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity TopLevel is
	port(
			clk : in std_logic;
			Car_Power_On : in std_logic;
			ok_status : out std_logic;
			fault_status : out std_logic;
			debug_port : out std_logic_vector(15 downto 0)
			);
end TopLevel;

architecture Behavioral of TopLevel is

component ROM is
generic(  addr : integer := 11;
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
end component ROM;
--
component AddSub is
	PORT (
			a : IN STD_LOGIC_VECTOR(15 DOWNTO 0);
			b : IN STD_LOGIC_VECTOR(15 DOWNTO 0);
			clk : IN STD_LOGIC;
			ce : IN STD_LOGIC;
			s : OUT STD_LOGIC_VECTOR(15 DOWNTO 0)
			);
end component AddSub;


component RAM is
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
end component RAM;

component ECU is
generic(	width:	integer:=16;
			depth:	integer:=1024;
			addr:	integer:=11);
Port ( 	clk : in  STD_LOGIC;
         Car_Power_On : in  STD_LOGIC;
         ok_status : out  STD_LOGIC;
         fault_status : out  STD_LOGIC;
         debug_port : out  STD_LOGIC_VECTOR (15 downto 0);
         a : in  STD_LOGIC_VECTOR (width-1 downto 0);
         b : in  std_logic_vector (width-1 downto 0);
			Golden : in std_logic_vector(width-1 downto 0);
			GoldenSott : in std_logic_vector(width-1 downto 0);
			OutA : out  STD_LOGIC_VECTOR (width-1 downto 0);
         OutB : out  std_logic_vector (width-1 downto 0);
         OutG : out  std_logic_vector (width-1 downto 0);
			InitROM : out  STD_LOGIC;
         Address : out  STD_LOGIC_VECTOR (10 downto 0);
			ErrorRAM : out std_logic;
			WriteRAM : out std_logic;
			WritRAMError : out std_logic;
			InRAM : in std_logic_vector(width-1 downto 0)
		 );
end component ECU;   

signal EnableWIn : std_logic;
signal AddrIn : std_logic_vector(10 downto 0);
signal Oa,Ob,Og : std_logic_vector(15 downto 0);
signal OutA,OutB,OutG,SottG,OutR : std_logic_vector(15 downto 0);
signal WriteRAM : std_logic;
signal Error : std_logic; 
signal WriteRAMErr : std_logic;
begin

C0 : ECU port map(clk,Car_Power_On,ok_status,fault_status,debug_port,Oa,Ob,Og,SottG,OutA,OutB,OutG,EnableWIn,AddrIn,Error,WriteRAM,WriteRAMErr,OutR);
C1 : ROM port map(clk,AddrIn,Oa,Ob,Og,EnableWIn);	
C2 : AddSub port map(OutA,OutB,clk,'1',SottG);
C3 : RAM port map(clk,Error,WriteRAM,AddrIn,OutG,OutR,WriteRAMErr);



end Behavioral;

