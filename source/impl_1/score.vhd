library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity score is
port(
	clk : in std_logic;
	game_over : in std_logic;
	home_screen : in std_logic;
	
	score1000 : out unsigned(3 downto 0);
	score100 : out unsigned(3 downto 0);
	score10 : out unsigned(3 downto 0);
	score1 : out unsigned(3 downto 0);
	high_score1000 : out unsigned(3 downto 0);
	high_score100 : out unsigned(3 downto 0);
	high_score10 : out unsigned(3 downto 0);
	high_score1 : out unsigned(3 downto 0)
);
end score;

architecture synth of score is
	signal base_speed : unsigned(7 downto 0) := 8d"5";
	signal count : unsigned(26 downto 0);
	signal num : unsigned(13 downto 0);
	signal temp : unsigned(10 downto 0);
	signal intermediate1 : unsigned(21 downto 0);
	signal intermediate2 : unsigned(21 downto 0);
	signal intermediate3 : unsigned(21 downto 0);
	signal intermediate2a : unsigned(12 downto 0);
	signal intermediate3a : unsigned(12 downto 0);
	signal intermediate1a : unsigned(12 downto 0);
	
	signal high_num : unsigned(13 downto 0);
	signal high_temp : unsigned(10 downto 0);
	signal high_intermediate1 : unsigned(21 downto 0);
	signal high_intermediate2 : unsigned(21 downto 0);
	signal high_intermediate3 : unsigned(21 downto 0);
	signal high_intermediate2a : unsigned(12 downto 0);
	signal high_intermediate3a : unsigned(12 downto 0);
	signal high_intermediate1a : unsigned(12 downto 0);
	
	signal amount : unsigned(22 downto 0) := "10011000100101101000000";
	signal restart : std_logic := '0';
	begin 
	
	
	process(clk) begin
		if rising_edge(clk) then
			if home_screen = '1' then 
				num <= 14d"0";
			elsif home_screen = '0' and game_over = '0' then
				if restart = '1' then 
					num <= 14d"0";
					restart <= '0';
				end if;
				count <= count + 1;
				if(count = amount) then
					num <= num + 1;
					count <= 27d"0";
				end if;
			else
				if num > high_num then 
					high_num <= num;
				elsif high_num > 0 then 
					high_num <= high_num;
				else 
					high_num <= 14d"0";
				end if;
				restart <= '1';
				count <= 27d"0";
			end if;
		end if;
	end process;
	temp <= num mod 11d"10";
	score1 <= temp(3 downto 0);
	
	intermediate1 <= num * 8d"52";
	intermediate1a <= intermediate1(21 downto 9) mod 10;
	score10 <= intermediate1a(3 downto 0);
	
	intermediate2 <= intermediate1(21 downto 9) * 9d"52";
	intermediate2a <= intermediate2(21 downto 9) mod 10;
	score100 <= intermediate2a(3 downto 0);
	
	intermediate3 <= intermediate2(21 downto 9) * 9d"52";
	intermediate3a <= intermediate3(21 downto 9) mod 10;
	score1000 <= intermediate3a(3 downto 0);
	
	high_temp <= high_num mod 11d"10";
	high_score1 <= high_temp(3 downto 0);
	
	high_intermediate1 <= high_num * 8d"52";
	high_intermediate1a <= high_intermediate1(21 downto 9) mod 10;
	high_score10 <= high_intermediate1a(3 downto 0);
	
	high_intermediate2 <= high_intermediate1(21 downto 9) * 9d"52";
	high_intermediate2a <= high_intermediate2(21 downto 9) mod 10;
	high_score100 <= high_intermediate2a(3 downto 0);
	
	high_intermediate3 <= high_intermediate2(21 downto 9) * 9d"52";
	high_intermediate3a <= high_intermediate3(21 downto 9) mod 10;
	high_score1000 <= high_intermediate3a(3 downto 0);
end synth;
