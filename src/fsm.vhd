library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity FSM is
  Port (   clk : in std_logic;
           reset : in std_logic;
           up_FSM : in std_logic;
           down_FSM : in std_logic;
           adauga_cifra_FSM : in std_logic;
           liber_ocupat : out std_logic; -- 0=liber, 1=ocupat
           introdu_caractere : out std_logic;
           en: out std_logic;-- afiseaza pe 1
           data_out:out std_logic_vector(11 downto 0)
           );
end FSM;

architecture Behavioral of FSM is

component modifica_cifra
        Port ( clk : in std_logic;
               reset : in std_logic;
               up : in std_logic;
               down : in std_logic;
               cifra : out std_logic_vector(3 downto 0)
             );
    end component;
    
signal cifra_curenta: std_logic_vector(3 downto 0);
signal reset_modifica_cifra: std_logic := '0';

signal cod_introdus, cod_salvat: std_logic_vector(11 downto 0);

type state_type is (IDLE, ENTER_CODE_1, ENTER_CODE_2, ENTER_CODE_3, LOCKED, 
                    UNLOCK_CODE_1, UNLOCK_CODE_2, UNLOCK_CODE_3, CHECK_CODE, 
                    UNLOCKED, FAILED_UNLOCK);
                    
signal current_state, next_state : state_type;

begin

modificator: modifica_cifra
        port map (
            clk => clk,
            reset => reset_modifica_cifra,
            up => up_FSM,
            down => down_FSM,
            cifra => cifra_curenta
        );

        
process(clk, reset)
    begin
        if reset = '1' then
            current_state <= IDLE;
            cod_introdus <= (others => '0');
            cod_salvat <= (others => '0');
            reset_modifica_cifra <= '0';
        elsif rising_edge(clk) then
            current_state <= next_state;
            
            -- reset modifica_cifra cand se trece la o noua stare de introducere
            reset_modifica_cifra <= '0';
            
            case next_state is
                -- salveaza cifra cand se iese din starea curenta, nu cand se intra
                when ENTER_CODE_2 =>
                    if current_state = ENTER_CODE_1 then
                        cod_introdus(11 downto 8) <= cifra_curenta;
                        reset_modifica_cifra <= '1';  -- reset pentru urmatoarea cifra
                    end if;
                    
                when ENTER_CODE_3 =>
                    if current_state = ENTER_CODE_2 then
                        cod_introdus(7 downto 4) <= cifra_curenta;
                        reset_modifica_cifra <= '1';
                    end if;
                    
                when LOCKED =>
                    if current_state = ENTER_CODE_3 then
                        cod_introdus(3 downto 0) <= cifra_curenta;
                        cod_salvat <= cod_introdus(11 downto 8) & cod_introdus(7 downto 4) & cifra_curenta;
                        cod_introdus <= (others => '0');
                    end if;
                    
                when UNLOCK_CODE_2 =>
                    if current_state = UNLOCK_CODE_1 then
                        cod_introdus(11 downto 8) <= cifra_curenta;
                        reset_modifica_cifra <= '1';
                    end if;
                    
                when UNLOCK_CODE_3 =>
                    if current_state = UNLOCK_CODE_2 then
                        cod_introdus(7 downto 4) <= cifra_curenta;
                        reset_modifica_cifra <= '1';
                    end if;
                    
                when CHECK_CODE =>
                    if current_state = UNLOCK_CODE_3 then
                        cod_introdus(3 downto 0) <= cifra_curenta;
                    end if;
                    
                -- reset modifica_cifra cand se intra in prima stare de introducere
                when ENTER_CODE_1 =>
                    if current_state = IDLE then
                        reset_modifica_cifra <= '1';
                    end if;
                    
                when UNLOCK_CODE_1 =>
                    if current_state = LOCKED or current_state = FAILED_UNLOCK then
                        reset_modifica_cifra <= '1';
                        cod_introdus <= (others => '0');  -- reset cod_introdus pentru noua incercare
                    end if;
                    
                when others =>
                    null;
            end case;
        end if;
    end process;

