--
--  osd.vhd
--   On-Screen-Display module.
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
-------------------------------------------------------------------------------
-- Document
--
-- JP: �⏕�I�ȏ���\������ׂ�On-Screen-Display���W���[���ł��B
-- JP: �{����VDP�ɂ͑��݂��܂��񂪁A�f�o�b�O�ړI��ESE-VDP�⑼��
-- JP: ���W���[���̓�����Ԃ����o�I�Ɋm�F���邽�߂ɗp�ӂ��Ă��܂��B
--

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use ieee.std_logic_arith.all;
use work.vdp_package.all;

entity osd is
  port(
    -- VDP clock ... 21.477MHz
    clk21m  : in std_logic;
    reset   : in std_logic;

    -- video timing
    h_counter   : in std_logic_vector(10 downto 0);
    dotCounterY : in std_logic_vector( 7 downto 0);

    -- pattern name table access
    locateX    : in std_logic_vector( 5 downto 0);
    locateY    : in std_logic_vector( 4 downto 0);
    charCodeIn : in std_logic_vector( 7 downto 0);
    charWrReq  : in std_logic;
    charWrAck  : out std_logic;
      
    -- Video Output
    videoR     : out std_logic_vector( 3 downto 0);
    videoG     : out std_logic_vector( 3 downto 0);
    videoB     : out std_logic_vector( 3 downto 0)
    );
end osd;

architecture rtl of osd is
  component font0406 is
    port (
      adr : in std_logic_vector(10 downto 0);
      clk : in std_logic;
      dbi : out std_logic_vector(3 downto 0)
      );
  end component;
  component osdnametable is
    port (
      address  : in  std_logic_vector(10 downto 0);
      inclock  : in  std_logic;
      we       : in  std_logic;
      data     : in  std_logic_vector(7 downto 0);
      q        : out std_logic_vector(7 downto 0)
      );
  end component;

  constant WINDOW_START_X : integer := 264;
  constant WINDOW_START_Y : integer := 0;

  signal charCode    : std_logic_vector(7 downto 0);
  signal fontAddr    : std_logic_vector(10 downto 0);
  signal patternOut  : std_logic_vector(3 downto 0);

  signal window   : std_logic;
  signal window_x : std_logic;
  signal window_y : std_logic;

  -- JP: OSD���̕����̍��W
  signal charLocateX : std_logic_vector(6 downto 0);
  signal charLocateY : std_logic_vector(4 downto 0);
  -- JP: �������̍��W
  signal charX : std_logic_vector(1 downto 0);
  signal charY : std_logic_vector(2 downto 0);

  signal iCharWrAck : std_logic;
  
  signal iVideoR     : std_logic_vector( 3 downto 0);
  signal iVideoG     : std_logic_vector( 3 downto 0);
  signal iVideoB     : std_logic_vector( 3 downto 0);

  signal pattern : std_logic_vector(3 downto 0);

  -- pattern name table signals
  signal patternNameTableAddr    : std_logic_vector(10 downto 0);
  signal patternNameTableWe      : std_logic;
  signal patternNameTableInData  : std_logic_vector(7 downto 0);
  signal patternNameTableOutData : std_logic_vector(7 downto 0);
begin

  charWrAck <= iCharWrAck;

  U1 : font0406 port map ( fontAddr, clk21m, patternOut );

  -- pattern name table
  U2 : osdnametable port map ( patternNameTableAddr, clk21m, patternNameTableWe, patternNameTableInData, patternNameTableOutData );

  process( clk21m, reset )
  begin
    if (reset = '1') then
      charCode    <= (others => '0');
      fontAddr    <= (others => '0');
      window_x    <= '0';
      window_y    <= '0';
      charLocateX <= (others => '0');
      charLocateY <= (others => '0');
      charX       <= (others => '0');
      charY       <= (others => '0');
      iVideoR     <= (others => '0');
      iVideoG     <= (others => '0');
      iVideoB     <= (others => '0');
      pattern     <= (others => '0');
      iCharWrAck  <= '0';
    elsif (clk21m'event and clk21m = '1') then

      case h_counter(1 downto 0) is
        when "00" =>
          patternNameTableWe <= '0';
          patternNameTableAddr <= charLocateY & charLocateX( 5 downto 0);
         
          if( h_counter(10 downto 2) = WINDOW_START_X/4 ) then
            charLocateX <= (others => '0');
            charX <= conv_std_logic_vector(1, charX'length);
            if( dotCounterY = WINDOW_START_Y ) then
              charLocateY <= (others => '0');
              charY <= (others => '0');
              window_y <= '1';
            elsif( dotCounterY = WINDOW_START_Y+6*32 ) then
              window_y <= '0';
            else
              if( charY = 5) then
                charLocateY <= charLocateY + 1;
                charY <= (others => '0');
              else
                charY <= charY + 1;
              end if;
            end if;
          else
            -- JP: �J�E���^���������
            if( charLocateX(6) = '1' ) then
              window_x <= '0';
            end if;
          end if;
        when "01" =>
          null;
        when "10" =>
          case charX is
            when "00" =>
              pattern <= patternOut;
              charX <= (others => '0');
              charCode <= charCode + 1;
            when "11" =>
              fontAddr <= patternNameTableOutData & charY;
              if( charLocateX(6) = '0' ) then
                charLocateX <= charLocateX + 1;
              end if;
              if( charLocateX = 0 ) then
                window_x <= '1';
              end if;
            when others => null;
          end case;
        when "11" =>
          if( pattern(3) = '1') then
            iVideoR <= "1111";
            iVideoG <= "1111";
            iVideoB <= "1111";
          else
            iVideoR <= "0000";
            iVideoG <= "0000";
            iVideoB <= "0000";
          end if;
          pattern <= pattern(2 downto 0) & '0';
          charX <= charX + 1;
 
          -- pattern name table write address
          if( charWrReq /= iCharWrAck ) then
            patternNameTableWe <= '1';
            patternNameTableAddr <= locateY & locateX;
            patternNameTableInData  <= charCodeIn;
            iCharWrAck <= not iCharWrAck;
          end if;
        when others => null;
      end case;

    end if;
  end process;

  window <= window_x and window_y;
  videoR <= iVideoR when window = '1' else (others => '0');
  videoG <= iVideoG when window = '1' else (others => '0');
  videoB <= iVideoB when window = '1' else (others => '0');
  
end rtl;
