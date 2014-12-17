--
--  sprite.vhd
--    Sprite module.
--
--  Copyright (C) 2004-2006 Kunihiko Ohnaka,
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
-- 26th,August,2006 modified by Kunihiko Ohnaka
--   - latch the base addresses every eight dot cycle
--     (DRAM RAS/CAS access emulation)
--
-- 20th,August,2006 modified by Kunihiko Ohnaka
--   - Change the drawing algorithm.
--   - Add sprite collision checking function.
--   - Add sprite over-mapped checking function.
--   - Many bugs are fixed, and it works fine.
--   - (first release virsion)
--
-- 17th,August,2004 created by Kunihiko Ohnaka
--   - Start new sprite module implementing.
--     * This module uses Block RAMs so that shrink the
--       circuit size.
--     * Separate sprite module from vdp.vhd.
--
-------------------------------------------------------------------------------
-- Document
--
-- JP: ���̎����ł�BLOCKRAM���g���A�����SLICE��ߖ񂷂�̂��_���B
-- JP: ���̎������g��Ȃ���Ԃł� vdp.vhd���R���p�C����������
-- JP: SLICE�g�p����1900�O��B
-- JP: 2006/8/16�B���̃X�v���C�g���g��Ȃ��ŐV��(Cyclone)�ł́A
-- JP:            2726LC������.
-- JP: 2006/8/19�B���̃X�v���C�g���g�����Ƃ���A2278LC�܂Ō����B
-- JP:
-- JP: [�p��]
-- JP: �E���[�J���v���[���ԍ�
-- JP:   ���郉�C����ɕ���ł���X�v���C�g(�v���[��)�����𔲂��o����
-- JP:   �X�v���C�g�v���[���ԍ����ɕ��ׂ����̏��ʁB
-- JP:   �Ⴆ�΂��郉�C���ɃX�v���C�g�v���[��#1,#4,#5�����݂���ꍇ�A
-- JP:   ���ꂼ��̃X�v���C�g�̃��[�J���v���[���ԍ���#0,#1,#2�ƂȂ�B
-- JP:   �X�v���C�g���[�h2�ł������ɍő�8���������΂Ȃ��̂ŁA
-- JP:   ���[�J���v���[���ԍ��͍ő��#7�ƂȂ�B
-- JP:
-- JP: �E��ʕ`��ш�
-- JP:    VDP�̎��@��8�h�b�g(32�N���b�N)�ŘA���A�h���X��̃f�[�^4�o�C�g
-- JP:    (GRAPHIC6,7�ł�RAM�̃C���^�[���[�u�A�N�Z�X�ɂ��o�C�g)
-- JP:    �̃��[�h�ɉ����A�����_���A�h���X�ւ�2�T�C�N��(2�o�C�g)��
-- JP:    �A�N�Z�X�����[
-- JP:    ������DRAM�A�N�Z�X�T�C�N���Ɉȉ��̂悤�ɖ��O��t����B
-- JP:     * ��ʕ`�惊�[�h�T�C�N��
-- JP:     * �X�v���C�gY���W�����T�C�N��
-- JP:     * �����_���A�N�Z�X�T�C�N��
-- JP:
-- JP: ������VDP�ł�VRAM�A�N�Z�X�T�C�N��
-- JP:    ����VDP�ł͋�����DRAM�ł͂Ȃ���荂���ȃ��������g�p���Ă���B
-- JP:    ���̂��߁A�S�N���b�N��1��m���Ƀ����_���A�N�Z�X�����s�ł���
-- JP:    �������������Ă��鎖��O��Ƃ��ăR�[�f�B���O���܂��B
-- JP:    �܂��ACyclone�Ŏ���MSX�ł́A16�r�b�g����SDRAM��p���Ă���
-- JP:    ���߁A���̃A�N�Z�X�ŘA������16�r�b�g�̃f�[�^��ǂގ����\
-- JP:    �ł��B
-- JP:    ����VDP�ł́AD0�`D7�̉���8�r�b�g��VRAM�̑O��64K�o�C�g�A
-- JP:    D8�`D15�̏��8�r�b�g���㔼64K�o�C�g�Ƀ}�b�s���O���Ă��܂��B
-- JP:    ���̂悤�ȕϑ��I�Ȋ��蓖�Ă�����̂́A���@��VDP�̃�����
-- JP:    �}�b�v���܂˂邽�߂ł��B���ہA4�N���b�N��2�o�C�g�̃�������
-- JP:    �ǂݏo���ш悪�K�v�ɂȂ�̂�GRAPHIC6,7�̃��[�h�����ł��B
-- JP:    ���@��VDP�́AGRAPHIC6,7�ł̓������̃C���^�[���[�u��p���A
-- JP:    (GRAPHIC7�ɂ�����)�����h�b�g��VRAM�̑O��64K�o�C�g��
-- JP:    ��肠�āA��h�b�g���㔼64K�o�C�g�Ɋ��蓖�ĂĂ��܂��B
-- JP:    ���̂��߁A����VDP�ł��O��64K�ƌ㔼64K�̓���A�h���X���
-- JP:    �f�[�^���P�T�C�N��(4�N���b�N)�œǂݏo����K�v������̂�
-- JP:    ���̂悤�ȃ}�b�s���O�ɂȂ��Ă��܂��B
-- JP:    �P���Ɍ����΁ASDRAM��16�r�b�g�A�N�Z�X���A���@��DRAM��
-- JP:    �C���^�[���[�u�A�N�Z�X�Ɍ����ĂĂ���Ƃ������Ƃł��B
-- JP:
-- JP:    ���낢��Ȍ��ۂ���AVDP�̓�����8�h�b�g�T�C�N���œ����Ă����
-- JP:    ��������Ă��܂��B8�h�b�g�A�܂�32�N���b�N�̂ǂ�����������
-- JP:    �̑ш悩�琄������ƁA�ȉ��̂悤�ɂȂ�܂��B
-- JP:
-- JP:   �@�@�h�b�g�@�F<=0=><=1=><=2=><=3=><=4=><=5=><=6=><=7=>
-- JP:   �ʏ�A�N�Z�X�F A0   A1   A2   A3   A4  (A5)  A6  (A7)
-- JP: �C���^�[���[�u�F B0   B1   B2   B3
-- JP:
-- JP:    - �`�撆
-- JP:   �@�@�EA0�`A3 (B0�`B3)
-- JP:        ��ʕ`��̂��߂Ɏg�p�BB0�`B3�̓C���^�[���[�u�œ�����
-- JP:        �ǂݏo����f�[�^�ŁAGRAPHIC6,7�ł����g��Ȃ��B
-- JP:   �@�@�EA4     �X�v���C�gY���W����
-- JP:   �@�@�EA6     VRAM R/W or VDP�R�}���h (2��Ɉ�񂸂A���݂Ɋ��蓖�Ă�)
-- JP:
-- JP:     - ��`�撆(�X�v���C�g������)
-- JP:    �@�@�EA0     �X�v���C�gX���W���[�h
-- JP:    �@�@�EA1     �X�v���C�g�p�^�[���ԍ����[�h
-- JP:    �@�@�EA2     �X�v���C�g�p�^�[�������[�h
-- JP:    �@�@�EA3     �X�v���C�g�p�^�[���E���[�h
-- JP:    �@�@�EA4     �X�v���C�g�J���[���[�h
-- JP:    �@�@�EA6     VRAM R/W or VDP�R�}���h (2��Ɉ�񂸂A���݂Ɋ��蓖�Ă�)
-- JP:
-- JP:   A5��A7�̃X���b�g�͎��ۂɂ͎g�p���邱�Ƃ��ł���̂ł����A
-- JP:   ������g���Ă��܂��Ǝ��@�����ш悪�����Ă��܂��̂ŁA
-- JP:   �����Ďg�킸�Ɏc���Ă��܂��B
-- JP:   �܂��A��`�撆�̃T�C�N���́A���@�Ƃ͈قȂ�܂��B���@�ł�
-- JP:   64�N���b�N�� 2�̃X�v���C�g���܂Ƃ߂ď������鎖�ŁADRAM��
-- JP:   �y�[�W���[�h�T�C�N����L�����p�ł���悤�ɂ��Ă��܂��B
-- JP:   �܂��A����64�N���b�N�̒��ɂ�VRAM��VDP�R�}���h�Ɋ������߂�
-- JP:   �X���b�g�������̂ŁA64�N���b�N�T�C�N���̌��Ԃ�VRAM�A�N
-- JP:   �Z�X�̂��߂̌��Ԃ��󂯂Ă���̂�������܂���B�i���m�F�j
-- JP:   ����VDP�ł����̓�������S�ɐ^�����鎖�͉\�ł����A
-- JP:   �\�[�X���K�v�ȏ�ɕ��G�Ɍ����Ă��܂��̂ƁA2��n��T�C�N��
-- JP:   ���炸��Ă��܂��̂�������҂茙�������̂ŁA��L�̂悤��
-- JP:   ���ꂢ�ȃT�C�N���ɂ��Ă��܂��B
-- JP:   �ǂ����Ă����@�Ɠ����^�C�~���O�ɂ������Ƃ�������
-- JP:   �`�������W���Ă݂Ă��������B
-- JP:

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use work.vdp_package.all;

entity sprite is
  port(
    -- VDP clock ... 21.477MHz
    clk21m  : in std_logic;
    reset   : in std_logic;

    dotState : in std_logic_vector( 1 downto 0);
    eightDotState : in std_logic_vector( 2 downto 0);

    dotCounterX  : in std_logic_vector( 8 downto 0);
    dotCounterYp : in std_logic_vector( 8 downto 0);

    -- VDP Status Registers of SPRITE
    pVdpS0SpCollisionIncidence : out std_logic;
    pVdpS0SpOverMapped         : out std_logic;
    pVdpS0SpOverMappedNum      : out std_logic_vector(4 downto 0);
    pVdpS3S4SpCollisionX       : out std_logic_vector(8 downto 0);
    pVdpS5S6SpCollisionY       : out std_logic_vector(8 downto 0);
    pVdpS0ResetReq             : in  std_logic;
    pVdpS0ResetAck             : out std_logic;
    pVdpS5ResetReq             : in  std_logic;
    pVdpS5ResetAck             : out std_logic;
    -- VDP Registers
    vdpR1SpSize : in std_logic;
    vdpR1SpZoom : in std_logic;
    vdpR11R5SpAttrTblBaseAddr : in std_logic_vector(9 downto 0);
    vdpR6SpPtnGeneTblBaseAddr : in std_logic_vector( 5 downto 0);
    vdpR8Color0On : in std_logic;
    vdpR8SpOff : in std_logic;
    vdpR23VStartLine : in std_logic_vector(7 downto 0);
    spMode2 : in std_logic;
    vramInterleaveMode : in std_logic;

    spVramAccessing : out std_logic;

    pRamDat : in std_logic_vector( 7 downto 0);
    pRamAdr : out std_logic_vector(16 downto 0);

    -- JP: �X�v���C�g��`�悵������'1'�ɂȂ�B�J���[�R�[�h0��
    -- JP: �`�悷�鎖���ł���̂ŁA���̃r�b�g���K�v
    spColorOut  : out std_logic;
    -- output color
    spColorCode : out std_logic_vector(3 downto 0)
    );
end sprite;

architecture rtl of sprite is
  constant SpMode1_nSprites: integer := 4;
  constant SpMode2_nSprites: integer := 8;

  signal spOffLatched : std_logic;
  signal dotCounterYLatched : std_logic_vector(8 downto 0);

  signal vdpS0ResetAck : std_logic;
  signal vdpS5ResetAck : std_logic;

  -- for spinforam
  signal spInfoRamAddr     : std_logic_vector(2 downto 0);
  signal spInfoRamWe       : std_logic;
  signal spInfoRamData_in  : std_logic_vector(31 downto 0);
  signal spInfoRamData_out : std_logic_vector(31 downto 0);

  signal spInfoRamX_in        : std_logic_vector( 8 downto 0);
  signal spInfoRamPattern_in  : std_logic_vector(15 downto 0);
  signal spInfoRamColor_in    : std_logic_vector( 3 downto 0);
  signal spInfoRamCC_in       : std_logic;
  signal spInfoRamIC_in       : std_logic;
  signal spInfoRamX_out       : std_logic_vector( 8 downto 0);
  signal spInfoRamPattern_out : std_logic_vector(15 downto 0);
  signal spInfoRamColor_out   : std_logic_vector( 3 downto 0);
  signal spInfoRamCC_out      : std_logic;
  signal spInfoRamIC_out      : std_logic;

  type typeSpState is (spstate_idle, spstate_ytest_draw, spstate_prepare);
  signal spState : typeSpState;

  -- JP: �X�v���C�g�v���[���ԍ��^
  subtype spPlaneNumType is std_logic_vector(4 downto 0);
  -- JP: �X�v���C�g�v���[���ԍ��~�������\�������̔z��
  type spRenderPlanesType is array( 0 to SpMode2_nSprites-1) of spPlaneNumType;
  signal spRenderPlanes : spRenderPlanesType;

  signal iRamAdr        : std_logic_vector(16 downto 0);
  signal iRamAdrYTest   : std_logic_vector(16 downto 0);
  signal iRamAdrPrepare : std_logic_vector(16 downto 0);

  signal spAttrTblBaseAddr   : std_logic_vector( vdpR11R5SpAttrTblBaseAddr'length -1 downto 0);
  signal spPtnGeneTblBaseAddr: std_logic_vector( vdpR6SpPtnGeneTblBaseAddr'length -1 downto 0);
  signal readVramAddrYRead   : std_logic_vector(16 downto 0);
  signal readVramAddrXRead   : std_logic_vector(16 downto 0);
  signal readVramAddrPNRead  : std_logic_vector(16 downto 0);
  signal readVramAddrCRead   : std_logic_vector(16 downto 0);
  signal readVramAddrPTRead  : std_logic_vector(16 downto 0);

  -- JP: Y���W�������̃v���[���ԍ�
  signal spYTestPlaneNum     : std_logic_vector( 4 downto 0);
  signal spYTestListUpCounter : std_logic_vector(3 downto 0);  -- 0 - 8
  signal spYTestEnd          : std_logic;
  -- JP: �������f�[�^�������̃��[�J���v���[���ԍ�
  signal spPrepareLocalPlaneNum   : std_logic_vector( 2 downto 0);
  -- JP: �������f�[�^�������̃v���[���ԍ�
  signal spPreparePlaneNum   : std_logic_vector( 4 downto 0);
  -- JP: �������f�[�^�������̃X�v���C�g��Y���C���ԍ�(�X�v���C�g�̂ǂ̕�����`�悷�邩)
  signal spPrepareLineNum    : std_logic_vector( 3 downto 0);
  -- JP: �������f�[�^�������̃X�v���C�g��X�ʒu�B0�̎���8�h�b�g�B1�̎��E8�h�b�g�B(16x16���[�h�݂̂Ŏg�p)
  signal spPrepareXPos       : std_logic;
  signal spPreparePatternNum : std_logic_vector( 7 downto 0);
  -- JP: �����f�[�^�̏������I������
  signal spPrepareEnd        : std_logic;
  signal spCcD : std_logic;

  -- JP: �����������Ă���X�v���C�g�̃��[�J���v���[���ԍ�
  signal spPreDrawLocalPlaneNum : std_logic_vector(2 downto 0);  -- 0 - 7
  signal spPreDrawEnd           : std_logic;

  -- JP: ���C���o�b�t�@�ւ̕`��p
  signal spDrawX : std_logic_vector(8 downto 0);  -- -32 - 287 (=256+31)
  signal spDrawPattern :std_logic_vector(15 downto 0);
  signal spDrawColor :std_logic_vector(3 downto 0);

  -- JP: �X�v���C�g�`�惉�C���o�b�t�@�̐���M��
  signal spLineBufAddr_e : std_logic_vector( 7 downto 0);
  signal spLineBufAddr_o : std_logic_vector( 7 downto 0);
  signal spLineBufWe_e : std_logic;
  signal spLineBufWe_o : std_logic;
  signal spLineBufData_in_e : std_logic_vector( 7 downto 0);
  signal spLineBufData_in_o : std_logic_vector( 7 downto 0);
  signal spLineBufData_out_e : std_logic_vector( 7 downto 0);
  signal spLineBufData_out_o : std_logic_vector( 7 downto 0);

  signal spLineBufDispWe : std_logic;
  signal spLineBufDrawWe : std_logic;
  signal spLineBufDispX : std_logic_vector( 7 downto 0);
  signal spLineBufDrawX : std_logic_vector( 7 downto 0);
  signal spLineBufDrawColor : std_logic_vector(7 downto 0);
  signal spLineBufDispData_out : std_logic_vector( 7 downto 0);
  signal spLineBufDrawData_out : std_logic_vector( 7 downto 0);

  signal spWindowX   : std_logic;

begin
  pVdpS0ResetAck <= vdpS0ResetAck;
  pVdpS5ResetAck <= vdpS5ResetAck;

  ----------------------------------------------------------------
  -- SPRITE information array
  ----------------------------------------------------------------
  iSpinforam : spinforam port map(spInfoRamAddr, clk21m, spInfoRamWe,
                                  spInfoRamData_in, spInfoRamData_out);

  spInfoRamData_in <= "0" &
                      spInfoRamX_in & spInfoRamPattern_in &
                      spInfoRamColor_in & spInfoRamCC_in & spInfoRamIC_in;
  spInfoRamX_out       <= spInfoRamData_out(30 downto 22);
  spInfoRamPattern_out <= spInfoRamData_out(21 downto  6);
  spInfoRamColor_out   <= spInfoRamData_out( 5 downto  2);
  spInfoRamCC_out      <= spInfoRamData_out(1);
  spInfoRamIC_out      <= spInfoRamData_out(0);

  spInfoRamAddr <= spPrepareLocalPlaneNum when spState = spstate_prepare else
                   spPreDrawLocalPlaneNum;

  ----------------------------------------------------------------
  -- SPRITE Line Buffer
  ----------------------------------------------------------------
  spLineBuf_e : ram port map(spLineBufAddr_e, clk21m, spLineBufWe_e,
                             spLineBufData_in_e, spLineBufData_out_e);
  spLineBuf_o : ram port map(spLineBufAddr_o, clk21m, spLineBufWe_o,
                             spLineBufData_in_o, spLineBufData_out_o);

  spLineBufAddr_e       <= spLineBufDispX      when dotCounterYp(0) = '0' else spLineBufDrawX;
  spLineBufData_in_e    <= "00000000"          when dotCounterYp(0) = '0' else spLineBufDrawColor;
  spLineBufWe_e         <= spLineBufDispWe     when dotCounterYp(0) = '0' else spLineBufDrawWe;
  spLineBufDispData_out <= spLineBufData_out_e when dotCounterYp(0) = '0' else spLineBufData_out_o;

  spLineBufAddr_o       <= spLineBufDrawX      when dotCounterYp(0) = '0' else spLineBufDispX;
  spLineBufData_in_o    <= spLineBufDrawColor  when dotCounterYp(0) = '0' else "00000000";
  spLineBufWe_o         <= spLineBufDrawWe     when dotCounterYp(0) = '0' else spLineBufDispWe;
  spLineBufDrawData_out <= spLineBufData_out_o when dotCounterYp(0) = '0' else spLineBufData_out_e;



  -----------------------------------------------------------------------------

  readVramAddrYread <= spAttrTblBaseAddr & spPreparePlaneNum & "00";
  readVramAddrXread <= spAttrTblBaseAddr & spPreparePlaneNum & "01";
  readVramAddrPNread <= spAttrTblBaseAddr & spPreparePlaneNum & "10";
  readVramAddrCread <= spAttrTblBaseAddr & spPreparePlaneNum & "11" when spMode2 = '0' else
                       spAttrTblBaseAddr(9 downto 3) & not spAttrTblBaseAddr(2) & spPreparePlaneNum & spPrepareLineNum;

  readVramAddrPTread <=
    -- 8x8 mode
    spPtnGeneTblBaseAddr & spPreparePatternNum(7 downto 0) & spPrepareLineNum( 2 downto 0) when vdpR1SpSize = '0' else
    -- 16x16 mode
    spPtnGeneTblBaseAddr & spPreparePatternNum(7 downto 2) & spPrepareXPos & spPrepareLineNum( 3 downto 0);

  spPrepareXPos <= '1' when eightDotState = "100" else
                   '0';

  -- JP: VRAM�A�N�Z�X�A�h���X�̏o��
  iRamAdr <= iRamAdrYTest when spState = spstate_ytest_draw else
             iRamAdrPrepare;
  pRamAdr <= iRamAdr(16 downto 0)  when vramInterleaveMode = '0' else
             iRamAdr(0) & iRamAdr(16 downto 1);

  -----------------------------------------------------------------------------
  -- SPRITE main process.
  -----------------------------------------------------------------------------
  process( clk21m, reset )
    variable spYTestEndV : std_logic;
    variable spListUpY : std_logic_vector( 7 downto 0);
    variable spCC0FoundV : std_logic;
    variable lastCC0LocalPlaneNumV : std_logic_vector(2 downto 0);
    variable spDrawXV : std_logic_vector(8 downto 0);  -- -32 - 287 (=256+31)
    variable vdpS0SpCollisionIncidenceV : std_logic;
    variable vdpS0SpOverMappedV         : std_logic;
    variable vdpS0SpOverMappedNumV      : std_logic_vector(4 downto 0);
    variable vdpS3S4SpCollisionXV       : std_logic_vector(8 downto 0);
    variable vdpS5S6SpCollisionYV       : std_logic_vector(8 downto 0);
  begin
    if( reset ='1' ) then
      spState <= spstate_idle;
      spOffLatched <= '1';
      iRamAdrPrepare <= (others => '0');
      iRamAdrYTest   <= (others => '0');
      spYTestPlaneNum <= (others => '0');
      spPrepareLocalPlaneNum <= (others => '0');
      spPrepareEnd <= '0';
      spVramAccessing <= '0';
      for i in 0 to SpMode2_nSprites -1 loop
        spRenderPlanes(i) <= (others => '0');
      end loop;
      vdpS0SpCollisionIncidenceV := '0';
      vdpS0SpOverMappedV := '0';
      vdpS0SpOverMappedNumV := (others => '0');
      vdpS3S4SpCollisionXV := (others => '0');
      vdpS5S6SpCollisionYV := (others => '0');
      spCC0FoundV := '0';
      lastCC0LocalPlaneNumV := (others => '0');
    elsif (clk21m'event and clk21m = '1') then

      -- latching address signals
      if( (dotCounterX = 0) and (dotState = "01") ) then
        --   +1 should be needed. Because it will be drawn in the next line.
        dotCounterYLatched <= dotCounterYp + ('0' & vdpR23VStartLine) + 1;

        spPtnGeneTblBaseAddr <= vdpR6SpPtnGeneTblBaseAddr;
        if( spMode2 = '0' ) then
          spAttrTblBaseAddr <= vdpR11R5SpAttrTblBaseAddr(9 downto 0);
        else
          spAttrTblBaseAddr <= vdpR11R5SpAttrTblBaseAddr(9 downto 2) & "00";
        end if;
      end if;

      ---------------------------------------------------------------------------
      -- JP: ��ʕ`�撆        : 8�h�b�g�`�悷��Ԃ�1�v���[���A�X�v���C�g��Y���W���������A
      -- JP:                    �\�����ׂ��X�v���C�g�����X�g�A�b�v����B
      -- JP: ��ʔ�`�撆      : ���X�g�A�b�v�����X�v���C�g�̏����W�߁Ainforam�Ɋi�[
      -- JP: ���̉�ʕ`�撆    : inforam�Ɋi�[���ꂽ�������ɁA���C���o�b�t�@�ɕ`��
      -- JP: ���̎��̉�ʕ`�撆: ���C���o�b�t�@�ɕ`�悳�ꂽ�G���o�͂��A��ʕ`��ɍ�����
      ---------------------------------------------------------------------------
      -- Timing generation
      if( dotState = "10") then
        case spState is
          when spstate_idle =>
            if( dotCounterX = 0 ) then
              spState <= spstate_ytest_draw;
              if( vdpR8SpOff = '0' ) then
                spVramAccessing <= '1';
              else
                spVramAccessing <= '0';
              end if;
            end if;
          when spstate_ytest_draw =>
            if( dotCounterX = 256+8 ) then
              spState <= spstate_prepare;
              if( spOffLatched = '0' ) then
                spVramAccessing <= '1';
              else
                spVramAccessing <= '0';
              end if;
            end if;
          when spstate_prepare =>
            if( spPrepareEnd = '1' ) then
              spState <= spstate_idle;
              spVramAccessing <= '0';
            end if;
          when others =>
            spState <= spstate_idle;
        end case;
      end if;

      -- Y-testing
      case dotState is
        when "11" =>
          iRamAdrYTest <= spAttrTblBaseAddr & spYTestPlaneNum & "00";
        when "10" =>
            null;
        when "00" =>
          null;
        when "01" =>
          if( dotCounterX = 0 ) then
            -- initialize
            spYTestPlaneNum  <= (others => '0');
            spYTestListUpCounter  <= (others => '0');
            spYTestEnd <= '0';
            spOffLatched <= vdpR8SpOff;
          elsif( (eightDotState = "110") and (spYTestEnd = '0') ) then
            -- JP: Y���W�̃A�h���X��dotStae="10"�̎��ɏo�Ă���B
            spYTestPlaneNum <= spYTestPlaneNum + 1;
            if( spYTestPlaneNum = 31 ) then
              spYTestEndV := '1';
            else
              spYTestEndV := '0';
            end if;
            spListUpY := dotCounterYLatched(7 downto 0) - pRamDat;
            -- JP: Y���W�� 208�̎��A����ȍ~�̃X�v���C�g�� OFF (SpMode2�ł�Y=216)
            if( (spMode2 = '0' and pRamDat = "11010000") or       -- Y = 208
                (spMode2 = '1' and pRamDat = "11011000") ) then   -- Y = 216
              spYTestEndV := '1';
            elsif( ((spListUpY( 7 downto 3) = "00000") and
                    (VdpR1SpSize = '0' ) and (VdpR1SpZoom='0')) or
                   ((spListUpY( 7 downto 4) = "0000" ) and
                    (VdpR1SpSize = '1' ) and (VdpR1SpZoom='0')) or
                   ((spListUpY( 7 downto 4) = "0000" ) and
                    (VdpR1SpSize = '0' ) and (VdpR1SpZoom='1')) or
                   ((spListUpY( 7 downto 5) = "000"  ) and
                    (VdpR1SpSize = '1' ) and (VdpR1SpZoom='1')) ) then
              -- JP: ���̃��C����ɏ���Ă���v���[���𔭌������I
              if( ((spYTestListUpCounter < 4) and (spMode2 = '0')) or
                  ((spYTestListUpCounter < 8) and (spMode2 = '1')) ) then
                -- JP: �܂���4��(���[�h2�ł�8��)�ǂ�łȂ���
                -- JP: �v���[���ԍ������o���Ă���
                spRenderPlanes(conv_integer(spYTestListUpCounter)) <= spYTestPlaneNum;
                spYTestListUpCounter <= spYTestListUpCounter + 1;
              else
                spYTestEndV := '1';
                -- SPRITE was over mapped.
                if( vdpS0SpOverMappedV = '0' ) then
                  vdpS0SpOverMappedV := '1';
                  vdpS0SpOverMappedNumV := spYTestPlaneNum;
                end if;
              end if;
            end if;
            spYTestEnd <= spYTestEndV;
          end if;
        when others => null;
      end case;

      -- prepareing
      case dotState is
        when "11" =>
          spInfoRamWe <= '0';
          case eightDotState is
            -- Sprite Attribute Table
            --        7 6 5 4 3 2 1 0
            --  +0 : |       Y       |
            --  +1 : |       X       |
            --  +2 : | Pattern Num   |
            --  +3 : |EC0 0 0| Color | (mode 1)
            when "000" =>               -- Y read
              iRamAdrPrepare <= readVramAddrYread;
            when "001" =>               -- X read
              iRamAdrPrepare <= readVramAddrXread;
            when "010" =>               -- Pattern Num read
              iRamAdrPrepare <= readVramAddrPNread;
            when "011" | "100" =>       -- Pattern read
              iRamAdrPrepare <= readVramAddrPTread;
            when "101" =>               -- Color read
              iRamAdrPrepare <= readVramAddrCread;
            when others => null;
          end case;
        when "10" =>
          null;
        when "00" =>
          null;
        when "01" =>
          if( spState = spstate_prepare ) then
            case eightDotState is
              when "001" =>               -- Y read
                -- JP: �X�v���C�g�̉��s�ڂ��Y���������o���Ă���
                spListUpY := dotCounterYLatched(7 downto 0) - pRamDat;
                if( VdpR1SpZoom = '0' ) then
                  spPrepareLineNum  <= spListUpY(3 downto 0);
                else
                  spPrepareLineNum  <= spListUpY(4 downto 1);
                end if;
              when "010" =>               -- X read
                spInfoRamX_in <= '0' & pRamDat;
              when "011" =>               -- Pattern Num read
                spPreparePatternNum <= pRamDat;
              when "100" =>               -- Pattern read left
                spInfoRamPattern_in(15 downto 8) <= pRamDat;
              when "101" =>               -- Pattern read right
                if( VdpR1SpSize = '0' ) then
                  -- 8x8 mode
                  spInfoRamPattern_in( 7 downto 0) <= (others => '0');
                else
                  -- 16x16 mode
                  spInfoRamPattern_in( 7 downto 0) <= pRamDat;
                end if;
              when "110" =>               -- Color read
                -- color
                spInfoRamColor_in <= pRamDat(3 downto 0);
                -- CC
                if(spMode2 = '1') then
                  spInfoRamCC_in <= pRamDat(6);
                else
                  spInfoRamCC_in <= '0';
                end if;
                -- IC
                spInfoRamIC_in <= pRamDat(5) and spMode2;
                -- EC
                if( pRamDat(7) = '1' ) then
                  -- EC = '1';
                  spInfoRamX_in <= spInfoRamX_in - 32;
                end if;

                -- If all of the sprites list-uped are readed,
                -- the sprites left should not be drawn.
                if( (spPrepareLocalPlaneNum >= spYTestListUpCounter) or
                    (spOffLatched = '1') ) then
                  spInfoRamPattern_in <= (others => '0');
                end if;

                -- Write sprite informations to spInfoRam.
                spInfoRamWe <= '1';
              when "111" =>
                spPrepareLocalPlaneNum <= spPrepareLocalPlaneNum + 1;
                if( spPrepareLocalPlaneNum = 7 ) then
                  spPrepareEnd <= '1';
                end if;
                spPreparePlaneNum <= spRenderPlanes(conv_integer(spPrepareLocalPlaneNum+1));

              when others => null;
            end case;
          else
            spPreparePlaneNum <= spRenderPlanes(0);
            spPrepareLocalPlaneNum <= (others => '0');
            spPrepareEnd <= '0';
            spInfoRamWe <= '0';
          end if;
        when others => null;
      end case;


      -------------------------------------------------------------------------
      -- Drawing to line buffer.
      --
      -- JP: ���̉�H�� dotCounterX�̃J�E���^�𗘗p���ĉ���������B
      -- JP:   0����31 �@���[�J���v���[��0�̕`��
      -- JP:  32����63 �@���[�J���v���[��1�̕`��
      -- JP:     :               :
      -- JP:    ����255�@���[�J���v���[��1�̕`��
      -------------------------------------------------------------------------
      if( spState = spstate_ytest_draw ) then
        case dotState is
          when "10" =>
            spLineBufDrawWe <= '0';
          when "00" =>
            if( dotCounterX(4 downto 0) = 1 ) then
              spDrawPattern <= spInfoRamPattern_out;
              spDrawXV      := spInfoRamX_out;
            else
              if( (VdpR1SpZoom = '0') or (dotCounterX(0) = '1') ) then
                spDrawPattern <= spDrawPattern(14 downto 0) & "0";
              end if;
              spDrawXV := spDrawX + 1;
            end if;
            spDrawX        <= spDrawXV;
            spLineBufDrawX <= spDrawXV(7 downto 0);
          when "01" =>
            spDrawColor <= spInfoRamColor_out;
          when "11" =>
            if( spInfoRamCC_out = '0' ) then
              lastCC0LocalPlaneNumV := spPreDrawLocalPlaneNum;
              spCC0FoundV := '1';
            end if;
            if( (spDrawPattern(15) = '1') and (spDrawX(8) = '0') and (spPreDrawEnd = '0') and
                ((vdpR8Color0On = '1') or (spDrawColor /= 0)) ) then
              -- JP: �X�v���C�g�̃h�b�g��`��
              -- JP: ���C���o�b�t�@��7�r�b�g�ڂ́A���炩�̐F��`�悵������'1'�ɂȂ�B
              -- JP: ���C���o�b�t�@��6-4�r�b�g�ڂ͂����ɕ`�悳��Ă���h�b�g�̃��[�J���v���[���ԍ�
              -- JP: (�F��������Ă���Ƃ��͐e�ƂȂ�CC='0'�̃X�v���C�g�̃��[�J���v���[���ԍ�)������B
              -- JP: �܂�AlastCC0LocalPlaneNumV�����̔ԍ��Ɠ������Ƃ���OR�������Ă悢���ɂȂ�B
              if( (spLineBufDrawData_out(7) = '0') and (spCC0FoundV = '1') ) then
                -- JP: �����`����Ă��Ȃ�(�r�b�g7��'0')�Ƃ��A���̃h�b�g�ɏ��߂Ă�
                -- JP: �X�v���C�g���`�悳���B�������ACC='0'�̃X�v���C�g�����ꃉ�C����ɂ܂�
                -- JP: ����Ă��Ȃ����͕`�悵�Ȃ�
                spLineBufDrawColor <= ("1" & lastCC0LocalPlaneNumV & spDrawColor);
                spLineBufDrawWe <= '1';
              elsif( (spLineBufDrawData_out(7) = '1') and (spInfoRamCC_out = '1') and
                     (spLineBufDrawData_out(6 downto 4) = lastCC0LocalPlaneNumV) ) then
                -- JP: ���ɊG���`����Ă��邪�ACC��'1'�ł����̃h�b�g�ɕ`����Ă���X�v���C�g��
                -- JP: localPlaneNum�� lastCC0LocalPlaneNumV�Ɠ��������́A���C���o�b�t�@����
                -- JP: ���n�f�[�^��ǂ݁A���������F�Ƙ_���a���惊�A�����߂��B
                spLineBufDrawColor <= spLineBufDrawData_out or ("0000" & spDrawColor);
                spLineBufDrawWe <= '1';
              elsif( (spLineBufDrawData_out(7) = '1') and
                     (spInfoRamCC_out = '0') ) then
                spLineBufDrawColor <= spLineBufDrawData_out;
                -- JP: �X�v���C�g���ՓˁB
                -- SPRITE colision occured
                vdpS0SpCollisionIncidenceV := '1';
                vdpS3S4SpCollisionXV := spDrawX + 12;
                -- Note: Drawing line is previous line.
                vdpS5S6SpCollisionYV := dotCounterYLatched + 7;
              end if;
            end if;
            --
            if( dotCounterX = 0 ) then
              spPreDrawLocalPlaneNum <= (others => '0');
              spPreDrawEnd <= '0';
              lastCC0LocalPlaneNumV := (others => '0');
              spCC0FoundV := '0';
            elsif( dotCounterX(4 downto 0) = 0 ) then
              spPreDrawLocalPlaneNum <= spPreDrawLocalPlaneNum + 1;
              if( spPreDrawLocalPlaneNum = 7 ) then
                spPreDrawEnd <= '1';
              end if;
            end if;
          when others => null;
        end case;
      end if;

      -- status register
      if( pVdpS0ResetReq /= vdpS0ResetAck ) then
        vdpS0ResetAck <= pVdpS0ResetReq;
        vdpS0SpCollisionIncidenceV := '0';
        vdpS0SpOverMappedV := '0';
        vdpS0SpOverMappedNumV := (others => '0');
      end if;
      if( pVdpS5ResetReq /= vdpS5ResetAck ) then
        vdpS5ResetAck <= pVdpS5ResetReq;
        vdpS3S4SpCollisionXV := (others => '0');
        vdpS5S6SpCollisionYV := (others => '0');
      end if;

      pVdpS0SpCollisionIncidence <= vdpS0SpCollisionIncidenceV;
      pVdpS0SpOverMapped    <= vdpS0SpOverMappedV;
      pVdpS0SpOverMappedNum <= vdpS0SpOverMappedNumV;
      pVdpS3S4SpCollisionX  <= vdpS3S4SpCollisionXV;
      pVdpS5S6SpCollisionY  <= vdpS5S6SpCollisionYV;

    end if;
  end process;


  -----------------------------------------------------------------------------
  -- JP: ��ʂւ̃����_�����O�Bvdp�G���e�B�e�B��dotState="11"�̎��ɒl���擾�ł���悤�ɁA
  -- JP: "01"�̃^�C�~���O�ŏo�͂���B
  -----------------------------------------------------------------------------
  process( clk21m, reset )
  begin
    if( reset = '1' ) then
      spLineBufDispWe <= '0';
      spLineBufDispX  <= (others => '0');
      spWindowX <= '0';
    elsif (clk21m'event and clk21m = '1') then
      case dotState is
        when "10" =>
          spLineBufDispWe <= '0';
          if( dotCounterX = 8) then
            -- JP: dotCounter�Ǝ��ۂ̕\��(�J���[�R�[�h�̏o��)��8�h�b�g����Ă���
            spWindowX <= '1';
            spLineBufDispX <= (others => '0');
          else
            spLineBufDispX <= spLineBufDispX + 1;
            if( spLineBufDispX = X"FF" ) then
              spWindowX <= '0';
            end if;
          end if;
        when "00" =>
          null;
        when "01" =>
          if( spWindowX = '1' ) then
            spColorOut  <= spLineBufDispData_out(7);
            spColorCode <= spLineBufDispData_out(3 downto 0);
          else
            spColorOut  <= '0';
            spColorCode <= (others => '0');
          end if;
        when "11" =>
          -- clear displayed dot
          if( spWindowX = '1' ) then
            spLineBufDispWe <= '1';
          end if;
        when others => null;
      end case;

    end if;
  end process;

end rtl;

