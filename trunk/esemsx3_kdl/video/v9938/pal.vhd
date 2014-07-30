--
--  pal.vhd
--   PAL sync signal generator.
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
-- 16th,September,2006 created by Kunihiko Ohnaka
--   - Start PAL mode implementation.
--
-------------------------------------------------------------------------------
-- Document
--
-- JP: ESE-VDP�R�A(vdp.vhd)�����������r�f�I�M�����APAL��
-- JP: �^�C�~���O�ɍ����������M������щf���M���ɕϊ����܂��B
-- JP: ESE-VDP�R�A��PAL���[�h���� PAL�̃^�C�~���O�ŉf��
-- JP: �M���␂�������M���𐶐����邽�߁A�{���W���[���ł�
-- JP: ���������M���ɓ����p���X��}�����鏈���������s����
-- JP: ���܂��B
--

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use work.vdp_package.all;

entity pal is
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
end pal;

architecture rtl of pal is
-- sync state register
  type typsstate is (sstate_A, sstate_B, sstate_C, sstate_D);
  signal sstate : typsstate;

  signal HS_n : std_logic;
begin

  process( clk21m, reset )
  begin
    if (reset = '1') then
      sstate <= sstate_A;
    elsif (clk21m'event and clk21m = '1') then
      if( (vCounterIn = 0) or
          (vCounterIn = 12) or
          ((vCounterIn = 626) and interlaceMode = '0') or
          ((vCounterIn = 625) and interlaceMode = '1') or
          ((vCounterIn = 626 + 12) and interlaceMode = '0') or
          ((vCounterIn = 625 + 12) and interlaceMode = '1') )then
        sstate <= sstate_A;
      elsif( (vCounterIn = 6) or
             ((vCounterIn = 626+6) and interlaceMode = '0') or
             ((vCounterIn = 625+6) and interlaceMode = '1') )then
        sstate <= sstate_B;
      elsif( (vCounterIn = 18) or
             ((vCounterIn = 626+18) and interlaceMode = '0') or
             ((vCounterIn = 625+18) and interlaceMode = '1') )then
        sstate <= sstate_C;
      end if;

      -- generate H sync pulse
      if( sstate = sstate_A ) then
        if( (hCounterIn = 1) or (hCounterIn = CLOCKS_PER_LINE/2+1) ) then
          HS_n <= '0';             -- pulse on
        elsif( (hCounterIn = 51) or (hCounterIn = CLOCKS_PER_LINE/2+51) ) then
          HS_n <= '1';             -- pulse off
        end if;
      elsif( sstate = sstate_B ) then
        if( (hCounterIn = CLOCKS_PER_LINE  -100+1) or
            (hCounterIn = CLOCKS_PER_LINE/2-100+1) ) then
          HS_n <= '0';             -- pulse on
        elsif( (hCounterIn =                   1) or
               (hCounterIn = CLOCKS_PER_LINE/2+1) ) then
          HS_n <= '1';             -- pulse off
        end if;
      elsif( sstate = sstate_C ) then
        if( hCounterIn = 1 ) then
          HS_n <= '0';             -- pulse on
        elsif( hCounterIn = 101 ) then
          HS_n <= '1';             -- pulse off
        end if;
      end if;

    end if;
  end process;

  videoHSout_n <= HS_n;
  videoVSout_n <= videoVSin_n;

  videoRout <= videoRin;
  videoGout <= videoGin;
  videoBout <= videoBin;

end rtl;



