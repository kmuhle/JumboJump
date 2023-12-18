library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity state is
	port(
		clk : in std_logic;
		
		NES_output : in std_logic_vector(7 downto 0);
		
		jumbo_left_X : in integer;
		jumbo_right_X : in integer;
		jumbo_top_Y : in integer;
		jumbo_bottom_Y : in integer;
		
		acorn_head_Y : in integer;
		acorn_head_1_X : in integer;
		acorn_head_2_X : in integer;
		acorn_head_3_X : in integer;
		
		home_screen : out std_logic;
		playing : out std_logic;
		game_over : out std_logic
	);
end state;

architecture synth of state is
	signal home_screen_temp : std_logic := '1';
	signal playing_temp : std_logic := '0';
	signal game_over_temp : std_logic := '0';
	
begin
	home_screen <= home_screen_temp;
	playing <= playing_temp;
	game_over <= game_over_temp;
	process(clk) begin
	
		if rising_edge(clk) then
			if NES_output(4) = '0' and (playing_temp = '0') then 
				if (home_screen_temp = '1') or (game_over_temp = '1') then 
					playing_temp <= '1';
					home_screen_temp <= '0';
					game_over_temp <= '0';
				end if;
			elsif NES_output(5) = '0' and (game_over = '1') then 
				playing_temp <= '0';
				home_screen_temp <= '1';
				game_over_temp <= '0';
			elsif(playing_temp = '1') then
				if ((jumbo_left_X = acorn_head_1_X) and (jumbo_bottom_Y = acorn_head_Y)) then
					game_over_temp <= '1';
					playing_temp <= '0';
				elsif ((jumbo_left_X = acorn_head_1_X) and (jumbo_top_Y = acorn_head_Y)) then
					game_over_temp <= '1';
					playing_temp <= '0';
				elsif ((jumbo_right_X = acorn_head_1_X) and (jumbo_bottom_Y = acorn_head_Y)) then
					game_over_temp <= '1';
					playing_temp <= '0';
				elsif ((jumbo_right_X = acorn_head_1_X) and (jumbo_top_Y = acorn_head_Y)) then
					game_over_temp <= '1';
					playing_temp <= '0';
				elsif ((jumbo_left_X = acorn_head_2_X) and (jumbo_bottom_Y = acorn_head_Y)) then
					game_over_temp <= '1';
					playing_temp <= '0';
				elsif ((jumbo_left_X = acorn_head_2_X) and (jumbo_top_Y = acorn_head_Y)) then
					game_over_temp <= '1';
					playing_temp <= '0';
				elsif ((jumbo_right_X = acorn_head_2_X) and (jumbo_bottom_Y = acorn_head_Y)) then
					game_over_temp <= '1';
					playing_temp <= '0';
				elsif ((jumbo_right_X = acorn_head_2_X) and (jumbo_top_Y = acorn_head_Y)) then
					game_over_temp <= '1';
					playing_temp <= '0';
				elsif ((jumbo_left_X = acorn_head_3_X) and (jumbo_bottom_Y = acorn_head_Y)) then
					game_over_temp <= '1';
					playing_temp <= '0';
				elsif ((jumbo_left_X = acorn_head_3_X) and (jumbo_top_Y = acorn_head_Y)) then
					game_over_temp <= '1';
					playing_temp <= '0';
				elsif ((jumbo_right_X = acorn_head_3_X) and (jumbo_bottom_Y = acorn_head_Y)) then
					game_over_temp <= '1';
					playing_temp <= '0';
				elsif ((jumbo_right_X = acorn_head_3_X) and (jumbo_top_Y = acorn_head_Y)) then
					game_over_temp <= '1';
					playing_temp <= '0';
				else 
					game_over_temp <= '0';
					home_screen_temp <= '0';				
					playing_temp <= '1';
				end if;
			elsif game_over_temp = '1' then 
				playing_temp <= '0';
				game_over_temp <= '1';
				home_screen_temp <= '0';
			else 
				playing_temp <= '0';
				home_screen_temp <= '1';
				game_over_temp <= '0';
			end if;
		end if;
	end process;
end synth;