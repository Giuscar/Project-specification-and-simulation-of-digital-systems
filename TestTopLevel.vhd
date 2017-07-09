--------------------------------------------------------------------------------
-- Company: 
-- Engineer:
--
-- Create Date:   17:28:23 12/11/2015
-- Design Name:   
-- Module Name:   C:/Users/massi/Desktop/Specification and simulation of digital systems/Assignment/hmw/TestTopLevel.vhd
-- Project Name:  hmw
-- Target Device:  
-- Tool versions:  
-- Description:   
-- 
-- VHDL Test Bench Created by ISE for module: TopLevel
-- 
-- Dependencies:
-- 
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
--
-- Notes: 
-- This testbench has been automatically generated using types std_logic and
-- std_logic_vector for the ports of the unit under test.  Xilinx recommends
-- that these types always be used for the top-level I/O of a design in order
-- to guarantee that the testbench will bind correctly to the post-implementation 
-- simulation model.
--------------------------------------------------------------------------------
LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
 
-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--USE ieee.numeric_std.ALL;
 
ENTITY TestTopLevel IS
END TestTopLevel;
 
ARCHITECTURE behavior OF TestTopLevel IS 
 
    -- Component Declaration for the Unit Under Test (UUT)
 
    COMPONENT TopLevel
    PORT(
         clk : IN  std_logic;
         Car_Power_On : IN  std_logic;
         ok_status : OUT  std_logic;
         fault_status : OUT  std_logic;
         debug_port : OUT  std_logic_vector(15 downto 0)
        );
    END COMPONENT;
    

   --Inputs
   signal clk : std_logic := '0';
   signal Car_Power_On : std_logic := '0';

 	--Outputs
   signal ok_status : std_logic;
   signal fault_status : std_logic;
   signal debug_port : std_logic_vector(15 downto 0);
   -- Clock period definitions
   constant clk_period : time := 6.67 ns; --10 ns
 
BEGIN
 
	-- Instantiate the Unit Under Test (UUT)
   uut: TopLevel PORT MAP (
          clk => clk,
          Car_Power_On => Car_Power_On,
          ok_status => ok_status,
          fault_status => fault_status,
          debug_port => debug_port
        );

   -- Clock process definitions
   clk_process :process
   begin
		clk <= '0';
		wait for clk_period/2;
		clk <= '1';
		wait for clk_period/2;
   end process;
 

   -- Stimulus process
   stim_proc: process
   begin		
      -- hold reset state for 100 ns.
     wait until clk='1' and clk'event;
	  
	  Car_Power_On <= '0';
	
	  wait until clk='1' and clk'event;

	  Car_Power_On <= '1';
	  
	  wait for 2 us;
	  
	  Car_Power_On <= '0';

      -- insert stimulus here 

      wait;
   end process;

END;
