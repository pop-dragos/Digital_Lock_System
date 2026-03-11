    library IEEE;
    use IEEE.STD_LOGIC_1164.ALL;
    -- Uncomment the following library declaration if using
    -- arithmetic functions with Signed or Unsigned values
    --use IEEE.NUMERIC_STD.ALL;
    -- Uncomment the following library declaration if instantiating
    -- any Xilinx leaf cells in this code.
    --library UNISIM;
    --use UNISIM.VComponents.all;
    
    entity top_level is
        Port ( clk : in std_logic;
               button_reset : in std_logic;        
               button_up : in std_logic;
               button_down : in std_logic;
               button_adauga_cifra : in std_logic;
               liber_ocupat : out std_logic; -- 0=liber, 1=ocupat
               introdu_caractere : out std_logic;
               an : out std_logic_vector(7 downto 0);
               seg : out std_logic_vector(7 downto 0)
         );
    end top_level;
    
     architecture Behavioral of top_level is
        component debouncer
            Port (
                btn : in STD_LOGIC;
                clk : in STD_LOGIC;
                en  : out STD_LOGIC
            );
        end component;
        
        component FSM 
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
        end component;
        
        component displ7seg
            Port ( 
                Clk  : in  STD_LOGIC;
                Rst  : in  STD_LOGIC;
                en   : in  STD_LOGIC;
                Data : in  STD_LOGIC_VECTOR (11 downto 0);   -- datele pentru 8 cifre (cifra 1 din stanga: biti 31..28)
                An   : out STD_LOGIC_VECTOR (7 downto 0);    -- selectia anodului activ
                Seg  : out STD_LOGIC_VECTOR (7 downto 0));   -- selectia catozilor (segmentelor) cifrei active
        end component;
        
        signal up_db, down_db, adauga_cifra_db, reset_db : std_logic;  
        signal enable_ssd :std_logic;
        signal ssd_data : std_logic_vector(11 downto 0);
        
    begin
        -- Debouncer pentru butonul de reset
        debounce_reset : debouncer
            port map (
                btn => button_reset,
                clk => clk,
                en  => reset_db
            );
            
        debounce_up : debouncer
            port map (
                btn => button_up,
                clk => clk,
                en  => up_db
            );
            
        debounce_down : debouncer
            port map (
                btn => button_down,
                clk => clk,
                en  => down_db
            );
            
        debounce_adauga : debouncer
            port map (
                btn => button_adauga_cifra,
                clk => clk,
                en  => adauga_cifra_db
            );
        
        state_machine: FSM
            port map(
               clk => clk,
               reset => reset_db,           
               up_FSM => up_db,
               down_FSM => down_db,
               adauga_cifra_FSM => adauga_cifra_db,
               liber_ocupat => liber_ocupat,
               introdu_caractere => introdu_caractere,
               en => enable_ssd,
               data_out => ssd_data
            );
            
             
         ssd : displ7seg
            port map (
                Clk  => clk,
                Rst => reset_db,            
                en => enable_ssd,
                Data => ssd_data,   -- datele pentru 8 cifre (cifra 1 din stanga: biti 31..28)
                An => an,    -- selectia anodului activ
                Seg => seg
             );
    end Behavioral;