process(current_state, adauga_cifra_FSM, cifra_curenta, cod_introdus, cod_salvat)
begin
    -- valori default pentru iesiri
    introdu_caractere <= '0';
    liber_ocupat <= '0';
    data_out <= (others => '0');
    en <= '0';
    next_state <= current_state;

    case current_state is
        when IDLE =>                     
            liber_ocupat <= '0';
            introdu_caractere <= '0';
            en <= '0';
            if adauga_cifra_FSM = '1' then               
                next_state <= ENTER_CODE_1;
            end if;
            
        when ENTER_CODE_1 =>           
            liber_ocupat <= '0';
            introdu_caractere <= '1'; 
            en <= '1';
            data_out(11 downto 8) <= cifra_curenta;    
            if adauga_cifra_FSM = '1' then
                next_state <= ENTER_CODE_2;
            end if;
            
        when ENTER_CODE_2 =>            
            liber_ocupat <= '0';
            introdu_caractere <= '1'; 
            en <= '1';
            data_out(11 downto 8) <= cod_introdus(11 downto 8);  
            data_out(7 downto 4) <= cifra_curenta;               
            if adauga_cifra_FSM = '1' then
                next_state <= ENTER_CODE_3;        
            end if;
            
        when ENTER_CODE_3 =>           
            liber_ocupat <= '0';
            introdu_caractere <= '1';
            en <= '1';
            data_out(11 downto 8) <= cod_introdus(11 downto 8);  
            data_out(7 downto 4) <= cod_introdus(7 downto 4);    
            data_out(3 downto 0) <= cifra_curenta;               
            if adauga_cifra_FSM = '1' then
                next_state <= LOCKED;
            end if;
            
        when LOCKED =>            
            liber_ocupat <= '1';
            introdu_caractere <= '0'; 
            en <= '0';   
            if adauga_cifra_FSM = '1' then
                next_state <= UNLOCK_CODE_1;
            end if;
        
        when UNLOCK_CODE_1 =>            
            liber_ocupat <= '1';
            introdu_caractere <= '1';  
            en <= '1';
            data_out(11 downto 8) <= cifra_curenta;    
            if adauga_cifra_FSM = '1' then
                next_state <= UNLOCK_CODE_2;
            end if;
            
        when UNLOCK_CODE_2 =>            
            liber_ocupat <= '1';
            introdu_caractere <= '1';  
            en <= '1';
            data_out(11 downto 8) <= cod_introdus(11 downto 8);  
            data_out(7 downto 4) <= cifra_curenta;               
            if adauga_cifra_FSM = '1' then
                next_state <= UNLOCK_CODE_3;
            end if;
            
        when UNLOCK_CODE_3 =>            
            liber_ocupat <= '1';
            introdu_caractere <= '1';  
            en <= '1';
            data_out(11 downto 8) <= cod_introdus(11 downto 8);  
            data_out(7 downto 4) <= cod_introdus(7 downto 4);    
            data_out(3 downto 0) <= cifra_curenta;               
            if adauga_cifra_FSM = '1' then
                next_state <= CHECK_CODE;
            end if;
            
        when CHECK_CODE =>
            liber_ocupat <= '1';          
            introdu_caractere <= '0';     
            en <= '1';
            data_out(11 downto 8) <= cod_introdus(11 downto 8);  
            data_out(7 downto 4) <= cod_introdus(7 downto 4);    
            data_out(3 downto 0) <= cod_introdus(3 downto 0);    
            
            if (cod_introdus(11 downto 8) & cod_introdus(7 downto 4) & cod_introdus(3 downto 0)) = cod_salvat then
                next_state <= UNLOCKED;
            else
                next_state <= FAILED_UNLOCK;
            end if;
            
        when UNLOCKED =>
            liber_ocupat <= '0';          
            introdu_caractere <= '0';     
            en <= '0';
            
        when FAILED_UNLOCK =>
            liber_ocupat <= '1';          
            introdu_caractere <= '0';     
            en <= '0';
            if adauga_cifra_FSM = '1' then
                next_state <= UNLOCK_CODE_1;
            end if;
            
    end case;       
end process;

end Behavioral;