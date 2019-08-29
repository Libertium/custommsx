; vdp_sets.inc
;-------------------------------
; VDP port 99H (set register)
dat_99:	db	00h,80h	; 00h -> R0
	db	50h,81h	; 50h -> R1 (40X24, TEXT Mode)
	db	02h,82h	; 02h -> R2
	db	00h,84h	; 00h -> R4
	db	0F4h,87h;0F4h -> R7 Set Color (White on Blue)
	db	00h,89h	; 00h -> R9  (PAL-mode)
	db	00h,90h	; 00h -> R16 (Palette)
; VDP port 9Ah (set color palette)
;	   Red/Blue,Green
dat_9A:	db	0  ,0	;0
	db	0  ,0	;1
	db	11h,6	;2
	db	33h,7	;3
	db	17h,1	;4
	db	27h,3	;5
	db	51h,1	;6
	db	27h,6	;7
	db	71h,1	;8
	db	73h,3	;9
	db	61h,6	;10
	db	64h,6	;11
	db	11h,4	;12
	db	65h,2	;13
	db	55h,5	;14
	db	77h,7	;15
;===============================
; end vdp_sets
