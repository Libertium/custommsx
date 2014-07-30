-- --------------------------------------------------------- --
--	scc_interpo test bench									 --
-- ========================================================= --
--	Copyright (c)2007 t.hara								 --
-- --------------------------------------------------------- --

library	ieee;
	use	ieee.std_logic_1164.all;
	use	ieee.std_logic_unsigned.all;
	use	ieee.std_logic_arith.all;

entity tb is
end tb;

architecture behavior of tb is

	-- test target
	component scc_interpo
		port(
			reset		: in	std_logic;							-- �񓯊����Z�b�g 
			clk			: in	std_logic;							-- �x�[�X�N���b�N 
			clkena		: in	std_logic;							-- �N���b�N�C�l�[�u�� 
			clear		: in	std_logic;							-- �������Z�b�g 
			left		: in	std_logic_vector(  7 downto 0 );	-- ��ԍ����T���v�� 
			right		: in	std_logic_vector(  7 downto 0 );	-- ��ԉE���T���v�� 
			wave		: out	std_logic_vector(  7 downto 0 );	-- �o�̓T���v�� 
			reg_en		: in	std_logic;							-- ��ԗL��/���� 
			reg_th1		: in	std_logic_vector(  7 downto 0 );	-- 臒l1 
			reg_th2		: in	std_logic_vector(  7 downto 0 );	-- 臒l2 
			reg_th3		: in	std_logic_vector(  7 downto 0 );	-- 臒l3 
			reg_cnt		: in	std_logic_vector( 11 downto 0 )		-- ������ 
		);
	end component;

	constant CYCLE : time := 10 ns;

	signal reset		: std_logic;
	signal clk			: std_logic;
	signal clkena		: std_logic;
	signal clear		: std_logic;
	signal left			: std_logic_vector(  7 downto 0 );
	signal right		: std_logic_vector(  7 downto 0 );
	signal wave			: std_logic_vector(  7 downto 0 );
	signal reg_en		: std_logic;
	signal reg_th1		: std_logic_vector(  7 downto 0 );
	signal reg_th2		: std_logic_vector(  7 downto 0 );
	signal reg_th3		: std_logic_vector(  7 downto 0 );
	signal reg_cnt		: std_logic_vector( 11 downto 0 );

	signal	tb_clkcnt		: integer := 0;
	signal	tb_clkcnt_clr	: std_logic := '1';
	signal	tb_end			: std_logic := '0';
begin

	--	instance
	u_target: scc_interpo
	port map(
		reset		=> reset	,
		clk			=> clk		,
		clkena		=> clkena	,
		clear		=> clear	,
		left		=> left		,
		right		=> right	,
		wave		=> wave		,
		reg_en		=> reg_en	,
		reg_th1		=> reg_th1	,
		reg_th2		=> reg_th2	,
		reg_th3		=> reg_th3	,
		reg_cnt		=> reg_cnt	
	);

	-- ----------------------------------------------------- --
	--	clock generator										 --
	-- ----------------------------------------------------- --
	process
	begin
		if( tb_end = '1' )then
			wait;
		end if;
		clk <= '0';
		wait for 5 ns;
		clk <= '1';
		wait for 5 ns;
	end process;

	process( clk )
	begin
		if( clk'event and clk = '1' )then
			if( tb_clkcnt_clr = '1' )then
				tb_clkcnt <= 0;
			elsif( clkena = '1' )then
				tb_clkcnt <= tb_clkcnt + 1;
			end if;
		end if;
	end process;

	-- ----------------------------------------------------- --
	--	test bench											 --
	-- ----------------------------------------------------- --
	process
	begin
		-- init
		clkena	<= '0';
		clear	<= '0';
		reset	<= '1';
		reg_en	<= '1';
		reg_th1	<= conv_std_logic_vector(  32, reg_th1'high + 1 );
		reg_th2	<= conv_std_logic_vector(  64, reg_th2'high + 1 );
		reg_th3	<= conv_std_logic_vector( 128, reg_th3'high + 1 );
		reg_cnt	<= conv_std_logic_vector( 500, reg_cnt'high + 1 );
		left	<= conv_std_logic_vector( 0, left'high  + 1 );
		right	<= conv_std_logic_vector( 0, right'high + 1 );

		-- reset
		wait until( clk'event and clk = '1' );
		wait until( clk'event and clk = '1' );
		reset <= '0';

		-- ���� +5 �̏ꍇ 
		clear			<= '1';
		clkena			<= '1';
		wait until( clk'event and clk = '1' );

		left			<= conv_std_logic_vector( 40     , left'high  + 1 );
		right			<= conv_std_logic_vector( 40 +  5, right'high + 1 );
		clear	<= '0';
		tb_clkcnt_clr	<= '0';
		for i in 0 to 500 loop
			wait until( clk'event and clk = '1' );
		end loop;
		tb_clkcnt_clr	<= '1';

		-- ���� -5 �̏ꍇ
		clear			<= '1';
		clkena			<= '1';
		wait until( clk'event and clk = '1' );

		left			<= conv_std_logic_vector( 40 +  5, left'high  + 1 );
		right			<= conv_std_logic_vector( 40     , right'high + 1 );
		clear	<= '0';
		tb_clkcnt_clr	<= '0';
		for i in 0 to 500 loop
			wait until( clk'event and clk = '1' );
		end loop;
		tb_clkcnt_clr	<= '1';

		-- ���� +10 �̏ꍇ 
		clear			<= '1';
		clkena			<= '1';
		wait until( clk'event and clk = '1' );

		left			<= conv_std_logic_vector( 40     , left'high  + 1 );
		right			<= conv_std_logic_vector( 40 + 10, right'high + 1 );
		clear	<= '0';
		tb_clkcnt_clr	<= '0';
		for i in 0 to 500 loop
			wait until( clk'event and clk = '1' );
		end loop;
		tb_clkcnt_clr	<= '1';

		-- ���� -10 �̏ꍇ
		clear			<= '1';
		clkena			<= '1';
		wait until( clk'event and clk = '1' );

		left			<= conv_std_logic_vector( 40 + 10, left'high  + 1 );
		right			<= conv_std_logic_vector( 40     , right'high + 1 );
		clear	<= '0';
		tb_clkcnt_clr	<= '0';
		for i in 0 to 500 loop
			wait until( clk'event and clk = '1' );
		end loop;
		tb_clkcnt_clr	<= '1';

		-- ���� +20 �̏ꍇ 
		clear			<= '1';
		clkena			<= '1';
		wait until( clk'event and clk = '1' );

		left			<= conv_std_logic_vector( 40     , left'high  + 1 );
		right			<= conv_std_logic_vector( 40 + 20, right'high + 1 );
		clear	<= '0';
		tb_clkcnt_clr	<= '0';
		for i in 0 to 500 loop
			wait until( clk'event and clk = '1' );
		end loop;
		tb_clkcnt_clr	<= '1';

		-- ���� -20 �̏ꍇ
		clear			<= '1';
		clkena			<= '1';
		wait until( clk'event and clk = '1' );

		left			<= conv_std_logic_vector( 40 + 20, left'high  + 1 );
		right			<= conv_std_logic_vector( 40     , right'high + 1 );
		clear	<= '0';
		tb_clkcnt_clr	<= '0';
		for i in 0 to 500 loop
			wait until( clk'event and clk = '1' );
		end loop;
		tb_clkcnt_clr	<= '1';

		-- ���� +50 �̏ꍇ 
		clear			<= '1';
		clkena			<= '1';
		wait until( clk'event and clk = '1' );

		left			<= conv_std_logic_vector( 40     , left'high  + 1 );
		right			<= conv_std_logic_vector( 40 + 50, right'high + 1 );
		clear	<= '0';
		tb_clkcnt_clr	<= '0';
		for i in 0 to 500 loop
			wait until( clk'event and clk = '1' );
		end loop;
		tb_clkcnt_clr	<= '1';

		-- ���� -50 �̏ꍇ
		clear			<= '1';
		clkena			<= '1';
		wait until( clk'event and clk = '1' );

		left			<= conv_std_logic_vector( 40 + 50, left'high  + 1 );
		right			<= conv_std_logic_vector( 40     , right'high + 1 );
		clear	<= '0';
		tb_clkcnt_clr	<= '0';
		for i in 0 to 500 loop
			wait until( clk'event and clk = '1' );
		end loop;
		tb_clkcnt_clr	<= '1';

		-- ���� +70 �̏ꍇ 
		clear			<= '1';
		clkena			<= '1';
		wait until( clk'event and clk = '1' );

		left			<= conv_std_logic_vector( 40     , left'high  + 1 );
		right			<= conv_std_logic_vector( 40 + 70, right'high + 1 );
		clear	<= '0';
		tb_clkcnt_clr	<= '0';
		for i in 0 to 500 loop
			wait until( clk'event and clk = '1' );
		end loop;
		tb_clkcnt_clr	<= '1';

		-- ���� -70 �̏ꍇ
		clear			<= '1';
		clkena			<= '1';
		wait until( clk'event and clk = '1' );

		left			<= conv_std_logic_vector( 40 + 70, left'high  + 1 );
		right			<= conv_std_logic_vector( 40     , right'high + 1 );
		clear	<= '0';
		tb_clkcnt_clr	<= '0';
		for i in 0 to 500 loop
			wait until( clk'event and clk = '1' );
		end loop;
		tb_clkcnt_clr	<= '1';

		-- 40 �� -80 �֘A�� 
		clear			<= '1';
		clkena			<= '1';
		wait until( clk'event and clk = '1' );

		left			<= conv_std_logic_vector( 40      , left'high  + 1 );
		right			<= conv_std_logic_vector( 256 - 80, right'high + 1 );	--  -80 �̈Ӗ� 
		clear	<= '0';
		tb_clkcnt_clr	<= '0';
		for i in 0 to 500 loop
			wait until( clk'event and clk = '1' );
		end loop;
		tb_clkcnt_clr	<= '1';

		-- ���� +160 �̏ꍇ 
		clear			<= '1';
		clkena			<= '1';
		wait until( clk'event and clk = '1' );

		left			<= conv_std_logic_vector( 256 - 80, left'high  + 1 );	--  -80 �̈Ӗ� 
		right			<= conv_std_logic_vector(       80, right'high + 1 );
		clear	<= '0';
		tb_clkcnt_clr	<= '0';
		for i in 0 to 500 loop
			wait until( clk'event and clk = '1' );
		end loop;
		tb_clkcnt_clr	<= '1';

		-- ���� -160 �̏ꍇ
		clear			<= '1';
		clkena			<= '1';
		wait until( clk'event and clk = '1' );

		left			<= conv_std_logic_vector(       80, right'high + 1 );
		right			<= conv_std_logic_vector( 256 - 80, left'high  + 1 );	--  -80 �̈Ӗ� 
		clear	<= '0';
		tb_clkcnt_clr	<= '0';
		for i in 0 to 500 loop
			wait until( clk'event and clk = '1' );
		end loop;
		tb_clkcnt_clr	<= '1';

		-- -80 �� -100 �֘A�� 
		clear			<= '1';
		clkena			<= '1';
		wait until( clk'event and clk = '1' );

		left			<= conv_std_logic_vector( 256 - 80, right'high + 1 );	--	-80 �̈Ӗ� 
		right			<= conv_std_logic_vector( 256 -100, left'high  + 1 );	--  -100 �̈Ӗ� 
		clear	<= '0';
		tb_clkcnt_clr	<= '0';
		for i in 0 to 500 loop
			wait until( clk'event and clk = '1' );
		end loop;
		tb_clkcnt_clr	<= '1';

		-- ���� +200 �̏ꍇ 
		clear			<= '1';
		clkena			<= '1';
		wait until( clk'event and clk = '1' );

		left			<= conv_std_logic_vector( 256 -100, left'high  + 1 );	--  -100 �̈Ӗ� 
		right			<= conv_std_logic_vector(      100, right'high + 1 );
		clear	<= '0';
		tb_clkcnt_clr	<= '0';
		for i in 0 to 500 loop
			wait until( clk'event and clk = '1' );
		end loop;
		tb_clkcnt_clr	<= '1';

		-- ���� -200 �̏ꍇ
		clear			<= '1';
		clkena			<= '1';
		wait until( clk'event and clk = '1' );

		left			<= conv_std_logic_vector(      100, right'high + 1 );
		right			<= conv_std_logic_vector( 256 -100, left'high  + 1 );	--  -100 �̈Ӗ� 
		clear	<= '0';
		tb_clkcnt_clr	<= '0';
		for i in 0 to 500 loop
			wait until( clk'event and clk = '1' );
		end loop;
		tb_clkcnt_clr	<= '1';

		-- -100 �� 40 �֘A��
		clear			<= '1';
		clkena			<= '1';
		wait until( clk'event and clk = '1' );

		left			<= conv_std_logic_vector( 256 -100, left'high  + 1 );	--  -100 �̈Ӗ� 
		right			<= conv_std_logic_vector( 40     , left'high  + 1 );
		clear	<= '0';
		tb_clkcnt_clr	<= '0';
		for i in 0 to 500 loop
			wait until( clk'event and clk = '1' );
		end loop;
		tb_clkcnt_clr	<= '1';

		-- ���� +20 �̏ꍇ�ɁA�ˑR�g�`�̉E�����ω������ꍇ 
		clear			<= '1';
		clkena			<= '1';
		wait until( clk'event and clk = '1' );

		left			<= conv_std_logic_vector( 40     , left'high  + 1 );
		right			<= conv_std_logic_vector( 40 + 20, right'high + 1 );
		clear	<= '0';
		tb_clkcnt_clr	<= '0';
		for i in 0 to 200 loop
			wait until( clk'event and clk = '1' );
		end loop;

		right			<= conv_std_logic_vector( 40 - 20, right'high + 1 );
		for i in 0 to 300 loop
			wait until( clk'event and clk = '1' );
		end loop;
		tb_clkcnt_clr	<= '1';

		tb_end <= '1';
		wait;
	end process;

end behavior;
