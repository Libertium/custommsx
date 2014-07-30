--
--  graphic4567.vhd
--    Imprementation of Graphic Mode 4,5,6 and 7.
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
-- JP: GRAPHIC���[�h4,5,6,7�̃��C��������H�ł��B
--

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use work.vdp_package.all;

entity graphic4567 is
  port(
    -- VDP clock ... 21.477MHz
    clk21m  : in std_logic;
    reset   : in std_logic;

    dotState : in std_logic_vector(1 downto 0);
    eightDotState : in std_logic_vector(2 downto 0);
    dotCounterX : in std_logic_vector(8 downto 0);
    dotCounterY : in std_logic_vector(8 downto 0);

    vdpModeGraphic4: in std_logic;
    vdpModeGraphic5: in std_logic;
    vdpModeGraphic6: in std_logic;
    vdpModeGraphic7: in std_logic;

    -- registers
    VdpR2PtnNameTblBaseAddr : in std_logic_vector(6 downto 0);

    --
    pRamDat     : in std_logic_vector(7 downto 0);
    pRamDatPair : in std_logic_vector(7 downto 0);
    pRamAdr     : out std_logic_vector(16 downto 0);

    pColorCode : out std_logic_vector(7 downto 0)
    );
end graphic4567;
architecture rtl of graphic4567 is
  signal logicalVramAddrG45 : std_logic_vector(16 downto 0);
  signal logicalVramAddrG67 : std_logic_vector(16 downto 0);
  signal localDotCounterX : std_logic_vector(8 downto 0);
  signal latchedPtnNameTblBaseAddr : std_logic_vector(6 downto 0);

  signal fifoAddr : std_logic_vector( 7 downto 0);
  signal fifoAddr_in : std_logic_vector( 7 downto 0);
  signal fifoAddr_out : std_logic_vector( 7 downto 0);
  signal fifoWe : std_logic;
  signal fifoIn : std_logic;
  signal fifoData_in : std_logic_vector( 7 downto 0);
  signal fifoData_out : std_logic_vector( 7 downto 0);

  signal colorData : std_logic_vector(7 downto 0);
begin

  -- JP: RAM�� dotState��"10","00"�̎��ɃA�h���X���o����"01"�ŃA�N�Z�X����B
  -- JP: �܂��A"10"�̃^�C�~���O�ł�A16�̈قȂ�y�A�ɂȂ�o�C�g��ǂݏo�������ł���B
  -- JP: (���@��VDP��DRAM�C���^�[���[�u�ɑ����BGRAPHIC6,7�ł����g��Ȃ��B����TEXT2����?)
  -- JP: ���@�ł�8�h�b�g���̃f�[�^��4�h�b�g���̎��ԂŃo�[�X�g�ň�C�ɓǂ݁A
  -- JP: �c���4�h�b�g�̎��Ԃ�VRAM R/W�� VDP�R�}���h�����s���Ă���B
  -- JP: ����VDP�ł����l�ɁA8�h�b�g�̍ŏ���4�h�b�g���ɕ`��p�̃f�[�^��ǂ݁A
  -- JP: �c���4�h�b�g�̊��Ԃ�VRAM R/W�� VDP�R�}���h�����s����B
  --
  -- JP: ����āA�ȉ��̂悤�ȃ^�C�~���O�ŉ�ʂ̕`����s�����B
  --
  -- [�f�[�^���[�h�n]
  --                     |-----------|-----------|-----------|-----------|
  -- eightDotState    0=><====1=====><====2=====><====3=====><====4=====>
  -- dotState         "10"00"01"11"10"00"01"11"10"00"01"11"10"00"01"11"10"
  --                  <ADR0>      <ADR1>      <ADR2>      <ADR3>      <ADRa>
  --                     <D0>  <P0>  <D1>  <P1>  <D2>  <P2>  <D3>  <P3>
  -- FIFO IN(G4,G5)         <D0>        <D1>        <D2>        <D3>
  -- FIFO IN(G6,G7)         <D0>  <P0>  <D1>  <P1>  <D2>  <P2>  <D3>  <P3>
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
  -- (GRAPHIC4)
  -- FIFO OUT               <D0>                    <D1>
  -- Palette Addr              <D0>        <D0>        <D1>        <D1>
  -- Palette Data                 <D0>        <D0>        <D1>        <D1>
  -- Display Output                  <D0========><D0========><D1=========><D1==
  -- (GRAPHIC5)
  -- FIFO OUT               <D0>                    <D1>
  -- Palette Addr              <D0>  <D0>  <D0>  <D0>  <D1>  <D1>  <D1>  <D1>
  -- Palette Data                 <D0>  <D0>  <D0>  <D0>  <D1>  <D1>  <D1>  <D1>
  -- Display Output                  <D0==><D0==><D0==><D0==><D1==><D1==><D1==><D1==>
  -- (GRAPHIC6)
  -- FIFO OUT               <D0>        <P0>        <D1>        <P1>
  -- Palette Addr              <D0>  <D0>  <P0>  <P0>  <D1>  <D1>  <P1>  <P1>
  -- Palette Data                 <D0>  <D0>  <P0>  <P0>  <D1>  <D1>  <P1>  <P1>
  -- Display Output                  <D0==><D0==><P0==><P0==><D1==><D1==><P1==><P1==>
  -- (GRAPHIC7)
  -- FIFO OUT               <D0>        <P0>        <D1>        <P1>
  -- Direct Color              <D0===>     <P0===>     <D1===>     <P1===>
  -- Display Output                  <D0========><P0========><D1=========><P1==
  --

  ----------------------------------------------------------------
  -- FIFO and control signals
  ----------------------------------------------------------------
  fifoAddr <= fifoAddr_in when (fifoIn = '1') else
              fifoAddr_out;
  fifoWe   <= '1' when fifoIn = '1' else '0';
  fifoData_in <= pRamDat when (dotState = "00") or (dotState = "01") else
                 pRamDatPair;

  fifoMem : ram port map(fifoAddr, clk21m, fifoWe, fifoData_in, fifoData_out);

  ----------------------------------------------------------------
  --
  ----------------------------------------------------------------

  -- VRAM address mappings.
  logicalVramAddrG45 <=  (latchedPtnNameTblBaseAddr(6 downto 0) & "1111111111") and
                         ("11" & dotCounterY(7 downto 0) & localDotCounterX(7 downto 1));
  logicalVramAddrG67 <=  (latchedPtnNameTblBaseAddr(5 downto 0) & "11111111111") and
                         ("1" & dotCounterY(7 downto 0) & localDotCounterX(7 downto 0));

  process( clk21m, reset )
  begin
    if(reset = '1' ) then
      fifoAddr_in <= (others => '0');
      fifoAddr_out <= (others => '0');
      fifoIn <= '0';
      pRamAdr <= (others => '0');
      latchedPtnNameTblBaseAddr <= (others => '0');
      localDotCounterX <= (others => '0');
    elsif (clk21m'event and clk21m = '1') then


      case dotState is
        when "00" =>
          if( eightDotState = "000" ) then
            localDotCounterX <= dotCounterX(8 downto 3) & "000";
            latchedPtnNameTblBaseAddr <= vdpR2PtnNameTblBaseAddr;
            fifoIn <= '0';
            if( dotCounterX = 0 ) then
              fifoAddr_in <= (others => '0');
            end if;
          elsif( (eightDotState = "001") or
                 (eightDotState = "010") or
                 (eightDotState = "011") or
                 (eightDotState = "100") ) then
            fifoIn <= '1';
            -- �{���œǂݏo���̂ŁA2��������
            localDotCounterX <= localDotCounterX + 2;
          end if;
        when "01" =>
          -- �O�̃X�e�[�g��fifoIn = '1'���o�͂�����A����(���̎��̃N���b�N�G�b�W)��
          -- FIFO�Ƀf�[�^����荞�܂��
          if( fifoIn = '1' ) then
              fifoIn <= '0';
              fifoAddr_in <= fifoAddr_in + 1;
          end if;
        when "11" =>
          if( ((vdpModeGraphic6 = '1') or (vdpModeGraphic7 = '1')) and
              ((eightDotState = "001") or
               (eightDotState = "010") or
               (eightDotState = "011") or
               (eightDotState = "100")) ) then
            -- GRAPHIC6,7�̎��̓y�A�f�[�^���g��
            fifoIn <= '1';
          end if;
          -- ���̃f�[�^�̃A�h���X
          if( (vdpModeGraphic4 = '1') or (vdpModeGraphic5 = '1') ) then
            pRamAdr <= logicalVramAddrG45(16 downto 0);
          else
            pRamAdr <= logicalVramAddrG67(0) & logicalVramAddrG67(16 downto 1);
          end if;
        when "10" =>
          -- JP: �O�̃X�e�[�g��fifoIn = '1'���o�͂�����A����(���̎��̃N���b�N�G�b�W)��
          -- JP: FIFO�Ƀf�[�^����荞�܂��
          -- JP: �����Ŏ�荞�܂��f�[�^�̓y�A�f�[�^
          if( fifoIn = '1' ) then
            fifoIn <= '0';
            fifoAddr_in <= fifoAddr_in + 1;
          end if;
        when others =>
          null;
      end case;

      -- Color code decision
      -- JP: "01"��"10"�̃^�C�~���O�ł����[�R�[�h���o�͂��Ă�����΁A
      -- JP: VDP�G���e�B�e�B�̕��Ńp���b�g���f�R�[�h���ĐF���o�͂��Ă����B
      -- JP: "01"��"10"�œ����F���o�͂���Ή�256�h�b�g�ɂȂ�A�Ⴄ�F��
      -- JP: �o�͂���Ή�512�h�b�g�\���ƂȂ�B
      case dotState is
        when "00" =>
          null;
        when "01" =>
          -- JP: ������FIFO�̃f�[�^�o�͂���荞�݁A�ŏ��̃h�b�g�̃J���[�R�[�h������
          if( (vdpModeGraphic4 ='1') or (vdpModeGraphic5 ='1') ) then
            -- JP: GRAPHIC5�͍��𑜓x���[�h�����A���̏�����vdp�G���e�B�e�B�̂ق���
            -- JP: �����Ȃ��Ă���̂ŁA�����ł̓����GRAPHIC4�ƑS�������ŗǂ��B
            if( eightDotState(0) = '0' ) then
              colorData <= fifoData_out;
              fifoAddr_out <= fifoAddr_out + 1;
              pColorCode(7 downto 4) <= (others => '0');
              pColorCode(3 downto 0) <= fifoData_out(7 downto 4);
            else
              pColorCode(7 downto 4) <= (others => '0');
              pColorCode(3 downto 0) <= colorData(3 downto 0);
            end if;
          elsif( vdpModeGraphic6 ='1' ) then
            colorData <= fifoData_out;
            fifoAddr_out <= fifoAddr_out + 1;
            pColorCode(7 downto 4) <= (others => '0');
            pColorCode(3 downto 0) <= fifoData_out(7 downto 4);
          else
            pColorCode <= fifoData_out;
            fifoAddr_out <= fifoAddr_out + 1;
          end if;
        when "11" =>
          null;
        when "10" =>
          -- High resolution mode .
          if( vdpModeGraphic6 = '1' ) then
            pColorCode(7 downto 4) <= (others => '0');
            pColorCode(3 downto 0) <= colorData(3 downto 0);
          end if;

          -- fifo read address reset
          -- (Note: dotCounterX(preDotCounter_x) will be count up at "11")
          if( dotCounterX = X"08") then
            fifoAddr_out <= (others => '0');
          end if;
        when others => null;
      end case;

    end if;
  end process;
end rtl;
