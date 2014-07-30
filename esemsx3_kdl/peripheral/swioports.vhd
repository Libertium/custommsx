-- 
-- swioports.vhd
--   Switched I/O ports ($40-$4F)
--   Revision 001
-- 
-- Copyright (c) 2011 KdL
-- All rights reserved.
--
-- Redistribution and use of this source code or any derivative works, are 
-- permitted provided that the following conditions are met:
--
-- 1. Redistributions of source code must retain the above copyright notice, 
--    this list of conditions and the following disclaimer.
-- 2. Redistributions in binary form must reproduce the above copyright 
--    notice, this list of conditions and the following disclaimer in the 
--    documentation and/or other materials provided with the distribution.
-- 3. Redistributions may not be sold, nor may they be used in a commercial 
--    product or activity without specific prior written permission.
--
-- THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS 
-- "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED 
-- TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR 
-- PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR 
-- CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, 
-- EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, 
-- PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS;
-- OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, 
-- WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR 
-- OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF 
-- ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
--

library	ieee;
	use	ieee.std_logic_1164.all;
	use	ieee.std_logic_unsigned.all;

entity switched_io_ports is
	port(	-- 'MAIN' group
			clk21m			: in	std_logic;
			reset			: in	std_logic;
			req				: in	std_logic;
			ack				: out	std_logic;
			wrt				: in	std_logic;
			adr				: in	std_logic_vector( 15 downto 0 );
			dbi				: out	std_logic_vector(  7 downto 0 );
			dbo				: in	std_logic_vector(  7 downto 0 );
			-- 'REGS" group
			io40			: inout	std_logic_vector(  7 downto 0 );		-- ID Manufacturers/Devices	:	$08 (008), $D4 (212=1chipMSX), $FF (255=null)
			io41_id212_n	: inout	std_logic_vector(  7 downto 0 );		-- $41 ID212 states			:	Smart Commands
			io42_id212_n	: inout	std_logic_vector(  7 downto 0 );		-- $42 ID212 states			:	Virtual DIP-SW states
			io43_id212_n	: inout	std_logic_vector(  7 downto 0 );		-- $43 ID212 states			:	Lock Mask for port $42 functions, cmt and reset key
			io44_id212_n	: inout	std_logic_vector(  7 downto 0 );		-- $44 ID212 states			:	Lights Mask have the green leds control when Lights Mode is enabled
			OpllVol			: inout	std_logic_vector(  2 downto 0 );		-- OPLL Volume
			SccVol			: inout	std_logic_vector(  2 downto 0 );		-- SCC Volume
			PsgVol			: inout	std_logic_vector(  2 downto 0 );		-- PSG Volume
			MstrVol			: inout	std_logic_vector(  2 downto 0 );		-- Master Volume
			CustomSpeed		: inout	std_logic_vector(  3 downto 0 );		-- Counter limiter of CPU wait control
			tMegaSD			: inout std_logic;								-- Turbo on MegaSD access
			tPanaRedir		: inout std_logic;								-- Pana Redirection switch
			Vga60Ena		: inout std_logic;								-- VGA modes forced at 60Hz
			Mapper_req		: inout	std_logic;								-- Mapper req 				:	Warm or Cold Reset are necessary to complete the request
			Mapper_ack		: out	std_logic;								-- Current Mapper state
			MegaSD_req		: inout	std_logic;								-- MegaSD req				:	Warm or Cold Reset are necessary to complete the request
			MegaSD_ack		: out	std_logic;								-- Current MegaSD state
			io41_id008_n	: inout	std_logic;								-- $41 ID008 BIT-0 state	:	0=5.37MHz, 1=3.58MHz (write_n only)
			swioKmap		: inout	std_logic;								-- Keyboard layout selector
			CmtScro			: inout	std_logic;								-- CMT state
			swioCmt			: inout	std_logic;								-- CMT enabler
			LightsMode		: inout	std_logic;								-- Custom green led states
			Red_sta			: inout	std_logic;								-- Custom red led state
			LastRst_sta		: inout	std_logic;								-- Last reset state			:	0=Cold Reset, 1=Warm Reset
			RstReq_sta		: inout	std_logic;								-- Reset request state		:	0=No, 1=Yes
			Blink_ena		: inout	std_logic;								-- MegaSD blink led enabler
			DefKmap			: inout	std_logic;								-- Default keyboard layout	:	0=JP, 1=Non-JP (as UK,FR,..) 
			-- 'DIP-SW' group
			ff_dip_req		: in	std_logic_vector(  7 downto 0 );		-- DIP-SW states/reqs
			ff_dip_ack		: inout	std_logic_vector(  7 downto 0 );		-- DIP-SW acks
			-- 'KEYS' group
			SdPaus			: in	std_logic;
			Scro			: in	std_logic;
			ff_Scro			: in	std_logic;
			Reso			: in	std_logic;
			ff_Reso			: in	std_logic;
			FKeys			: in	std_logic_vector(  7 downto 0 );
			vFKeys			: in	std_logic_vector(  7 downto 0 );
			LevCtrl			: inout	std_logic_vector(  2 downto 0 );		-- Volume and high-speed level
			GreenLvEna		: out	std_logic;
			-- 'RESET' group
			swioRESET_n		: inout	std_logic;								-- Reset Pulse
			warmRESET		: inout	std_logic								-- 0=Cold Reset, 1=Warm Reset
	);
