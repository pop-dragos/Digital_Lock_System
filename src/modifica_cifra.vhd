library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity modifica_cifra is
    Port (
        clk : in std_logic;
        reset : in std_logic;
        up : in std_logic;
        down : in std_logic;
        cifra : out std_logic_vector(3 downto 0)
    );
end modifica_cifra;

architecture Behavioral of modifica_cifra is
    signal cifra_out : std_logic_vector(3 downto 0) := (others => '0');
    signal up_last, down_last : std_logic := '0';
begin
    process(clk, reset)
    begin
        if rising_edge(clk) then
            if reset = '1' then
                cifra_out <= (others => '0');
                up_last <= '0';
                down_last <= '0';
            else
                if up = '1' and up_last = '0' then
                    if unsigned(cifra_out) = 15 then
                        cifra_out <= "0000";
                    else
                        cifra_out <= std_logic_vector(unsigned(cifra_out) + 1);
                    end if;
                end if;

                if down = '1' and down_last = '0' then
                    if unsigned(cifra_out) = 0 then
                        cifra_out <= "1111";
                    else
                        cifra_out <= std_logic_vector(unsigned(cifra_out) - 1);
                    end if;
                end if;

                up_last <= up;
                down_last <= down;
            end if;
        end if;
    end process;

    cifra <= cifra_out;
end Behavioral;
