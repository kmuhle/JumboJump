
library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_unsigned.all;
use IEEE.numeric_std.all;
library work;
use work.sprite_package.all;

entity pattern_gen is
port ( 
	clk : in std_logic;
	hs : in integer;
	vs : in integer;
	rgb : out std_logic_vector(5 downto 0);
	latch_out : out std_logic;
	clock_out : out std_logic;
	data : in std_logic
);
end pattern_gen;

architecture synth of pattern_gen is

component state is
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
end component;

component score is
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
end component;

component NES is
port(
	clk : in std_logic;
	latch : out std_logic;
	clock : out std_logic;
	data : in std_logic;
	output : out std_logic_vector(7 downto 0)
  );
end component;


constant cols : integer := 40;
constant pix_box : integer := 16;
constant jumbo_speed : integer := 25;
constant acorn_speed : integer := 40;
constant ground_speed : integer := 40;
constant cloud_speed : integer := 100;

signal NES_output : std_logic_vector(7 downto 0);

signal rand_count : integer := 0;
signal counter : integer := 0;
signal jumping : std_logic := '0';

signal jumbo_count : integer := 0;
signal acorn_count : integer := 0;
signal cloud_count : integer := 0;
signal ground_count : integer := 0;
signal walk_count : integer := 0;

signal game_over : std_logic;
signal home_screen : std_logic;
signal playing : std_logic;

signal score1000 : unsigned(3 downto 0);
signal score100 : unsigned(3 downto 0);
signal score10 : unsigned(3 downto 0);
signal score1 : unsigned(3 downto 0);
signal high_score1000 : unsigned(3 downto 0);
signal high_score100 : unsigned(3 downto 0);
signal high_score10 : unsigned(3 downto 0);
signal high_score1 : unsigned(3 downto 0);

signal game_speed : integer := 0;

signal sprite_X : integer := 0;
signal sprite_Y : integer := 0;
signal rgb_color : std_logic_vector(5 downto 0) := (others => '0');

signal jumbo_left_X : integer := 10;
signal jumbo_right_X : integer := 11;
signal jumbo_top_Y : integer := 23;
signal jumbo_bottom_Y : integer := 24;

signal brown_c2 : integer := 17;
signal brown_c3 : integer := 18;
signal brown_c4 : integer := 19;
signal brown_c5 : integer := 20;
signal brown_c6 : integer := 21;
signal brown_c7 : integer := 22;

signal brown_r1 : integer := 6;
signal brown_r2 : integer := 7;
signal brown_r3 : integer := 8;
signal brown_r4 : integer := 9;
signal brown_r5 : integer := 10;
signal brown_r6 : integer := 11;

signal game_over_text_brown : integer := 12;
signal game_over_text_brown_top: integer := 13;
signal game_over_text_brown_bottom: integer := 14;

signal game_over_text_reject : integer := 11;
signal game_over_text_reject_top: integer := 15;
signal game_over_text_reject_bottom: integer := 16;

signal press_start_left : integer := 10;
signal press_start_top: integer := 12;
signal press_start_bottom: integer := 13;

signal jumbo_jump_left : integer := 6;
signal jumbo_jump_top: integer := 9;
signal jumbo_jump_bottom: integer := 10;
 
signal acorn_head_Y : integer := 24;
signal acorn_head_1_X : integer := cols;
signal acorn_head_2_X : integer := cols + cols/2;
signal acorn_head_3_X : integer := cols + cols;

signal cloud_left_X : integer := cols;
signal cloud_right_X : integer := cols + 1;
signal cloud_Y : integer := 15;

signal score_num_Y : integer := 2;
signal score_num_0_X : integer := 37;
signal score_num_1_X : integer := 36;
signal score_num_2_X : integer := 35;
signal score_num_3_X : integer := 34;
signal score_num_4_X : integer := 33;

signal high_score_num_0_X : integer := 31;
signal high_score_num_1_X : integer := 30;
signal high_score_num_2_X : integer := 29;
signal high_score_num_3_X : integer := 28;
signal high_score_num_4_X : integer := 27;

signal letter_H_X : integer := 25;
signal letter_H_Y : integer := 2;
signal letter_i_X : integer := 26;
signal letter_i_Y : integer := 2;


signal ground_1_X : integer := cols;
signal ground_1_Y : integer := 26;
signal ground_2_X : integer := cols;
signal ground_2_Y : integer := 27;
signal ground_3_X : integer := cols;
signal ground_3_Y : integer := 28;
signal ground_4_X : integer := cols;
signal ground_4_Y : integer := 29;
signal ground : integer := 25;
signal sky: integer := 24;


signal increase_speed : std_logic := '0';
signal previous_score10 : unsigned(3 downto 0);
signal speed_up : integer := 0;

type color_arr is array(0 to 3) of std_logic_vector(5 downto 0);
constant jumbo_color : color_arr := ("101111", "101010", "010101", "000000");
constant F_paper_color : color_arr := ("101111", "010101", "111111", "110000");
constant acorn_head_color : color_arr := ("101111", "000000", "111000", "100100" );
constant score_color : color_arr := ("101111", "111111", "000000", "000000" );
constant high_score_color : color_arr := ("101111", "111111", "010101", "000000" );
constant cloud_color : color_arr := ("101111", "101010", "111111", "000000" );
constant ground_color : color_arr := ("011001", "000100", "111101", "110110" );
constant brown_color : color_arr := ("101111", "000000", "000000", "000000" );
constant text_color : color_arr := ("101111", "000000", "000000", "000000" );
constant title_color : color_arr := ("101111", "100100", "000000", "000000" );
 

begin 
state_instance : state port map (
    clk => clk,
	NES_output => NES_output,
    jumbo_left_X => jumbo_left_X,
    jumbo_right_X => jumbo_right_X,
    jumbo_top_Y => jumbo_top_Y,
    jumbo_bottom_Y => jumbo_bottom_Y,
    acorn_head_Y => acorn_head_Y,
	acorn_head_1_X => acorn_head_1_X,
	acorn_head_2_X => acorn_head_2_X,
	acorn_head_3_X => acorn_head_3_X,
    home_screen => home_screen,
    playing => playing,
    game_over => game_over
  );
  
score_1 : score port map (
	clk => clk, 
	game_over => game_over,
	home_screen => home_screen,
	score1000 => score1000,
	score100 => score100,
	score10 => score10,
	score1 => score1,
	high_score1000 => high_score1000,
	high_score100 => high_score100,
	high_score10 => high_score10,
	high_score1 => high_score1
);

NES_1 : NES port map (
	clk => clk,
	latch => latch_out,
	clock => clock_out, 
	data => data,
	output => NES_output
);


process (clk) begin

