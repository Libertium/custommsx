;**************************************************
; IPLROM2 for OCM with boot from MMC/SD/SDHC-card *
;	with data compression			  *
;**************************************************
;
buffer	equ	0C000h	;buffer for data
prog	equ	0FC00h	; for programm
;========================================
;start:
	ld	bc,end_p-st_prog; len prg
	ld	de,prog		; addr prg
	ld	hl,end_beg	;
	ldir			; copy to RAM
	jp	prog		; start programm
end_beg:
.phase	prog
st_prog:
; -----
	ld	a, 40h		;enable SD/MMC
	ld	(6000h), a
	ld	bc, 100h	;b=1 (1 sector)
	ld	d, c		;cde=0
	ld	e, c		; address MBR
	ld	hl, buffer	;buffer for sector
	call	rd_card		;read MBR from SD/MMC
	jr	c, rd_EPCS	;error
; read OK
	call	test_MBR	;search partition
	jr	c, rd_EPCS	; CY=1 no partition
; yes partition (cde = sector N)
	push	de
	push	bc
	ld	b, 1		;1 sector
	ld	hl, buffer	;buffer for DAT
	call	rd_card		; read PBR
	call	src_FAT		; search "FAT"
	pop	bc
	pop	de
	jr	nz, rd_EPCS	; Z=0 - no FAT16
; yes "FAT"
yes_FAT:
; cde = adress PBR
	call	test_BIOS	;test BIOS on SD
	jr	c, rd_EPCS	; not BIOS on SD
; read BIOS from SD/MMC/SDHC
; c,d,e = sector address on SD/MMC/SDHC
	call	prm_SD		;Print message SD
	ld	hl,rd_16sd	;load 16 kbyte from SD-card
	ld	(p_read+1), hl
	jr	rd_SD		; read from SD
;---------------------------------------
;load BIOS from EPCS4
rd_EPCS:
	call	prm_EPCS	;Print message EPCS
	ld	hl,ldz_EPCS	;load compress from EPCS4
	ld	(p_read+1), hl
;
	ld	a,60h		;EPCS ON
	ld	(6000h), a
	ld	c,04h		;cde=040000h
	ld	de,0000h	;    byte adress in EPCS4
rd_SD:	call	ld_BIOS		;load BIOS
	jr	c,err_ld	; error load
;=======================================
; START SYSTEM
	ld	a, 80h		;enable
	ld	(7000h), a	; ermbank
	ld	hl, (8000h)	; 2 first byte
	xor	a		;CY=0
	ld	de, 4241h	;="AB" ?
	sbc	hl, de
	jr	z, st_bios	; start BIOS
; error BIOS
err_ld:	call	prm_error	; print message ERROR
	jr	$		;cikl
st_bios:
	xor	a         	;MEGASD Off
	ld	(6000h), a
	inc	a
	ld	(6800h), a
	ld	(7000h), a
	ld	(7800h), a
	ld	a, 0C0h		;
	out	(0A8h),	a
; test BASIC.ROM
	ld	a,(0)		; first byte
	cp	0F3h		; = DI ?
	jr	nz,err_ld	; error BIOS
	rst	0		;reset MSX BASIC
;=================================	
; load BIOS from SD or EPCS4
; c,d,e = sector address in SD or byte address in EPCS4
ld_BIOS:
	call	prm_step	;print message :>>>
	ld	b, 16+8+4	;16+8+4 page (28*16 Kb)
	ld	a, 80h		;bit 7 = 1 enable ermmem
;/---- load 24 page (384 kb)
c_load:	ld	(7000h), a	;ermbank2(8 kb)
	inc	a
	ld	(7800h), a	;ermbank3(8 kb)
	inc	a
	push	af
	push	bc
; load page 16 kb
p_read:	call	rd_16sd		;read and load 16 kbyte
	ld	a,c		;save c (adress)
	pop	bc
	pop	hl
	ld	c,a		;restore c
	ret	c		;error
	ld	a,'>'-20h	; Print '>'
	out	(DATP),a
	ld	a, h		;
	djnz	c_load		;
