--
--  graphic123M.vhd
--    Imprementation of Graphic Mode 1,2,3 and Multicolor Mode.
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
-- 12th,August,2006 created by Kunihiko Ohnaka
-- JP: VDP�̃R�A�̎����ƃX�N���[�����[�h�̎����𕪗�����
--
-------------------------------------------------------------------------------
-- Document
--
-- JP: GRAPHIC���[�h1,2,3����� MULTICOLOR���[�h�̃��C��������H�ł��B
--

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use work.vdp_package.all;

entity graphic123M is
  port(
    -- VDP clock ... 21.477MHz
    clk21m  : in std_logic;
    reset   : in std_logic;

    dotState : in std_logic_vector(1 downto 0);
    eightDotState : in std_logic_vector(2 downto 0);
    dotCounterX : in std_logic_vector(8 downto 0);
    dotCounterY : in std_logic_vector(8 downto 0);

    vdpModeMulti: in std_logic;
    vdpModeGraphic1: in std_logic;
    vdpModeGraphic2: in std_logic;
    vdpModeGraphic3: in std_logic;

    -- registers
    VdpR2PtnNameTblBaseAddr : in std_logic_vector(6 downto 0);
    VdpR4PtnGeneTblBaseAddr : in std_logic_vector(5 downto 0);
    VdpR10R3ColorTblBaseAddr : in std_logic_vector(10 downto 0);
    --
    pRamDat : in std_logic_vector(7 downto 0);
    pRamAdr : out std_logic_vector(16 downto 0);

    pColorCode : out std_logic_vector(3 downto 0)
    );
end graphic123M;
architecture rtl of graphic123M is
  signal logicalVramAddrNam : std_logic_vector(16 downto 0);
  signal logicalVramAddrGen : std_logic_vector(16 downto 0);
  signal logicalVramAddrCol : std_logic_vector(16 downto 0);

  signal patternNum : std_logic_vector( 7 downto 0);
  signal prePattern : std_logic_vector( 7 downto 0);
  signal preColor : std_logic_vector( 7 downto 0);
  signal pattern : std_logic_vector( 7 downto 0);
  signal color : std_logic_vector( 7 downto 0);

begin

  -- JP: RAM�� dotState��"10","00"�̎��ɃA�h���X���o����"01"�ŃA�N�Z�X����B
  -- JP: eightDotState�Ō���ƁA
  -- JP:  0-1    Read pattern num.
  -- JP:  1-2    Read pattern
  -- JP:  2-3    Read color.
  -- JP: �ƂȂ�B
  --
  -- JP: ����āA�ȉ��̂悤�ȃ^�C�~���O�ŉ�ʂ̕`����s���B
  --
  -- [�f�[�^���[�h�n]
  --                     |-----------|-----------|-----------|-----------|
  -- eightDotState    0=><====1=====><====2=====><====3=====><====4=====>
  -- dotState         "10"00"01"11"10"00"01"11"10"00"01"11"10"00"01"11"10"
  --                  <ADR0>      <ADR1>      <ADR2>                  <ADRa>
  --                     <PN>        <PT>        <CO>
  --
  --                     |-----------|-----------|-----------|-----------|
  -- eightDotState    4=><====5=====><====6=====><====7=====><====0=====>
  -- dotState         "10"00"01"11"10"00"01"11"10"00"01"11"10"00"01"11"10"
  --                  <ADRa>      <ADRa>      <ADRb>      <ADRc>      <ADR4>
  --  ��ADRa�`c��VDP�R�}���h��X�v���C�g��Y���W�����AVRAM R/W�Ɏg����
  --
  -- [�`��n(4�h�b�g���̂�)]
  --                     |-----------|-----------|-----------|-----------|
  -- eightDotState    7=><====0=====><====1=====><====2=====><====3=====>
  -- dotState         "10"00"01"11"10"00"01"11"10"00"01"11"10"00"01"11"10"
  -- Shift OUT               <D0>                    <D1>
  -- Palette Addr              <D0>        <D0>        <D1>        <D1>
  -- Palette Data                 <D0>        <D0>        <D1>        <D1>
  -- Display Output                  <D0========><D0========><D1=========><D1==
  --

  ----------------------------------------------------------------
  --
  ----------------------------------------------------------------

  -- VRAM address mappings.
  logicalVramAddrNam <=  (VdpR2PtnNameTblBaseAddr & dotCounterY(7 downto 3) & dotCounterX(7 downto 3) );

  logicalVramAddrGen <= (VdpR4PtnGeneTblBaseAddr & patternNum & dotCounterY(2 downto 0)) when vdpModeGraphic1 = '1' else
                        (VdpR4PtnGeneTblBaseAddr(5 downto 2) & dotCounterY(7 downto 6) & patternNum & dotCounterY(2 downto 0) ) and
                        ("1111" & VdpR4PtnGeneTblBaseAddr(1 downto 0) & "11111111" & "111");

  logicalVramAddrCol <= (VdpR4PtnGeneTblBaseAddr & patternNum & dotCounterY(4 downto 2)) when vdpModeMulti = '1' else
                        (VdpR10R3ColorTblBaseAddr & '0' & patternNum( 7 downto 3 )) when  vdpModeGraphic1 = '1' else
                        (VdpR10R3ColorTblBaseAddr(10 downto 7) & dotCounterY(7 downto 6) & patternNum & dotCounterY(2 downto 0)) and
                        ("1111" & VdpR10R3ColorTblBaseAddr(6 downto 0) & "111111" );

  process( clk21m, reset )
  begin
    if(reset = '1' ) then
      patternNum <= (others => '0');
      pattern <= (others => '0');
      prePattern <= (others => '0');
      color <= (others => '0');
      preColor <= (others => '0');
      pRamAdr <= (others => '0');
    elsif (clk21m'event and clk21m = '1') then

      case dotState is
        when "11" =>
          case eightDotState is
            when "000" =>
              -- read pattern name table
              pRamAdr <= logicalVramAddrNam;
            when "001" =>
              -- read pattern Generator table
              pRamAdr <= logicalVramAddrGen;
            when "010" =>
              -- read color table
              -- (or pattern of multi color)
              pRamAdr <= logicalVramAddrCol;
            when others =>
              null;
          end case;
        when "10" =>
          null;
        when "00" =>
          null;
        when "01" =>
          case eightDotState is
            when "001" =>
              -- read pattern name table
              patternNum <= pRamDat;
            when "010" =>
              -- read pattern Generator table
              prePattern <= pRamDat;
            when "011" =>
              -- read color table
              -- (color of multi color)
              preColor <= pRamDat;
            when others =>
              null;
          end case;
        when others => null;
      end case;

      -- Color code decision
      -- JP: "01"��"10"�̃^�C�~���O�ŃJ���[�R�[�h���o�͂��Ă�����΁A
      -- JP: VDP�G���e�B�e�B�̕��Ńp���b�g���f�R�[�h���ĐF���o�͂��Ă����B
      -- JP: "01"��"10"�œ����F���o�͂���Ή�256�h�b�g�ɂȂ�A�Ⴄ�F��
      -- JP: �o�͂���Ή�512�h�b�g�\���ƂȂ�B
      case dotState is
        when "00" =>
          if( eightDotState = "000" ) then
            -- load next 8 dot data
            pattern <= prePattern;
            color <= preColor;
          end if;
        when "01" =>
          -- �p�^�[���ɉ����ăJ���[�R�[�h������
          if( vdpModeMulti = '1' ) then
            if( eightDotState(2) = '0' ) then
              pColorCode <= color(7 downto 4);
            else
              pColorCode <= color(3 downto 0);
            end if;
          elsif( pattern(7) = '1' ) then
            pColorCode <= color(7 downto 4);
          else
            pColorCode <= color(3 downto 0);
          end if;
          -- �p�^�[�����V�t�g
          pattern <= pattern(6 downto 0) & '0';
        when "11" =>
          null;
        when "10" =>
          null;
        when others => null;
      end case;
    end if;
  end process;
end rtl;