end	switched_io_ports;

architecture RTL of switched_io_ports is

	signal	swio_ack		: std_logic;									-- Main ack signal

begin
	-- out assignment: 'ports $40-$4F'
				-- $40 => read_n/write ($41 ID008 BIT-0 is not here, it's a write_n only signal)
	dbi	<=	io40								when( (adr(3 downto 0) = "0000") )else
				-- $43 ID008 for compatibility => read only
			"00000000"							when( (adr(3 downto 0) = "0011") and (io40 = "11110111") )else
				-- $41 ID212 smart commands => read_n/write
			io41_id212_n						when( (adr(3 downto 0) = "0001") and (io40 = "00101011") )else
				-- $42 ID212 virtual dip-sw states => read/write_n
			io42_id212_n						when( (adr(3 downto 0) = "0010") and (io40 = "00101011") )else
				-- $43 ID212 lock mask => read/write_n
				-- [MSB] megasd/mapper/resetkey/slot2/slot1/cmt/display/turbo [LSB]
			io43_id212_n						when( (adr(3 downto 0) = "0011") and (io40 = "00101011") )else
				-- $44 ID212 green leds mask of lights mode => read/write_n
			io44_id212_n						when( (adr(3 downto 0) = "0100") and (io40 = "00101011") )else
				-- $45 ID212 [MSB] master status & volume / psg status & volume [LSB] => read/write_n
			(MstrVol(2) and MstrVol(1) and MstrVol(0)) & not MstrVol & (not (PsgVol(2) or PsgVol(1) or PsgVol(0))) & PsgVol	when( (adr(3 downto 0) = "0101") and (io40 = "00101011") )else
				-- $46 ID212 [MSB] any scc status & volume / opll status & volume [LSB] => read/write_n
			(not (SccVol(2) or SccVol(1) or SccVol(0))) & SccVol & (not (OpllVol(2) or OpllVol(1) or OpllVol(0))) & OpllVol	when( (adr(3 downto 0) = "0110") and (io40 = "00101011") )else
				-- $47 ID212 [MSB] megasd_req/mapper_req/vga60ena/pana_redir/turbo_megasd/custom_speed_lev(1-7) [LSB] => read only
			MegaSD_req & Mapper_req & Vga60Ena & tPanaRedir & tMegaSD & ("001" - CustomSpeed(2 downto 0))
												when( (adr(3 downto 0) = "0111") and (io40 = "00101011") )else
				-- $48 ID212 states as below => read only
			Blink_ena & RstReq_sta & LastRst_sta & Red_sta & LightsMode & CmtScro & swioKmap & not io41_id008_n
												when( (adr(3 downto 0) = "1000") and (io40 = "00101011") )else
				-- $49 ID212 => all
				-- ... ID212 => free
				-- $4D ID212 => regs
				-- $4E ID212 states as below => read only
			ff_dip_req							when( (adr(3 downto 0) = "1110") and (io40 = "00101011") )else
				-- $4F ID212 [MSB] def_keyb_layout/swio_rel_n(1-127) [LSB] => read only
			DefKmap & "0000001"					when( (adr(3 downto 0) = "1111") and (io40 = "00101011") )else
				-- Not found
			"11111111";

	ack	<=	swio_ack;

	process( reset, clk21m )
	begin
		if( reset = '1' )then

			swioRESET_n	<=	'1';						-- End of Reset pulse
			io40		<=	"11111111";					-- Default when system boot (Machine On)
			---------------------------------------------------------------------------------------
			DefKmap		<=	'1';						-- Default Keyboard Layout (0=JP, 1=NON-JP)
			---------------------------------------------------------------------------------------
			if( warmRESET /= '1' )then
				-- Cold Reset
--				io41_id212_n	<=	"00000000";			-- Smart Commands	will be zero at 1st boot
				io42_id212_n	<=	ff_dip_req;			-- Virtual DIP-SW	are	DIP-SW
				ff_dip_ack		<=	ff_dip_req;			-- Sync to its req
				io43_id212_n	<=	"00X00000";			-- Lock Mask		is	Full Unlocked
				io44_id212_n	<=	"00000000";			-- Lights Mask		is	Full Off
				OpllVol			<=	"111";				-- Default OPLL Volume (old preset "110")
				SccVol			<=	"111";				-- Default SCC Volume (old preset "110")
				PsgVol			<=	"111";				-- Default PSG Volume (old preset "011")
				MstrVol			<=	"000";				-- Default Master Volume
				CustomSpeed		<=	"0010";				-- Custom Turbo		(old 10.74MHz)
				tMegaSD			<=	'1';				-- Turbo MegaSD
				tPanaRedir		<=	'0';				-- Pana Redirection
				Vga60Ena		<=	'1';				-- VGA modes		are	forced to 60Hz
				Mapper_req		<=	ff_dip_req(6);		-- Set Mapper state to	DIP-SW7 state
				Mapper_ack		<=	ff_dip_req(6);		-- Prevent system crash using DIP-SW7
				MegaSD_req		<=	ff_dip_req(7);		-- Set MegaSD state to	DIP-SW8 state
				MegaSD_ack		<=	ff_dip_req(7);		-- Prevent system crash using DIP-SW8
				io41_id008_n	<=	'1';				-- CPU Clock		is	3.58MHz
				swioKmap		<=  DefKmap;			-- Keyboard Layout	to	Default
				swioCmt			<=	'0';				-- CMT				is	Off
				LightsMode		<=	'0';				-- Lights Mode		is	Auto
				Red_sta			<=	not io41_id008_n;	-- Red Led			is	Turbo 5.37MHz
				LastRst_sta		<=	'0';				-- Cold state
				Blink_ena		<=	'1';				-- MegaSD Blink		is	On
			else
				-- Warm Reset
				io42_id212_n(6)	<=	Mapper_req;			-- Set Mapper state to	last required
				Mapper_ack		<=	Mapper_req;			-- Confirm the last Mapper state
				io42_id212_n(7)	<=	MegaSD_req;			-- Set MegaSD state to	last required
				MegaSD_ack		<=	MegaSD_req;			-- Confirm the last MegaSD state
				LastRst_sta		<=	'1';				-- Warm state
			end if;

		elsif( clk21m'event and clk21m = '1' )then
			if( warmRESET /= '0' )then
				warmRESET	<=	'0';					-- End of Warm Reset cycle
			else
				-- in assignment: 'Green Level Enabler'
				GreenLvEna	<=	'0';
				-- in assignment: 'Reset Request State' (internal signal)
				if( (Mapper_req /= io42_id212_n(6)) or (MegaSD_req /= io42_id212_n(7)) )then
					RstReq_sta	<=	'1';									-- Yes
				else
					RstReq_sta	<=	'0';									-- No
				end if;
				-- in assignment: 'Red State'
				if( LightsMode = '0')then
					Red_sta		<=	not io41_id008_n;
				end if;
				-- in assignment: 'DIP-SW' (under 1chipMSX)
				if( ff_dip_req(0) /= ff_dip_ack(0) )then					-- DIP-SW1		is	TURBO state
					if( io43_id212_n(0) = '0' )then							-- BIT[0]=0		of	Lock Mask
						io41_id008_n	<=	'1';							-- 5.37MHz		is	Off
						io42_id212_n(0)	<=	ff_dip_req(0);					-- 3.58MHz 		or	Custom Turbo
						ff_dip_ack(0)	<=	ff_dip_req(0);
					end if;
				end if;
				if( ff_dip_req(1) /= ff_dip_ack(1) )then					-- DIP-SW2		is	DISPLAY(A) state
					if( io43_id212_n(1) = '0' )then							-- BIT[1]=0		of	Lock Mask
						io42_id212_n(1)	<=	ff_dip_req(1);
						ff_dip_ack(1)	<=	ff_dip_req(1);
					end if;	
				end if;
				if( ff_dip_req(2) /= ff_dip_ack(2) )then					-- DIP-SW3		is	DISPLAY(B) state
					if( io43_id212_n(1) = '0' )then							-- BIT[1]=0		of	Lock Mask
						io42_id212_n(2)	<=	ff_dip_req(2);
						ff_dip_ack(2)	<=	ff_dip_req(2);
					end if;	
				end if;
				if( ff_dip_req(3) /= ff_dip_ack(3) )then					-- DIP-SW4		is	SLOT1 state
					if( io43_id212_n(3) = '0' )then							-- BIT[3]=0		of	Lock Mask
						io42_id212_n(3)	<=	ff_dip_req(3);
						ff_dip_ack(3)	<=	ff_dip_req(3);
					end if;	
				end if;
				if( ff_dip_req(4) /= ff_dip_ack(4) )then					-- DIP-SW5		is	SLOT2(A) state
					if( io43_id212_n(4) = '0' )then							-- BIT[4]=0		of	Lock Mask
						io42_id212_n(4)	<=	ff_dip_req(4);
						ff_dip_ack(4)	<=	ff_dip_req(4);
					end if;
				end if;
				if( ff_dip_req(5) /= ff_dip_ack(5) )then					-- DIP-SW6		is	SLOT2(B) state
					if( io43_id212_n(4) = '0' )then							-- BIT[4]=0		of	Lock Mask
						io42_id212_n(5)	<=	ff_dip_req(5);
						ff_dip_ack(5)	<=	ff_dip_req(5);
					end if;
				end if;
				if( ff_dip_req(6) /= ff_dip_ack(6) )then					-- DIP-SW7		is	MAPPER state
					if( io43_id212_n(6) = '0' )then							-- BIT[6]=0		of	Lock Mask
						Mapper_req		<=	ff_dip_req(6);
						ff_dip_ack(6)	<=	ff_dip_req(6);
					end if;
				end if;
				if( ff_dip_req(7) /= ff_dip_ack(7) )then					-- DIP-SW8		is	MEGASD state
					if( io43_id212_n(7) = '0' )then							-- BIT[7]=0		of	Lock Mask
						MegaSD_req		<=	ff_dip_req(7);
						ff_dip_ack(7)	<=	ff_dip_req(7);
					end if;
				end if;
				-- in assignment: 'Toggle Keys' (from keyboard)
				if( SdPaus = '0' )then
					if( Fkeys(7) = '0' )then
						if( io43_id212_n(0) = '0' )then						-- BIT[0]=0		of	Lock Mask
							if( Fkeys(0) /= vFKeys(0) )then					-- F12			is	TURBO selector
								if( io41_id008_n = '1' and io42_id212_n(0) = '0' )then
									io41_id008_n	<=	'0';				-- 3.58MHz		>>	5.37MHz
								elsif( io41_id008_n = '0' and io42_id212_n(0) = '0' )then
									io41_id008_n	<=	'1';
									io42_id212_n(0)	<=	'1';				-- 5.37MHz		>>	Custom Turbo
								else
									io42_id212_n(0)	<=	'0';				-- Custom Turbo	>>	3.58MHz
								end if;
							end if;
						end if;
						if( io43_id212_n(1) = '0' )then						-- BIT[1]=0		of	Lock Mask
							if( ff_Reso /= Reso )then						-- PRNSCR		is	DISPLAY selector (next)
								case io42_id212_n(2 downto 1) is
								when "00"	=>	io42_id212_n(2)				<=	'1';	--	Y/C		to	RGB
								when "10"	=>	io42_id212_n(2 downto 1)	<=	"01";	--	RGB		to	VGA
								when "01"	=>	io42_id212_n(2)				<=	'1';	--	VGA		to	VGA+
								when "11"	=>	io42_id212_n(2 downto 1)	<=	"00";	--	VGA+	to	Y/C
								end case;
							end if;
						end if;
						if( io43_id212_n(2) = '0' )then						-- BIT[2]=0		of	Lock Mask
							if( Fkeys(5 downto 1) /= vFKeys(5 downto 1) )then
								GreenLvEna	<=	'1';
								LevCtrl		<=	"111";
							end if;
							if( Fkeys(1) /= vFKeys(1) )then					-- F11			is	OPLL Volume Up
								if( OpllVol /= "111" )then
									LevCtrl	<= OpllVol + 1;
									OpllVol <= OpllVol + 1;
								end if;
							end if;
							if( Fkeys(2) /= vFKeys(2) )then					-- F10			is	SCC Volume Up
								if( SccVol /= "111" )then
									LevCtrl	<= SccVol + 1;
									SccVol	<= SccVol + 1;
								end if;
							end if;
							if( Fkeys(3) /= vFKeys(3) )then					-- F9			is	PSG Volume Up
								if( PsgVol /= "111" )then
									LevCtrl	<= PsgVol + 1;
									PsgVol	<= PsgVol + 1;
								end if;
							end if;
							if( Fkeys(4) /= vFkeys(4) )then					-- PGDOWN		is	Master Volume Down
								if( MstrVol /= "111" )then
									LevCtrl	<= not (MstrVol + 1);
									MstrVol <= MstrVol + 1;
								else
									LevCtrl	<= "000";									
								end if;
							end if;
							if( Fkeys(5) /= vFkeys(5) )then					-- PGUP			is	Master Volume Up
								if( MstrVol /= "000" )then
									LevCtrl	<= not (MstrVol - 1);
									MstrVol <= MstrVol - 1;
								end if;
							end if;
							if( ff_Scro /= Scro )then						-- SCRLK		is	CMT selector
								swioCmt		<=	not	swioCmt;
							end if;
						end if;
					else													--	BIT[0]=0	of	Lock Mask
						if( io43_id212_n(0) = '0' and io42_id212_n(0) = '1' )then
							if( Fkeys(5 downto 4) /= vFKeys(5 downto 4) )then
								GreenLvEna	<=	'1';
							end if;
							if( Fkeys(5) /= vFkeys(5) )then					-- SHIFT+PGUP	is	Custom Turbo selector (clock up)
								if( CustomSpeed /= "0010" )then
									LevCtrl 	<= "010" - CustomSpeed(2 downto 0);
									CustomSpeed <= CustomSpeed - 1;
								else
									LevCtrl <= "111";
								end if;
							end if;
							if( Fkeys(4) /= vFkeys(4) )then					-- SHIFT+PGDOWN	is	Custom Turbo selector (clock down)
								if( CustomSpeed /= "1000" )then
									LevCtrl 	<= "000" - CustomSpeed(2 downto 0);
									CustomSpeed <= CustomSpeed + 1;
								else
									LevCtrl <= "001";
								end if;
							end if;
						end if;
						if( io43_id212_n(1) = '0' )then						-- BIT[1]=0		of	Lock Mask
							if( ff_Reso /= Reso )then						-- SHIFT+PRNSCR	is	DISPLAY selector (previous)
								case io42_id212_n(2 downto 1) is
								when "11"	=>	io42_id212_n(2)				<=	'0';	--	VGA+	to	VGA
								when "01"	=>	io42_id212_n(2 downto 1)	<=	"10";	--	VGA		to	RGB
								when "10"	=>	io42_id212_n(2)				<=	'0';	--	RGB		to	Y/C
								when "00"	=>	io42_id212_n(2 downto 1)	<=	"11";	--	Y/C		to	VGA+
								end case;
							end if;
						end if;
						if( io43_id212_n(2) = '0' )then						-- BIT[2]=0		of	Lock Mask
							if( Fkeys(3 downto 1) /= vFKeys(3 downto 1) )then
								GreenLvEna	<=	'1';
								LevCtrl		<=	"000";
							end if;							
							if( Fkeys(1) /= vFKeys(1) )then					-- SHIFT+F11	is	OPLL Volume Down
								if( OpllVol /= "000" )then
									LevCtrl	<= OpllVol - 1;
									OpllVol <= OpllVol - 1;
								end if;
							end if;
							if( Fkeys(2) /= vFKeys(2) )then					-- SHIFT+F10	is	SCC Volume Down
								if( SccVol /= "000" )then
									LevCtrl	<= SccVol - 1;
									SccVol	<= SccVol - 1;
								end if;
							end if;
							if( Fkeys(3) /= vFKeys(3) )then					-- SHIFT+F9		is	PSG Volume Down
								if( PsgVol /= "000" )then
									LevCtrl	<= PsgVol - 1;
									PsgVol	<= PsgVol - 1;
								end if;
							end if;
						end if;
						if( io43_id212_n(3) = '0' )then						-- BIT[3]=0		of	Lock Mask
							if( Fkeys(0) /= vFKeys(0) )then					-- SHIFT+F12	is	SLOT1 selector
								io42_id212_n(3)	<=	not	io42_id212_n(3);
							end if;											-- EXTERNAL SLOT1	>> <<	INTERNAL SCC-I(A)
						end if;
						if( io43_id212_n(4) = '0' )then						-- BIT[4]=0		of	Lock Mask
							if( ff_Scro /= Scro )then						-- SHIFT+SCRLK	is	SLOT2 selector
								case io42_id212_n(5 downto 4) is
								when "00"	=>	io42_id212_n(5)				<=	'1';	--	EXTERNAL SLOT2		to	INTERNAL ASCII 8K
								when "10"	=>	io42_id212_n(5 downto 4)	<=	"01";	--	INTERNAL ASCII 8K	to	INTERNAL SCC-I(B)
								when "01"	=>	io42_id212_n(5)				<=	'1';	--	INTERNAL SCC-I(B)	to	INTERNAL ASCII 16K
								when "11"	=>	io42_id212_n(5 downto 4)	<=	"00";	--	INTERNAL ASCII 16K	to	EXTERNAL SLOT2
								end case;
							end if;											-- [Hint!] You can get SCC-I(B) quickly with a SHIFT+'double'SCRLK
						end if;
					end if;
				end if;
				-- in assignment: 'Port $40 [ID Manufacturers/Devices]' (read_n/write)
				if( req = '1' and wrt = '1' and (adr(3 downto 0) = "0000") )then
					case dbo is
						when "00001000"	=>	io40	<=	"11110111";			--	ID 008 => $08
						when "11010100"	=>  io40	<=  "00101011";			--	ID 212 => $D4 => 1chipMSX
						when others 	=>	io40	<=	"11111111";			--	invalid IDs
					end case;
				end if;
				-- in assignment: 'Port $41 ID008 BIT[0] [Turbo 5.37MHz]' (write_n only)
				if( req = '1' and wrt = '1' and (adr(3 downto 0) = "0001")  and (io40 = "11110111") )then
					if( tPanaRedir = '0')then
						io41_id008_n	<=	dbo(0);							-- 3.58MHz	>>		<< 5.37MHz
						io42_id212_n(0)	<=	'0';							-- 5.37MHz	have priority over 3.58MHz
					else
						io41_id008_n	<=	'1';							-- Custom Turbo
						io42_id212_n(0)	<=	not dbo(0);
					end if;
				end if;
				-- in assignment: 'Port $41 ID212 [Smart Commands]' (write only)
				if( req = '1' and wrt = '1' and (adr(3 downto 0) = "0001")  and (io40 = "00101011") )then
					io41_id212_n	<=	not dbo;
					case dbo is
						-- SMART CODES	#000
--						when "00000000"	=>									-- Null Command (Reserved)
--							null;
						-- SMART CODES	#001, #002	
						when "00000001"	=>									-- True 5.37MHz		via ID008 (Default)
							tPanaRedir		<=	'0';
						when "00000010"	=>									-- Custom Speed		via ID008
							tPanaRedir		<=	'1';
						-- SMART CODES	#003, #004, #005, #006, #007, #008, #009, #010
						when "00000011"	=>									-- Standard			3.58MHz
							io41_id008_n	<=	'1';
							io42_id212_n(0)	<=	'0';
						when "00000100"	=>									-- Custom Speed 1	4.10MHz
							io41_id008_n	<=	'1';
							io42_id212_n(0)	<=	'1';
							CustomSpeed		<=	"1000";
						when "00000101"	=>									-- Custom Speed 2	4.48MHz
							io41_id008_n	<=	'1';
							io42_id212_n(0)	<=	'1';
							CustomSpeed		<=	"0111";
						when "00000110"	=>									-- Custom Speed 3	4.90MHz
							io41_id008_n	<=	'1';
							io42_id212_n(0)	<=	'1';
							CustomSpeed		<=	"0110";
						when "00000111"	=>									-- Custom Speed 4	5.39MHz
							io41_id008_n	<=	'1';
							io42_id212_n(0)	<=	'1';
							CustomSpeed		<=	"0101";
						when "00001000"	=>									-- Custom Speed 5	6.10MHz
							io41_id008_n	<=	'1';
							io42_id212_n(0)	<=	'1';
							CustomSpeed		<=	"0100";
						when "00001001"	=>									-- Custom Speed 6	6.96MHz
							io41_id008_n	<=	'1';
							io42_id212_n(0)	<=	'1';
							CustomSpeed		<=	"0011";
						when "00001010"	=>									-- Custom Speed 7	8.06MHz (Default)
							io41_id008_n	<=	'1';
							io42_id212_n(0)	<=	'1';
							CustomSpeed		<=	"0010";
						-- SMART CODES	#011, #012
						when "00001011"	=>									-- Turbo MegaSD		Off
							tMegaSD			<=	'0';
						when "00001100"	=>									-- Turbo MegaSD		On	(Default)
							tMegaSD			<=	'1';
						-- SMART CODES	#013, #014, #015, #016, #017, #018, #19, #20
						when "00001101"	=>									-- Ext. Slot1 		+ Ext. Slot2
							io42_id212_n(5 downto 3)	<=	"000";
						when "00001110"	=>									-- Int. SCC-I Slot1	+ Ext. Slot2
							io42_id212_n(5 downto 3)	<=	"001";
						when "00001111"	=>									-- Ext. Slot1		+ Int. SCC-I Slot2
							io42_id212_n(5 downto 3)	<=	"010";
						when "00010000"	=>									-- Int. SCC-I Slot1	+ Int. SCC-I Slot2
							io42_id212_n(5 downto 3)	<=	"011";
						when "00010001"	=>									-- Ext. Slot1		+ Int. ASCII8K Slot2
							io42_id212_n(5 downto 3)	<=	"100";
						when "00010010"	=>									-- Int. SCC-I Slot1	+ Int. ASCII8K Slot2
							io42_id212_n(5 downto 3)	<=	"101";
						when "00010011"	=>									-- Ext. Slot1		+ Int. ASCII16K Slot2
							io42_id212_n(5 downto 3)	<=	"110";								
						when "00010100"	=>									-- Int. SCC-I Slot1	+ Int. ASCII16K Slot2
							io42_id212_n(5 downto 3)	<=	"111";
						-- SMART CODES	#021, #022
						when "00010101"	=>									-- Japanese Keyboard Layout
							swioKmap		<=	'0';
						when "00010110"	=>									-- Non-Japanese Keyboard Layout
							swioKmap		<=	'1';
						-- SMART CODES	#023, #024, #025, #026
						when "00010111"	=>									-- Display Mode 15KHz Composite or S-Video
							io42_id212_n(2 downto 1)	<=	"00";
						when "00011000"	=>									-- Display Mode 15KHz RGB+Audio(Mono)
							io42_id212_n(2 downto 1)	<=	"10";
						when "00011001"	=>									-- Display Mode 31Khz VGA
							io42_id212_n(2 downto 1)	<=	"01";
						when "00011010"	=>									-- Display Mode 31Khz VGA High Luminance
							io42_id212_n(2 downto 1)	<=	"11";
						-- SMART CODES	#027, #028
						when "00011011"	=>									-- VGA modes		are in standard mode (50Hz & 60Hz)
							Vga60Ena		<=	'0';
						when "00011100"	=>									-- VGA modes		are forced to 60Hz (Default)
							Vga60Ena		<=	'1';
						-- SMART CODES	#029, #030
						when "00011101"	=>									-- MegaSD Off		(warm reset is required)
							MegaSD_req		<=	'0';
						when "00011110"	=>									-- MegaSD On		(warm reset is required)
							MegaSD_req		<=	'1';
						-- SMART CODES	#031, #032, #033, #034, #035
						when "00011111"	=>									-- MegaSD Blink Off	+ DIP-SW8 State On
							Blink_ena		<=	'0';
						when "00100000"	=>									-- MegaSD Blink On	+ DIP-SW8 State Off	(Default)
							Blink_ena		<=	'1';						-- This mode have priority when Lights Mode is On							
						when "00100001"	=>									-- Lights Mode		is	Auto (Default)
							LightsMode		<=	'0';						-- Red Led			is	Turbo 5.37MHz
						when "00100010"	=>									-- Lights Mode		is	On + Red Off
							LightsMode		<=	'1';
							Red_sta			<=	'0';
						when "00100011"	=>									-- Lights Mode		is	On + Red On
							LightsMode		<=	'1';
							Red_sta			<=	'1';
						-- SMART CODES	#036, #037, #038
						when "00100100"	=>									-- Mute Volume Preset
							OpllVol			<=	"000";
							SccVol			<=	"000";
							PsgVol			<=	"000";
							MstrVol			<=	"000";
						when "00100101"	=>									-- Original Volume Preset
							OpllVol			<=	"110";
							SccVol			<=	"110";
							PsgVol			<=	"011";
							MstrVol			<=	"000";
						when "00100110"	=>									-- Default Volume Preset
							OpllVol			<=	"111";
							SccVol			<=	"111";
							PsgVol			<=	"111";
							MstrVol			<=	"000";
						-- SMART CODES	#039, #040
						when "00100111"	=>
							swioCmt			<=	'0';						-- CMT Off			(Default)
						when "00101000"	=>
							swioCmt			<=	'1';						-- CMT On
						-- SMART CODES	#041, #042
						when "00101001"	=>									-- Turbo Locked
							io43_id212_n(0)	<=	'1';
						when "00101010"	=>									-- Turbo Unlocked
							io43_id212_n(0)	<=	'0';
						-- SMART CODES	#043, #044
						when "00101011"	=>									-- Display Locked
							io43_id212_n(1)	<=	'1';
						when "00101100"	=>									-- Display Unlocked
							io43_id212_n(1)	<=	'0';
						-- SMART CODES	#045, #046
						when "00101101"	=>									-- Audio Mixer & CMT Locked
							io43_id212_n(2)	<=	'1';
						when "00101110"	=>									-- Audio Mixer & CMT Unlocked
							io43_id212_n(2)	<=	'0';
						-- SMART CODES	#047, #048
						when "00101111"	=>									-- Slot1 Locked
							io43_id212_n(3)	<=	'1';
						when "00110000"	=>									-- Slot1 Unlocked
							io43_id212_n(3)	<=	'0';
						-- SMART CODES	#049, #050
						when "00110001"	=>									-- Slot2 Locked
							io43_id212_n(4)	<=	'1';
						when "00110010"	=>									-- Slot2 Unlocked
							io43_id212_n(4)	<=	'0';
						-- SMART CODES	#051, #052
						when "00110011"	=>									-- Slot1 + Slot2 Locked
							io43_id212_n(4 downto 3)	<=	"11";
						when "00110100"	=>									-- Slot1 + Slot2 Unlocked
							io43_id212_n(4 downto 3)	<=	"00";
						-- SMART CODES	#053, #054
						when "00110101"	=>									-- Reset Key Locked
							io43_id212_n(5)	<=	'1';
						when "00110110"	=>									-- Reset Key Unlocked
							io43_id212_n(5)	<=	'0';
						-- SMART CODES	#055, #056
						when "00110111"	=>									-- Mapper Locked
							io43_id212_n(6)	<=	'1';
						when "00111000"	=>									-- Mapper Unlocked
							io43_id212_n(6)	<=	'0';
						-- SMART CODES	#057, #058
						when "00111001"	=>									-- MegaSD Locked
							io43_id212_n(7)	<=	'1';
						when "00111010"	=>									-- MegaSD Unlocked
							io43_id212_n(7)	<=	'0';
						-- SMART CODES	#059, #060
						when "00111011"	=>									-- Full Locked
							io43_id212_n	<=	"11111111";
						when "00111100"	=>									-- Full Unlocked
							io43_id212_n	<=	"00000000";
						-- SMART CODES	#61, #..., #127						-- Free Group
						-- SMART CODE 	#128
                        when "10000000" =>									-- Null Command (useful for programming)
                            null;
                        -- SMART CODES	#129, #..., #210					-- Free Group
						-- SMART CODE 	#211
						when "11010011" =>									-- Keyboard Layout Restore
							swioKmap		<=  DefKmap;
						-- SMART CODE 	#212
						when "11010100" =>
							null;											-- Null Command
						-- SMART CODES	#213
						when "11010101"	=>									-- Turbo Restore
							io42_id212_n(0)	<=	ff_dip_req(0);
							ff_dip_ack(0)	<=	ff_dip_req(0);
							CustomSpeed		<=	"0010";
							tMegaSD			<=	'1';
							tPanaRedir		<=	'0';
							io41_id008_n	<=	'1';
							Red_sta			<=	not io41_id008_n;
						-- SMART CODES	#214, #..., #249					-- Free Group
						-- SMART CODES	#250
						when "11111010"	=>									-- Set the Last Reset state to Cold Reset
							LastRst_sta		<=	'0';
						-- SMART CODES	#251, #252, #253, #254
						when "11111011"	=>									-- Cold Reset (Volume will be reset)
							swioRESET_n 	<=	'0';
						when "11111100"	=>									-- Mapper 2048KB	+ Warm Reset (Volume will not reset)
							Mapper_req		<=	'0';
							warmRESET 		<=	'1';
							swioRESET_n 	<=	'0';
						when "11111101"	=>									-- Warm Reset (Volume will not reset)
							warmRESET 		<=	'1';
							swioRESET_n 	<=	'0';
						when "11111110"	=>									-- Mapper 4096KB	+ Warm Reset (Volume will not reset)
							Mapper_req		<=	'1';
							warmRESET 		<=	'1';
							swioRESET_n 	<=	'0';
						-- SMART CODE	#255
						when "11111111"	=>									-- System Restore
							io42_id212_n(5 downto 0)	<=	ff_dip_req(5 downto 0);
							ff_dip_ack(5 downto 0)		<=	ff_dip_req(5 downto 0);
							io43_id212_n	<=	"00000000";
							io44_id212_n	<=	"00000000";
							OpllVol			<=	"111";
							SccVol			<=	"111";
							PsgVol			<=	"111";
							MstrVol			<=	"000";
							CustomSpeed		<=	"0010";
							tMegaSD			<=	'1';
							tPanaRedir		<=	'0';
							Vga60Ena		<=	'1';
							Mapper_req		<=	ff_dip_req(6);
							MegaSD_req		<=	ff_dip_req(7);
							io41_id008_n	<=	'1';
							swioKmap		<=  DefKmap;
							swioCmt			<=	'0';
							LightsMode		<=	'0';
							Red_sta			<=	not io41_id008_n;
							Blink_ena		<=	'1';
						-- ALL UNUSED CODES
						when others		=>
							io41_id212_n	<=	"11111111";					-- Not found
					end case;
				end if;
				-- in assignment: 'Port $42 ID212 [Virtual DIP-SW]' (read/write_n, always unlocked)
				if( req = '1' and wrt = '1' and (adr(3 downto 0) = "0010")  and (io40 = "00101011") )then
					io41_id008_n				<=	'1';					-- Custom Turbo have priority over 5.37MHz
					io42_id212_n(5 downto 0)	<=	not dbo(5 downto 0);	-- BIT[0-5]
					Mapper_req					<=	not dbo(6);				-- BIT[6]
					MegaSD_req					<=	not dbo(7);				-- BIT[7]
				end if;
				-- in assignment: 'Port $43 ID212 [Lock Mask]' (read/write_n)
				if( req = '1' and wrt = '1' and (adr(3 downto 0) = "0011")  and (io40 = "00101011") )then
					io43_id212_n		<=	not dbo;
				end if;
				-- in assignment: 'Port $44 ID212 [Green Leds Mask]' (read/write_n)
				if( req = '1' and wrt = '1' and (adr(3 downto 0) = "0100")  and (io40 = "00101011") )then
					io44_id212_n		<=	not dbo;
				end if;
				-- in assignment: 'Port $45 ID212 [Master/Psg Volume]' (read/write_n)
				if( req = '1' and wrt = '1' and (adr(3 downto 0) = "0101")  and (io40 = "00101011") )then
					PsgVol				<=	not dbo(2 downto 0);
					MstrVol				<=	dbo(6 downto 4);
				end if;
				-- in assignment: 'Port $46 ID212 [Scc/Opll Volume]' (read/write_n)
				if( req = '1' and wrt = '1' and (adr(3 downto 0) = "0110")  and (io40 = "00101011") )then
					OpllVol				<=	not dbo(2 downto 0);
					SccVol				<=	not dbo(6 downto 4);
				end if;
			end if;
		end if;
	end process;

	-- detection of main ack signal
	process( reset, clk21m )
	begin
		if( reset = '1' )then
			swio_ack	<= '0';
		elsif( clk21m'event and clk21m = '1' and warmRESET /= '1' )then
			swio_ack	<= req;												-- Protected until the end of Warm Reset
		end if;
	end process;

end RTL;