;\----
	ld	a,' '-20h
	out	(DATP),a
	ld	a,'O'-20h
	out	(DATP),a
	ld	a,'K'-20h
	out	(DATP),a
	ret			;OK
;***********************************************
; load compressed page (16 kb) from EPCS4
; c,d,e = byte address in EPCS4
;***********************************************
ldz_EPCS:
	call	ld_epcs		;load block from EPCS
	ret	c		;error or end
	push	de
	push	bc
	ld	hl,buffer	;source
	ld	de,8000h	;destination
	call	unpack		;unpack block
	pop	bc
	pop	de
	xor	a		;cy=0 OK
	ret
;===========================================
; load block from EPCS4 -> 0C000h...
; INPUT:
; c,d,e - byte address in EPCS4
ld_epcs:
	push	de
	push	bc
;---
	ld	hl, 4000h	;/CS=0
	ld	(hl), 03h	;CMD READ_from_EPCS4
	ld	(hl), c
	ld	(hl), d
	ld	(hl), e		;address
	ld	a, (hl)
	ld	de,buffer	;buffer for block
; len compressed page = 4000h
	ld	a, (hl)		; =00h ?
	or	a
	jr	nz,no_4000
	ld	a, (hl)		; =40h ?
	cp	40h
	jr	nz,no_4000
; len block
	ld	c, (hl)
	ld	b, (hl)		;bc=len block
	push	bc
	dec	bc
	dec	bc
	dec	bc
	dec	bc		;len-4
ckl_rd:	ld	a,(hl)		;byte from EPCS4
	ld	(de),a		; to buffer
	inc	de
	dec	bc
	ld	a,c
	or	b
	jr	nz,ckl_rd
;
	ld	a, (5000h)	;/CS=1
; count new byte address in EPCS4
	pop	hl		; len block
	pop	bc
	pop	de		;cde = adress block
	add	hl,de
	ex	de,hl
	ret	nc   		;
	inc	c		;c,d,e -> new address
	xor	a		;cy=0 -> no error
	ret
; exit
no_4000:ld	a, (5000h)	;/CS=1
	pop	bc
	pop	de
	scf			;cy=1 -> error or end
	ret
;=============================================
prm_step:
; 7*40=280
	ld	A,LOW(7*40) 	;col=0, str=7
	OUT	(CMDP),A
	LD	A,40H+08h+HIGH(7*40)
	OUT	(CMDP),A
	ld	A,':'-20h
	out	(DATP),A
	ret
prm_error:
	push	bc
	push	hl
	ld	hl,t_ERR
; 8*40=320
	ld	A,LOW(8*40)	;col=0, str=8
	ld	C,CMDP	;99H
	OUT	(C),A
	LD	A,40H+08h+HIGH(8*40)
	jr	prm_2
prm_EPCS:
	push	bc
	push	hl
	ld	hl,t_EPCS
	jr	prm_
prm_SD:	push	bc
	push	hl
	LD	HL,t_SD	;Send message to display
prm_:
; 6*40=240
	ld	A,6*40	;col=0, str=6
	ld	C,CMDP	;99H
	OUT	(C),A
	LD	A,40H+08h
prm_2:
	OUT	(C),A	;Adress VRAM = 0800h
	call	print
	pop	hl
	pop	bc
	ret
;---------------------------------------------
t_SD:	db	'Load from SD-card',0
t_EPCS:	db	'Load from EPCS4  ',0
t_ERR:	db	'Error BIOS',0
;=============================================
;=============================================
set41CMD:
	ld	hl,4000h
	ld	a,(hl)
	ld	(hl), 40h+41	;CMD41
	ld	(hl), 40h
	ld	(hl), 0
	ld	(hl), 0
	ld	(hl), 0
	ld	(hl), 95h	;CRC
	jr	set_		;
