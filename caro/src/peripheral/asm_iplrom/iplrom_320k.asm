;
; iplrom.vhd
;   initial program loader for Cyclone & EPCS (Altera)
;   Revision 1.01(K)
;
; Copyright (c) 2006 Kazuhiro Tsujikawa (ESE Artists' factory)
; All rights reserved.
;
; Redistribution and use of this source code or any derivative works, are
; permitted provided that the following conditions are met:
;
; 1. Redistributions of source code must retain the above copyright notice,
;    this list of conditions and the following disclaimer.
; 2. Redistributions in binary form must reproduce the above copyright
;    notice, this list of conditions and the following disclaimer in the
;    documentation and/or other materials provided with the distribution.
; 3. Redistributions may not be sold, nor may they be used in a commercial
;    product or activity without specific prior written permission.
;
; THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS
; "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED
; TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR
; PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR
; CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL,
; EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO,
; PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS;
; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY,
; WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR
; OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF
; ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
;
; IPL-ROM Revision 1.01(K) for 256+48+16 kB unpacked
; EPCS4 start address: 30000h - Optimized by KdL 2013.06.12
;
; Coded in TWZ'CA3 w/ TASM80 v3.2ud for OCM-PLD Pack v3.2 or later
; Hint! The better optimization is obtained when the filesize is 513 bytes
;

            .org        $FC00
;----------------------------------------

SDBIOS_LEN: .equ        24                 ; = 384 kB / 16 => SD-CARD BIOS
EPBIOS_LEN: .equ        20                 ; = 320 kB / 16 => EPCS BIOS
;----------------------------------------

begin:                                     ; => low memory ($0000)
            di
; self copy
            ld          bc, end - begin    ; bc = ipl-rom file size (Bytes)
            ld          de, begin          ; de = start address of RAM
            ld          h, e               ; ld hl, $0000
            ld          l, e               ; hl = start address of IPL-ROM
            ldir                           ; copy to RAM
; set VDP color palette
            ld          hl, data_r16
            ld          bc, $0299          ; 2 Bytes => $99
            otir
            ld          bc, $209A          ; 32 Bytes => $9A
            otdr
; b = $00
;----------------------------------------

            jp          init_stack         ; warning! don't remove or touch !!!
;----------------------------------------

init_stack:                                ; => high memory ($FCXX)
            ld          sp, $FFFF          ; initialize stack pointer
; check 'AB' marker in RAM
            ld          a, $80
            ld          ($7000), a
            ld          hl, ($8000)
            ld          de, 'B'*256 + 'A'
            sbc         hl, de
            jr          z, exit_epcs       ; yes 'AB' => jp z, init_sys
; check SD-CARD
            ld          a, $40
            ld          ($6000), a

            ld          hl, $C000          ; buffer for sector
            inc         b                  ; ld bc, $0100 => sector 0
            ld          c, l
            ld          d, l               ; ld de, $0000
            ld          e, l
load_sd:
            call        read_sd            ; read from SD-CARD
;----------------------------------------

;           jr          c, load_sd         ; useful to load the sdbios only
            jr          c, load_epcs       ; read error
; read OK => CY = 0
;----------------------------------------

; search 'FAT' checksum
            ld          hl, $C000          ; buffer
            ld          bc, $0080
loop_f:
            ld          a,'F'              ; 'F'
            cpir
            or          a
            jr          nz, exit_fat
test_fat:
            add         a, (hl)            ; 'A'
            inc         hl
            add         a, (hl)            ; 'T'
            sub         'F' + 'A' + 'T'
            dec         hl
            jr          nz, loop_f
; yes marker 'FAT'
            ld          c, b               ; ld c, $00
            ld          e, c               ; ld de, $0000
            ld          d, c
            scf
; no 'FAT'
exit_fat:
            jr          c, find_ab         ; CY = 1 => yes 'FAT'
;----------------------------------------

; test MBR, search partition
            ld          b, $04             ; number partition
            ld          hl, $C000 + $01C6  ; offset in sector
find_part:
            push        hl
            ld          e, (hl)
            inc         hl
            ld          d, (hl)
            inc         hl
            ld          c, (hl)
            ld          a, c
            or          d
            or          e
            pop         hl
            jr          nz,exit_mbr        ; yes partition

            ld          de, $0010
            add         hl, de
            djnz        find_part
; no partition
            scf                            ; CY = 1 error
;----------------------------------------

exit_mbr:
            jr          c, load_epcs       ; no partition
; yes partition
            push        de
            push        bc
            ld          b, $01             ; 1 sector
            ld          hl, $C000          ; buffer for DAT
            call        read_sd            ; read PBR
            pop         bc
            pop         de
            jr          nc, find_ab        ; CY = 1 => error
;----------------------------------------

load_epcs:
            ld          hl, read_epcs      ; for get_data: call read_epcs
            ld          (get_data + 1), hl
;----------------------------------------

; load BIOS from EPCS
            ld          a, $60
            ld          ($6000), a

            ld          de, $0180          ; address in EPCS = 30000h / 512
            ld          b, EPBIOS_LEN - 2  ; 18 => to init next_16k
            ld          a, e
            call        load_blocks        ; 19 pages + 2 * free-16k (20-21)
; d = $03
            ld          e, $E0             ; ld de, $03E0
            call        load_blocks        ; xbasic2 (22) + 2 * free-16k (23-24)
exit_epcs:
            jr          init_sys
;----------------------------------------

; test BIOS on SD-CARD
find_ab:
            ld          ix, $C000          ; buffer PBR sector

            ld          l, (ix + $0E)      ; number of reserved
            ld          h, (ix + $0F)      ; sectors
            ld          a, c
            add         hl, de
            adc         a, $00
            ld          c, a

            ld          e, (ix + $11)      ; number of root
            ld          d, (ix + $12)      ; directory entries
            ld          a, e
            and         $0F
            ld          b, $04
loop1_ab:
            srl         d
            rr          e
            djnz        loop1_ab

            or          a                  ; CY = 0
            jr          z, parse_ab

            inc         de
parse_ab:
            push        de
            ld          b, (ix + $10)      ; number of FAT

            ld          e, (ix + $16)      ; number of sectors
            ld          d, (ix + $17)      ; per FAT
            ld          a, c
loop2_ab:
            add         hl, de
            adc         a, $00
            djnz        loop2_ab

            pop         de
            add         hl, de
            ex          de, hl
            ld          c, a

            push        de
            push        bc
            ld          b, $01
            ld          hl, $C000          ; buffer
            call        read_sd            ; read
            jr          c, exit_ab         ; error

            ld          hl, ($C000)        ; two first Bytes
            ld          de, 'B'*256 + 'A'  ; 'AB' marker Disk BIOS
            or          a                  ; CY = 0
            sbc         hl, de             ; compare
            pop         bc
            pop         de
            jr          z, exit_ab         ; yes marker
            scf                            ; CY = 1 error
;----------------------------------------
exit_ab:
            jr          c, load_epcs       ; test error
; test OK
;----------------------------------------

; load BIOS from SD-CARD
            ld          b, SDBIOS_LEN      ; = 24 pages (384 kB)
            ld          a, $80             ; bit7 = 1 enable ermmem
            call        load_erm
;----------------------------------------

; start system
init_sys:
            xor         a
            ld          ($6000), a
            inc         a
            ld          ($6800), a
            ld          ($7000), a
            ld          ($7800), a

            ld          a, $C0
            out         ($A8), a
            rst         00                 ; reset MSX BASIC
;----------------------------------------  ; $C7 => color 15 (unused/green)

; VDP port $9A (set color palette) optimized for otdr
;             unused/green , red/blue
            .db              $77           ; color 15 (red/blue) => .db $77, $07
            .db         $05, $55           ; color 14
            .db         $02, $65           ; color 13
            .db         $04, $11           ; color 12
            .db         $06, $64           ; color 11
            .db         $06, $61           ; color 10
            .db         $03, $73           ; color 9
            .db         $01, $71           ; color 8
            .db         $06, $27           ; color 7
            .db         $01, $51           ; color 6
            .db         $03, $27           ; color 5
            .db         $01, $17           ; color 4
            .db         $07, $33           ; color 3
            .db         $06, $11           ; color 2
            .db         $00                ; color 1 (unused/green)
; VDP port 99H (set register)
data_r16:                                  ; optimized for otir
;              start otir ----->
            .db              $00           ; color 1 (red/blue)
            .db         $90, $00           ; $00 => R16 (Palette) => color 0
;                               <----- start otdr
;----------------------------------------

load_blocks:
            call        next_16k
            call        free_16k
;----------------------------------------

free_16k:
            ld          de, $0380          ; address in EPCS for free-16k block
next_16k:
            ld          c, e
            inc         b                  ; +1 block (16 kB)
load_erm:
            ld          ($7000), a         ; ermbank2 (8 kB)
            inc         a
            ld          ($7800), a         ; ermbank3 (8 kB)
            inc         a
            push        af
            push        bc
; load page 16 kB
            ld          b, $20             ; 32 sectors
            ld          hl, $8000          ; buffer
get_data:
            call        read_sd            ; or read_epcs (read and load)
            pop         bc
            pop         hl
            ret         c                  ; error
            ld          a, h
            djnz        load_erm
            ret                            ; OK
;----------------------------------------

; for EPCS
read_epcs:
            push        de
            push        bc
            sla         e
            rl          d
            ld          a, b
            add         a, a
            ld          c, a
            ld          b, $00
            push        hl
            ld          hl, $4000          ; /CS = 0
            ld          (hl), $03
            ld          (hl), d
            ld          (hl), e
            ld          (hl), b
            ld          a, (hl)
            pop         de
loop_epcs:
            ld          a, (hl)
            ld          (de), a
            inc         de
            djnz        loop_epcs

            dec         c
            jr          nz, loop_epcs

            ld          a, ($5000)         ; /CS = 1

            pop         bc
            pop         hl
            xor         a
            ld          d, a
            ld          e, b
            add         hl, de
            ex          de, hl
            adc         a, c
            ld          c, a
            ret
;----------------------------------------

; for SD-CARD
set_cmd:
            ld          a, (hl)
            sla         e
            rl          d
            rl          c
            ld          (hl), b            ; CMD
            ld          (hl), c
            ld          (hl), d
            ld          (hl), e
            ld          (hl), $00
            ld          (hl), $95
            ld          a, (hl)
            ld          b, $10             ; 16
loop_cmd:
            ld          a, (hl)
            cp          $FF
            ccf
            ret         nc                 ; no error
            djnz        loop_cmd

            scf                            ; error
            ret
;----------------------------------------

init_sd:
            ld          b, $0A             ; 10 Bytes
loop_cs1:
            ld          a, ($5000)         ; /CS = 1 (bit12)
            djnz        loop_cs1

            ld          bc, $4000          ; CMD0 - GO_IDLE_STATE
            ld          e, c
            ld          d, c               ; cde = 0
            call        set_cmd
            ret         c                  ; error

            and         $F7
            cp          $01
            scf                            ; CY = 1
            ret         nz                 ; error
parse_cmd:
            ld          b, $77             ; CMD55
            call        set_cmd
            and         $04
            jr          z, set_cmd41       ; = $04

            ld          b, $41             ; CMD1 - SEND_OP_COND
            call        set_cmd
            jr          end_cmd1
set_cmd41:
            ld          b, $69             ; CMD41
            call        set_cmd
end_cmd1:
            ret         c                  ; error

            cp          $01
            jr          z, parse_cmd

            or          a
            ret         z

            scf
            ret
;----------------------------------------

test_sd:
            call        init_sd
            pop         bc
            pop         de
            pop         hl
            ret         c                  ; error

; read from SD-CARD
read_sd:
            push        hl
            push        de
            push        bc
            ld          b, $51             ; CMD17 - READ_SINGLE_BLOCK
            ld          hl, $4000
            call        set_cmd
            jr          c, test_sd         ; error

            pop         bc
            pop         de
            pop         hl
            or          a
            scf
            ret         nz                 ; error

            push        de
            push        bc
            ex          de, hl
            ld          bc, $0200          ; 512 Bytes
            ld          hl, $4000
find_fe:
            ld          a, (hl)
            cp          $FE
            jr          nz, find_fe

            ldir
            ex          de, hl
            ld          a, (de)
            pop         bc
            ld          a, (de)
            pop         de
            inc         de
            ld          a, d
            or          e
            jr          nz, loop_sd

            inc         c
loop_sd:
            djnz        read_sd

            ret
;----------------------------------------

end:
            .dw         $2184              ; random filler (lenght 513 bytes)

            .end

