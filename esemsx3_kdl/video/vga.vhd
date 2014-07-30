--
--  vga.vhd
--   VGA up-scan converter.
--
--  Copyright (C) 2006 Kunihiko Ohnaka
--  All rights reserved.
--                                     http://www.ohnaka.jp/ese-vdp/
--
--  �{�\�t�g�E�F�A����і{�\�t�g�E�F�A�Ɋ�Â��č쐬���ꂽ�h�����́A�ȉ��̏�����
--  �������ꍇ�Ɍ���A�ĔЕz����юg�p��������܂��B
--
--  1.�\�[�X�R�[�h�`���ōĔЕz����ꍇ�A��L�̒��쌠�\���A�{�����ꗗ�A����щ��L
--    �Ɛӏ��������̂܂܂̌`�ŕێ����邱�ƁB
--  2.�o�C�i���`���ōĔЕz����ꍇ�A�Еz���ɕt���̃h�L�������g���̎����ɁA��L��
--    ���쌠�\���A�{�����ꗗ�A����щ��L�Ɛӏ������܂߂邱�ƁB
--  3.���ʂɂ�鎖�O�̋��Ȃ��ɁA�{�\�t�g�E�F�A��̔��A����я��ƓI�Ȑ��i�⊈��
--    �Ɏg�p���Ȃ����ƁB
--
--  �{�\�t�g�E�F�A�́A���쌠�҂ɂ���āu����̂܂܁v�񋟂���Ă��܂��B���쌠�҂́A
--  ����ړI�ւ̓K�����̕ۏ؁A���i���̕ۏ؁A�܂�����Ɍ��肳��Ȃ��A�����Ȃ閾��
--  �I�������͈ÖقȕۏؐӔC�������܂���B���쌠�҂́A���R�̂�������킸�A���Q
--  �����̌�����������킸�A���ӔC�̍������_��ł��邩���i�ӔC�ł��邩�i�ߎ�
--  ���̑��́j�s�@�s�ׂł��邩���킸�A���ɂ��̂悤�ȑ��Q����������\����m��
--  ����Ă����Ƃ��Ă��A�{�\�t�g�E�F�A�̎g�p�ɂ���Ĕ��������i��֕i�܂��͑�p�T
--  �[�r�X�̒��B�A�g�p�̑r���A�f�[�^�̑r���A���v�̑r���A�Ɩ��̒��f���܂߁A�܂���
--  ��Ɍ��肳��Ȃ��j���ڑ��Q�A�Ԑڑ��Q�A�����I�ȑ��Q�A���ʑ��Q�A�����I���Q�A��
--  ���͌��ʑ��Q�ɂ��āA��ؐӔC�𕉂�Ȃ����̂Ƃ��܂��B
--
--  Note that above Japanese version license is the formal document.
--  The following translation is only for reference.
--
--  Redistribution and use of this software or any derivative works,
--  are permitted provided that the following conditions are met:
--
--  1. Redistributions of source code must retain the above copyright
--     notice, this list of conditions and the following disclaimer.
--  2. Redistributions in binary form must reproduce the above
--     copyright notice, this list of conditions and the following
--     disclaimer in the documentation and/or other materials
--     provided with the distribution.
--  3. Redistributions may not be sold, nor may they be used in a 
--     commercial product or activity without specific prior written
--     permission.
--
--  THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS 
--  "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT 
--  LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS
--  FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE
--  COPYRIGHT OWNER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT,
--  INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING,
--  BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
--  LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER 
--  CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT
--  LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN
--  ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE
--  POSSIBILITY OF SUCH DAMAGE.
--
-------------------------------------------------------------------------------
-- Memo
--   Japanese comment lines are starts with "JP:".
--   JP: ���{��̃R�����g�s�� JP:�𓪂ɕt���鎖�ɂ���
--
-------------------------------------------------------------------------------
-- Revision History
--
-- 29th,October,2006 modified by Kunihiko Ohnaka
--   - Insert the license text.
--   - Add the document part below.
--
-- ?th,August,2006 modified by Kunihiko Ohnaka
--   - Move the equalization pulse generator from
--     vdp.vhd.
--
-- 20th,August,2006 modified by Kunihiko Ohnaka
--  - Change field mapping algorithm when interlace
--    mode is enabled.
--        even field  -> even line (odd  line is blacK)
--        odd  field  -> odd line  (even line is blacK)
--
-- 13th,October,2003 created by Kunihiko Ohnaka
-- JP: VDP�̃R�A�̎����ƕ\���f�o�C�X�ւ̏o�͂�ʃ\�[�X�ɂ����D
--
-------------------------------------------------------------------------------
-- Document
--
-- JP: ESE-VDP�R�A(vdp.vhd)�����������r�f�I�M�����AVGA�^�C�~���O��
-- JP: �ϊ�����A�b�v�X�L�����R���o�[�^�ł��B
-- JP: NTSC�͐����������g����15.7KHz�A�����������g����60Hz�ł����A
-- JP: VGA�̐����������g����31.5KHz�A�����������g����60Hz�ł���A
-- JP: ���C�����������قڔ{�ɂȂ����悤�ȃ^�C�~���O�ɂȂ�܂��B
-- JP: �����ŁAvdp�� ntsc���[�h�œ������A�e���C����{�̑��x��
-- JP: ��x�`�悷�邱�ƂŃX�L�����R���o�[�g���������Ă��܂��B
--

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use work.vdp_package.all;

entity vga is
  port(
    -- VDP clock ... 21.477MHz
    clk21m  : in std_logic;
    reset   : in std_logic;

    -- Video Input
    videoRin : in std_logic_vector( 5 downto 0);
    videoGin : in std_logic_vector( 5 downto 0);
    videoBin : in std_logic_vector( 5 downto 0);
    videoHSin_n : in std_logic;
    videoVSin_n : in std_logic;
    hCounterIn : in std_logic_vector(10 downto 0);
    vCounterIn : in std_logic_vector(10 downto 0);
    interlaceMode : in std_logic;
    
    -- Video Output
    videoRout : out std_logic_vector( 5 downto 0);
    videoGout : out std_logic_vector( 5 downto 0);
    videoBout : out std_logic_vector( 5 downto 0);
    videoHSout_n : out std_logic;
    videoVSout_n : out std_logic
    );
end vga;

architecture rtl of vga is
  -- video output enable
  signal videoOutX : std_logic;
--  signal videoOutY : std_logic;

  -- double buffer signal
  signal xPositionW : std_logic_vector(9 downto 0);
  signal xPositionR : std_logic_vector(9 downto 0);
  signal evenOdd    : std_logic;
  signal we_buf     : std_logic;
  signal dataRout   : std_logic_vector(5 downto 0);
  signal dataGout   : std_logic_vector(5 downto 0);
  signal dataBout   : std_logic_vector(5 downto 0);

  -- DISP_START_X + DISP_WIDTH < CLOCKS_PER_LINE/2 = 684
  constant DISP_WIDTH : integer := 562;  -- 30 + 512 + 20
  constant DISP_START_X : integer := 120;
begin

  videoRout <= dataRout when videoOutX = '1' else (others => '0');
  videoGout <= dataGout when videoOutX = '1' else (others => '0');
  videoBout <= dataBout when videoOutX = '1' else (others => '0');

  dbuf : doublebuf port map(clk21m, xPositionW, xPositionR, evenOdd, we_buf,
                            videoRin, videoGin, videoBin,
                            dataRout, dataGout, dataBout);

  xPositionW <= hCounterIn(10 downto 1) - (CLOCKS_PER_LINE/2 - DISP_WIDTH - 10);
  evenOdd <= vCounterIn(1);
  we_buf <= '1';

  process( clk21m, reset )
  begin
    if (reset = '1') then
      videoHSout_n <= '1';
      videoVSout_n <= '1';
      videoOutX <= '0';
      xPositionR <= (others => '0');
    elsif (clk21m'event and clk21m = '1') then

      -- Generate V-SYNC signal.
      -- The videoVSin_n signal is not used.
      if( interlaceMode = '0' ) then
        if( (vCounterIn = 3*2) or (vCounterIn = 524+3*2) )then
          videoVSout_n <= '0';
        elsif( (vCounterIn = 6*2) or (vCounterIn = 524+6*2) ) then
          videoVSout_n <= '1';
        end if;
      else
        if( (vCounterIn = 3*2) or (vCounterIn = 525+3*2) )then
          videoVSout_n <= '0';
        elsif( (vCounterIn = 6*2) or (vCounterIn = 525+6*2) ) then
          videoVSout_n <= '1';
        end if;
      end if;

      -- Generate H-SYNC signal.
      -- The videoHSin_n signal is not used.
      if( (hCounterIn = 0) or (hCounterIn = (CLOCKS_PER_LINE/2)) ) then
        videoHSout_n <= '0';
      elsif( (hCounterIn = 40) or (hCounterIn = (CLOCKS_PER_LINE/2) + 40) ) then
        videoHSout_n <= '1';
      end if;

      -- Generate data read timing.
      if( (hCounterIn = DISP_START_X) or
          (hCounterIn = DISP_START_X + (CLOCKS_PER_LINE/2)) ) then
        xPositionR <= (others => '0');
      else
        xPositionR <= xPositionR + 1;
      end if;

      -- Generate video output timing.
      if( (hCounterIn = DISP_START_X) or
          ((hCounterIn = DISP_START_X + (CLOCKS_PER_LINE/2)) and interlaceMode = '0') ) then
        videoOutX <= '1';
      elsif( (hCounterIn = DISP_START_X+DISP_WIDTH) or
             (hCounterIn = DISP_START_X+DISP_WIDTH + (CLOCKS_PER_LINE/2)) ) then
        videoOutX <= '0';
      end if;
      
    end if;

  end process;
end rtl;




