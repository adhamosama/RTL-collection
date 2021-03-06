--  
-- Copyright (c) 2018 Allmine Inc
-- OrphanedGland (wilhelm.klink@gmail.com)
--

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity skein512_tb is
end entity skein512_tb;

architecture skein512_tb_behav of skein512_tb is
  
  alias slv is std_logic_vector;
  
  component blake512_4g is
  port (
    clk                           : in std_logic;
    reset                         : in std_logic;
    start                         : in std_logic;
    data_in                       : in std_logic_vector(639 downto 0);
    hash                          : out std_logic_vector(511 downto 0);
    hash_new                      : out std_logic
  );
  end component blake512_4g;
  
  component bmw512 is
  port (
    clk                           : in std_logic;
    reset                         : in std_logic;
    start                         : in std_logic;
    data_in                       : in std_logic_vector(511 downto 0);
    hash                          : out std_logic_vector(511 downto 0);
    hash_new                      : out std_logic
  );
  end component bmw512;
  
  component groestl512 is
  port (
    clk                           : in std_logic;
    reset                         : in std_logic;
    start                         : in std_logic;
    data_in                       : in std_logic_vector(511 downto 0);
    hash                          : out std_logic_vector(511 downto 0);
    hash_new                      : out std_logic
  );
  end component groestl512;
  
  component skein512_reference is
  port (
    clk                           : in std_logic;
    reset                         : in std_logic;
    start                         : in std_logic;
    data_in                       : in std_logic_vector(511 downto 0);
    hash                          : out std_logic_vector(511 downto 0);
    hash_new                      : out std_logic
  );
  end component skein512_reference;
  
  component skein512 is
  port (
    clk                           : in std_logic;
    reset                         : in std_logic;
    start                         : in std_logic;
    data_in                       : in std_logic_vector(511 downto 0);
    hash                          : out std_logic_vector(511 downto 0);
    hash_new                      : out std_logic
  );
  end component skein512;

  
  constant TCLK_125               : time := 8 ns;
  
  signal clk                      : std_logic := '0';
  signal reset                    : std_logic;
  signal start                    : std_logic := '0';
  signal data_in                  : slv(639 downto 0) := (others => '0');
  signal blake512_hash            : slv(511 downto 0);
  signal blake512_hash_new        : std_logic;
  signal bmw512_hash              : slv(511 downto 0);
  signal bmw512_hash_new          : std_logic;
  signal groestl512_hash          : slv(511 downto 0);
  signal groestl512_hash_new      : std_logic;
  signal skein512_ref_hash        : slv(511 downto 0);
  signal skein512_ref_hash_new    : std_logic;
  signal skein512_hash            : slv(511 downto 0);
  signal skein512_hash_new        : std_logic;
  
begin

  reset                           <= '1', '0' after 12.5 * TCLK_125;

  blake512_4g_inst : blake512_4g
  port map (
    clk                           => clk,
    reset                         => reset,
    start                         => start,
    data_in                       => data_in,
    hash                          => blake512_hash,
    hash_new                      => blake512_hash_new
  );
 
  bmw512_inst : bmw512
  port map (
    clk                           => clk,
    reset                         => reset,
    start                         => blake512_hash_new,
    data_in                       => blake512_hash,
    hash                          => bmw512_hash,
    hash_new                      => bmw512_hash_new
  );
  
  groestl512_inst : groestl512
  port map (
    clk                           => clk,
    reset                         => reset,
    start                         => bmw512_hash_new,
    data_in                       => bmw512_hash,
    hash                          => groestl512_hash,
    hash_new                      => groestl512_hash_new
  );
  
  skein512_ref_inst : skein512_reference
  port map (
    clk                           => clk,
    reset                         => reset,
    start                         => groestl512_hash_new,
    data_in                       => groestl512_hash,
    hash                          => skein512_ref_hash,
    hash_new                      => skein512_ref_hash_new
  );
  
  skein512_inst : skein512
  port map (
    clk                           => clk,
    reset                         => reset,
    start                         => groestl512_hash_new,
    data_in                       => groestl512_hash,
    hash                          => skein512_hash,
    hash_new                      => skein512_hash_new
  );
  
  msg_gen: process is
  begin
    wait until reset = '0';
    data_in                       <= X"efbeadde" & X"deadbeef" & X"deadbeef" & X"deadbeef" & X"deadbeef" & X"deadbeef" & X"deadbeef" & X"deadbeef" & X"deadbeef" & X"deadbeef" &
                                     X"deadbeef" & X"deadbeef" & X"deadbeef" & X"deadbeef" & X"deadbeef" & X"deadbeef" & X"deadbeef" & X"deadbeef" & X"deadbeef" & X"deadbeef"; 
    start                         <= '1';
    wait for TCLK_125;
    start                         <= '0';  
  end process msg_gen;
  
  clk_gen: process is
  begin
      clk                         <= not clk;
      wait for TCLK_125/2;
  end process clk_gen;
  
end architecture skein512_tb_behav;