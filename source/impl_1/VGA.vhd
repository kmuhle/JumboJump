library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

 

entity VGA is

port(
	clk : in std_logic; 
	rgb : out std_logic_vector(5 downto 0); 
	hs_out   : out std_logic;        
	vs_out   : out std_logic;
	latch_out : out std_logic;
	clock_out : out std_logic;
	data : in std_logic
);        

end VGA;

architecture synth of VGA is

component pattern_gen is
port ( 
	clk : in std_logic;
	hs : in integer;
	vs : in integer;
	rgb : out std_logic_vector(5 downto 0);
	latch_out : out std_logic;
	clock_out : out std_logic;
	data : in std_logic
);
end component;

signal hs : integer := 640;
signal vs : integer := 480; 

begin

pattern_gen1 : pattern_gen port map(clk => clk, hs => hs, vs => vs, rgb  => rgb, latch_out => latch_out, clock_out => clock_out, data => data);

process (clk)

begin

if rising_edge(clk) then
	if (hs >= (640 + 16)) and (hs < (640 + 16 + 96)) then
		hs_out <= '0';
	else
		hs_out <= '1';
	end if;


	if (vs >= (480 + 10)) and (vs < (480 + 10 + 2)) then
		vs_out <= '0';
	else
		vs_out <= '1';
	end if;


	if (hs = 799) then  
		hs <= 0;
		if (vs = 524) then
			vs <= 0;
		else 
			vs <= vs + 1;
		end if; 
	else 
		hs <= hs + 1;
	end if;
	


end if;
end process;

end;
