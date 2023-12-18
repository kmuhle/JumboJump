library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;
 
entity top is

port(
	   clk : in std_logic;
       rgb : out std_logic_vector(5 downto 0);
       hs_out   : out std_logic;      
       vs_out   : out std_logic;
	   outcore : out std_logic;
	   latch_out : out std_logic;
		clock_out : out std_logic;
		data : in std_logic
); 
end top; 

architecture synth of top is 

component mypll is
port(
ref_clk_i: in std_logic;
rst_n_i: in std_logic;
outcore_o: out std_logic;
outglobal_o: out std_logic
);
end component;

component VGA is
port(
	   clk : in std_logic; 
	   rgb : out std_logic_vector(5 downto 0);
       hs_out   : out std_logic;       
       vs_out   : out std_logic; 
	   latch_out : out std_logic;
		clock_out : out std_logic;
		data : in std_logic	  ); 
		
end component;


signal outglobal : std_logic;

begin

 mypll1 : mypll port map ( ref_clk_i => clk, rst_n_i => '1', outcore_o => outcore, outglobal_o => outglobal);
 VGA1 : VGA port map (clk => outglobal,rgb => rgb, hs_out => hs_out, vs_out => vs_out, latch_out => latch_out, clock_out => clock_out, data => data);

end;
