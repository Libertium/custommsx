--
--  doublebuf.vhd
--    Double Buffered Line Memory.
--
--  Copyright (C) 2000-2006 Kunihiko Ohnaka
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
-- Document
--
-- JP: �_�u���o�b�t�@�����O�@�\�t�����C���o�b�t�@���W���[���B
-- JP: vga.vhd�ɂ��A�b�v�X�L�����R���o�[�g�Ɏg�p���܂��B
--
-- JP: xPositionW�� X���W�����Cwe�� 1�ɂ���Ə������݃o�b�t�@��
-- JP: �������܂��D�܂��CxPositionR�� X���W������ƁC�ǂݍ���
-- JP: �o�b�t�@����ǂݏo�����F�R�[�h�� q����o�͂����B
-- JP: evenOdd�M���ɂ���āC�ǂݍ��݃o�b�t�@�Ə������݃o�b�t�@��
-- JP: �؂�ւ��B

library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_unsigned.all;
use work.vdp_package.all;

entity doublebuf is
   port (
         clk        : in  std_logic;
         xPositionW : in  std_logic_vector(9 downto 0);
         xPositionR : in  std_logic_vector(9 downto 0);
         evenOdd    : in  std_logic;
         we         : in  std_logic;
         dataRin    : in  std_logic_vector(5 downto 0);
         dataGin    : in  std_logic_vector(5 downto 0);
         dataBin    : in  std_logic_vector(5 downto 0);
         dataRout   : out  std_logic_vector(5 downto 0);
         dataGout   : out  std_logic_vector(5 downto 0);
         dataBout   : out  std_logic_vector(5 downto 0)
        );
end doublebuf;

architecture RTL of doublebuf is
  signal we_e : std_logic;
  signal we_o : std_logic;
  signal addr_e : std_logic_vector(9 downto 0);
  signal addr_o : std_logic_vector(9 downto 0);
  signal outR_e : std_logic_vector(5 downto 0);
  signal outG_e : std_logic_vector(5 downto 0);
  signal outB_e : std_logic_vector(5 downto 0);
  signal outR_o : std_logic_vector(5 downto 0);
  signal outG_o : std_logic_vector(5 downto 0);
  signal outB_o : std_logic_vector(5 downto 0);
begin

  bufRe : linebuf port map(addr_e, clk, we_e, dataRin, outR_e);
  bufGe : linebuf port map(addr_e, clk, we_e, dataGin, outG_e);
  bufBe : linebuf port map(addr_e, clk, we_e, dataBin, outB_e);

  bufRo : linebuf port map(addr_o, clk, we_o, dataRin, outR_o);
  bufGo : linebuf port map(addr_o, clk, we_o, dataGin, outG_o);
  bufBo : linebuf port map(addr_o, clk, we_o, dataBin, outB_o);

  we_e <= we when evenOdd = '0' else '0';
  we_o <= we when evenOdd = '1' else '0';

  addr_e <= xPositionW when evenOdd = '0' else xPositionR;
  addr_o <= xPositionW when evenOdd = '1' else xPositionR;

  dataRout <= outR_e when evenOdd = '1' else outR_o;
  dataGout <= outG_e when evenOdd = '1' else outG_o;
  dataBout <= outB_e when evenOdd = '1' else outB_o;

end RTL;
