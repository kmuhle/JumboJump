library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity LFSR is
    port (
        clk : in std_logic;
        rst : in std_logic;
        rand_num : out std_logic_vector(4 downto 0)
    );
end LFSR;

architecture synth of LFSR is
    signal lfsr_reg : std_logic_vector(4 downto 0) := "10011";  -- Initial seed for 5-bit LFSR

begin
    process (clk, rst)
    begin
        if rst = '1' then
            lfsr_reg <= "10011";  -- Reset to the initial seed
        elsif rising_edge(clk) then
            lfsr_reg(4 downto 1) <= lfsr_reg(3 downto 0);
            lfsr_reg(0) <= lfsr_reg(4) xor lfsr_reg(3);

        end if;
		rand_num <= lfsr_reg;
    end process;
    
end synth;

--library IEEE;
--use IEEE.std_logic_1164.all;

--entity lfsr is
  --port(
	  --clk : in std_logic;
	  --reset : in std_logic;
	  --count : out std_logic
  --);
--end lfsr4;

--architecture synth of lfsr is
--signal counter : std_logic_vector(31 downto 0);
--signal counter2 : std_logic_vector(1 downto 0):= "01";
--signal temp : std_logic;

--begin
   -- --count <= "0000";
    --process(clk, reset) begin
        --if reset = '1' then 
            --counter <= "0000000000000000000000000000100";
        --elsif rising_edge(clk) then 
			-- --counter(31 downto 1) <= counter(30 downto 0);
			-- --counter(0) <= (counter(31) xor counter(5));
			--temp <= counter2(0);
			--counter2(0) <= counter2(1);
			--counter2(1) <= temp;
        --end if;
		
    --end process; 
    --count <= counter2(0);
--end;




