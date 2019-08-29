; pletter v0.5c msx unpacker
; call unpack with hl pointing to some pletter5 data, 
; and de pointing to the destination.
; changes all registers
; define lengthindata when the original size is written 
; in the pletter data
;  define LENGTHINDATA
;  module pletter
;
.z80
;--------------------------------------
GETBIT  macro
	add a,a
	jr nz,$+5
;getbit:
	ld a,(hl)
	inc hl
	rla
	endm
;
GETBITEXX  macro 
	add a,a
	jr nz,$+7
;getbitexx:
	exx
	ld a,(hl)
	inc hl
	exx
	rla
	endm
;=====================================
unpack:
;  ifdef LENGTHINDATA
;  inc hl
;  inc hl
;  endif
	ld a,(hl)
	inc hl
	exx
; set modeX
	ld de,0
	add a,a
	inc a
	rl e
	add a,a
	rl e
	add a,a
	rl e
	rl e
	ld hl,modes
	add hl,de
	ld e,(hl)
	ld ixl,e
	inc hl
	ld e,(hl)
	ld ixh,e	;ix=modeX
	ld e,1
	exx
	ld iy,loop
;---
literal:ldi		;load byte
loop:	GETBIT
	jr nc,literal
;---
	exx
	ld h,d
	ld l,e
getlen:	GETBITEXX
	jr nc,.lenok
;----
.lus:	GETBITEXX
	adc hl,hl
	ret c		;exit
	GETBITEXX
	jr nc,.lenok
;
	GETBITEXX
	adc hl,hl
	ret c		;exit
	GETBITEXX
	jr c,.lus
;----
.lenok:	inc hl
	exx
	ld c,(hl)
	inc hl
	ld b,0
	bit 7,c
	jr z,offsok
	jp (ix)
;---------------------------------
mode6:	GETBIT
	rl b
mode5:	GETBIT
	rl b
mode4:	GETBIT
	rl b
mode3:	GETBIT
	rl b
mode2:	GETBIT
	rl b
	GETBIT
	jr nc,offsok
	or a
	inc b
	res 7,c
offsok:	inc bc
	push hl
	exx
	push hl
	exx
	ld l,e
	ld h,d
	sbc hl,bc
	pop bc
	ldir		;load
	pop hl
	jp (iy)		;jp loop
;----------------------------
modes:	dw	offsok
	dw	mode2
	dw	mode3
	dw	mode4
	dw	mode5
	dw	mode6
;----------------------------
;	endmodule

;eof
;	end
