library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity NES is
port(
	clk : in std_logic;
	latch : out std_logic;
	clock : out std_logic;
	data : in std_logic;
	output : out std_logic_vector(7 downto 0)
  );
end NES;

architecture synth of NES is
	signal count : unsigned(19 downto 0); -- rolls over once every 2^20 / 48 MHz, about once every 22ms
	
	signal nes_clk : std_logic;
	signal nes_count : unsigned(7 downto 0);
	
	signal tempOutput : std_logic_vector(7 downto 0);
	
	begin 
		process(clk) begin
			if rising_edge(clk) then
				count <= count + 1;
			end if;
		end process;
		process(nes_clk) begin
			if rising_edge(nes_clk) then
				if nes_count < 8 then
					tempOutput <= tempOutput(6 downto 0) & data;
				elsif nes_count = 8 then
					output <= tempOutput;
				end if;
			end if;
		end process;
		nes_clk <= count(8);
		nes_count <= count(16 downto 9);
		latch <= '1' when nes_count = "11111111" else '0';
		clock <= nes_clk when nes_count < 8 else '0';
end synth;