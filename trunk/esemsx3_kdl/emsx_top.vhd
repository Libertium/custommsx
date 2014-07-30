-- 
-- emsx_top.vhd
--	 ESE MSX-SYSTEM3 / MSX clone on a Cyclone FPGA (ALTERA)
--	 Revision 1.00
-- 
-- Copyright (c) 2006 Kazuhiro Tsujikawa (ESE Artists' factory)
-- All rights reserved.
-- 
-- Redistribution and use of this source code or any derivative works, are 
-- permitted provided that the following conditions are met:
--
-- 1. Redistributions of source code must retain the above copyright notice, 
--		this list of conditions and the following disclaimer.
-- 2. Redistributions in binary form must reproduce the above copyright 
--		notice, this list of conditions and the following disclaimer in the 
--		documentation and/or other materials provided with the distribution.
-- 3. Redistributions may not be sold, nor may they be used in a commercial 
--		product or activity without specific prior written permission.
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
--------------------------------------------------------------------------------
-- OCM-PLD Pack v2.4 by KdL (2011.04.13)
-- Special thx to t.hara, caro & all MRC users (http://www.msx.org/)
--------------------------------------------------------------------------------
--

library	ieee;
	use	ieee.std_logic_1164.all;
	use	ieee.std_logic_unsigned.all;
	use	work.vdp_package.all;

entity emsx_top is
	port(
		-- Clock, Reset ports
		pClk21m			: in	std_logic;							-- VDP Clock ... 21.48MHz
		pExtClk			: in	std_logic;							-- Reserved (for multi FPGAs)
		pCpuClk			: out	std_logic;							-- CPU Clock ... 3.58MHz (up to 10.74MHz/21.48MHz)

		-- MSX cartridge slot ports
		pSltClk			: in	std_logic;							-- pCpuClk returns here, for Z80, etc.
		pSltRst_n		: in	std_logic;							-- pCpuRst_n returns here
		pSltSltsl_n		: inout	std_logic;
		pSltSlts2_n		: inout	std_logic;
		pSltIorq_n		: inout	std_logic;
		pSltRd_n		: inout	std_logic;
		pSltWr_n		: inout	std_logic;
		pSltAdr			: inout	std_logic_vector( 15 downto 0 );
		pSltDat			: inout	std_logic_vector(  7 downto 0 );
		pSltBdir_n		: out	std_logic;							-- Bus direction (not used in	master mode)

		pSltCs1_n		: inout	std_logic;
		pSltCs2_n		: inout	std_logic;
		pSltCs12_n		: inout	std_logic;
		pSltRfsh_n		: inout	std_logic;
		pSltWait_n		: inout	std_logic;
		pSltInt_n		: inout	std_logic;
		pSltM1_n		: inout	std_logic;
		pSltMerq_n		: inout	std_logic;

		pSltRsv5		: out	std_logic;							-- Reserved
		pSltRsv16		: out	std_logic;							-- Reserved (w/ external pull-up)
		pSltSw1			: inout	std_logic;							-- Reserved (w/ external pull-up)
		pSltSw2			: inout	std_logic;							-- Reserved

		-- SD-RAM ports
		pMemClk			: out	std_logic;							-- SD-RAM Clock
		pMemCke			: out	std_logic;							-- SD-RAM Clock enable
		pMemCs_n		: out	std_logic;							-- SD-RAM Chip select
		pMemRas_n		: out	std_logic;							-- SD-RAM Row/RAS
		pMemCas_n		: out	std_logic;							-- SD-RAM /CAS
		pMemWe_n		: out	std_logic;							-- SD-RAM /WE
		pMemUdq			: out	std_logic;							-- SD-RAM UDQM
		pMemLdq			: out	std_logic;							-- SD-RAM LDQM
		pMemBa1			: out	std_logic;							-- SD-RAM Bank select address 1
		pMemBa0			: out	std_logic;							-- SD-RAM Bank select address 0
		pMemAdr			: out	std_logic_vector( 12 downto 0 );	-- SD-RAM Address
		pMemDat			: inout	std_logic_vector( 15 downto 0 );	-- SD-RAM Data

		-- PS/2 keyboard ports
		pPs2Clk			: inout	std_logic;
		pPs2Dat			: inout	std_logic;

		-- Joystick ports (Port_A, Port_B)
		pJoyA			: inout	std_logic_vector( 5 downto 0);
		pStrA			: out	std_logic;
		pJoyB			: inout	std_logic_vector( 5 downto 0);
		pStrB			: out	std_logic;

		-- SD/MMC slot ports
		pSd_Ck			: out	std_logic;							-- pin	5
		pSd_Cm			: out	std_logic;							-- pin	2
		pSd_Dt			: inout	std_logic_vector( 3 downto 0);		-- pin	1(D3), 9(D2), 8(D1), 7(D0)

		-- DIP switch, Lamp ports
		pDip			: in	std_logic_vector( 7 downto 0);		-- 0=ON,	1=OFF (default on shipment)
		pLed			: out	std_logic_vector( 7 downto 0);		-- 0=OFF,	1=ON  (green)
		pLedPwr			: out	std_logic;							-- 0=OFF,	1=ON  (red)

		-- Video, Audio/CMT ports
		pDac_VR			: inout	std_logic_vector( 5 downto 0);		-- RGB_Red / Svideo_C
		pDac_VG			: inout	std_logic_vector( 5 downto 0);		-- RGB_Grn / Svideo_Y
		pDac_VB			: inout	std_logic_vector( 5 downto 0);		-- RGB_Blu / CompositeVideo
		pDac_SL			: out	std_logic_vector( 5 downto 0);		-- Sound-L
		pDac_SR			: inout	std_logic_vector( 5 downto 0);		-- Sound-R / CMT

		pVideoHS_n		: out	std_logic;							-- Csync(RGB15K), HSync(VGA31K)
		pVideoVS_n		: out	std_logic;							-- Audio(RGB15K), VSync(VGA31K)

		pVideoClk		: out	std_logic;							-- (Reserved)
		pVideoDat		: out	std_logic;							-- (Reserved)

		-- Reserved ports (USB)
		pUsbP1			: inout	std_logic;
		pUsbN1			: inout	std_logic;
		pUsbP2			: inout	std_logic;
		pUsbN2			: inout	std_logic;

		-- Reserved ports
		pIopRsv14		: in	std_logic;
		pIopRsv15		: in	std_logic;
		pIopRsv16		: in	std_logic;
		pIopRsv17		: in	std_logic;
		pIopRsv18		: in	std_logic;
		pIopRsv19		: in	std_logic;
		pIopRsv20		: in	std_logic;
		pIopRsv21		: in	std_logic
	);
end emsx_top;

architecture RTL of emsx_top is

	-- Clock generator ( Altera specific component )
	component pll4x
		port(
			inclk0	: in	std_logic := '0';	-- 21.48MHz input to PLL	(external I/O pin, from crystal oscillator)
			c0		: out	std_logic;			-- 21.48MHz output from PLL (internal LEs, for VDP, internal-bus, etc.)
			c1		: out	std_logic;			-- 85.92MHz output from PLL (internal LEs, for SD-RAM)
			e0		: out	std_logic			-- 85.92MHz output from PLL (external I/O pin, for SD-RAM)
		);
	end component;

	-- CPU
	component t80a
		port(
			RESET_n		: in	std_logic;
			RstKeyLock	: inout	std_logic;
			swioRESET_n	: inout	std_logic;
			CLK_n		: in	std_logic;
			WAIT_n		: in	std_logic;
			INT_n		: in	std_logic;
			NMI_n		: in	std_logic;
			BUSRQ_n 	: in	std_logic;
			M1_n		: out	std_logic;
			MREQ_n		: out	std_logic;
			IORQ_n		: out	std_logic;
			RD_n		: out	std_logic;
			WR_n		: out	std_logic;
			RFSH_n		: out	std_logic;
			HALT_n		: out	std_logic;
			BUSAK_n 	: out	std_logic;
			A			: out	std_logic_vector( 15 downto 0 );
			D			: inout	std_logic_vector(  7 downto 0 )
		);
	end component;

	-- boot loader ROM (initial program loader)
	component iplrom
		port(
			clk		: in	std_logic;
			adr		: in	std_logic_vector(15 downto 0);
			dbi		: out	std_logic_vector(7 downto 0)
		);
	end component;

	-- MEGA-SD (SD controller)
	component megasd
		port(
			clk21m	: in	std_logic;
			reset	: in	std_logic;
			clkena	: in	std_logic;
			req		: in	std_logic;
			ack		: out	std_logic;
			wrt		: in	std_logic;
			adr		: in	std_logic_vector(15 downto 0);
			dbi		: out	std_logic_vector(7 downto 0);
			dbo		: in	std_logic_vector(7 downto 0);

			ramreq	: out	std_logic;
			ramwrt	: out	std_logic;
			ramadr	: out	std_logic_vector(19 downto 0);
			ramdbi	: in	std_logic_vector(7 downto 0);
			ramdbo	: out	std_logic_vector(7 downto 0);

			mmcdbi	: out	std_logic_vector(7 downto 0);
			mmcena	: out	std_logic;
			mmcact	: out	std_logic;

			mmc_ck	: out	std_logic;
			mmc_cs	: out	std_logic;
			mmc_di	: out	std_logic;
			mmc_do	: in	std_logic;

			epc_ck	: out	std_logic;
			epc_cs	: out	std_logic;
			epc_oe	: out	std_logic;
			epc_di	: out	std_logic;
			epc_do	: in	std_logic
		);
	end component;

	-- ASMI (Altera specific component)
	component cyclone_asmiblock
		port (
			dclkin		: in	std_logic;		-- DCLK
			scein		: in	std_logic;		-- nCSO
			sdoin		: in	std_logic;		-- ASDO
			oe			: in	std_logic;		--(1=disable(Hi-Z))
			data0out	: out	std_logic		-- DATA0
		);
	end component;

	component mapper
		port(
			clk21m		: in	std_logic;
			reset		: in	std_logic;
			clkena		: in	std_logic;
			req			: in	std_logic;
			ack			: out	std_logic;
			mem			: in	std_logic;
			wrt			: in	std_logic;
			adr			: in	std_logic_vector( 15 downto 0 );
			dbi			: out	std_logic_vector(  7 downto 0 );
			dbo			: in	std_logic_vector(  7 downto 0 );

			ramreq		: out	std_logic;
			ramwrt		: out	std_logic;
			ramadr		: out	std_logic_vector( 21 downto 0 );
			ramdbi		: in	std_logic_vector(  7 downto 0 );
			ramdbo		: out	std_logic_vector(  7 downto 0 )
		);
	end component;

	component eseps2 is
	port (
		clk21m		: in	std_logic;
		reset		: in	std_logic;
		clkena		: in	std_logic;

		Kmap		: in	std_logic;
		
		Caps		: inout	std_logic;
		Kana		: inout	std_logic;
		Paus		: inout	std_logic;
		Scro		: inout	std_logic;
		Reso		: inout	std_logic;
		
		FKeys		: out	std_logic_vector(  7 downto 0 );

		pPs2Clk	 	: inout	std_logic;
		pPs2Dat	 	: inout	std_logic;
		PpiPortC	: inout	std_logic_vector(  7 downto 0 );
		pKeyX		: inout	std_logic_vector(  7 downto 0 );
		CmtScro		: inout	std_logic
	);
	end component;

	component rtc
		port(
			clk21m		: in	std_logic;
			reset		: in	std_logic;
			clkena		: in	std_logic;
			req			: in	std_logic;
			ack			: out	std_logic;
			wrt			: in	std_logic;
			adr			: in	std_logic_vector( 15 downto 0 );
			dbi			: out	std_logic_vector(  7 downto 0 );
			dbo			: in	std_logic_vector(  7 downto 0 )
		);
	end component;

	component kanji is
	port (
		clk21m			: in	std_logic;
		reset			: in	std_logic;
		clkena			: in	std_logic;
		req				: in	std_logic;
		ack				: out	std_logic;
		wrt				: in	std_logic;
		adr				: in	std_logic_vector( 15 downto 0 );
		dbi				: out	std_logic_vector(  7 downto 0 );
		dbo				: in	std_logic_vector(  7 downto 0 );

		ramreq			: out	std_logic;
		ramadr			: out	std_logic_vector( 17 downto 0 );
		ramdbi			: in	std_logic_vector(  7 downto 0 );
		ramdbo			: out	std_logic_vector(  7 downto 0 )
	);
	end component;

	component vdp
	port(
		-- VDP Clock ... 21.477MHz
		clk21m			: in	std_logic;
		reset			: in	std_logic;
		req				: in	std_logic;
		ack				: out	std_logic;
		wrt				: in	std_logic;
		adr				: in	std_logic_vector( 15 downto 0 );
		dbi				: out	std_logic_vector(  7 downto 0 );
		dbo				: in	std_logic_vector(  7 downto 0 );

		int_n			: out	std_logic;

		pRamOe_n		: out	std_logic;
		pRamWe_n		: out	std_logic;
		pRamAdr			: out	std_logic_vector( 16 downto 0 );
		pRamDbi			: in	std_logic_vector( 15 downto 0 );
		pRamDbo			: out	std_logic_vector(  7 downto 0 );

		-- Video Output
		pVideoR			: out	std_logic_vector(  5 downto 0 );
		pVideoG			: out	std_logic_vector(  5 downto 0 );
		pVideoB			: out	std_logic_vector(  5 downto 0 );

		pVideoHS_n		: out	std_logic;
		pVideoVS_n		: out	std_logic;
		pVideoCS_n		: out	std_logic;

		pVideoDHClk		: out	std_logic;
		pVideoDLClk		: out	std_logic;

		-- CXA1645(RGB->NTSC encoder) signals
		pVideoSC		: out	std_logic;
		pVideoSYNC		: out	std_logic;

		-- Display resolution (0=15kHz, 1=31kHz)
		DispReso		: in	 std_logic;

		-- Debug window signals
--		debugWindowToggle : in	std_logic;
--		osdLocateX		: in	std_logic_vector(  5 downto 0 );
--		osdLocateY		: in	std_logic_vector(  4 downto 0 );
--		osdCharCodeIn 	: in	std_logic_vector(  7 downto 0 );
--		osdCharWrReq	: in	std_logic;
--		osdCharWrAck	: out	std_logic;

		-- 60Hz forced
		ntsc_forced		: in	std_logic

	);
	end component;

	component vencode
		port(
			clk21m		: in	std_logic;
			reset		: in	std_logic;
			videoR		: in	std_logic_vector(  5 downto 0 );
			videoG		: in	std_logic_vector(  5 downto 0 );
			videoB		: in	std_logic_vector(  5 downto 0 );
			videoHS_n 	: in	std_logic;
			videoVS_n 	: in	std_logic;
			videoY		: out	std_logic_vector(  5 downto 0 );
			videoC		: out	std_logic_vector(  5 downto 0 );
			videoV		: out	std_logic_vector(  5 downto 0 )
		);
	end component;

	component psg
		port(
			clk21m		: in	std_logic;
			reset		: in	std_logic;
			clkena		: in	std_logic;
			req			: in	std_logic;
			ack			: out	std_logic;
			wrt			: in	std_logic;
			adr			: in	std_logic_vector( 15 downto 0 );
			dbi			: out	std_logic_vector(  7 downto 0 );
			dbo			: in	std_logic_vector(  7 downto 0 );

			joya		: inout	std_logic_vector(  5 downto 0 );
			stra		: out	std_logic;
			joyb		: inout	std_logic_vector(  5 downto 0 );
			strb		: out	std_logic;

			kana		: out	std_logic;
			cmtin		: in	std_logic;
			keymode 	: in	std_logic;

			wave		: out	std_logic_vector(  7 downto 0 )
		);
	end component;

	component megaram
		port(
			clk21m		: in	std_logic;
			reset		: in	std_logic;
			clkena		: in	std_logic;
			req			: in	std_logic;
			ack			: out	std_logic;
			wrt			: in	std_logic;
			adr			: in	std_logic_vector( 15 downto 0 );
			dbi			: out	std_logic_vector(  7 downto 0 );
			dbo			: in	std_logic_vector(  7 downto 0 );

			ramreq		: out	std_logic;
			ramwrt		: out	std_logic;
			ramadr		: out	std_logic_vector( 19 downto 0 );
			ramdbi		: in	std_logic_vector(  7 downto 0 );
			ramdbo		: out	std_logic_vector(  7 downto 0 );

			mapsel		: in	std_logic_vector(  1 downto 0 );	-- "0-":SCC+, "10":ASC8K, "11":ASC16K

			wavl		: out	std_logic_vector( 14 downto 0 );
			wavr		: out	std_logic_vector( 14 downto 0 )
		);
	end component;

	component eseopll
		port(
			clk21m		: in	std_logic;
			reset		: in	std_logic;
			clkena		: in	std_logic;
			enawait 	: in	std_logic;
			req			: in	std_logic;
			ack			: out	std_logic;
			wrt			: in	std_logic;
			adr			: in	std_logic_vector( 15 downto 0 );
			dbo			: in	std_logic_vector(  7 downto 0 );
			wav			: out	std_logic_vector(  9 downto 0 )
			);
	end component;

	component esepwm
		generic (
			MSBI : integer
		);
		port(
			clk		: in	std_logic;
			reset	: in	std_logic;
			DACin	: in	std_logic_vector( MSBI downto 0 );
			DACout	: out	std_logic
		);
	end component;

	component scc_mix_mul
		port(
			a			: in	std_logic_vector( 15 downto 0 );	-- 16bit ２の補数 
			b			: in	std_logic_vector(  2 downto 0 );	-- 3bit バイナリ 
			c			: out	std_logic_vector( 18 downto 0 )		-- 19bit ２の補数 
		);
	end component;

	--	system timer (MSXturboR)
	component system_timer
		port(
			clk21m	: in	std_logic;
			reset	: in	std_logic;
			req		: in	std_logic;
			ack		: out	std_logic;
			wrt		: in	std_logic;
			adr		: in	std_logic_vector( 15 downto 0 );
			dbi		: out	std_logic_vector(  7 downto 0 );
			dbo		: in	std_logic_vector(  7 downto 0 )
		);
	end	component;

	--	low pass filter 1
	component lpf1
		generic (
			msbi	: integer
		);
		port(
			clk21m	: in	std_logic;
			reset	: in	std_logic;
			clkena	: in	std_logic;
			idata	: in	std_logic_vector( msbi downto 0 );
			odata	: out	std_logic_vector( msbi downto 0 )
		);
	end component;

	--	low pass filter 2
	component lpf2
		generic (
			msbi	: integer
		);
		port(
			clk21m	: in	std_logic;
			reset	: in	std_logic;
			clkena	: in	std_logic;
			idata	: in	std_logic_vector( msbi downto 0 );
			odata	: out	std_logic_vector( msbi downto 0 )
		);
	end component;

	--	補間演算 
	component interpo
		generic (
			msbi	: integer
		);
		port(
			clk21m	: in	std_logic;
			reset	: in	std_logic;
			clkena	: in	std_logic;
			idata	: in	std_logic_vector( msbi downto 0 );
			odata	: out	std_logic_vector( msbi downto 0 )
		);
	end component;

	--	switched I/O ports
	component switched_io_ports
		port(
			-- 'MAIN' group
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
			io41_id008_n	: inout	std_logic;								-- $41 ID008 BIT-0 state	:	0=5.37MHz, 0=3.58MHz (write only)
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
	end	component;

	-- Switched I/O ports
	signal	swio_req		: std_logic;
	signal	swio_ack		: std_logic;
	signal	swio_dbi		: std_logic_vector(  7 downto 0 );
	signal	io40			: std_logic_vector(  7 downto 0 );				-- here to reduce LEs
	signal	io41_id212_n	: std_logic_vector(  7 downto 0 );				-- here to reduce LEs
	signal	io42_id212_n	: std_logic_vector(  7 downto 0 );
	signal	io43_id212_n	: std_logic_vector(  7 downto 0 );
	alias	RstKeyLock		: std_logic is io43_id212_n(5);
	signal	io44_id212_n	: std_logic_vector(  7 downto 0 );
	alias	GreenLeds		: std_logic_vector(  7 downto 0 ) is io44_id212_n;
	signal	CustomSpeed		: std_logic_vector(  3 downto 0 );
	signal	tMegaSD			: std_logic;
	signal	tPanaRedir		: std_logic;									-- here to reduce LEs
	signal	Vga60Ena		: std_logic;
	signal	Mapper_req		: std_logic;									-- here to reduce LEs
	signal	Mapper_ack		: std_logic;
	signal	MegaSD_req		: std_logic;									-- here to reduce LEs
	signal	MegaSD_ack		: std_logic;
	signal	io41_id008_n	: std_logic;
	signal  swioKmap		: std_logic;
	signal	CmtScro			: std_logic;
	signal	swioCmt			: std_logic;
    signal  LightsMode		: std_logic;
	signal	Red_sta			: std_logic;
	signal	LastRst_sta		: std_logic;									-- here to reduce LEs
	signal	RstReq_sta		: std_logic;									-- here to reduce LEs
	signal	Blink_ena		: std_logic;
	signal	DefKmap			: std_logic;									-- here to reduce LEs
	signal	ff_dip_req		: std_logic_vector(  7 downto 0 );
	signal	ff_dip_ack		: std_logic_vector(  7 downto 0 );				-- here to reduce LEs
	signal	LevCtrl			: std_logic_vector(  2 downto 0 );
	signal	GreenLvEna		: std_logic;
	signal	swioRESET_n		: std_logic;
	signal	warmRESET		: std_logic;

	-- System timer
	signal	systim_req		: std_logic;
	signal	systim_ack		: std_logic;
	signal	systim_dbi		: std_logic_vector(  7 downto 0 );

	-- Operation mode
	signal	w_key_mode		: std_logic;									-- Kana key board layout: 1=JIS layout
	signal	Kmap			: std_logic;									-- '0': Japanese-106 	'1': Non-Japanese (English-101, French, ..)
	signal	DisplayMode		: std_logic_vector(  1 downto 0 );
	signal	Slot1Mode		: std_logic;
	signal	Slot2Mode		: std_logic_vector(  1 downto 0 );
	alias	FullRAM			: std_logic is Mapper_ack;						-- '0': 2048kb RAM		'1': 4096kb RAM
	alias	MmcMode			: std_logic is MegaSD_ack;						-- '0': disable SD/MMC	'1': enable SD/MMC
	alias	ff_dip_sw		: std_logic_vector(  7 downto 0 ) is ff_dip_req;

	-- Clock, Reset control signals
	signal	clk21m			: std_logic;
	signal	memclk			: std_logic;
	signal	cpuclk			: std_logic;
	signal	clkena			: std_logic;
	signal	clkdiv			: std_logic_vector(  1 downto 0 );
	signal	ff_clksel		: std_logic;
	signal	ff_clksel5m_n	: std_logic;
	signal	hybridclk		: std_logic;
	signal	hstartcount		: std_logic_vector(  2 downto 0 );
	signal	htoutcount		: std_logic_vector(  2 downto 0 );
	signal	reset			: std_logic;
	signal	RstEna			: std_logic := '0';
	signal	RstSeq			: std_logic_vector(  4 downto 0 ) := (others => '0');
	signal	FreeCounter		: std_logic_vector( 15 downto 0 ) := (others => '0');

	-- MSX cartridge slot control signals
	signal BusDir			: std_logic;
	signal iSltSltsl_n		: std_logic;
	signal iSltRfsh_n		: std_logic;
	signal iSltMerq_n		: std_logic;
	signal iSltIorq_n		: std_logic;
	signal iSltRd_n			: std_logic;
	signal iSltWr_n			: std_logic;
	signal xSltRd_n			: std_logic;
	signal xSltWr_n			: std_logic;
	signal iSltAdr			: std_logic_vector(15 downto 0);
	signal iSltDat			: std_logic_vector(7 downto 0);
	signal dlydbi			: std_logic_vector(7 downto 0);
	signal BusReq_n			: std_logic;
	signal CpuM1_n			: std_logic;
	signal CpuRst_n			: std_logic;
	signal CpuRfsh_n		: std_logic;

	-- Internal bus signals (common)
	signal req, ireq		: std_logic;
	signal ack, iack		: std_logic;
	signal mem				: std_logic;
	signal wrt				: std_logic;
	signal adr				: std_logic_vector(15 downto 0);
	signal dbi				: std_logic_vector(7 downto 0);
	signal dbo				: std_logic_vector(7 downto 0);

	-- Primary, Expansion slot signals
	signal ExpDbi			: std_logic_vector(7 downto 0);
	signal ExpSlot0			: std_logic_vector(7 downto 0);
	signal ExpSlot3			: std_logic_vector(7 downto 0);
	signal PriSltNum		: std_logic_vector(1 downto 0);
	signal ExpSltNum0		: std_logic_vector(1 downto 0);
	signal ExpSltNum3		: std_logic_vector(1 downto 0);

	-- Slot decode signals
	signal iSltBot			: std_logic;
	signal iSltMap			: std_logic;
	signal jSltMem			: std_logic;
	signal iSltScc1			: std_logic;
	signal jSltScc1			: std_logic;
	signal iSltScc2			: std_logic;
	signal jSltScc2			: std_logic;
	signal iSltErm			: std_logic;

	-- BIOS-ROM decode signals
	signal RomReq			: std_logic;
	signal rom_main			: std_logic;
	signal rom_opll			: std_logic;
	signal rom_extr			: std_logic;
	signal rom_kanj			: std_logic;

	-- IPL-ROM signals
	signal RomDbi			: std_logic_vector(7 downto 0);

	-- ESE-RAM signals
	signal ErmReq			: std_logic;
	signal ErmAck			: std_logic;
	signal ErmDbi			: std_logic_vector(7 downto 0);
	signal ErmRam			: std_logic;
	signal ErmWrt			: std_logic;
	signal ErmDbo			: std_logic_vector(7 downto 0);
	signal ErmAdr			: std_logic_vector(19 downto 0);

	-- SD/MMC signals
	signal MmcEna			: std_logic;
	signal MmcAct			: std_logic;
	signal MmcDbi			: std_logic_vector(7 downto 0);
	signal MmcEnaLed		: std_logic;

	-- EPCS/ASMI signals
	signal EPC_CK			: std_logic;
	signal EPC_CS			: std_logic;
	signal EPC_OE			: std_logic;
	signal EPC_DI			: std_logic;
	signal EPC_DO			: std_logic;

	-- Mapper RAM signals
	signal MapReq			: std_logic;
	signal MapAck			: std_logic;
	signal MapDbi			: std_logic_vector(7 downto 0);
	signal MapRam			: std_logic;
	signal MapWrt			: std_logic;
	signal MapDbo			: std_logic_vector(7 downto 0);
	signal MapAdr			: std_logic_vector(21 downto 0);

	-- PPI(8255) signals
	signal PpiReq			: std_logic;
	signal PpiAck			: std_logic;
	signal PpiDbi			: std_logic_vector(7 downto 0);
	signal PpiPortA			: std_logic_vector(7 downto 0);
	signal PpiPortB			: std_logic_vector(7 downto 0);
	signal PpiPortC			: std_logic_vector(7 downto 0);

	-- PS/2 signals
	signal Paus				: std_logic;
	signal Scro				: std_logic;
	signal Reso				: std_logic;
	signal Reso_v			: std_logic;
	signal Kana				: std_logic;
	signal Caps				: std_logic;
	signal Fkeys			: std_logic_vector(7 downto 0);

	-- CMT signals
	signal CmtIn			: std_logic;
	alias  CmtOut			: std_logic is PpiPortC(5);

	-- 1 bit sound port signal
	alias  KeyClick			: std_logic is PpiPortC(7);

	-- RTC signals
	signal RtcReq			: std_logic;
	signal RtcAck			: std_logic;
	signal RtcDbi			: std_logic_vector(7 downto 0);

	-- Kanji ROM signals
	signal KanReq			: std_logic;
	signal KanAck			: std_logic;
	signal KanDbi			: std_logic_vector(7 downto 0);
	signal KanRom			: std_logic;
	signal KanDbo			: std_logic_vector(7 downto 0);
	signal KanAdr			: std_logic_vector(17 downto 0);

	-- VDP signals
	signal VdpReq			: std_logic;
	signal VdpAck			: std_logic;
	signal VdpDbi			: std_logic_vector(7 downto 0);
	signal VideoSC			: std_logic;
	signal VideoDLClk		: std_logic;
	signal VideoDHClk		: std_logic;
	signal OeVdp_n			: std_logic;
	signal WeVdp_n			: std_logic;
	signal VdpAdr			: std_logic_vector(16 downto 0);
	signal VrmDbo			: std_logic_vector(7 downto 0);
	signal VrmDbi			: std_logic_vector(15 downto 0);
	signal pVdpInt_n		: std_logic;
	-- (for on screen display)
--	signal osdFkey			: std_logic;
--	signal osdLocateX		: std_logic_vector(5 downto 0);
--	signal osdLocateY		: std_logic_vector(4 downto 0);
--	signal osdCharCodeIn	: std_logic_vector(7 downto 0);
--	signal osdCharWrReq		: std_logic;
--	signal osdCharWrAck		: std_logic;

	-- Video signals
	signal VideoR			: std_logic_vector( 5 downto 0);				-- RGB_Red
	signal VideoG			: std_logic_vector( 5 downto 0);				-- RGB_Green
	signal VideoB			: std_logic_vector( 5 downto 0);				-- RGB_Blue
	signal VideoHS_n		: std_logic;									-- Holizontal Sync
	signal VideoVS_n		: std_logic;									-- Vertical Sync
	signal VideoCS_n		: std_logic;									-- Composite Sync
	signal videoY			: std_logic_vector( 5 downto 0);				-- Svideo_Y
	signal videoC			: std_logic_vector( 5 downto 0);				-- Svideo_C
	signal videoV			: std_logic_vector( 5 downto 0);				-- CompositeVideo

	-- PSG signals
	signal PsgReq			: std_logic;
	signal PsgAck			: std_logic;
	signal PsgDbi			: std_logic_vector(7 downto 0);
	signal PsgAmp			: std_logic_vector(7 downto 0);
--signal JoyA				: std_logic_vector(5 downto 0);
--signal StrA				: std_logic;
--signal JoyB				: std_logic_vector(5 downto 0);
--signal StrB				: std_logic;

	-- SCC signals
	signal Scc1Req			: std_logic;
	signal Scc1Ack			: std_logic;
	signal Scc1Dbi			: std_logic_vector(  7 downto 0 );
	signal Scc1Ram			: std_logic;
	signal Scc1Wrt			: std_logic;
	signal Scc1Adr			: std_logic_vector( 19 downto 0 );
	signal Scc1Dbo			: std_logic_vector(  7 downto 0 );
	signal Scc1AmpL			: std_logic_vector( 14 downto 0 );
	signal Scc1AmpR			: std_logic_vector( 14 downto 0 );

	signal Scc2Req			: std_logic;
	signal Scc2Ack			: std_logic;
	signal Scc2Dbi			: std_logic_vector(  7 downto 0 );
	signal Scc2Ram			: std_logic;
	signal Scc2Wrt			: std_logic;
	signal Scc2Adr			: std_logic_vector( 19 downto 0 );
	signal Scc2Dbo			: std_logic_vector(  7 downto 0 );
	signal Scc2AmpL			: std_logic_vector( 14 downto 0 );
	signal Scc2AmpR			: std_logic_vector( 14 downto 0 );

	signal Scc1Type			: std_logic_vector(  1 downto 0 );

	-- Opll signals
	signal OpllReq			: std_logic;
	signal OpllAck			: std_logic;
	signal OpllAmp			: std_logic_vector(9 downto 0);
	signal OpllEnaWait		: std_logic;
	
	-- Sound signals
	constant DAC_MSBI		: integer := 13;
	signal DACin			: std_logic_vector(DAC_MSBI downto 0);
	signal DACout			: std_logic;

	signal OpllVol			: std_logic_vector(2 downto 0);
	signal SccVol			: std_logic_vector(2 downto 0);
	signal PsgVol			: std_logic_vector(2 downto 0);
	signal MstrVol			: std_logic_vector(2 downto 0);

	signal pSltSndL			: std_logic_vector(5 downto 0);
	signal pSltSndR			: std_logic_vector(5 downto 0);
	signal pSltSound		: std_logic_vector(5 downto 0);

	-- Exernal memory signals
	signal RamReq			: std_logic;
	signal RamAck			: std_logic;
	signal RamDbi			: std_logic_vector(7 downto 0);
	signal ClrAdr			: std_logic_vector(17 downto 0);
	signal CpuAdr			: std_logic_vector(22 downto 0);

	-- SD-RAM control signals
	signal SdrSta			: std_logic_vector(2 downto 0);
	signal SdrCmd			: std_logic_vector(3 downto 0);
	signal SdrBa0			: std_logic;
	signal SdrBa1			: std_logic;
	signal SdrUdq			: std_logic;
	signal SdrLdq			: std_logic;
	signal SdrAdr			: std_logic_vector(12 downto 0);
	signal SdrDat			: std_logic_vector(15 downto 0);
	signal SdPaus			: std_logic;
	
	constant SdrCmd_de		: std_logic_vector(3 downto 0) := "1111"; 		-- deselect
	constant SdrCmd_pr		: std_logic_vector(3 downto 0) := "0010";		-- precharge all
	constant SdrCmd_re		: std_logic_vector(3 downto 0) := "0001";		-- refresh
	constant SdrCmd_ms		: std_logic_vector(3 downto 0) := "0000";		-- mode regiser set

	constant SdrCmd_xx		: std_logic_vector(3 downto 0) := "0111";		-- no operation
	constant SdrCmd_ac		: std_logic_vector(3 downto 0) := "0011";		-- activate
	constant SdrCmd_rd		: std_logic_vector(3 downto 0) := "0101";		-- read
	constant SdrCmd_wr		: std_logic_vector(3 downto 0) := "0100";		-- write

	-- Clock divider
	signal clkdiv3			: std_logic_vector(  1 downto 0 );
	signal w_10hz			: std_logic;
	signal w_20hz			: std_logic;
	signal PausFlash		: std_logic;
	signal ff_mem_seq		: std_logic_vector(  1 downto 0 );

	-- Operation mode
	signal ff_clk21m_cnt	: std_logic_vector( 20 downto 0 );		  		-- free run counter
	signal rtcbase_cnt		: std_logic_vector( 21 downto 0 );		  		-- rtc base counter
	signal flash_cnt		: std_logic_vector(  3 downto 0 );		  		-- flash counter
	signal GreenLv			: std_logic_vector(  6 downto 0 );				-- green level
	signal GreenLv_cnt		: std_logic_vector(  3 downto 0 );		  		-- green level counter
	signal ff_rst_seq		: std_logic_vector(  1 downto 0 );
	alias  FadedRed			: std_logic is ff_clk21m_cnt(0);
	alias  FadedGreen		: std_logic is ff_clk21m_cnt(12);

	-- Sound output, Toggle keys
	signal vFKeys			: std_logic_vector(  7 downto 0 );
	signal ff_Scro			: std_logic;
	signal ff_Reso			: std_logic;

	-- DRAM arbiter
	signal w_wrt_req		: std_logic;

	-- SD-RAM controller
	signal ff_sdr_seq		: std_logic_vector(  2 downto 0 );

	-- Mixer
	signal	ff_prepsg		: std_logic_vector( 8 downto 0 );
	signal	ff_prescc		: std_logic_vector( 15 downto 0 );
	signal	ff_psg			: std_logic_vector( DACin'high + 2 downto DACin'low );
	signal	ff_scc			: std_logic_vector( DACin'high + 2 downto DACin'low );
	signal	w_scc_sft		: std_logic_vector( DACin'high + 2 downto DACin'low );
	signal	w_scc			: std_logic_vector( 18 downto 0 );
	signal	w_s				: std_logic_vector( 15 downto 7 );
	signal	ff_opll			: std_logic_vector( DACin'high + 2 downto DACin'low );
	signal	ff_psg_offset	: std_logic_vector( DACin'high + 2 downto DACin'low );
	signal	ff_scc_offset	: std_logic_vector( DACin'high + 2 downto DACin'low );
	signal	ff_pre_dacin	: std_logic_vector( DACin'high + 2 downto DACin'low );
	constant c_amp_offset	: std_logic_vector( DACin'high + 2 downto DACin'low ) := ( ff_pre_dacin'high => '1', others => '0' );
	constant c_opll_zero	: std_logic_vector( OpllAmp'range ) := ( OpllAmp'high => '1', others => '0' );

	-- Sound output filter
	signal	lpf1_wave		: std_logic_vector( DACin'high downto 0 );
--	signal	lpf2_wave		: std_logic_vector( DACin'high downto 0 );
--	signal	lpf3_wave		: std_logic_vector( DACin'high downto 0 );
--	signal	lpf4_wave		: std_logic_vector( DACin'high downto 0 );
	signal	lpf5_wave		: std_logic_vector( DACin'high downto 0 );

--	signal	ff_lpf_div		: std_logic_vector( 3 downto 0 );	-- sccic
--	signal	w_lpf2ena		: std_logic;						-- sccic
--	signal	w_lpf3ena		: std_logic;
--	signal	w_lpf4ena		: std_logic;
--	signal	w_lpf5ena		: std_logic;

	-- 60Hz
	signal ntsc_forced		: std_logic;

--	★t.hara test PCM 
--	signal ff_pcm			: std_logic_vector( 11 downto 0 );
--	signal pcm_req			: std_logic;

begin

	----------------------------------------------------------------
	-- Clock generator (21.48MHz > 3.58MHz)
	-- pCpuClk should be independent from reset
	----------------------------------------------------------------

	-- Clock enabler : 3.58MHz = 21.48MHz / 6
	process( reset, clk21m )
	begin
		if( reset = '1' )then
			clkena	<= '0';
		elsif( clk21m'event and clk21m = '1' )then
			if( clkdiv3 = "00" )then
				clkena <= cpuclk;
			else
				clkena <= '0';
			end if;
		end if;
	end process;

	-- CPUCLK : 3.58MHz = 21.48MHz / 6
	process( reset, clk21m )
	begin
		if( reset = '1' )then
			cpuclk	<= '1';
		elsif( clk21m'event and clk21m = '1' )then
			if( clkdiv3 = "10" )then
				cpuclk <= not cpuclk;
			else
				-- hold
			end if;
		end if;
	end process;

	-- Prescaler : 21.48MHz / 6
	process( reset, clk21m )
	begin
		if( reset = '1' )then
			clkdiv3	<= "10";
		elsif( clk21m'event and clk21m = '1' )then
			if( clkdiv3 = "00" )then
				clkdiv3	<= "10";
			else
				clkdiv3	<=	clkdiv3 - 1;
			end if;
		end if;
	end process;

	-- Prescaler : 21.48MHz / 4
	process( reset, clk21m )
	begin
		if( reset = '1' )then
			clkdiv	<= (others => '0');
		elsif( clk21m'event and clk21m = '1' )then
			clkdiv	<=	clkdiv - 1;
		end if;
	end process;

	-- hybrid clock start counter
	process( reset, clk21m )
	begin
		if( reset = '1' )then
			hstartcount	<=	(others => '0');
		elsif( clk21m'event and clk21m = '1' )then
			if( ff_clk21m_cnt( 16 downto 0 ) = "00000000000000000" )then
				if( mmcena = '0' )then
					hstartcount	<=	"111";									-- begin after 48ms
				elsif( hstartcount /= "000" )then
					hstartcount	<=	hstartcount - 1;
				end if;
			end if;
		end if;
	end process;
	
	-- hybrid clock time out counter
	process( reset, clk21m )
	begin
		if( reset = '1' )then
			htoutcount	<=	(others => '0');
		elsif( clk21m'event and clk21m = '1' )then	
			if( hstartcount = "000" or htoutcount /= "000" )then
				if( mmcena = '1' )then
					htoutcount	<=	"111";									-- time out after 96ms
				elsif( ff_clk21m_cnt( 17 downto 0 ) = "000000000000000000" )then
					htoutcount	<=	htoutcount - 1;
				end if;
			end if;
		end if;
	end process;

	-- hybrid clock enabler
	process( reset, clk21m )
	begin
		if( reset = '1' )then
			hybridclk	<=	'0';
		elsif( clk21m'event and clk21m = '1' )then
			if( htoutcount = "000" )then
				hybridclk	<= '0';
			else
				hybridclk	<= tMegaSD;
			end if;
		end if;
	end process;

	-- Virtual DIP-SW assignment (20hz)
	process( clk21m )
	begin
		if( clk21m'event and clk21m = '0' and RstEna = '1' )then
			if( cpuclk = '0' and clkdiv = "00" and SdPaus = '0' )then
				if( w_20hz = '1' )then
					ff_clksel5m_n 	<=	io41_id008_n	or hybridclk;
					ff_clksel 		<=	io42_id212_n(0)	or hybridclk;
					CmtScro			<=	swioCmt;
					DisplayMode(1)	<=	io42_id212_n(1);
					DisplayMode(0)	<=	io42_id212_n(2);
					Slot1Mode 		<=	io42_id212_n(3);
					Slot2Mode(1)	<=	io42_id212_n(4);
					Slot2Mode(0)	<=	io42_id212_n(5);
				end if;
			end if;
		end if;
	end process;

	Kmap	<=	swioKmap	when( w_10hz = '1' );

	-- ※FFで叩いた信号 1bitだけで選択すること (pCpuClk にヒゲが出ると不安定になる) 
	pCpuClk 	<=	cpuclk	or	(not pSltWait_n)	when( SdPaus /= '0' )else
					clkdiv(0)		when( ff_clksel = '1' and reset /= '1' )else		-- 10.74 MHz
					clkdiv(1)		when( ff_clksel5m_n = '0' and reset /= '1' )else	--  5.37 MHz
					cpuclk;																--  3.58 MHz (Default when reset = '1')

	----------------------------------------------------------------
	-- Reset control
	-- "RstSeq" should be cleared when power-on reset
	----------------------------------------------------------------

	process( memclk )
	begin
		if( memclk'event and memclk = '1' )then
			ff_mem_seq <= ff_mem_seq(0) & (not ff_mem_seq(1));
		end if;
	end process;

	process(memclk)
	begin
		if( memclk'event and memclk = '1' )then
			if( ff_mem_seq = "00" )then
				FreeCounter <= FreeCounter + 1;
			end if;
		end if;
	end process;

	process(memclk)
	begin
		if( memclk'event and memclk = '1' )then
			if( (ff_mem_seq = "00") and (FreeCounter = X"FFFF") and (RstSeq /= "11111") )then
				RstSeq <= RstSeq + 1;			-- 3ms (= 65536 / 21.48MHz)
			end if;
		end if;
	end process;

	--	Reset pulse width = 48 ms
	process( RstEna, memclk )
	begin
		if( RstEna = '0' )then
			CpuRst_n 	<= '0';
		elsif( memclk'event and memclk = '1' )then
			CpuRst_n	<= 'Z';
		end if;
	end process;

	reset 	<= 	'1' when( (pSltRst_n = '0' and io43_id212_n(5) = '0') or swioRESET_n = '0' )else
				'0';

	----------------------------------------------------------------
	-- Operation mode
	----------------------------------------------------------------

	-- free run counter
	process( reset, clk21m )
	begin
		if( reset = '1' )then
			ff_clk21m_cnt <= (others => '0');
		elsif( clk21m'event and clk21m = '1' )then
			ff_clk21m_cnt <= ff_clk21m_cnt + 1;
		end if;
	end process;

	-- rtc base counter
	process( clk21m )									-- no rtc time delay holding the reset key
	begin
		if( clk21m'event and clk21m = '1' )then
			if( w_10hz = '1' )then						-- ((21.47727MHz/10Hz)-1) => 2147726 to 0 => 2147727 clock cycles
				rtcbase_cnt	<= "1000001100010110001110";
			else
				rtcbase_cnt	<= rtcbase_cnt - 1;
			end if;
		end if;
	end process;

	-- flash counter
	process( clk21m )
	begin
		if( clk21m'event and clk21m = '1')then
			if( SdPaus = '0' )then
				if( ff_clksel5m_n = '1' )then
					flash_cnt <= "0000";
				else
					flash_cnt <= "0100";
				end if;
			elsif( w_10hz = '1' )then
				if( flash_cnt = "0000" )then
					flash_cnt	<= "1011";				-- 1200ms
				else
					flash_cnt	<= flash_cnt - 1;
				end if;
			end if;
		end if;
	end process;

	-- green level counter
	process( reset, clk21m )
	begin
		if( reset = '1' )then
			GreenLv_cnt <= "0000";
		elsif( clk21m'event and clk21m = '1' )then
			if( GreenLvEna = '1' )then
				GreenLv_cnt	<= "1111";
 			elsif( w_10hz = '1' and GreenLv_cnt /= "0000" )then
				GreenLv_cnt	<= GreenLv_cnt - 1;			-- 1600ms
			end if;
		end if;
	end process;

	-- green level assignment
	process( reset, clk21m )
	begin
		if( reset = '1' )then
			GreenLv <= (others => '0');
		elsif( clk21m'event and clk21m = '1' )then
			case LevCtrl is
			when "111"	=>	GreenLv <=	"1111111";
			when "110"	=>	GreenLv	<=	"0111111";
			when "101"	=>	GreenLv	<=	"0011111";
			when "100"	=>	GreenLv	<=	"0001111";
			when "011"	=>	GreenLv	<=	"0000111";
			when "010"	=>	GreenLv	<=	"0000011";
			when "001"	=>	GreenLv	<=	"0000001";
			when others	=>	GreenLv <=	"0000000";
			end case;
		end if;
	end process;
					
	-- reset enable wait counter
	--
	--	ff_rst_seq(0)	X___X~~~X~~~X___X___X ...
	--	ff_rst_seq(1)	X___X___X~~~X~~~X___X ...
	--
	process( reset, clk21m )
	begin
		if( reset = '1' )then
			ff_rst_seq <= "00";
		elsif( clk21m'event and clk21m = '1' )then
			if( w_10hz = '1' )then
				ff_rst_seq <= ff_rst_seq(0) & (not ff_rst_seq(1));
			else
				--	hold
			end if;
		end if;
	end process;

	-- power LED
	process( reset, clk21m )
	begin
		if( reset = '1' )then
			pLedPwr	<= clk21m;							-- a simple check test on red led
		elsif( clk21m'event and clk21m = '1' )then
				if( SdPaus = '1' )then
					if( PausFlash = '1' )then			-- Pause		is Faded Flash
						pLedPwr	<=  FadedRed;
					else
						pLedPwr	<= '0';
					end if;
				elsif( Red_sta = '1' )then				-- 5.37MHz On	is Faded Red On
					pLedPwr	<=  FadedRed;
				else
					pLedPwr	<= '0';						-- Off / Blink
			end if;
		end if;
	end process;

	-- reset enabler
	process( reset, clk21m )
	begin
		if( reset = '1' )then
			RstEna <= '0';
		elsif( clk21m'event and clk21m = '1' )then
			if( ff_rst_seq = "11" and warmRESET /= '1' )then
				RstEna	<= '1';							--	RstEna change to 1 after 200ms from power on
			else
				--	hold
			end if;
		end if;
	end process;
	
	-- DIP SW latch
	process( clk21m )
	begin
		if( clk21m'event and clk21m = '1' )then
			if( w_10hz = '1' and SdPaus = '0' )then		--	chattering protect
				ff_dip_sw <= not pDip;					--	convert negative logic to positive logic, and latch
			else
				--	hold
			end if;
		end if;
	end process;

	-- Kana keyboard layout: 1=JIS layout
	w_key_mode	<=	'1';

	-- 10.00Hz (reset enabler)
	w_10hz		<=	'1' when( rtcbase_cnt = "0000000000000000000000" )else
					'0';
	-- 21.48MHz / 2^20 => 20.48Hz (dip-sw latch and virtual dip-sw assignment)
	w_20hz		<=	'1' when( ff_clk21m_cnt( 19 downto 0 ) = "00000000000000000000" )else
					'0';
	-- Pause Flash (800ms ON + 400ms OFF = 1200ms per cycle)
	PausFlash	<=	'0' when( flash_cnt( 3 downto 2 ) = "00" )else
					'1';
	-- Blink assignment
	MmcEnaLed	<=	((ff_clk21m_cnt(20) or (not ff_clk21m_cnt(19))) and FadedGreen)
							when( Blink_ena = '1' and MmcEna = '1' )else
					(MmcMode		and FadedGreen)
							when( Blink_ena = '0' and LightsMode = '0' )else
					(GreenLeds(7)	and FadedGreen)
							when( LightsMode = '1' )else
					'0';
	-- Leds assignment
	pLed		<=	MmcEnaLed			&					-- Blink + LightsMode
					(GreenLeds(6)		and  FadedGreen) &
					(GreenLeds(5)		and  FadedGreen) &
					(GreenLeds(4)		and  FadedGreen) &
					(GreenLeds(3)		and  FadedGreen) &
					(GreenLeds(2)		and  FadedGreen) &
					(GreenLeds(1)		and  FadedGreen) &
					(GreenLeds(0)		and  FadedGreen)	when( LightsMode = '1' )else

					MmcEnaLed			&					-- Volume + high-speed level
					(GreenLv(6)		and  FreeCounter(1)) &
					(GreenLv(5)		and  FreeCounter(1)) &
					(GreenLv(4)		and  FreeCounter(1)) &
					(GreenLv(3)		and  FreeCounter(1)) &
					(GreenLv(2)		and  FreeCounter(1)) &
					(GreenLv(1)		and  FreeCounter(1)) &
					(GreenLv(0)		and  FreeCounter(1))	when( GreenLv_cnt /= "0000" )else
					
					MmcEnaLed			&					-- Blink + Virtual DIP-SW (Auto)
					(FullRAM			and  FadedGreen) &
					(Slot2Mode(0)		and  FadedGreen) &
					(Slot2Mode(1)		and  FadedGreen) &
					(Slot1Mode			and  FadedGreen) &
					(DisplayMode(0)		and  FadedGreen) &
					(DisplayMode(1)		and  FadedGreen) &
					(io42_id212_n(0)	and  FadedGreen)	when( reset /= '1' )else
					
					(others => 			FreeCounter(0));	-- a simple check test on green leds

	----------------------------------------------------------------
	-- MSX cartridge slot control
	----------------------------------------------------------------
	pSltCs1_n	<=	pSltRd_n when( pSltAdr(15 downto 14) = "01" )else '1';
	pSltCs2_n	<=	pSltRd_n when( pSltAdr(15 downto 14) = "10" )else '1';
	pSltCs12_n	<=	pSltRd_n when( pSltAdr(15 downto 14) = "01" )else 
					pSltRd_n when( pSltAdr(15 downto 14) = "10" )else '1';
	pSltM1_n	<=	CpuM1_n;
	pSltRfsh_n	<=	CpuRfsh_n;

	pSltInt_n	<=	pVdpInt_n;

	pSltSltsl_n <=	'1' when Scc1Type /= "00" else
					'0' when( pSltMerq_n = '0' and CpuRfsh_n = '1' and PriSltNum = "01" )else
					'1';

	pSltSlts2_n <=	'1' when Slot2Mode /= "00" else
					'0' when pSltMerq_n	= '0' and CpuRfsh_n = '1' and PriSltNum	 = "10" else
					'1';

	pSltBdir_n	<=	'Z';

	pSltDat		<=	(others => 'Z') when pSltRd_n = '1' else
					dbi when( pSltIorq_n = '0' and BusDir	 = '1' )else
					dbi when( pSltMerq_n = '0' and PriSltNum = "00" )else
					dbi when( pSltMerq_n = '0' and PriSltNum = "11" )else
					dbi when( pSltMerq_n = '0' and PriSltNum = "01" and Scc1Type /= "00" )else
					dbi when( pSltMerq_n = '0' and PriSltNum = "10" and Slot2Mode  /= "00" )else
					(others => 'Z');

	pSltRsv5	<= 'Z';
	pSltRsv16	<= 'Z';
	pSltSw1		<= 'Z';
	pSltSw2		<= 'Z';

	----------------------------------------------------------------
	-- Z80 CPU wait control
	----------------------------------------------------------------
	process(pSltClk, reset)

		variable iCpuM1_n	: std_logic;
		variable jSltMerq_n	: std_logic;
		variable jSltIorq_n	: std_logic;
		variable count		: std_logic_vector(3 downto 0);

	begin

		if( reset = '1' )then
			iCpuM1_n	:= '1';
			jSltIorq_n	:= '1';
			jSltMerq_n	:= '1';
			count		:= (others => '0');
			pSltWait_n	<= 'Z';
		elsif( pSltClk'event and pSltClk = '1' )then

			if( pSltMerq_n = '0' and jSltMerq_n = '1' )then
				if( ff_clksel = '1' )then
					if( hybridclk = '1' )then
						count := "0010";
					else
						count := CustomSpeed;	-- 4 MHz to 8 MHz
					end if;
				end if;
			elsif( pSltIorq_n = '0' and jSltIorq_n = '1' )then
				if( ff_clksel = '1' )then
					count := "0011";			-- 7 MHz
				end if;
			elsif( count /= "0000" )then
				count := count - 1;
			end if;
			
			if( CpuM1_n = '0' and iCpuM1_n = '1' )then
				pSltWait_n <= '0';
			elsif( count /= "0000" )then
				pSltWait_n <= '0';
			elsif( (ff_clksel = '1' or ff_clksel5m_n = '0') and OpllReq = '1' and OpllAck = '0' )then
				pSltWait_n <= '0';
			elsif( ErmReq = '1' and adr(15 downto 13) = "010" and MmcAct = '1' )then
				pSltWait_n <= '0';
			elsif( SdPaus = '1' )then
				pSltWait_n <= '0';
			else
				pSltWait_n <= 'Z';
			end if;

			iCpuM1_n := CpuM1_n;
			jSltIorq_n := pSltIorq_n;
			jSltMerq_n := pSltMerq_n;

		end if;

	end process;


	----------------------------------------------------------------
	-- On chip internal bus control
	----------------------------------------------------------------
	iSltSltsl_n		<= '1';

	process(clk21m, reset)

		variable ExpDec : std_logic;

	begin

		if( reset = '1' )then

			iSltRfsh_n		<= '1';
			iSltMerq_n		<= '1';
			iSltIorq_n		<= '1';
			iSltRd_n		<= '1';
			iSltWr_n		<= '1';
			xSltRd_n		<= '1';
			xSltWr_n		<= '1';
			iSltAdr			<= (others => '1');
			iSltDat			<= (others => '1');

			iack			<= '0';

			dlydbi			<= (others => '1');
			ExpDec			:= '0';

		elsif( clk21m'event and clk21m = '1' )then

			-- MSX slot signals
			iSltRfsh_n		<= pSltRfsh_n;
			iSltMerq_n		<= pSltMerq_n;
			iSltIorq_n		<= pSltIorq_n;
			iSltRd_n		<= pSltRd_n;
			iSltWr_n		<= pSltWr_n;
			xSltRd_n		<= pSltRd_n;
			xSltWr_n		<= pSltWr_n;
			iSltAdr			<= pSltAdr;
			iSltDat			<= pSltDat;
			
			if( iSltMerq_n = '1' and iSltIorq_n = '1' )then
				iack <= '0';
			elsif( ack = '1' )then
				iack <= '1';
			end if;

			if( mem = '1' and ExpDec = '1' )then
				dlydbi <= ExpDbi;
			elsif( mem = '1' and iSltBot = '1' )then
				dlydbi <= RomDbi;
			elsif( mem = '1' and iSltErm = '1' and MmcEna = '1' )then
				dlydbi <= MmcDbi;
			elsif( mem = '0' and adr(6 downto 2)	= "00010" )then
				dlydbi <= VdpDbi;
			elsif( mem = '0' and adr(6 downto 2)	= "00110" )then
				dlydbi <= VdpDbi;
			elsif( mem = '0' and adr(6 downto 2)	= "01000" )then
				dlydbi <= PsgDbi;
			elsif( mem = '0' and adr(6 downto 2)	= "01010" )then
				dlydbi <= PpiDbi;
			elsif( mem = '0' and adr(6 downto 2)	= "11111" )then
				dlydbi <= MapDbi;
			elsif( mem = '0' and adr(6 downto 1)	= "011010" )then
				dlydbi <= RtcDbi;
			elsif( mem = '0' and adr(6 downto 2)	= "10110" )then
				dlydbi <= KanDbi;
			elsif( mem = '0' and adr(6 downto 1)	= "110011" )then
				dlydbi <= systim_dbi;
			elsif( mem = '0' and adr(6 downto 4)	= "100" )then		-- I/O:40-4Fh / switched I/O ports
				dlydbi <= swio_dbi;
			else
				dlydbi <= (others => '1');
			end if;

			if( adr = X"FFFF" )then
				ExpDec := '1';
			else
				ExpDec := '0';
			end if;

		end if;

	end process;

	----------------------------------------------------------------
	process(clk21m, reset)

	begin

		if( reset = '1' )then

			jSltScc1	<= '0';
			jSltScc2	<= '0';
			jSltMem		<= '0';

			wrt <= '0';

		elsif( clk21m'event and clk21m = '0' )then

			if( mem = '1' and iSltScc1 = '1' )then
				jSltScc1 <= '1';
			else
				jSltScc1 <= '0';
			end if;

			if( mem = '1' and iSltScc2 = '1' )then
				jSltScc2 <= '1';
			else
				jSltScc2 <= '0';
			end if;

			if( mem = '1' and iSltErm = '1' )then
				if( MmcEna = '1' and adr(15 downto 13) = "010" )then
					jSltMem <= '0';
				elsif( MmcMode = '1')then				-- enable SD/MMC drive
					jSltMem <= '1';
				else									-- disable SD/MMC drive
					jSltMem <= '0';
				end if;
			elsif( mem = '1' and (iSltMap = '1' or rom_main = '1' or rom_opll = '1' or rom_extr = '1') )then
					jSltMem <= '1';
			else
					jSltMem <= '0';
			end if;

			if( req = '0' )then
				wrt <= not pSltWr_n;	 -- 1=write, 0=read
			end if;

			ireq <= req;

		end if;

	end process;

	-- access request, CPU > Components
	req <=	'1' when 	( ( (iSltMerq_n = '0') or (iSltIorq_n = '0') ) and
						( (xSltRd_n = '0')   or (xSltWr_n = '0')   ) and iack = '0') else '0';
	mem <= iSltIorq_n;	-- 1=memory area, 0=i/o area
	dbo <= iSltDat;		-- CPU data (CPU > device)
	adr <= iSltAdr;		-- CPU address (CPU > device)

	-- access acknowledge, Components > CPU
	ack		<=	RamAck	when( RamReq = '1' )else					-- ErmAck, MapAck, KanAck;
				Scc1Ack	when( mem = '1' and iSltScc1 = '1' )else	-- Scc1Ack
				Scc2Ack	when( mem = '1' and iSltScc2 = '1' )else	-- Scc2Ack
				OpllAck	when( OpllReq = '1' )else					-- OpllAck
				req;												-- PsgAck, PpiAck, MapAck, VdpAck, RtcAck
	dbi		<=	Scc1Dbi	when( jSltScc1 = '1' )else
				Scc2Dbi	when( jSltScc2 = '1' )else
				RamDbi	when( jSltMem  = '1' )else
				dlydbi;

	----------------------------------------------------------------
	-- PPI(8255) / primary-slot, keyboard, 1 bit sound port
	----------------------------------------------------------------
	process( reset, clk21m )
	begin
		if( reset = '1' )then
			PpiPortA <= "11111111";			-- primary slot : page 0 => boot-rom, page 1/2 => ese-mmc, page 3 => mapper
			PpiPortC <= (others => '0');
		elsif( clk21m'event and clk21m = '1' )then
			-- I/O port access on A8-ABh ... PPI(8255) access
			if( PpiReq = '1' )then
				if( wrt = '1' and adr(1 downto 0) = "00" )then
					PpiPortA <= dbo;
				elsif( wrt = '1' and adr(1 downto 0) = "10" )then
					PpiPortC <= dbo;
				elsif( wrt = '1' and adr(1 downto 0) = "11" and dbo(7) = '0' )then
					case dbo(3 downto 1) is
						when "000"	=> PpiPortC(0) <= dbo(0); -- key_matrix Y(0)
						when "001"	=> PpiPortC(1) <= dbo(0); -- key_matrix Y(1)
						when "010"	=> PpiPortC(2) <= dbo(0); -- key_matrix Y(2)
						when "011"	=> PpiPortC(3) <= dbo(0); -- key_matrix Y(3)
						when "100"	=> PpiPortC(4) <= dbo(0); -- cassete motor on (0=ON,1=OFF)
						when "101"	=> PpiPortC(5) <= dbo(0); -- cassete audio out
						when "110"	=> PpiPortC(6) <= dbo(0); -- CAPS lamp (0=ON,1=OFF)
						when others => PpiPortC(7) <= dbo(0); -- 1 bit sound port
					end case;
				end if;
			end if;
			PpiAck <= PpiReq;
		end if;
	end process;

	Caps <= PpiPortC(6);

	-- I/O port access on A8-ABh ... PPI(8255) register read
	with adr(1 downto 0) select PpiDbi <=
		PpiPortA			when "00",
		PpiPortB			when "01",
		PpiPortC			when "10",
		(others => '1')		when others;

	----------------------------------------------------------------
	--	★t.hara test
	--	PCM
	----------------------------------------------------------------
--	process( reset, clk21m )
--	begin
--		if( reset = '1' )then
--			ff_pcm <= "100000000000";
--		elsif( clk21m'event and clk21m = '1' )then
--			if( pcm_req = '1' )then
--				if(    wrt = '1' and adr(0) = '0' )then
--					ff_pcm(  7 downto 0 ) <= dbo;
--				elsif( wrt = '1' and adr(0) = '1' )then
--					ff_pcm( 11 downto 8 ) <= dbo( 3 downto 0 );
--				else
--					-- hold
--				end if;
--			end if;
--		end if;
--	end process;

	----------------------------------------------------------------
	-- Expansion slot
	----------------------------------------------------------------

	-- slot #0
	process( reset, clk21m )
	begin
		if( reset = '1' )then
			ExpSlot0 <= (others => '0');
		elsif( clk21m'event and clk21m = '1' )then
			-- Memory mapped I/O port access on FFFFh ... expansion slot register (master mode)
			if( req = '1' and iSltMerq_n = '0' and wrt = '1' and adr = X"FFFF" )then
				if( PpiPortA(7 downto 6) = "00" )then
					ExpSlot0 <= dbo;
				end if;
			end if;
		end if;
	end process;

	-- slot #3
	process( reset, clk21m )
	begin
		if( reset = '1' )then
			ExpSlot3 <= "00101011";			 -- primary slot : page 0 => iplrom, page 1/2 => megasd, page 3 => mapper
		elsif( clk21m'event and clk21m = '1' )then
			-- Memory mapped I/O port access on FFFFh ... expansion slot register (master mode)
			if( req = '1' and iSltMerq_n = '0' and wrt = '1' and adr = X"FFFF" )then
				if( PpiPortA(7 downto 6) = "11" )then
					ExpSlot3 <= dbo;
				end if;
			end if;
		end if;
	end process;

	-- primary slot number (master mode)
	with adr(15 downto 14) select PriSltNum	<=
		PpiPortA(1 downto 0) when "00",
		PpiPortA(3 downto 2) when "01",
		PpiPortA(5 downto 4) when "10",
		PpiPortA(7 downto 6) when others;

	-- expansion slot number : slot 0 (master mode)
	with adr(15 downto 14) select ExpSltNum0 <=
		ExpSlot0(1 downto 0) when "00",
		ExpSlot0(3 downto 2) when "01",
		ExpSlot0(5 downto 4) when "10",
		ExpSlot0(7 downto 6) when others;

	-- expansion slot number : slot 3 (master mode)
	with adr(15 downto 14) select ExpSltNum3 <=
		ExpSlot3(1 downto 0) when "00",
		ExpSlot3(3 downto 2) when "01",
		ExpSlot3(5 downto 4) when "10",
		ExpSlot3(7 downto 6) when others;

	-- expansion slot register read
	with PpiPortA(7 downto 6) select ExpDbi <=
		not ExpSlot0		 when "00",
		not ExpSlot3		 when "11",
		(others => '1')		 when others;

	----------------------------------------------------------------
	-- slot / address decode
	----------------------------------------------------------------
	iSltScc1 <=	'0' when( Scc1Type = "00"										)else
				'0' when( adr(15 downto 14) = "00" or adr(15 downto 14) = "11"	)else
				mem when( PriSltNum = "01"										)else	-- SCC is slot#1, page 1/2
				'0';

	iSltScc2 <=	'0' when( Slot2Mode = "00"										)else
				'0' when( adr(15 downto 14) = "00" or adr(15 downto 14) = "11"	)else
				mem when( PriSltNum = "10"										)else	-- SCC is slot#2, page 1/2
				'0';

	iSltMap	<=	'0' when( adr = X"FFFF"											)else
				mem when( PriSltNum	 = "11" and ExpSltNum3 = "00"				)else	-- MapperRAM is slot#3-0, page 0-3 without FFFFh
				'0';

	iSltErm	<=	'0' when( adr(15 downto 14) = "00" or adr(15 downto 14) = "11"	)else
				mem when( PriSltNum	 = "11" and ExpSltNum3 = "10"				)else	-- ESE-RAM is slot#3-2, page 1/2
				'0';

	iSltBot	<=	'0' when( adr(15 downto 14) = "01" or adr(15 downto 14) = "10"	)else
				mem when( PriSltNum	 = "11" and ExpSltNum3 = "11"				)else	-- IPL-ROM is slot#3-3, page 0/3
				'0';

	rom_main <=	'0' when( adr(15) /= '0'							)else				-- MAIN-ROM
				mem when( PriSltNum	= "00" and ExpSltNum0 = "00"	)else '0';
	rom_opll <=	'0' when( adr(15 downto 14) /= "01"					)else				-- OPLL
				mem when( PriSltNum	= "00" and ExpSltNum0 = "10"	)else '0';
	rom_extr <=	'0' when( adr(15 downto 14) /= "00"					)else				-- SUB-ROM
				mem when( PriSltNum	= "11" and ExpSltNum3 = "01"	)else '0';
	rom_kanj <=	'0' when( mem = '1'									)else				-- Kanji-ROM
				'1' when( adr(7 downto 2) = "110110"				)else '0';

	-- RamX / RamY access request
	RamReq	<=	Scc1Ram or Scc2Ram or ErmRam or MapRam or RomReq or KanRom;

	-- access request to component
	VdpReq	<=	req when( mem = '0' and adr(7 downto 2) = "100110"	)else '0';		-- I/O:98-9Bh	/ VDP(V9958)
	PsgReq	<=	req when( mem = '0' and adr(7 downto 2) = "101000"	)else '0';		-- I/O:A0-A3h	/ PSG(AY-3-8910)
	PpiReq	<=	req when( mem = '0' and adr(7 downto 2) = "101010"	)else '0';		-- I/O:A8-ABh	/ PPI(8255)
	OpllReq	<=	req when( mem = '0' and adr(7 downto 2) = "011111"	)else '0';		-- I/O:7C-7Fh	/ OPLL(YM2413)
	KanReq	<=	req when( mem = '0' and adr(7 downto 2) = "110110"	)else '0';		-- I/O:D8-DBh	/ Kanji
	RomReq	<=	req when( (rom_main or rom_opll or rom_extr) = '1'	)else '0';
	MapReq	<=	req when( mem = '0' and adr(7 downto 2) = "111111"	)else			-- I/O:FC-FFh	/ Memory-mapper
				req when(				iSltMap = '1'				)else '0';		-- MEM			/ Memory-mapper
	Scc1Req	<=	req when(				iSltScc1 = '1'				)else '0';		-- MEM:			/ ESE-SCC
	Scc2Req	<=	req when(				iSltScc2 = '1'				)else '0';		-- MEM:			/ ESE-SCC
	ErmReq	<=	req when(				iSltErm = '1'				)else '0';		-- MEM:			/ ESE-RAM, MegaSD
	RtcReq	<=	req when( mem = '0' and adr(7 downto 1) = "1011010"	)else '0';		-- I/O:B4-B5h	/ RTC(RP-5C01)
	systim_req	<=	req when( mem = '0' and adr(7 downto 1) = "1110011" )else '0';	-- I/O:E6-E7h	/ system timer
	swio_req	<=	req when( mem = '0' and adr(7 downto 4) = "0100" )else '0';			-- I/O:40-4Fh	/ switched I/O ports
--	pcm_req		<=	req when( mem = '0' and adr(7 downto 1) = "1110100" )else '0';	-- I/O:E8-E9h	/ test PCM	★t.hara

	BusDir	<=	'1' when( pSltAdr(7 downto 2) = "100110"	)else	-- I/O:98-9Bh / VDP(V9958)
				'1' when( pSltAdr(7 downto 2) = "101000"	)else	-- I/O:A0-A3h / PSG(AY-3-8910)
				'1' when( pSltAdr(7 downto 2) = "101010"	)else	-- I/O:A8-ABh / PPI(8255)
				'1' when( pSltAdr(7 downto 2) = "110110"	)else	-- I/O:D8-DBh / Kanji
				'1' when( pSltAdr(7 downto 2) = "111111"	)else	-- I/O:FC-FFh / Memory-mapper
				'1' when( pSltAdr(7 downto 1) = "1011010"	)else	-- I/O:B4-B5h / RTC(RP-5C01)
				'1' when( pSltAdr(7 downto 1) = "1110011"	)else	-- I/O:E6-E7h / system timer
				'1' when( pSltAdr(7 downto 4) = "0100"		)else	-- I/O:40-4Fh / switched I/O ports
--				'1' when( pSltAdr(7 downto 1) = "1110100"	)else	-- I/O:E8-E9h / test PCM  ★t.hara
				'0';

	----------------------------------------------------------------
	-- Test for on-screen-display
	----------------------------------------------------------------

	-- デバッグ用の OSD-VRAM に文字列を転送する回路 起動時の一瞬しか動作しない 
--	process( reset, clk21m )
--		constant str		: string := "ESE MSX-SYSTEM3'[2007/02/10]";
--		variable osdStat	: std_logic_vector( 1 downto 0 );
--		variable x			: std_logic_vector( 4 downto 0 );
--	begin
--		if( reset = '1' )then
--			osdCharWrReq	<= '0';
--			osdCharCodeIn	<= (others => '0');
--			x				:= (others => '0');
--			osdStat		:= "00";
--		elsif( clk21m'event and clk21m = '1' )then
--			case osdStat is
--				when "00" =>
--					x			:= (others => '0');
--					osdStat	:= "01";
--				when "01" =>
--					osdCharCodeIn	<= char_to_std_logic_vector( str( conv_integer(x)+1 ) );
--					osdCharWrReq	<= not osdCharWrAck;
--					osdStat		:= "10";
--				when "10" =>
--					-- waiting wr ack
--					if( osdCharWrReq = osdCharWrAck )then
--						if( x = 27 )then
--							osdStat := "11";
--						else
--							osdStat := "01";
--							x := x+1;
--						end if;
--					end if;
--				when "11" =>
--					null;
--				when others => null;
--			end case;
--		end if;
--
--		osdLocateX <= '0' & x;
--		osdLocateY <= (others => '0');
--	end process;

	----------------------------------------------------------------
	-- Video output
	----------------------------------------------------------------
	process (clk21m)
	begin
		if( clk21m'event and clk21m = '1' )then
			case DisplayMode is
			when "00" =>								-- TV 15KHz
				pDac_VR		<= videoC;
				pDac_VG		<= videoY;
				pDac_VB		<= videoV;
				Reso_v		<= '0';						-- Hsync:15kHz
				ntsc_forced	<= '0';
				pVideoHS_n	<= VideoHS_n;
				pVideoVS_n	<= VideoVS_n;

			when "01" =>								-- RGB 15kHz (Half amplitude)
				pDac_VR		<= '0' & VideoR( 5 downto 1 );
				pDac_VG		<= '0' & VideoG( 5 downto 1 );
				pDac_VB		<= '0' & VideoB( 5 downto 1 );
				Reso_v		<= '0';						-- Hsync:15kHz
				ntsc_forced	<= '0';
				pVideoHS_n	<= VideoCS_n;
				pVideoVS_n	<= DACout;	 				-- Audio

			when "10" =>								-- VGA 31KHz (Half amplitude / 60Hz Forced)
				pDac_VR		<= '0' & VideoR( 5 downto 1 );
				pDac_VG		<= '0' & VideoG( 5 downto 1 );
				pDac_VB		<= '0' & VideoB( 5 downto 1 );
				Reso_v		<= '1';						-- Hsync:31kHz
				ntsc_forced	<= Vga60Ena;
				pVideoHS_n	<= VideoHS_n;
				pVideoVS_n	<= VideoVS_n;

			when others =>								-- VGA 31kHz (Full amplitude / 60Hz Forced)
				pDac_VR		<= VideoR;
				pDac_VG		<= VideoG;
				pDac_VB		<= VideoB;
				Reso_v		<= '1';						-- Hsync:31kHz
				ntsc_forced	<= Vga60Ena;
				pVideoHS_n	<= VideoHS_n;
				pVideoVS_n	<= VideoVS_n;
			end case;
		end if;
	end process;

	-- PRNSCR key
	process( reset, clk21m )
	begin
		if( reset = '1' )then
			ff_Reso <= '0';
		elsif( clk21m'event and clk21m = '1' and RstEna = '1' )then
			ff_Reso <= Reso;
		end if;
	end process;

	pVideoClk <= 'Z';
	pVideoDat <= 'Z';

	----------------------------------------------------------------
	-- Sound output
	----------------------------------------------------------------

	-- | b7  | b6   | b5   | b4   | b3  | b2  | b1  | b0  |
	-- | SHI | --   | PgUp | PgDn | F9  | F10 | F11 | F12 |
	process( reset, clk21m )
	begin
		if( reset = '1' )then
			vFkeys	<= (others => '0');		-- Sync to oFkeys
		elsif( clk21m'event and clk21m = '1' and RstEna = '1' )then
			vFkeys	<=	Fkeys;
		end if;
	end process;

	-- mixer (pipe lined)
	u_mul: scc_mix_mul
	port map (
		a	=> ff_prescc			,	-- 16bit 二の補数 
		b	=> SccVol and (not (SdPaus & SdPaus & SdPaus))	,	-- 3bit バイナリ（符号無し） 
		c	=> w_scc					-- 19bit 二の補数 
	);

	w_s <= (others => w_scc(18));
	with MstrVol select w_scc_sft <=
		w_s( 15 downto 14 )	& w_scc( 18 downto  5 )	when "000",
		w_s( 15 downto 13 ) & w_scc( 18 downto  6 )	when "001",
		w_s( 15 downto 12 ) & w_scc( 18 downto  7 )	when "010",
		w_s( 15 downto 11 ) & w_scc( 18 downto  8 )	when "011",
		w_s( 15 downto 10 ) & w_scc( 18 downto  9 )	when "100",
		w_s( 15 downto  9 ) & w_scc( 18 downto 10 )	when "101",
		w_s( 15 downto  8 ) & w_scc( 18 downto 11 )	when "110",
		w_s( 15 downto  7 ) & w_scc( 18 downto 12 )	when "111",
		(others => 'X') when others;

	process( clk21m )
		variable chAmp		: std_logic_vector( ff_pre_dacin'range );
	begin
		if( clk21m'event and clk21m = '1' )then
			ff_prepsg	<=	(('0'         & PsgAmp  ) + (KeyClick & "00000"));
			ff_prescc	<=	((Scc1AmpL(14) & Scc1AmpL) + (Scc2AmpL(14) & Scc2AmpL));

			ff_psg		<=	"000" & SHR( (ff_prepsg * (PsgVol and (not (SdPaus & SdPaus & SdPaus))) ) &  "0", MstrVol );
			ff_scc		<=	w_scc_sft;

			if( OpllAmp < c_opll_zero )then
				chAmp := "00" & SHR( ((c_opll_zero - OpllAmp) * (OpllVol and (not (SdPaus & SdPaus & SdPaus))) ) & "0", MstrVol );
				ff_opll <= c_amp_offset - ( chAmp - chAmp( chAmp'high downto 3 ) );
			else
				chAmp := "00" & SHR( ((OpllAmp - c_opll_zero) * (OpllVol and (not (SdPaus & SdPaus & SdPaus))) ) & "0", MstrVol );
				ff_opll <= c_amp_offset + ( chAmp - chAmp( chAmp'high downto 3 ) );
			end if;
		end if;
	end process;

	process( clk21m )
	begin
		if( clk21m'event and clk21m = '1' )then
			ff_pre_dacin	<=	((ff_psg + ff_scc) + ff_opll);

			-- Limiter
			case ff_pre_dacin( ff_pre_dacin'high downto ff_pre_dacin'high - 2 ) is
				when "111" => DACin	<= (others=>'1');
				when "110" => DACin	<= (others=>'1');
				when "101" => DACin	<= (others=>'1');
				when "100" => DACin	<= "1" & ff_pre_dacin( ff_pre_dacin'high - 3 downto 0 );
				when "011" => DACin	<= "0" & ff_pre_dacin( ff_pre_dacin'high - 3 downto 0 );
				when "010" => DACin	<= (others=>'0');
				when "001" => DACin	<= (others=>'0');
				when "000" => DACin	<= (others=>'0');
			end case;

--			DACin <= ff_pcm;	--	★t.hara test
		end if;
	end process;

		  pDac_SL	<= DACout & DACout & DACout & DACout & DACout & DACout;

	-- Cassette Magnetic Tape (CMT) interface
	process( clk21m )
	begin
	  if( clk21m'event and clk21m = '1' )then
		if( CmtScro = '1' )then					-- When Scroll Lock is ON
	        pDac_SR(5 downto 4) <= "ZZ";
	        pDac_SR(3 downto 1) <= CmtIn & (not CmtIn) & '0';
	        pDac_SR(0)			<= CmtOut;
	        CmtIn				<= pDac_SR(5);
		else									-- When Scroll Lock is OFF (default)
	        pDac_SR				<= DACout & DACout & DACout & DACout & DACout & DACout;
	        CmtIn				<= '0';			-- CMT data input : always '0' on MSX turboR
	    end if;
	  end if;
	end process;

	-- SCRLK key
	process( reset, clk21m )
	begin
		if( reset = '1' )then
			ff_Scro		<= '0';
		elsif( clk21m'event and clk21m = '1' and RstEna = '1' )then
			ff_Scro 	<= Scro;
		end if;
	end process;

	----------------------------------------------------------------
	-- External memory access
	----------------------------------------------------------------
	-- Slot map / SD-RAM memory map in master mode
	--
	-- Slot 0-0	: MainROM				690000-697FFF(	32KB)
	-- Slot 0-2	: FM-BIOS				69C000-69FFFF(	16KB)
	-- Slot 1	: (EXTERNAL-SLOT)
	-- Slot 2	: (EXTERNAL-SLOT)
	--				/ MegaRam			600000-67FFFF( 512KB)
	-- Slot 3-0	: Mapper				000000-1FFFFF(2048KB) / 000000-3FFFFF(4096KB)
	-- Slot 3-1	: SubROM				698000-69BFFF(	16KB)
	-- Slot 3-2	: MegaSD				680000-68FFFF(	64KB) / 680000-6BFFFF(BIOS:256KB)
	-- Slot 3-3	: IPL-ROM				(blockRAM:512Bytes)
	-- VRAM		: VRAM					700000-71FFFF( 128KB)

	---------------------------------------------------------
	-- iSltMap							000000-1FFFFF(2048KB) / 000000-3FFFFF(4096KB)
	-- iSltScc1							400000-4FFFFF(1024KB)
	-- iSltScc2							600000-67FFFF( 512KB)
	-- iSltErm							680000-6BFFFF( 256KB)
	-- rom_main							690000-697FFF(  32KB)
	-- rom_extr							698000-69BFFF(  16KB)
	-- rom_opll							69C000-69FFFF(  16KB)
	-- rom_kanji						6A0000-6BFFFF( 128KB)
	
	CpuAdr(22 downto 20) <= "00" & MapAdr(20) 			when( iSltMap  = '1' and FullRAM = '0' )else	--	2MB
							"0" & MapAdr(21 downto 20) 	when( iSltMap  = '1' )else						--	4MB
							"100"						when( iSltScc1 = '1' )else
							"110";

	CpuAdr(19 downto 0)	 <=				  MapAdr(19 downto 0)	when( iSltMap  = '1' )else
										  Scc1Adr(19 downto 0)	when( iSltScc1 = '1' )else
							"0"			& Scc2Adr(18 downto 0)	when( iSltScc2 = '1' )else
							"10"		& ErmAdr(17 downto 0)	when( iSltErm  = '1' )else
							"101"		& KanAdr(16 downto 0)	when( rom_kanj = '1' )else
							"10010"		& adr(14 downto 0)		when( rom_main = '1' )else
							"100110"	& adr(13 downto 0)		when( rom_extr = '1' )else
							"100111"	& adr(13 downto 0);		--when( rom_opll = '1')


	----------------------------------------------------------------
	-- SD-RAM access
	----------------------------------------------------------------
	--	 SdrSta = "000" => idle
	--	 SdrSta = "001" => precharge all
	--	 SdrSta = "010" => refresh
	--	 SdrSta = "011" => mode register set
	--	 SdrSta = "100" => read cpu
	--	 SdrSta = "101" => write cpu
	--	 SdrSta = "110" => read vdp
	--	 SdrSta = "111" => write vdp
	----------------------------------------------------------------
	w_wrt_req	<=	(RamReq and (
						(Scc1Wrt and iSltScc1 ) or
						(Scc2Wrt and iSltScc2 ) or
						(ErmWrt  and iSltErm  ) or
						(MapWrt  and iSltMap  ))
					);

	process( memclk )
	begin
		if( memclk'event and memclk = '1' )then
			if( ff_sdr_seq = "111" )then
				if( RstSeq(4 downto 2) = "000" )then
					SdrSta <= "000";												-- Idle
				elsif( RstSeq(4 downto 2) = "001" )then
					case RstSeq(1 downto 0) is
						when "00"		=> SdrSta <= "000";							-- Idle
						when "01"		=> SdrSta <= "001";							-- precharge all
						when "10"		=> SdrSta <= "010";							-- refresh (more than 8 cycles)
						when others		=> SdrSta <= "011";							-- mode register set
					end case;
				elsif( RstSeq(4 downto 3) /= "11" )then
					SdrSta <= "101";												-- Write (Initialize memory content)
				elsif( iSltRfsh_n = '0' and VideoDLClk = '1' )then
					SdrSta <= "010";												-- refresh
				elsif( SdPaus = '1' and VideoDLClk = '1' )then
					SdrSta <= "010";												-- refresh
				else
					--	Normal memory access mode
					SdrSta(2) <= '1';												-- read/write cpu/vdp
				end if;
			elsif( ff_sdr_seq = "001" and SdrSta(2) = '1' and RstSeq(4 downto 3) = "11" )then
				SdrSta(1) <= VideoDLClk;											-- 0:cpu, 1:vdp
				if( VideoDLClk = '0' )then
					--	for cpu
					SdrSta(0) <= w_wrt_req;
				else
					--	for vdp
					if( WeVdp_n = '0' )then
						SdrSta(0) <= '1';
					else
						SdrSta(0) <= '0';
					end if;
				end if;
			end if;
		end if;
	end process;

	process( memclk )
	begin
		if( memclk'event and memclk = '1' )then
			case ff_sdr_seq is
				when "000" =>
					if( SdrSta(2) = '1' )then				-- CPU/VDP read/write
						SdrCmd <= SdrCmd_ac;
					elsif( SdrSta(1 downto 0) = "00" )then	-- idle
						SdrCmd <= SdrCmd_xx;
					elsif( SdrSta(1 downto 0) = "01" )then	-- precharge all
						SdrCmd <= SdrCmd_pr;
					elsif( SdrSta(1 downto 0) = "10" )then	-- refresh
						SdrCmd <= SdrCmd_re;
					else									-- mode register set
						SdrCmd <= SdrCmd_ms;
					end if;
				when "001" =>
					SdrCmd <= SdrCmd_xx;
				when "010" =>
					if( SdrSta(2) = '1' )then
						if( SdrSta(0) = '0' )then
							SdrCmd <= SdrCmd_rd;			-- "100"(cpu read) / "110"(vdp read)
						else
							SdrCmd <= SdrCmd_wr;			-- "101"(cpu write) / "111"(vdp write)
						end if;
					end if;
				when "011" =>
					SdrCmd <= SdrCmd_xx;
				when others	=>
					null;
			end case;
		end if;
	end process;

	process( memclk )
	begin
		if( memclk'event and memclk = '1' )then
			case ff_sdr_seq is
				when "000" =>
					SdrUdq <= '1';
					SdrLdq <= '1';
				when "010" =>
					if( SdrSta(2) = '1' )then
						if( SdrSta(0) = '0' )then
							SdrUdq <= '0';
							SdrLdq <= '0';
						else
							if( RstSeq(4 downto 3) /= "11" )then
								SdrUdq <= '0';
								SdrLdq <= '0';
							elsif( VideoDLClk = '0' )then
								SdrUdq <= not CpuAdr(0);
								SdrLdq <= CpuAdr(0);
							else
								SdrUdq <= not VdpAdr(16);
								SdrLdq <= VdpAdr(16);
							end if;
						end if;
					end if;
				when "011" =>
					SdrUdq <= '1';
					SdrLdq <= '1';
				when others =>
					null;
			end case;
		end if;
	end process;

	process( memclk )
	begin
		if( memclk'event and memclk = '1' )then
			case ff_sdr_seq is
				when "000" =>
					if( SdrSta(2) = '0' )then
						--	single	CL=2 WT=0(seq) BL=1
						SdrAdr <= "00010" & "0" & "010" & "0" & "000";
					else
						if( RstSeq(4 downto 3) /= "11" )then
							SdrAdr <= ClrAdr(12 downto 0);		-- clear memory (VRAM, MainRAM)
						elsif( VideoDLClk = '0' )then
							SdrAdr <= CpuAdr(13 downto 1);		-- cpu read/write
						else
							SdrAdr <= VdpAdr(12 downto 0);		-- vdp read/write
						end if;
					end if;
				when "010" =>
					SdrAdr(12 downto 9) <= "0010";										-- A10=1 => enable auto precharge
					if( RstSeq(4 downto 2) = "010" )then
						SdrAdr(8 downto 0) <= "11" & "1000" & ClrAdr(15 downto 13);	 	-- clear VRAM(128KB)
					elsif( RstSeq(4 downto 2) = "011" )then
						SdrAdr(8 downto 0) <= "11" & "0000" & ClrAdr(15 downto 13);	 	-- clear ERAM(128KB)
					elsif( RstSeq(4 downto 3) = "10" )then
						SdrAdr(8 downto 0) <= "01" & "0000" & ClrAdr(15 downto 13);	 	-- clear MainRAM(128KB)
					elsif( VideoDLClk = '0' )then
						SdrAdr(8 downto 0) <= CpuAdr(22 downto 14);
					else
						SdrAdr(8 downto 0) <= "11" & "1000" & VdpAdr(15 downto 13);
					end if;
				when others =>
					null;
			end case;
		end if;
	end process;

	process( memclk )
	begin
		if( memclk'event and memclk = '1' )then
			if( ff_sdr_seq = "010" )then
				if( SdrSta(2) = '1' )then
					if( SdrSta(0) = '0' )then
						SdrDat <= (others => 'Z');
					else
						if( RstSeq(4 downto 3) /= "11" )then
							SdrDat <= (others => '0');
						elsif( VideoDLClk = '0' )then
							SdrDat <= dbo & dbo;					-- "101"(cpu write)
						else
							SdrDat <= VrmDbo & VrmDbo;				-- "111"(vdp write)
						end if;
					end if;
				end if;
			else
				SdrDat <= (others => 'Z');
			end if;
		end if;
	end process;

	process( memclk )
	begin
		if( memclk'event and memclk = '1' )then
			if( ff_sdr_seq = "010" )then
				if( RstSeq(4 downto 3) /= "11" )then
					ClrAdr <= (others => '0');
				else
					ClrAdr <= ClrAdr + 1;
				end if;
			end if;
		end if;
	end process;

	process( memclk )
	begin
		if( memclk'event and memclk = '1' )then
			if( ff_sdr_seq = "101" )then
				if( SdrSta(2) = '1' and SdrSta(0) = '0' )then
					if( VideoDLClk = '0' )then
						if( CpuAdr(0) = '0' )then
								RamDbi	<= pMemDat(  7 downto 0 );	-- "100"(cpu read)
						else
								RamDbi	<= pMemDat( 15 downto 8 );	-- "100"(cpu read)
						end if;
					else
						VrmDbi	<= pMemDat( 15 downto 0 );		-- "110"(vdp read)
					end if;
				end if;
			end if;
		end if;
	end process;

	process( memclk )
	begin
		if( memclk'event and memclk = '1' )then
			if( mmcena = '0' )then
				if( ff_sdr_seq = "101" )then
					if( SdrSta(2) = '1' )then
						if( SdrSta(0) = '0' and pVdpInt_n /= '0' )then
							SdPaus <= Paus;
						end if;
					else
						SdPaus <= Paus;
					end if;
				end if;
			end if;
		end if;
	end process;

	process( memclk )
	begin
		if( memclk'event and memclk = '1' )then
			case ff_sdr_seq is
				when "000" =>
					if( VideoDHClk = '1' or RstSeq(4 downto 3) /= "11" )then
						ff_sdr_seq <= "001";
					end if;
				when "001" =>	ff_sdr_seq	<=	"010";
				when "010" =>	ff_sdr_seq	<=	"011";
				when "011" =>	ff_sdr_seq	<=	"100";
				when "100" =>	ff_sdr_seq	<=	"101";
				when "101" =>	ff_sdr_seq	<=	"110";
				when "110" =>	ff_sdr_seq 	<=	"111";
				when others =>
					if( VideoDHClk = '0' or RstSeq(4 downto 3) /= "11" )then
						ff_sdr_seq <= "000";
					end if;
			end case;
		end if;
	end process;

	process( reset, clk21m )
	begin
		if( reset = '1' )then
			RamAck <= '0';
		elsif( clk21m'event and clk21m = '1' )then
			if( RamReq = '0' )then
				RamAck <= '0';
			elsif( VideoDLClk = '0' and VideoDHClk = '1' )then
				RamAck <= '1';
			end if;
		end if;
	end process;

	pMemCke		<= '1';
	pMemCs_n	<= SdrCmd(3);
	pMemRas_n	<= SdrCmd(2);
	pMemCas_n	<= SdrCmd(1);
	pMemWe_n	<= SdrCmd(0);

	pMemUdq		<= SdrUdq;
	pMemLdq		<= SdrLdq;
	pMemBa1		<= '0';
	pMemBa0		<= '0';

	pMemAdr		<= SdrAdr;
	pMemDat		<= SdrDat;


	----------------------------------------------------------------
	-- Reserved ports (USB)
	----------------------------------------------------------------
	pUsbP1		<= 'Z';
	pUsbN1		<= 'Z';
	pUsbP2		<= 'Z';
	pUsbN2		<= 'Z';

	----------------------------------------------------------------
	-- Connect components
	----------------------------------------------------------------
	U00 : pll4x
		port map(
			inclk0	 => pClk21m,				-- 21.48MHz external
			c0		 => clk21m,					-- 21.48MHz internal
			c1		 => memclk,					-- 85.92MHz = 21.48MHz x 4
			e0		 => pMemClk					-- 85.92MHz external
		);

	U01 : t80a
		port map(
			RESET_n		=> pSltRst_n,
			RstKeyLock	=> RstKeyLock,
			swioRESET_n	=> swioRESET_n,
			CLK_n		=> pSltClk,
			WAIT_n		=> pSltWait_n,
			INT_n		=> pSltInt_n,
			NMI_n		=> '1',
			BUSRQ_n		=> BusReq_n,
			M1_n		=> CpuM1_n,
			MREQ_n		=> pSltMerq_n,
			IORQ_n		=> pSltIorq_n,
			RD_n		=> pSltRd_n,
			WR_n		=> pSltWr_n,
			RFSH_n		=> CpuRfsh_n,
			HALT_n		=> open,
			BUSAK_n 	=> open,
			A			=> pSltAdr,
			D			=> pSltDat
		);
		BusReq_n	<= '1';

	U02 : iplrom
		port map(clk21m, adr, RomDbi);

	U03 : megasd
		port map(clk21m, reset, clkena, ErmReq, ErmAck, wrt, adr, ErmDbi, dbo, 
						 ErmRam, ErmWrt, ErmAdr, RamDbi, ErmDbo, 
						 MmcDbi, MmcEna, MmcAct, pSd_Ck, pSd_Dt(3), pSd_Cm, pSd_Dt(0), 
						 EPC_CK, EPC_CS, EPC_OE, EPC_DI, EPC_DO);
		pSd_Dt(2 downto 0) <= (others => 'Z');

	U04 : cyclone_asmiblock
		port map(EPC_CK, EPC_CS, EPC_DI, EPC_OE, EPC_DO);

	U05 : mapper
		port map(clk21m, reset, clkena, MapReq, MapAck, mem, wrt, adr, MapDbi, dbo, 
						 MapRam, MapWrt, MapAdr, RamDbi, MapDbo);

	U06 : eseps2
		port map (clk21m, reset, clkena, Kmap, Caps, Kana, Paus, Scro, Reso, Fkeys,
						pPs2Clk, pPs2Dat, PpiPortC, PpiPortB, CmtScro);

	U07 : rtc
		port map(
			clk21m		=> clk21m	,
			reset		=> reset	,
			clkena		=> w_10hz	,
			req			=> RtcReq	,
			ack			=> open		,
			wrt			=> wrt		,
			adr			=> adr		,
			dbi			=> RtcDbi	,
			dbo			=> dbo
		);

	U08 : kanji
		port map(clk21m, reset, clkena, KanReq, KanAck, wrt, adr, KanDbi, dbo, 
						 KanRom, KanAdr, RamDbi, KanDbo);

	U20 : vdp
		port map(
			clk21m, reset, VdpReq, VdpAck, wrt, adr, VdpDbi, dbo, pVdpInt_n, 
			OeVdp_n, WeVdp_n, VdpAdr, VrmDbi, VrmDbo,
			VideoR, VideoG, VideoB, VideoHS_n, VideoVS_n, VideoCS_n, 
			VideoDHClk, VideoDLClk, open, open, Reso_v,	ntsc_forced
--			osdFkey, osdLocateX, osdLocateY, osdCharCodeIn, osdCharWrReq, osdCharWrAck,
		);

	U21 : vencode
		port map(
			clk21m, reset, VideoR, VideoG, videoB, VideoHS_n, VideoVS_n,
			videoY, videoC, videoV
		);

	U30 : psg
		port map(clk21m, reset, clkena, PsgReq, PsgAck, wrt, adr, PsgDbi, dbo, 
						 pJoyA, pStrA, pJoyB, pStrB, Kana, CmtIn, w_key_mode, PsgAmp);

	U31_1 : megaram
		port map(clk21m, reset, clkena, Scc1Req, Scc1Ack, wrt, adr, Scc1Dbi, dbo, 
						 Scc1Ram, Scc1Wrt, Scc1Adr, RamDbi, Scc1Dbo, Scc1Type, Scc1AmpL, Scc1AmpR);

	Scc1Type <=	"00"	when( Slot1Mode = '0' )else
				"10";

	U31_2 : megaram
		port map(clk21m, reset, clkena, Scc2Req, Scc2Ack, wrt, adr, Scc2Dbi, dbo, 
						 Scc2Ram, Scc2Wrt, Scc2Adr, RamDbi, Scc2Dbo, Slot2Mode, Scc2AmpL, Scc2AmpR);

	U32 : eseopll
		port map(clk21m, reset, clkena, OpllEnaWait, OpllReq, OpllAck, wrt, adr, dbo, OpllAmp);

	OpllEnaWait		<=	'1' when( ff_clksel = '1' or ff_clksel5m_n = '0' )else
						'0';

	--	sound output lowpass filter, sccic
--	process( reset, clk21m )
--	begin
--		if( reset = '1' )then
--			ff_lpf_div <= (others => '0');
--		elsif( clk21m'event and clk21m = '1' )then
--			if( clkena = '1' )then
--				ff_lpf_div <= ff_lpf_div + 1;
--			end if;
--		end if;
--	end process;

	u_interpo: interpo
	generic map (
		msbi	=> DACin'high
	)
	port map (
		clk21m	=> clk21m		,
		reset	=> reset		,
		clkena	=> clkena		,
		idata	=> DACin		,
		odata	=> lpf1_wave	
	);

	--	ローパスフィルタ 
--	w_lpf2ena <= '1' when( ff_lpf_div(         0) = '1'    and clkena = '1' ) else '0';		-- sccic
--	w_lpf3ena <= '1' when( ff_lpf_div(1 downto 0) = "11"   and clkena = '1' ) else '0';
--	w_lpf4ena <= '1' when( ff_lpf_div(2 downto 0) = "111"  and clkena = '1' ) else '0';
--	w_lpf5ena <= '1' when( ff_lpf_div(3 downto 0) = "1111" and clkena = '1' ) else '0';
--
--	u_lpf1: lpf2
--	generic map (
--		msbi	=> DACin'high
--	)
--	port map (
--		clk21m	=> clk21m		,
--		reset	=> reset		,
--		clkena	=> clkena		,
--		idata	=> DACin		,
--		odata	=> lpf1_wave	
--	);

	u_lpf2: lpf2
	generic map (
		msbi	=> DACin'high
	)
	port map (
		clk21m	=> clk21m		,
		reset	=> reset		,
--		clkena	=> w_lpf2ena	,	-- sccic
		clkena	=> clkena		,	-- no sccic
		idata	=> lpf1_wave	,
		odata	=> lpf5_wave	
	);

--	u_lpf3: lpf1
--	generic map (
--		msbi	=> DACin'high
--	)
--	port map (
--		clk21m	=> clk21m		,
--		reset	=> reset		,
--		clkena	=> w_lpf3ena	,
--		idata	=> lpf2_wave	,
--		odata	=> lpf3_wave	
--	);
--
--	u_lpf4: lpf1
--	generic map (
--		msbi	=> DACin'high
--	)
--	port map (
--		clk21m	=> clk21m		,
--		reset	=> reset		,
--		clkena	=> w_lpf4ena	,
--		idata	=> lpf3_wave	,
--		odata	=> lpf4_wave	
--	);
--
--	u_lpf5: lpf1
--	generic map (
--		msbi	=> DACin'high
--	)
--	port map (
--		clk21m	=> clk21m		,
--		reset	=> reset		,
--		clkena	=> w_lpf5ena	,
--		idata	=> lpf4_wave	,
--		odata	=> lpf5_wave	
--	);

	U33: esepwm
		generic map ( DAC_MSBI ) port map (clk21m, reset, lpf5_wave, DACout);

	U34: system_timer
	port map (
		clk21m	=> clk21m		,
		reset	=> reset		,
		req		=> systim_req	,
		ack		=> systim_ack	,
		wrt		=> wrt			,
		adr		=> adr			,
		dbi		=> systim_dbi	,
		dbo		=> dbo			
	);
	
	U35: switched_io_ports
	port map (
		clk21m			=> clk21m		,
		reset			=> reset		,
		req				=> swio_req		,
		ack				=> swio_ack		,
		wrt				=> wrt			,
		adr				=> adr			,
		dbi				=> swio_dbi		,
		dbo				=> dbo			,

		io40			=> io40			,	-- here to reduce LEs
		io41_id212_n	=> io41_id212_n	,	-- here to reduce LEs
		io42_id212_n	=> io42_id212_n	,
		io43_id212_n	=> io43_id212_n	,
		io44_id212_n	=> io44_id212_n	,
		OpllVol			=> OpllVol		,
		SccVol			=> SccVol		,
		PsgVol			=> PsgVol		,
		MstrVol			=> MstrVol		,
		CustomSpeed		=> CustomSpeed	,
		tMegaSD			=> tMegaSD		,
		tPanaRedir		=> tPanaRedir	,	-- here to reduce LEs
		Vga60Ena		=> Vga60Ena		,
		Mapper_req		=> Mapper_req	,	-- here to reduce LEs
		Mapper_ack		=> Mapper_ack	,
		MegaSD_req		=> MegaSD_req	,	-- here to reduce LEs
		MegaSD_ack		=> MegaSD_ack	,
		io41_id008_n	=> io41_id008_n	,
		swioKmap		=> swioKmap		,
		CmtScro			=> CmtScro		,
		swioCmt			=> swioCmt		,
		LightsMode		=> LightsMode	,
		Red_sta			=> Red_sta		,
		LastRst_sta		=> LastRst_sta	,	-- here to reduce LEs
		RstReq_sta		=> RstReq_sta	,	-- here to reduce LEs
		Blink_ena		=> Blink_ena	,
		DefKmap			=> DefKmap		,	-- here to reduce LEs

		ff_dip_req		=> ff_dip_req	,
		ff_dip_ack		=> ff_dip_ack	,	-- here to reduce LEs

		SdPaus			=> SdPaus		,
		Scro			=> Scro			,
		ff_Scro			=> ff_Scro		,
		Reso			=> Reso			,
		ff_Reso			=> ff_Reso		,
		FKeys			=> FKeys		,
		vFKeys			=> vFKeys		,
		LevCtrl			=> LevCtrl		,
		GreenLvEna		=> GreenLvEna	,

		swioRESET_n		=> swioRESET_n	,
		warmRESET		=> warmRESET		
	);

end RTL;
