library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity ECU is
generic(	width:	integer:=16;
			depth:	integer:=1024;
			addr:	integer:=11);
	Port (  
			  clk : in  STD_LOGIC;
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
end ECU;

architecture Behavioral of ECU is

type state_type is (S0,S1,S2,S3,S4,S5,S6,S7);
signal CurrentState,NextState : state_type;
signal flag : std_logic := '0';
signal EnableWriteROM : std_logic := '1';
signal AssignResult : std_logic;
signal intAddress : std_logic_vector(addr-1 downto 0);
signal index : integer;	
signal errorDebug : std_logic_vector(15 downto 0);
signal diseq : std_logic := '0';
signal indRAM : std_logic_vector(10 downto 0) := "00000000000";
signal flag2,Continue : std_logic := '0';
signal fine : std_logic := '0';
begin

StateReg : process(clk)
	 begin
		if(clk='1' and clk'EVENT) then
		   if(Car_Power_On = '1')then
				flag <= '0';
		   end if;
			if(Car_Power_On = '0' and flag='1') then
				CurrentState <= S0;
			else
				CurrentState <= NextState;
			end if;
		end if;
end process stateReg;
  
CombReg : process(CurrentState,Car_Power_On)

	begin
	 case CurrentState is
		when S0 =>
			if(EnableWriteROM='1') then
				NextState <= S1;
				InitROM <= '0'; --in this way i initialise the ROM writing dates coming from files dati.txt and out.txt
				flag <= '0';
				EnableWriteROM <= '0'; 
				--debug_port <= "0000000000";
			 end if;
				WritRAMError <= '0'; 
				intAddress <= "00000000000";
				index <= 0;
				errorDebug <= "0000000000000000";
				NextState <= S1;
	   when S1 =>
				ErrorRAM <= '0'; --l'ho messo qui, perchè in S5 se errorRAM <= '1' lo rimaneva sempre e ad ogni colpo di clock accedeva al processo della RAM.
									  --debug_port <= errorDebug; --l'ho messo qui perche' mi creava problemi
		   if(EnableWriteROM = '0') then
				InitROM <= '1'; --i can calculate values a,b and g contained in ROM at k-position
				EnableWriteROM <= '1'; 
			end if;
		   if(index < depth) then
				Address <= intAddress;
				NextState <= S2;
			else
				NextState <= S6;
				--WritRAMError <= '1';
			end if;
		when S2 =>
				intAddress <= intAddress + "00000000001";
				NextState <= S3;
		when S3 =>
				index <= index + 1;
				--I assign the ECU input a,b,Golden (linked to ROM output) to the output one 
				--OutA and OutB are the input of AddSub. The result is GoldenSott. 
				OutA <= b;
				OutB <= a;
				OutG <= Golden;
				NextState <= S4 after 6.7 ns; --aspetto che il sottrattore mi dia il risultato
      when S4 => 
				--I make a comparison between value contain in ROM and the output of addSub (one of the ECU inputs)
			if(Golden = GoldenSott) then	
				AssignResult <= '0'; --the results are equal
				NextState <= S5;
			else
				AssignResult <= '1'; --the results are different
				NextState <= S5;
			end if;	
		when S5 =>
		   if(AssignResult = '0') then
				ErrorRAM <= '0'; 
				WriteRAM <= '1'; --signal that enables writing in RAM
            NextState <= S1;			
			elsif(AssignResult = '1') then
				errorDebug <= errorDebug + "0000000000000001";
				ErrorRAM <= '1'; --i sign the error in RAM
				WriteRAM <= '1';
				NextState <= S1;
 			end if;
		when S6 =>
		   if(flag2 = '0') then --uso questo flag per scrivere la prima volta il nro di errori
										-- impostato il flag a 1 invio quali sono quei valori soggetti ad errore.
		       debug_port <= errorDebug;
			    NextState <= S7 after 1 us;
				 Continue <= '1';
				 flag2 <= '1';
		   elsif(errorDebug = "00000000000" and flag2 /= '0') then --non ho errori
			    ok_status <='1';
				 ok_status <='0' after 50 us;
			elsif(errorDebug /= "00000000000" and flag2 /= '0') then --ho errori
			    fault_status <= '1';
				 ok_status <= '0'; 
				 if(conv_integer(indRAM) < conv_integer(errorDebug)) then
		          WritRAMError <= '1';
				    NextState <= S7;
				    indRAM <= indRAM + "00000000001";
				    Address <= indRAM;
					 Continue <= '0';
			     else
				    Continue <= '1';
				  	 fault_status <= '0';
					 fine <= '1';
					 NextState <= S7;
			     end if;
			 end if;
		when S7 =>
		    if(fine = '0') then
		      if(Continue = '0') then
				   WritRAMError <= '0';
				   debug_port <= InRAM;
			   end if;
			   NextState <= S6;
		     end if;
		end case;
end process CombReg;	
			
			



end Behavioral;