;=============================================
set8CMD:
	ld	hl,4000h
	ld	a,(hl)
	ld	(hl), 40h+8	;CMD8
	ld	(hl), 0
	ld	(hl), 0
	ld	(hl), 01h
	ld	(hl), 0AAh
	ld	(hl), 87h	;CRC
	jr	set_
;==========================================
; (b) -> CMD
set0cmd:ld	c,0		;parametr = 0
	ld	de,0		;
;=============================================
; for SD/MMC
set_cmd:	
	ld	hl, 4000h	;
type_c	equ	$+1
	ld	a, 0		;card type
	cp	(hl)		;
	ld	(hl), b		;CMD
	bit	1,a
	jr	z,set_sd	;bit1 = 1 (SDHC)
; for SDHC
	ld	(hl), 0
	ld	(hl), c
	ld	(hl), d
	ld	(hl), e
	jr	set_crc		;
; for SD/MMC
set_sd:	
	sla	e		;number of sector
	rl	d		; -> number of byte
	rl	c		; cde*2
	ld	(hl), c
	ld	(hl), d
	ld	(hl), e
	ld	(hl), 0
set_crc:ld	(hl), 95h	;CS=95h
set_:	ld	a, (hl)
	ld	b, 16
;/-----
cikl_4:	ld	a, (hl)
	cp	0FFh
	ccf	
	ret	nc		;no ERROR
	djnz	cikl_4
;\-----
	scf			;ERROR
	ret	
;=================================
; SD Init
init_sd:
	ld	b, 10		;
init_c:	ld	a, (5000h)	; /CS=1 (bit12)
	djnz	init_c
;\-----
	ld	b, 40h+0	; CMD=0 GO_IDLE_STATE
	call	set0CMD
	ret	c		; error
	and	0F7h		;
	cp	01h		;bit0 - in idle state ?
	scf			;CY=1
	ret	nz		; error
; bit 0=1 (in idle state)
;--------------------------------
	call	set8CMD		; CMD8
	cp	01h
	jr	nz, mmc_	; Not SD-card
	ld	a,(hl)
	ld	a,(hl)
	ld	a,(hl)
	and	0Fh
	cp	01h		;
	scf			;CY=1
	ret	nz		; error
	ld	a,(hl)
	cp	0AAh
	scf			;CY=1
	ret	nz		; error
;--------------------------------
cikl_i:	ld	b, 40h+55	; CMD=55 APP_CMD
	call	set0CMD
	ret	c		; error
	and	4		;bit 2=1 - illegal command
	jr	z, com_OK	;command OK
; command for MMC-card
mmc_:	xor	a		; type_c = 0 (MM-card)
	ld	(type_c),a	; Card type 0-MM, 1 - SD
	ld	b, 40h+1	; CMD=1 SEND_OP_COND
	call	set0CMD
	jr	corr
; command for SD-card
com_OK:	ld	a,1		; type_c = 1 (SD-card)
	ld	(type_c),a
	call	set41CMD	; ACMD=41 APP_SEND_OP_COND
corr:	ret	c		; error
	cp	01h		; in_idle_state=1 ?
	jr	z, cikl_i	; yes, repeat
;\-------------------------------
; in_idle_state = 0
	or	a		; CY=0
	jr	z,init0ok	;	Ok
	scf			; CY=1
	ret			; 	error
init0ok:
	ld	a,(type_c)
	or	a		; if MMC
	ret	z		;	return
; select SD or SDHC
	ld	b,40h+58	; CMD58 READ_OCR
	call	set0CMD
	ret	c		; error
	ld	a,(hl)		; read CCS (bit 6)
	cp	(hl)
	cp	(hl)
	cp	(hl)
	bit	6,a		; CCS=1 ?
	ret	z		; SD-card   CCS=0
	ld	a,2		; SDHC-card CCS=1
	ld	(type_c),a
	ret
;==========================================
; reinit SD-card
reinit:	call	init_sd
	pop	bc
	pop	de
	pop	hl
	ret	c		;error