if rising_edge(clk) then 
	
	if hs < 640 and vs < 480 then 
		rgb_color <= "111111";
		sprite_X <= hs+1 mod pix_box;
		sprite_Y <= vs mod pix_box;
		
		if home_screen = '1' then
			walk_count <= 0;
		elsif walk_count >= 12000 then 
			walk_count <= 0;
		else 
			walk_count <= walk_count + 1;
		end if;
		
		if ((hs / pix_box) = letter_H_X) and ((vs / pix_box) = letter_H_Y) then 
			rgb_color <= high_score_color(letter_H(sprite_Y, sprite_X));
		elsif ((hs / pix_box) = letter_i_X) and ((vs / pix_box) = letter_i_Y) then 
			rgb_color <= high_score_color(letter_i(sprite_Y, sprite_X));
		elsif ((hs / pix_box) = high_score_num_0_X) and ((vs / pix_box) = score_num_Y) then 
			if(high_score1 = 4d"0") then
				rgb_color <= high_score_color(num_0(sprite_Y, sprite_X));
			elsif(high_score1 = 4d"1") then
				rgb_color <= high_score_color(num_1(sprite_Y, sprite_X));
			elsif(high_score1 = 4d"2") then
				rgb_color <= high_score_color(num_2(sprite_Y, sprite_X));
			elsif(high_score1 = 4d"3") then
				rgb_color <= high_score_color(num_3(sprite_Y, sprite_X));
			elsif(high_score1 = 4d"4") then
				rgb_color <= high_score_color(num_4(sprite_Y, sprite_X));
			elsif(high_score1 = 4d"5") then
				rgb_color <= high_score_color(num_5(sprite_Y, sprite_X));
			elsif(high_score1 = 4d"6") then
				rgb_color <= high_score_color(num_6(sprite_Y, sprite_X));
			elsif(high_score1 = 4d"7") then
				rgb_color <= high_score_color(num_7(sprite_Y, sprite_X));
			elsif(high_score1 = 4d"8") then
				rgb_color <= high_score_color(num_8(sprite_Y, sprite_X));
			elsif(high_score1 = 4d"9") then
				rgb_color <= high_score_color(num_9(sprite_Y, sprite_X));
			end if; 
		elsif ((hs / pix_box) = high_score_num_1_X) and ((vs / pix_box) = score_num_Y) then 
			if(high_score10 = 4d"0") then
				rgb_color <= high_score_color(num_0(sprite_Y, sprite_X));
			elsif(high_score10 = 4d"1") then
				rgb_color <= high_score_color(num_1(sprite_Y, sprite_X));
			elsif(high_score10 = 4d"2") then
				rgb_color <= high_score_color(num_2(sprite_Y, sprite_X));
			elsif(high_score10 = 4d"3") then
				rgb_color <= high_score_color(num_3(sprite_Y, sprite_X));
			elsif(high_score10 = 4d"4") then
				rgb_color <= high_score_color(num_4(sprite_Y, sprite_X));
			elsif(high_score10 = 4d"5") then
				rgb_color <= high_score_color(num_5(sprite_Y, sprite_X));
			elsif(high_score10 = 4d"6") then
				rgb_color <= high_score_color(num_6(sprite_Y, sprite_X));
			elsif(high_score10 = 4d"7") then
				rgb_color <= high_score_color(num_7(sprite_Y, sprite_X));
			elsif(high_score10 = 4d"8") then
				rgb_color <= high_score_color(num_8(sprite_Y, sprite_X));
			elsif(high_score10 = 4d"9") then
				rgb_color <= high_score_color(num_9(sprite_Y, sprite_X));
			end if; 
		elsif ((hs / pix_box) = high_score_num_2_X) and ((vs / pix_box) = score_num_Y) then 
			if(high_score100 = 4d"0") then
				rgb_color <= high_score_color(num_0(sprite_Y, sprite_X));
			elsif(high_score100 = 4d"1") then
				rgb_color <= high_score_color(num_1(sprite_Y, sprite_X));
			elsif(high_score100 = 4d"2") then
				rgb_color <= high_score_color(num_2(sprite_Y, sprite_X));
			elsif(high_score100 = 4d"3") then
				rgb_color <= high_score_color(num_3(sprite_Y, sprite_X));
			elsif(high_score100 = 4d"4") then
				rgb_color <= high_score_color(num_4(sprite_Y, sprite_X));
			elsif(high_score100 = 4d"5") then
				rgb_color <= high_score_color(num_5(sprite_Y, sprite_X));
			elsif(high_score100 = 4d"6") then
				rgb_color <= high_score_color(num_6(sprite_Y, sprite_X));
			elsif(high_score100 = 4d"7") then
				rgb_color <= high_score_color(num_7(sprite_Y, sprite_X));
			elsif(high_score100 = 4d"8") then
				rgb_color <= high_score_color(num_8(sprite_Y, sprite_X));
			elsif(high_score100 = 4d"9") then
				rgb_color <= high_score_color(num_9(sprite_Y, sprite_X));
			end if; 
		elsif ((hs / pix_box) = high_score_num_3_X) and ((vs / pix_box) = score_num_Y) then 
			if(high_score1000 = 4d"0") then
				rgb_color <= high_score_color(num_0(sprite_Y, sprite_X));
			elsif(high_score1000 = 4d"1") then
				rgb_color <= high_score_color(num_1(sprite_Y, sprite_X));
			elsif(high_score1000 = 4d"2") then
				rgb_color <= high_score_color(num_2(sprite_Y, sprite_X));
			elsif(high_score1000 = 4d"3") then
				rgb_color <= high_score_color(num_3(sprite_Y, sprite_X));
			elsif(high_score1000 = 4d"4") then
				rgb_color <= high_score_color(num_4(sprite_Y, sprite_X));
			elsif(high_score1000 = 4d"5") then
				rgb_color <= high_score_color(num_5(sprite_Y, sprite_X));
			elsif(high_score1000 = 4d"6") then
				rgb_color <= high_score_color(num_6(sprite_Y, sprite_X));
			elsif(high_score1000 = 4d"7") then
				rgb_color <= high_score_color(num_7(sprite_Y, sprite_X));
			elsif(high_score1000 = 4d"8") then
				rgb_color <= high_score_color(num_8(sprite_Y, sprite_X));
			elsif(high_score1000 = 4d"9") then
				rgb_color <= high_score_color(num_9(sprite_Y, sprite_X));
			end if; 
		elsif ((hs / pix_box) = high_score_num_4_X) and ((vs / pix_box) = score_num_Y) then 
			rgb_color <= high_score_color(num_0(sprite_Y, sprite_X));
		elsif ((hs / pix_box) = score_num_0_X) and ((vs / pix_box) = score_num_Y) then 
			if(score1 = 4d"0") then
				rgb_color <= score_color(num_0(sprite_Y, sprite_X));
			elsif(score1 = 4d"1") then
				rgb_color <= score_color(num_1(sprite_Y, sprite_X));
			elsif(score1 = 4d"2") then
				rgb_color <= score_color(num_2(sprite_Y, sprite_X));
			elsif(score1 = 4d"3") then
				rgb_color <= score_color(num_3(sprite_Y, sprite_X));
			elsif(score1 = 4d"4") then
				rgb_color <= score_color(num_4(sprite_Y, sprite_X));
			elsif(score1 = 4d"5") then
				rgb_color <= score_color(num_5(sprite_Y, sprite_X));
			elsif(score1 = 4d"6") then
				rgb_color <= score_color(num_6(sprite_Y, sprite_X));
			elsif(score1 = 4d"7") then
				rgb_color <= score_color(num_7(sprite_Y, sprite_X));
			elsif(score1 = 4d"8") then
				rgb_color <= score_color(num_8(sprite_Y, sprite_X));
			elsif(score1 = 4d"9") then
				rgb_color <= score_color(num_9(sprite_Y, sprite_X));
			end if; 
		elsif ((hs / pix_box) = score_num_1_X) and ((vs / pix_box) = score_num_Y) then 
			if(score10 = 4d"0") then
				rgb_color <= score_color(num_0(sprite_Y, sprite_X));
			elsif(score10 = 4d"1") then
				rgb_color <= score_color(num_1(sprite_Y, sprite_X));
			elsif(score10 = 4d"2") then
				rgb_color <= score_color(num_2(sprite_Y, sprite_X));
			elsif(score10 = 4d"3") then
				rgb_color <= score_color(num_3(sprite_Y, sprite_X));
			elsif(score10 = 4d"4") then
				rgb_color <= score_color(num_4(sprite_Y, sprite_X));
			elsif(score10 = 4d"5") then
				rgb_color <= score_color(num_5(sprite_Y, sprite_X));
			elsif(score10 = 4d"6") then
				rgb_color <= score_color(num_6(sprite_Y, sprite_X));
			elsif(score10 = 4d"7") then
				rgb_color <= score_color(num_7(sprite_Y, sprite_X));
			elsif(score10 = 4d"8") then
				rgb_color <= score_color(num_8(sprite_Y, sprite_X));
			elsif(score10 = 4d"9") then
				rgb_color <= score_color(num_9(sprite_Y, sprite_X));
			end if; 
		elsif ((hs / pix_box) = score_num_2_X) and ((vs / pix_box) = score_num_Y) then 
			rgb_color <= score_color(num_7(sprite_Y, sprite_X));
			if(score100 = 4d"0") then
				rgb_color <= score_color(num_0(sprite_Y, sprite_X));
			elsif(score100 = 4d"1") then
				rgb_color <= score_color(num_1(sprite_Y, sprite_X));
			elsif(score100 = 4d"2") then
				rgb_color <= score_color(num_2(sprite_Y, sprite_X));
			elsif(score100 = 4d"3") then
				rgb_color <= score_color(num_3(sprite_Y, sprite_X));
			elsif(score100 = 4d"4") then
				rgb_color <= score_color(num_4(sprite_Y, sprite_X));
			elsif(score100 = 4d"5") then
				rgb_color <= score_color(num_5(sprite_Y, sprite_X));
			elsif(score100 = 4d"6") then
				rgb_color <= score_color(num_6(sprite_Y, sprite_X));
			elsif(score100 = 4d"7") then
				rgb_color <= score_color(num_7(sprite_Y, sprite_X));
			elsif(score100 = 4d"8") then
				rgb_color <= score_color(num_8(sprite_Y, sprite_X));
			elsif(score100 = 4d"9") then
				rgb_color <= score_color(num_9(sprite_Y, sprite_X));
			end if; 
		elsif ((hs / pix_box) = score_num_3_X) and ((vs / pix_box) = score_num_Y) then 
			if(score1000 = 4d"0") then
				rgb_color <= score_color(num_0(sprite_Y, sprite_X));
			elsif(score1000 = 4d"1") then
				rgb_color <= score_color(num_1(sprite_Y, sprite_X));
			elsif(score1000 = 4d"2") then
				rgb_color <= score_color(num_2(sprite_Y, sprite_X));
			elsif(score1000 = 4d"3") then
				rgb_color <= score_color(num_3(sprite_Y, sprite_X));
			elsif(score1000 = 4d"4") then
				rgb_color <= score_color(num_4(sprite_Y, sprite_X));
			elsif(score1000 = 4d"5") then
				rgb_color <= score_color(num_5(sprite_Y, sprite_X));
			elsif(score1000 = 4d"6") then
				rgb_color <= score_color(num_6(sprite_Y, sprite_X));
			elsif(score1000 = 4d"7") then
				rgb_color <= score_color(num_7(sprite_Y, sprite_X));
			elsif(score1000 = 4d"8") then
				rgb_color <= score_color(num_8(sprite_Y, sprite_X));
			elsif(score1000 = 4d"9") then
				rgb_color <= score_color(num_9(sprite_Y, sprite_X));
			end if; 
		elsif ((hs / pix_box) = score_num_4_X) and ((vs / pix_box) = score_num_Y) then 
			rgb_color <= score_color(num_0(sprite_Y, sprite_X));
		elsif ((vs / pix_box) >= ground) then
			rgb_color <= "011001";
		elsif ((vs / pix_box)) <= sky then
			rgb_color <= "101111";
		else 
			rgb_color <= "111111";
		end if;
		
		if (home_screen = '1') then 
			------Begin Jumbo Jump
			--J
			if ((hs / pix_box) = jumbo_jump_left) and ((vs / pix_box) = jumbo_jump_top) then 
				rgb_color <= title_color(big_j_top_left(sprite_Y, sprite_X));
			elsif ((hs / pix_box) = jumbo_jump_left) and ((vs / pix_box) = jumbo_jump_bottom) then 
				rgb_color <= title_color(big_j_bottom_left(sprite_Y, sprite_X));
			elsif ((hs / pix_box) = jumbo_jump_left+1) and ((vs / pix_box) = jumbo_jump_top) then 
				rgb_color <= title_color(big_j_top_right(sprite_Y, sprite_X));
			elsif ((hs / pix_box) = jumbo_jump_left+1) and ((vs / pix_box) = jumbo_jump_bottom) then 
				rgb_color <= title_color(big_j_bottom_right(sprite_Y, sprite_X));
			--u
			elsif ((hs / pix_box) = jumbo_jump_left+3) and ((vs / pix_box) = jumbo_jump_top) then 
				rgb_color <= title_color(u_top_left(sprite_Y, sprite_X));
			elsif ((hs / pix_box) = jumbo_jump_left+3) and ((vs / pix_box) = jumbo_jump_bottom) then 
				rgb_color <= title_color(u_bottom_left(sprite_Y, sprite_X));
			elsif ((hs / pix_box) = jumbo_jump_left+4) and ((vs / pix_box) = jumbo_jump_top) then 
				rgb_color <= title_color(u_top_right(sprite_Y, sprite_X));
			elsif ((hs / pix_box) = jumbo_jump_left+4) and ((vs / pix_box) = jumbo_jump_bottom) then 
				rgb_color <= title_color(u_bottom_right(sprite_Y, sprite_X));
			--m
			elsif ((hs / pix_box) = jumbo_jump_left+6) and ((vs / pix_box) = jumbo_jump_top) then 
				rgb_color <= title_color(m_top_left(sprite_Y, sprite_X));
			elsif ((hs / pix_box) = jumbo_jump_left+6) and ((vs / pix_box) = jumbo_jump_bottom) then 
				rgb_color <= title_color(m_bottom_left(sprite_Y, sprite_X));
			elsif ((hs / pix_box) = jumbo_jump_left+7) and ((vs / pix_box) = jumbo_jump_top) then 
				rgb_color <= title_color(m_top_right(sprite_Y, sprite_X));
			elsif ((hs / pix_box) = jumbo_jump_left+7) and ((vs / pix_box) = jumbo_jump_bottom) then 
				rgb_color <= title_color(m_bottom_right(sprite_Y, sprite_X));
			--b
			elsif ((hs / pix_box) = jumbo_jump_left+9) and ((vs / pix_box) = jumbo_jump_top) then 
				rgb_color <= title_color(b_top_left(sprite_Y, sprite_X));
			elsif ((hs / pix_box) = jumbo_jump_left+9) and ((vs / pix_box) = jumbo_jump_bottom) then 
				rgb_color <= title_color(b_bottom_left(sprite_Y, sprite_X));
			elsif ((hs / pix_box) = jumbo_jump_left+10) and ((vs / pix_box) = jumbo_jump_top) then 
				rgb_color <= title_color(b_top_right(sprite_Y, sprite_X));
			elsif ((hs / pix_box) = jumbo_jump_left+10) and ((vs / pix_box) = jumbo_jump_bottom) then 
				rgb_color <= title_color(b_bottom_right(sprite_Y, sprite_X));
			--o
			elsif ((hs / pix_box) = jumbo_jump_left+12) and ((vs / pix_box) = jumbo_jump_top) then 
				rgb_color <= title_color(o_top_left(sprite_Y, sprite_X));
			elsif ((hs / pix_box) = jumbo_jump_left+12) and ((vs / pix_box) = jumbo_jump_bottom) then 
				rgb_color <= title_color(o_bottom_left(sprite_Y, sprite_X));
			elsif ((hs / pix_box) = jumbo_jump_left+13) and ((vs / pix_box) = jumbo_jump_top) then 
				rgb_color <= title_color(o_top_right(sprite_Y, sprite_X));
			elsif ((hs / pix_box) = jumbo_jump_left+13) and ((vs / pix_box) = jumbo_jump_bottom) then 
				rgb_color <= title_color(o_bottom_right(sprite_Y, sprite_X));
			--J
			elsif ((hs / pix_box) = jumbo_jump_left+16) and ((vs / pix_box) = jumbo_jump_top) then 
				rgb_color <= title_color(big_j_top_left(sprite_Y, sprite_X));
			elsif ((hs / pix_box) = jumbo_jump_left+16) and ((vs / pix_box) = jumbo_jump_bottom) then 
				rgb_color <= title_color(big_j_bottom_left(sprite_Y, sprite_X));
			elsif ((hs / pix_box) = jumbo_jump_left+17) and ((vs / pix_box) = jumbo_jump_top) then 
				rgb_color <= title_color(big_j_top_right(sprite_Y, sprite_X));
			elsif ((hs / pix_box) = jumbo_jump_left+17) and ((vs / pix_box) = jumbo_jump_bottom) then 
				rgb_color <= title_color(big_j_bottom_right(sprite_Y, sprite_X));
			--u
			elsif ((hs / pix_box) = jumbo_jump_left+19) and ((vs / pix_box) = jumbo_jump_top) then 
				rgb_color <= title_color(u_top_left(sprite_Y, sprite_X));
			elsif ((hs / pix_box) = jumbo_jump_left+19) and ((vs / pix_box) = jumbo_jump_bottom) then 
				rgb_color <= title_color(u_bottom_left(sprite_Y, sprite_X));
			elsif ((hs / pix_box) = jumbo_jump_left+20) and ((vs / pix_box) = jumbo_jump_top) then 
				rgb_color <= title_color(u_top_right(sprite_Y, sprite_X));
			elsif ((hs / pix_box) = jumbo_jump_left+20) and ((vs / pix_box) = jumbo_jump_bottom) then 
				rgb_color <= title_color(u_bottom_right(sprite_Y, sprite_X));
			--m
			elsif ((hs / pix_box) = jumbo_jump_left+22) and ((vs / pix_box) = jumbo_jump_top) then 
				rgb_color <= title_color(m_top_left(sprite_Y, sprite_X));
			elsif ((hs / pix_box) = jumbo_jump_left+22) and ((vs / pix_box) = jumbo_jump_bottom) then 
				rgb_color <= title_color(m_bottom_left(sprite_Y, sprite_X));
			elsif ((hs / pix_box) = jumbo_jump_left+23) and ((vs / pix_box) = jumbo_jump_top) then 
				rgb_color <= title_color(m_top_right(sprite_Y, sprite_X));
			elsif ((hs / pix_box) = jumbo_jump_left+23) and ((vs / pix_box) = jumbo_jump_bottom) then 
				rgb_color <= title_color(m_bottom_right(sprite_Y, sprite_X));
			--p
			elsif ((hs / pix_box) = jumbo_jump_left+25) and ((vs / pix_box) = jumbo_jump_top) then 
				rgb_color <= title_color(p_top_left(sprite_Y, sprite_X));
			elsif ((hs / pix_box) = jumbo_jump_left+25) and ((vs / pix_box) = jumbo_jump_bottom) then 
				rgb_color <= title_color(p_bottom_left(sprite_Y, sprite_X));
			elsif ((hs / pix_box) = jumbo_jump_left+26) and ((vs / pix_box) = jumbo_jump_top) then 
				rgb_color <= title_color(p_top_right(sprite_Y, sprite_X));
			elsif ((hs / pix_box) = jumbo_jump_left+26) and ((vs / pix_box) = jumbo_jump_bottom) then 
				rgb_color <= title_color(p_bottom_right(sprite_Y, sprite_X));
			---- begin 'press start'
			-- p			
			elsif ((hs / pix_box) = press_start_left) and ((vs / pix_box) = press_start_top) then 
				rgb_color <= text_color(p_top_left(sprite_Y, sprite_X));
			elsif ((hs / pix_box) = press_start_left) and ((vs / pix_box) = press_start_bottom) then 
				rgb_color <= text_color(p_bottom_left(sprite_Y, sprite_X));
			elsif ((hs / pix_box) = press_start_left+1) and ((vs / pix_box) = press_start_top) then 
				rgb_color <= text_color(p_top_right(sprite_Y, sprite_X));
			elsif ((hs / pix_box) = press_start_left+1) and ((vs / pix_box) = press_start_bottom) then 
				rgb_color <= text_color(p_bottom_right(sprite_Y, sprite_X));
			-- r
			elsif ((hs / pix_box) = press_start_left+2) and ((vs / pix_box) = press_start_top) then 
				rgb_color <= text_color(r_top_left(sprite_Y, sprite_X));
			elsif ((hs / pix_box) = press_start_left+2) and ((vs / pix_box) = press_start_bottom) then 
				rgb_color <= text_color(r_bottom_left(sprite_Y, sprite_X));
			elsif ((hs / pix_box) = press_start_left+3) and ((vs / pix_box) = press_start_top) then 
				rgb_color <= text_color(r_top_right(sprite_Y, sprite_X));
			elsif ((hs / pix_box) = press_start_left+3) and ((vs / pix_box) = press_start_bottom) then 
				rgb_color <= text_color(r_bottom_right(sprite_Y, sprite_X));
			-- e
			elsif ((hs / pix_box) = press_start_left+4) and ((vs / pix_box) = press_start_top) then 
				rgb_color <= text_color(e_top_left(sprite_Y, sprite_X));
			elsif ((hs / pix_box) = press_start_left+4) and ((vs / pix_box) = press_start_bottom) then 
				rgb_color <= text_color(e_bottom_left(sprite_Y, sprite_X));
			elsif ((hs / pix_box) = press_start_left+5) and ((vs / pix_box) = press_start_top) then 
				rgb_color <= text_color(e_top_right(sprite_Y, sprite_X));
			elsif ((hs / pix_box) = press_start_left+5) and ((vs / pix_box) = press_start_bottom) then 
				rgb_color <= text_color(e_bottom_right(sprite_Y, sprite_X));
			-- s
			elsif ((hs / pix_box) = press_start_left+6) and ((vs / pix_box) = press_start_top) then 
				rgb_color <= text_color(s_top_left(sprite_Y, sprite_X));
			elsif ((hs / pix_box) = press_start_left+6) and ((vs / pix_box) = press_start_bottom) then 
				rgb_color <= text_color(s_bottom_left(sprite_Y, sprite_X));
			elsif ((hs / pix_box) = press_start_left+7) and ((vs / pix_box) = press_start_top) then 
				rgb_color <= text_color(s_top_right(sprite_Y, sprite_X));
			elsif ((hs / pix_box) = press_start_left+7) and ((vs / pix_box) = press_start_bottom) then 
				rgb_color <= text_color(s_bottom_right(sprite_Y, sprite_X));
			-- s
			elsif ((hs / pix_box) = press_start_left+8) and ((vs / pix_box) = press_start_top) then 
				rgb_color <= text_color(s_top_left(sprite_Y, sprite_X));
			elsif ((hs / pix_box) = press_start_left+8) and ((vs / pix_box) = press_start_bottom) then 
				rgb_color <= text_color(s_bottom_left(sprite_Y, sprite_X));
			elsif ((hs / pix_box) = press_start_left+9) and ((vs / pix_box) = press_start_top) then 
				rgb_color <= text_color(s_top_right(sprite_Y, sprite_X));
			elsif ((hs / pix_box) = press_start_left+9) and ((vs / pix_box) = press_start_bottom) then 
				rgb_color <= text_color(s_bottom_right(sprite_Y, sprite_X));
			-- s
			elsif ((hs / pix_box) = press_start_left+11) and ((vs / pix_box) = press_start_top) then 
				rgb_color <= text_color(s_top_left(sprite_Y, sprite_X));
			elsif ((hs / pix_box) = press_start_left+11) and ((vs / pix_box) = press_start_bottom) then 
				rgb_color <= text_color(s_bottom_left(sprite_Y, sprite_X));
			elsif ((hs / pix_box) = press_start_left+12) and ((vs / pix_box) = press_start_top) then 
				rgb_color <= text_color(s_top_right(sprite_Y, sprite_X));
			elsif ((hs / pix_box) = press_start_left+12) and ((vs / pix_box) = press_start_bottom) then 
				rgb_color <= text_color(s_bottom_right(sprite_Y, sprite_X));
			-- t
			elsif ((hs / pix_box) = press_start_left+13) and ((vs / pix_box) = press_start_top) then 
				rgb_color <= text_color(t_top_left(sprite_Y, sprite_X));
			elsif ((hs / pix_box) = press_start_left+13) and ((vs / pix_box) = press_start_bottom) then 
				rgb_color <= text_color(t_bottom_left(sprite_Y, sprite_X));
			elsif ((hs / pix_box) = press_start_left+14) and ((vs / pix_box) = press_start_top) then 
				rgb_color <= text_color(t_top_right(sprite_Y, sprite_X));
			elsif ((hs / pix_box) = press_start_left+14) and ((vs / pix_box) = press_start_bottom) then 
				rgb_color <= text_color(t_bottom_right(sprite_Y, sprite_X));
			-- a
			elsif ((hs / pix_box) = press_start_left+15) and ((vs / pix_box) = press_start_top) then 
				rgb_color <= text_color(a_top_left(sprite_Y, sprite_X));
			elsif ((hs / pix_box) = press_start_left+15) and ((vs / pix_box) = press_start_bottom) then 
				rgb_color <= text_color(a_bottom_left(sprite_Y, sprite_X));
			elsif ((hs / pix_box) = press_start_left+16) and ((vs / pix_box) = press_start_top) then 
				rgb_color <= text_color(a_top_right(sprite_Y, sprite_X));
			elsif ((hs / pix_box) = press_start_left+16) and ((vs / pix_box) = press_start_bottom) then 
				rgb_color <= text_color(a_bottom_right(sprite_Y, sprite_X));
			-- r
			elsif ((hs / pix_box) = press_start_left+17) and ((vs / pix_box) = press_start_top) then 
				rgb_color <= text_color(r_top_left(sprite_Y, sprite_X));
			elsif ((hs / pix_box) = press_start_left+17) and ((vs / pix_box) = press_start_bottom) then 
				rgb_color <= text_color(r_bottom_left(sprite_Y, sprite_X));
			elsif ((hs / pix_box) = press_start_left+18) and ((vs / pix_box) = press_start_top) then 
				rgb_color <= text_color(r_top_right(sprite_Y, sprite_X));
			elsif ((hs / pix_box) = press_start_left+18) and ((vs / pix_box) = press_start_bottom) then 
				rgb_color <= text_color(r_bottom_right(sprite_Y, sprite_X));
			-- t
			elsif ((hs / pix_box) = press_start_left+19) and ((vs / pix_box) = press_start_top) then 
				rgb_color <= text_color(t_top_left(sprite_Y, sprite_X));
			elsif ((hs / pix_box) = press_start_left+19) and ((vs / pix_box) = press_start_bottom) then 
				rgb_color <= text_color(t_bottom_left(sprite_Y, sprite_X));
			elsif ((hs / pix_box) = press_start_left+20) and ((vs / pix_box) = press_start_top) then 
				rgb_color <= text_color(t_top_right(sprite_Y, sprite_X));
			elsif ((hs / pix_box) = press_start_left+20) and ((vs / pix_box) = press_start_bottom) then 
				rgb_color <= text_color(t_bottom_right(sprite_Y, sprite_X));
			---- end 'press start'
			
			elsif ((hs / pix_box) = 10) and ((vs / pix_box) = 24) then 
				rgb_color <= jumbo_color(jumbo_box_3(sprite_Y, sprite_X));
			elsif ((hs / pix_box) = 11) and ((vs / pix_box) = 24) then 
				rgb_color <= jumbo_color(jumbo_box_4(sprite_Y, sprite_X));
			elsif ((hs / pix_box) = 10) and ((vs / pix_box) = 23) then 
				rgb_color <= jumbo_color(jumbo_box_1(sprite_Y, sprite_X));
			elsif ((hs / pix_box) = 11) and ((vs / pix_box) = 23) then 
				rgb_color <= jumbo_color(jumbo_box_2(sprite_Y, sprite_X));
			end if;
		
		elsif (game_over = '1') then
		--- brown sprite
			
			if ((hs / pix_box) = brown_c3) and ((vs / pix_box) = brown_r2) then 
				rgb_color <= brown_color(brown_c3_r2(sprite_Y, sprite_X));
			elsif ((hs / pix_box) = brown_c3) and ((vs / pix_box) = brown_r3) then 
				rgb_color <= brown_color(brown_c3_r3(sprite_Y, sprite_X));
			elsif ((hs / pix_box) = brown_c3) and ((vs / pix_box) = brown_r4) then 
				rgb_color <= brown_color(brown_c3_r4(sprite_Y, sprite_X));
			elsif ((hs / pix_box) = brown_c3) and ((vs / pix_box) = brown_r5) then 
				rgb_color <= brown_color(brown_c3_r5(sprite_Y, sprite_X));
			--
			elsif ((hs / pix_box) = brown_c4) and ((vs / pix_box) = brown_r1) then 
				rgb_color <= brown_color(brown_c4_r1(sprite_Y, sprite_X));
			elsif ((hs / pix_box) = brown_c4) and ((vs / pix_box) = brown_r2) then 
				rgb_color <= brown_color(brown_c4_r2(sprite_Y, sprite_X));
			elsif ((hs / pix_box) = brown_c4) and ((vs / pix_box) = brown_r3) then 
				rgb_color <= brown_color(brown_c4_r3(sprite_Y, sprite_X));
			elsif ((hs / pix_box) = brown_c4) and ((vs / pix_box) = brown_r4) then 
				rgb_color <= brown_color(brown_c4_r4(sprite_Y, sprite_X));
			elsif ((hs / pix_box) = brown_c4) and ((vs / pix_box) = brown_r5) then 
				rgb_color <= brown_color(brown_c4_r5(sprite_Y, sprite_X));
			elsif ((hs / pix_box) = brown_c4) and ((vs / pix_box) = brown_r6) then 
				rgb_color <= brown_color(brown_c4_r6(sprite_Y, sprite_X));
			--
			elsif ((hs / pix_box) = brown_c5) and ((vs / pix_box) = brown_r1) then 
				rgb_color <= brown_color(brown_c5_r1(sprite_Y, sprite_X));
			elsif ((hs / pix_box) = brown_c5) and ((vs / pix_box) = brown_r2) then 
				rgb_color <= brown_color(brown_c5_r2(sprite_Y, sprite_X));
			elsif ((hs / pix_box) = brown_c5) and ((vs / pix_box) = brown_r3) then 
				rgb_color <= brown_color(brown_c5_r3(sprite_Y, sprite_X));
			elsif ((hs / pix_box) = brown_c5) and ((vs / pix_box) = brown_r4) then 
				rgb_color <= brown_color(brown_c5_r4(sprite_Y, sprite_X));
			elsif ((hs / pix_box) = brown_c5) and ((vs / pix_box) = brown_r5) then 
				rgb_color <= brown_color(brown_c5_r5(sprite_Y, sprite_X));
			elsif ((hs / pix_box) = brown_c5) and ((vs / pix_box) = brown_r6) then 
				rgb_color <= brown_color(brown_c5_r6(sprite_Y, sprite_X));
			--
			
			elsif ((hs / pix_box) = brown_c6) and ((vs / pix_box) = brown_r2) then 
				rgb_color <= brown_color(brown_c6_r2(sprite_Y, sprite_X));
			elsif ((hs / pix_box) = brown_c6) and ((vs / pix_box) = brown_r3) then 
				rgb_color <= brown_color(brown_c6_r3(sprite_Y, sprite_X));
			elsif ((hs / pix_box) = brown_c6) and ((vs / pix_box) = brown_r4) then 
				rgb_color <= brown_color(brown_c6_r4(sprite_Y, sprite_X));
			elsif ((hs / pix_box) = brown_c6) and ((vs / pix_box) = brown_r5) then 
				rgb_color <= brown_color(brown_c6_r5(sprite_Y, sprite_X));
			--- brown sprite end
			
			
			
			---game_over text--
			--b
			elsif ((hs / pix_box) = game_over_text_brown) and ((vs / pix_box) = game_over_text_brown_top) then 
				rgb_color <= text_color(b_top_left(sprite_Y, sprite_X));
			elsif ((hs / pix_box) = game_over_text_brown) and ((vs / pix_box) = game_over_text_brown_bottom) then 
				rgb_color <= text_color(b_bottom_left(sprite_Y, sprite_X));
			elsif ((hs / pix_box) = game_over_text_brown+1) and ((vs / pix_box) = game_over_text_brown_top) then 
				rgb_color <= text_color(b_top_right(sprite_Y, sprite_X));
			elsif ((hs / pix_box) = game_over_text_brown+1) and ((vs / pix_box) = game_over_text_brown_bottom) then 
				rgb_color <= text_color(b_bottom_right(sprite_Y, sprite_X));
			--r
			elsif ((hs / pix_box) = game_over_text_brown+3) and ((vs / pix_box) = game_over_text_brown_top) then 
				rgb_color <= text_color(r_top_left(sprite_Y, sprite_X));
			elsif ((hs / pix_box) = game_over_text_brown+3) and ((vs / pix_box) = game_over_text_brown_bottom) then 
				rgb_color <= text_color(r_bottom_left(sprite_Y, sprite_X));
			elsif ((hs / pix_box) = game_over_text_brown+4) and ((vs / pix_box) = game_over_text_brown_top) then 
				rgb_color <= text_color(r_top_right(sprite_Y, sprite_X));
			elsif ((hs / pix_box) = game_over_text_brown+4) and ((vs / pix_box) = game_over_text_brown_bottom) then 
				rgb_color <= text_color(r_bottom_right(sprite_Y, sprite_X));
			--o
			elsif ((hs / pix_box) = game_over_text_brown+6) and ((vs / pix_box) = game_over_text_brown_top) then 
				rgb_color <= text_color(o_top_left(sprite_Y, sprite_X));
			elsif ((hs / pix_box) = game_over_text_brown+6) and ((vs / pix_box) = game_over_text_brown_bottom) then 
				rgb_color <= text_color(o_bottom_left(sprite_Y, sprite_X));
			elsif ((hs / pix_box) = game_over_text_brown+7) and ((vs / pix_box) = game_over_text_brown_top) then 
				rgb_color <= text_color(o_top_right(sprite_Y, sprite_X));
			elsif ((hs / pix_box) = game_over_text_brown+7) and ((vs / pix_box) = game_over_text_brown_bottom) then 
				rgb_color <= text_color(o_bottom_right(sprite_Y, sprite_X));
			--w
			elsif ((hs / pix_box) = game_over_text_brown+9) and ((vs / pix_box) = game_over_text_brown_top) then 
				rgb_color <= text_color(w_top_left(sprite_Y, sprite_X));
			elsif ((hs / pix_box) = game_over_text_brown+9) and ((vs / pix_box) = game_over_text_brown_bottom) then 
				rgb_color <= text_color(w_bottom_left(sprite_Y, sprite_X));
			elsif ((hs / pix_box) = game_over_text_brown+10) and ((vs / pix_box) = game_over_text_brown_top) then 
				rgb_color <= text_color(w_top_right(sprite_Y, sprite_X));
			elsif ((hs / pix_box) = game_over_text_brown+10) and ((vs / pix_box) = game_over_text_brown_bottom) then 
				rgb_color <= text_color(w_bottom_right(sprite_Y, sprite_X));
			--n
			elsif ((hs / pix_box) = game_over_text_brown+12) and ((vs / pix_box) = game_over_text_brown_top) then 
				rgb_color <= text_color(n_top_left(sprite_Y, sprite_X));
			elsif ((hs / pix_box) = game_over_text_brown+12) and ((vs / pix_box) = game_over_text_brown_bottom) then 
				rgb_color <= text_color(n_bottom_left(sprite_Y, sprite_X));
			elsif ((hs / pix_box) = game_over_text_brown+13) and ((vs / pix_box) = game_over_text_brown_top) then 
				rgb_color <= text_color(n_top_right(sprite_Y, sprite_X));
			elsif ((hs / pix_box) = game_over_text_brown+13) and ((vs / pix_box) = game_over_text_brown_bottom) then 
				rgb_color <= text_color(n_bottom_right(sprite_Y, sprite_X));
				
			--r
			elsif ((hs / pix_box) = game_over_text_reject) and ((vs / pix_box) = game_over_text_reject_top) then 
				rgb_color <= text_color(r_top_left(sprite_Y, sprite_X));
			elsif ((hs / pix_box) = game_over_text_reject) and ((vs / pix_box) = game_over_text_reject_bottom) then 
				rgb_color <= text_color(r_bottom_left(sprite_Y, sprite_X));
			elsif ((hs / pix_box) = game_over_text_reject+1) and ((vs / pix_box) = game_over_text_reject_top) then 
				rgb_color <= text_color(r_top_right(sprite_Y, sprite_X));
			elsif ((hs / pix_box) = game_over_text_reject+1) and ((vs / pix_box) = game_over_text_reject_bottom) then 
				rgb_color <= text_color(r_bottom_right(sprite_Y, sprite_X));
			--e
			elsif ((hs / pix_box) = game_over_text_reject+3) and ((vs / pix_box) = game_over_text_reject_top) then 
				rgb_color <= text_color(e_top_left(sprite_Y, sprite_X));
			elsif ((hs / pix_box) = game_over_text_reject+3) and ((vs / pix_box) = game_over_text_reject_bottom) then 
				rgb_color <= text_color(e_bottom_left(sprite_Y, sprite_X));
			elsif ((hs / pix_box) = game_over_text_reject+4) and ((vs / pix_box) = game_over_text_reject_top) then 
				rgb_color <= text_color(e_top_right(sprite_Y, sprite_X));
			elsif ((hs / pix_box) = game_over_text_reject+4) and ((vs / pix_box) = game_over_text_reject_bottom) then 
				rgb_color <= text_color(e_bottom_right(sprite_Y, sprite_X));
			--j
			elsif ((hs / pix_box) = game_over_text_reject+6) and ((vs / pix_box) = game_over_text_reject_top) then 
				rgb_color <= text_color(j_top_left(sprite_Y, sprite_X));
			elsif ((hs / pix_box) = game_over_text_reject+6) and ((vs / pix_box) = game_over_text_reject_bottom) then 
				rgb_color <= text_color(j_bottom_left(sprite_Y, sprite_X));
			elsif ((hs / pix_box) = game_over_text_reject+7) and ((vs / pix_box) = game_over_text_reject_top) then 
				rgb_color <= text_color(j_top_right(sprite_Y, sprite_X));
			elsif ((hs / pix_box) = game_over_text_reject+7) and ((vs / pix_box) = game_over_text_reject_bottom) then 
				rgb_color <= text_color(j_bottom_right(sprite_Y, sprite_X));
			--e
			elsif ((hs / pix_box) = game_over_text_reject+9) and ((vs / pix_box) = game_over_text_reject_top) then 
				rgb_color <= text_color(e_top_left(sprite_Y, sprite_X));
			elsif ((hs / pix_box) = game_over_text_reject+9) and ((vs / pix_box) = game_over_text_reject_bottom) then 
				rgb_color <= text_color(e_bottom_left(sprite_Y, sprite_X));
			elsif ((hs / pix_box) = game_over_text_reject+10) and ((vs / pix_box) = game_over_text_reject_top) then 
				rgb_color <= text_color(e_top_right(sprite_Y, sprite_X));
			elsif ((hs / pix_box) = game_over_text_reject+10) and ((vs / pix_box) = game_over_text_reject_bottom) then 
				rgb_color <= text_color(e_bottom_right(sprite_Y, sprite_X));
			--c
			elsif ((hs / pix_box) = game_over_text_reject+12) and ((vs / pix_box) = game_over_text_reject_top) then 
				rgb_color <= text_color(c_top_left(sprite_Y, sprite_X));
			elsif ((hs / pix_box) = game_over_text_reject+12) and ((vs / pix_box) = game_over_text_reject_bottom) then 
				rgb_color <= text_color(c_bottom_left(sprite_Y, sprite_X));
			elsif ((hs / pix_box) = game_over_text_reject+13) and ((vs / pix_box) = game_over_text_reject_top) then 
				rgb_color <= text_color(c_top_right(sprite_Y, sprite_X));
			elsif ((hs / pix_box) = game_over_text_reject+13) and ((vs / pix_box) = game_over_text_reject_bottom) then 
				rgb_color <= text_color(c_bottom_right(sprite_Y, sprite_X));
			--t
			elsif ((hs / pix_box) = game_over_text_reject+15) and ((vs / pix_box) = game_over_text_reject_top) then 
				rgb_color <= text_color(t_top_left(sprite_Y, sprite_X));
			elsif ((hs / pix_box) = game_over_text_reject+15) and ((vs / pix_box) = game_over_text_reject_bottom) then 
				rgb_color <= text_color(t_bottom_left(sprite_Y, sprite_X));
			elsif ((hs / pix_box) = game_over_text_reject+16) and ((vs / pix_box) = game_over_text_reject_top) then 
				rgb_color <= text_color(t_top_right(sprite_Y, sprite_X));
			elsif ((hs / pix_box) = game_over_text_reject+16) and ((vs / pix_box) = game_over_text_reject_bottom) then 
				rgb_color <= text_color(t_bottom_right(sprite_Y, sprite_X));
			
			elsif ((hs / pix_box) = game_over_text_reject+18) and ((vs / pix_box) = game_over_text_reject_top) then 
				rgb_color <= text_color(colon_top(sprite_Y, sprite_X));
			elsif ((hs / pix_box) = game_over_text_reject+18) and ((vs / pix_box) = game_over_text_reject_bottom) then 
				rgb_color <= text_color(colon_bottom(sprite_Y, sprite_X));
			elsif ((hs / pix_box) = game_over_text_reject+19) and ((vs / pix_box) = game_over_text_reject_top) then 
				rgb_color <= text_color(slash_top(sprite_Y, sprite_X));
			elsif ((hs / pix_box) = game_over_text_reject+19) and ((vs / pix_box) = game_over_text_reject_bottom) then 
				rgb_color <= text_color(slash_bottom(sprite_Y, sprite_X));
				
			elsif ((hs / pix_box) = jumbo_left_X) and ((vs / pix_box) = jumbo_top_Y) then 
				rgb_color <= jumbo_color(jumbo_box_1(sprite_Y, sprite_X));
			elsif ((hs / pix_box) = jumbo_right_X) and ((vs / pix_box) = jumbo_top_Y) then 
				rgb_color <= jumbo_color(jumbo_box_2_dead(sprite_Y, sprite_X));
			elsif ((hs / pix_box) = jumbo_left_X) and ((vs / pix_box) = jumbo_bottom_Y) then 
				rgb_color <= jumbo_color(jumbo_box_3(sprite_Y, sprite_X));
			elsif ((hs / pix_box) = jumbo_right_X) and ((vs / pix_box) = jumbo_bottom_Y) then 
				rgb_color <= jumbo_color(jumbo_box_4_dead(sprite_Y, sprite_X));
			end if;
		elsif playing = '1' then
			if ((hs / pix_box) = jumbo_left_X) and ((vs / pix_box) = jumbo_top_Y) then 
				rgb_color <= jumbo_color(jumbo_box_1(sprite_Y, sprite_X));
			elsif ((hs / pix_box) = jumbo_right_X) and ((vs / pix_box) = jumbo_top_Y) then 
				rgb_color <= jumbo_color(jumbo_box_2(sprite_Y, sprite_X));
			elsif ((hs / pix_box) = jumbo_left_X) and ((vs / pix_box) = jumbo_bottom_Y) then 
				if walk_count < 6000 and walk_count >= 3000 then 
					rgb_color <= jumbo_color(jumbo_walk_1_box_3(sprite_Y, sprite_X));
				elsif walk_count < 12000 and walk_count >= 9000 then
					rgb_color <= jumbo_color(jumbo_walk_2_box_3(sprite_Y, sprite_X));
				else
					rgb_color <= jumbo_color(jumbo_box_3(sprite_Y, sprite_X));
				end if;
			elsif ((hs / pix_box) = jumbo_right_X) and ((vs / pix_box) = jumbo_bottom_Y) then 
				if walk_count < 6000 and walk_count >= 3000 then 
					rgb_color <= jumbo_color(jumbo_walk_1_box_4(sprite_Y, sprite_X));
				elsif walk_count < 1200 and walk_count >= 9000 then
					rgb_color <= jumbo_color(jumbo_walk_2_box_4(sprite_Y, sprite_X));
				else
					rgb_color <= jumbo_color(jumbo_box_4(sprite_Y, sprite_X));
				end if;
			elsif ((hs/pix_box) = acorn_head_1_X) and ((vs / pix_box) = acorn_head_Y) then
				rgb_color <= acorn_head_color(acorn_head_1(sprite_Y, sprite_X));
			elsif ((hs/pix_box) = acorn_head_2_X) and ((vs / pix_box) = acorn_head_Y) then
				rgb_color <= acorn_head_color(acorn_head_1(sprite_Y, sprite_X));
			elsif ((hs/pix_box) = acorn_head_3_X) and ((vs / pix_box) = acorn_head_Y) then
				rgb_color <= acorn_head_color(acorn_head_1(sprite_Y, sprite_X));
			elsif ((hs / pix_box) = cloud_left_X) and ((vs / pix_box) = cloud_Y) then 
				rgb_color <= cloud_color(cloud_left(sprite_Y, sprite_X));
			elsif ((hs / pix_box) = cloud_right_X) and ((vs / pix_box) = cloud_Y) then 
				rgb_color <= cloud_color(cloud_right(sprite_Y, sprite_X));
			elsif ((hs / pix_box) = ground_1_X) and ((vs / pix_box) = ground_1_Y) then 
				rgb_color <= ground_color(ground_2(sprite_Y, sprite_X));
			elsif ((hs / pix_box) = ground_2_X) and ((vs / pix_box) = ground_2_Y) then 
				rgb_color <= ground_color(ground_2(sprite_Y, sprite_X));
			elsif ((hs / pix_box) = ground_3_X) and ((vs / pix_box) = ground_3_Y) then 
				rgb_color <= ground_color(ground_2(sprite_Y, sprite_X));
			end if; 
			
		end if;
	else 
		rgb_color <= "000000";
	end if;