;***********************************************
; load (b) sectors from MMC/SD/SDHC
; c,d,e = sector number
; hl = adress for load
;***********************************************
rd_16sd:ld	b,32		;32*512=16kb
	ld	hl,8000h	; eseram
rd_card:push	hl
	push	de
	push	bc
	ld	b, 51h		;CMD17 - READ_SINGLE_BLOCK
	call	set_cmd
	jr	c, reinit	;error
;
	pop	bc
	pop	de
	pop	hl
	or	a
	scf	
	ret	nz		;error
;
	push	de
	push	bc
	ex	de, hl		;de = adress for load
	ld	bc, 200h	;512 byte
	ld	hl, 4000h
;/------
cikl_5:	ld	a, (hl)
	cp	0FEh
	jr	nz, cikl_5
;\------
	ldir			;read sector
	ex	de, hl
	ld	a, (de)
	pop	bc
	ld	a, (de)
	pop	de
	inc	de		;sector+1
	ld	a, d
	or	e
	jr	nz, pass_2
;
	inc	c
pass_2:	djnz	rd_card		;next sector
;
	ret	
;=================================
; search "FAT"
src_FAT:
	ld	hl, buffer	;buffer
	ld	bc, 80h
;/-----
cikl_6:	ld	a,'F'
	cpir	
	jr	z, pass_3
	ret			;Z=0, no FAT
;-------
pass_3:	push	hl
	ld	d, (hl)
	inc	hl
	ld	e, (hl)
	ld	hl,'AT'
	or	a
	sbc	hl, de
	pop	hl
	jr	nz, cikl_6
;\------ yes marker "FAT"
	ret			;Z=1 yes FAT
;=================================
; test MBR - search partition
test_MBR:
	ld	b, 4		;number partition
	ld	ix, buffer+1beh	;offset in sector
;/-----
cikl_7:	ld	e, (ix+8)	;
	ld	d, (ix+9)	;
	ld	c, (ix+10)	;cde - start sector
	ld	a, c
	or	d
	or	e		;cde /= 0 OK
	ret	nz		;Yes partition (CY=0)
; next partition
	ld	de, 16
	add	ix, de
	djnz	cikl_7
;\----- no partition
	scf			;CY=1 error
	ret	
;=========================================
; test BIOS on MMC/SD/SDHC
test_BIOS:
	ld	ix, buffer	;PBR sector
;
	ld	l, (ix+0Eh)	;number of reserved
	ld	h, (ix+0Fh)	;sectors
	ld	a, c
	add	hl, de
	adc	a, 0
	ld	c, a
;---
	ld	e, (ix+11h)	;number of root
	ld	d, (ix+12h)     ;directory entries
	ld	a, e
	and	0Fh
	ld	b, 4
cikl_1:	srl	d
	rr	e
	djnz	cikl_1
;
	or	a
	jr	z, pass_1
;
	inc	de
pass_1:	push	de
	ld	b, (ix+10h)	; number of FAT
;
	ld	e, (ix+16h)	; number of sectors
	ld	d, (ix+17h)	; per FAT
	ld	a, c
cikl_2:	add	hl, de
	adc	a, 0
	djnz	cikl_2
;\------
	pop	de
	add	hl, de
	ex	de, hl
	ld	c, a
;
	push	de
	push	bc
	ld	b, 1		;1 sector
	ld	hl, buffer	; buffer
	call	rd_card		; read MMC/SD/SDHC
	ret	c		;  error
;
	ld	hl, (buffer)	;2 first byte
	ld	de,'BA'		;'AB' marker disk BIOS
	or	a
	sbc	hl, de		;compare
	pop	bc
	pop	de
	ret	z		;yes marker
	scf			;CY=1, error
	ret
;--------------------------------------
PRINT:	xor	A	;Print a string in [HL] up to <20h
	ld	A,(HL)
	inc	HL
	sub	20H
	ret	c	;exit if < 20h
	out	(DATP),A
	jr	PRINT+1
;-------------------------------
; end iplromz2.inc