end if;

rgb <= rgb_color;

end process;
  
  
process (clk) 

begin
	if rising_edge(clk) then
	
		if home_screen = '1' then 
			jumbo_left_X <= 10;
			jumbo_right_X <= 11;
			jumbo_top_Y <= 23;
			jumbo_bottom_Y <= 24;
			jumbo_count <= 0;
			acorn_head_1_X <= cols;
			acorn_head_2_X <= cols + cols/2;
			acorn_head_3_X <= cols + cols;
			acorn_count <= 0;
		elsif game_over = '1' then 
			acorn_head_1_X <= cols;
			acorn_head_2_X <= cols + cols/2;
			acorn_head_3_X <= cols + cols;
			game_speed <= 0;
		else 
			acorn_count <= acorn_count + 1;
			jumbo_count <= jumbo_count + 1;
			cloud_count <= cloud_count + 1;
			ground_count <= ground_count + 1;
		
		
		--if previous_score10 = score10 then
			--if (increase_speed = '0') and (score10 = 4d"9") and (score1 = 4d"9") then
				--increase_speed <= '1';
			--end if;
		--else 
			--previous_score10 <= score10;
		--end if;
		
		if (score10 = 4d"9") and (score1 = 4d"9") then 
			speed_up <= speed_up + 1;
		else 
			speed_up <= 0;
		end if;
		
		if (game_speed < 20) and speed_up = 1 then 
			game_speed <= game_speed + 2;
		end if;
	
		if (NES_output(7) = '0') and (jumbo_bottom_Y = 24) then 
			jumping <= '1';
		end if;
		
		if (game_over = '0') and (playing = '1') and (home_screen = '0') and (jumbo_count >= 104160 * (jumbo_speed)) then
			if jumping = '1' then 
				if jumbo_top_Y > 19 then 
					jumbo_top_Y <= jumbo_top_Y - 1;
				else 
					jumping <= '0';
				end if;
				if jumbo_bottom_Y > 20 then 
					jumbo_bottom_Y <= jumbo_bottom_Y - 1;
				else 
					jumping <= '0';
				end if;
				jumbo_count <= 0;
			else 
				if jumbo_bottom_Y < 24 then 
					jumbo_bottom_Y <= jumbo_bottom_Y + 1;
				end if;
				if jumbo_top_Y < 23 then 
					jumbo_top_Y <= jumbo_top_Y + 1;
				end if;
				jumbo_count <= 0;
			end if; 
		end if;
		
		if (game_over = '0') and (playing = '1') and (home_screen = '0') and (acorn_count >= 104160 * (acorn_speed - game_speed)) then
			acorn_count <= 0;
			if (acorn_head_1_X <= 0) then
				if (not ((cols + rand_count) = acorn_head_2_X)) and (not ((cols + rand_count) = acorn_head_3_X)) then
					acorn_head_1_X <= cols + rand_count;
				end if;
			elsif (acorn_head_2_X <= 0) then
				if (not ((cols + rand_count) = acorn_head_1_X)) and (not ((cols + rand_count) = acorn_head_3_X)) then
					acorn_head_2_X <= cols + rand_count;
				end if;
			elsif (acorn_head_3_X <= 0) then
				if (not ((cols + rand_count) = acorn_head_1_X)) and (not ((cols + rand_count) = acorn_head_2_X)) then
					acorn_head_3_X <= cols + rand_count;
				end if;
			else
				acorn_head_1_X <= acorn_head_1_X - 1;
				acorn_head_2_X <= acorn_head_2_X - 1;
				acorn_head_3_X <= acorn_head_3_X - 1;
			end if;
			
			if rand_count >= 30 then 
				rand_count <= 0;
			else 
				rand_count <= rand_count + 1;
			end if;
		end if;
		
		
		if (game_over = '0') and (playing = '1') and (home_screen = '0') and (cloud_count >= 104160 * cloud_speed) then
			cloud_count <= 0;
			if (cloud_left_X <= 0) then
				cloud_left_X <= cols + 5;
				cloud_right_X <= cols + 6;
			else
				cloud_left_X <= cloud_left_X - 1;
				cloud_right_X <= cloud_right_X - 1;
			end if;
		end if;
		
		if (game_over = '0') and (playing = '1') and (home_screen = '0') and (ground_count >= 104160 * (ground_speed - game_speed)) then
			ground_count <= 0;
			if (ground_1_X <= 0) then
				ground_1_X <= cols + ground_3_X/2;
			elsif (ground_2_X <= 0) then
				ground_2_X <= cols + ground_1_X/2;
			elsif (ground_3_X <= 0) then
				ground_3_X <= cols + ground_2_X/2;
			else
				ground_1_X <= ground_1_X - 1;
				ground_2_X <= ground_2_X - 1;
				ground_3_X <= ground_3_X - 1;
			end if;
		end if;
		end if;	
	end if;
end process;
end;


