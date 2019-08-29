; zg68.inc
.XLIST
zg_68:
; 20h..3Fh
	db    000h,000h,000h,000h,000h,000h,000h,000h	; SPACE
	db    000h,020h,020h,020h,020h,000h,020h,000h	; !
	db    000h,048h,048h,000h,000h,000h,000h,000h	; "
	db    000h,000h,050h,0F8h,050h,0F8h,050h,000h	; #
	db    000h,020h,0F8h,0A0h,0F8h,028h,0F8h,020h	; $
	db    000h,000h,0C8h,0D0h,020h,058h,098h,000h	; %
	db    000h,040h,0A0h,040h,0A8h,090h,068h,000h	; &
	db    000h,020h,040h,000h,000h,000h,000h,000h	; '
	db    000h,008h,010h,010h,010h,010h,008h,000h	; (
	db    000h,040h,020h,020h,020h,020h,040h,000h	; (
	db    000h,000h,050h,020h,0F8h,020h,050h,000h	; *
	db    000h,000h,020h,020h,0F8h,020h,020h,000h	; +
	db    000h,000h,000h,000h,000h,020h,020h,040h	; ,
	db    000h,000h,000h,000h,0F8h,000h,000h,000h	; -
	db    000h,000h,000h,000h,000h,060h,060h,000h	; .
	db    000h,000h,008h,010h,020h,040h,080h,000h	; /
; 30h..3Fh
	db    000h,070h,098h,0A8h,0A8h,0C8h,070h,000h	; 0
	db    000h,020h,060h,020h,020h,020h,0F8h,000h	; 1
	db    000h,070h,088h,008h,070h,080h,0F8h,000h	; 2
	db    000h,070h,088h,030h,008h,088h,070h,000h	; 3
	db    000h,010h,030h,050h,090h,0F8h,010h,000h	; 4
	db    000h,0F8h,080h,0F0h,008h,088h,070h,000h	; 5
	db    000h,070h,080h,0F0h,088h,088h,070h,000h	; 6
	db    000h,0F8h,008h,010h,020h,020h,020h,000h	; 7
	db    000h,070h,088h,070h,088h,088h,070h,000h	; 8
	db    000h,070h,088h,088h,078h,008h,070h,000h	; 9
	db    000h,000h,020h,000h,000h,020h,000h,000h	; :
	db    000h,000h,020h,000h,000h,020h,020h,040h	; ;
	db    000h,000h,010h,020h,040h,020h,010h,000h	; <
	db    000h,000h,000h,078h,000h,078h,000h,000h	; =
	db    000h,000h,020h,010h,008h,010h,020h,000h	; >
	db    000h,070h,088h,010h,020h,000h,020h,000h	; ?
; 40h..4Fh
	db    000h,070h,0A8h,0A8h,0B0h,080h,078h,000h	; @
	db    000h,078h,088h,088h,0F8h,088h,088h,000h	; A
	db    000h,0F0h,088h,0F0h,088h,088h,0F0h,000h	; B
	db    000h,070h,088h,080h,080h,088h,070h,000h	; C
	db    000h,0E0h,090h,088h,088h,088h,0F0h,000h	; D
	db    000h,0F8h,080h,0F0h,080h,080h,0F8h,000h	; E
	db    000h,0F8h,080h,0F0h,080h,080h,080h,000h	; F
	db    000h,070h,088h,080h,0B8h,088h,070h,000h	; G
	db    000h,088h,088h,0F8h,088h,088h,088h,000h	; H
	db    000h,0F8h,020h,020h,020h,020h,0F8h,000h	; I
	db    000h,008h,008h,008h,088h,088h,070h,000h	; J
	db    000h,090h,0A0h,0C0h,0A0h,090h,088h,000h	; K
	db    000h,080h,080h,080h,080h,080h,0F8h,000h	; L
	db    000h,088h,0D8h,0A8h,0A8h,088h,088h,000h	; M
	db    000h,088h,088h,0C8h,0A8h,098h,088h,000h	; N
	db    000h,070h,088h,088h,088h,088h,070h,000h	; O
; 50h..5Fh
	db    000h,0F0h,088h,088h,0F0h,080h,080h,000h	; P
	db    000h,070h,088h,088h,088h,0A8h,070h,010h	; Q
	db    000h,0F0h,088h,088h,0F0h,090h,088h,000h	; R
	db    000h,070h,080h,070h,008h,088h,070h,000h	; S
	db    000h,0F8h,020h,020h,020h,020h,020h,000h	; T
	db    000h,088h,088h,088h,088h,088h,070h,000h	; U
	db    000h,088h,088h,088h,088h,050h,020h,000h	; V
	db    000h,088h,088h,088h,0A8h,0A8h,050h,000h	; W
	db    000h,088h,050h,020h,020h,050h,088h,000h	; X
	db    000h,088h,088h,050h,020h,020h,020h,000h	; Y
	db    000h,0F8h,090h,020h,040h,088h,0F8h,000h	; Z
	db    000h,070h,040h,040h,040h,040h,070h,000h	; [
	db    000h,000h,080h,040h,020h,010h,008h,000h	; \
	db    000h,070h,010h,010h,010h,010h,070h,000h	; ]
	db    000h,020h,050h,088h,000h,000h,000h,000h	; ^
	db    000h,000h,000h,000h,000h,000h,000h,0FCh	; _
; 60h..6Fh
	db    000h,040h,040h,020h,000h,000h,000h,000h	; `
	db    000h,000h,070h,008h,078h,088h,078h,000h	; a
	db    000h,080h,080h,0F0h,088h,088h,0F0h,000h	; b
	db    000h,000h,070h,088h,080h,080h,078h,000h	; c
	db    000h,008h,008h,078h,088h,088h,078h,000h	; d
	db    000h,000h,070h,088h,0F0h,080h,078h,000h	; e
	db    000h,018h,020h,030h,020h,020h,020h,000h	; f
	db    000h,000h,078h,088h,088h,078h,008h,070h	; g
	db    000h,080h,080h,0F0h,088h,088h,088h,000h	; h
	db    000h,020h,000h,060h,020h,020h,070h,000h	; i
	db    000h,008h,000h,008h,008h,008h,048h,030h	; j
	db    000h,040h,050h,060h,060h,050h,048h,000h	; k
	db    000h,020h,020h,020h,020h,020h,018h,000h	; l
	db    000h,000h,0D0h,0A8h,0A8h,0A8h,0A8h,000h	; m
	db    000h,000h,0F0h,088h,088h,088h,088h,000h	; n
	db    000h,000h,070h,088h,088h,088h,070h,000h	; o
; 70h..7Fh
	db    000h,000h,0F0h,088h,088h,0F0h,080h,080h	; p
	db    000h,000h,070h,090h,090h,070h,010h,018h	; q
	db    000h,000h,038h,040h,040h,040h,040h,000h	; r
	db    000h,000h,070h,080h,070h,008h,0F0h,000h	; s
	db    000h,020h,070h,020h,020h,020h,018h,000h	; t
	db    000h,000h,088h,088h,088h,088h,070h,000h	; u
	db    000h,000h,088h,088h,050h,050h,020h,000h	; v
	db    000h,000h,088h,0A8h,0A8h,0A8h,050h,000h	; w
	db    000h,000h,088h,050h,020h,050h,088h,000h	; x
	db    000h,000h,088h,088h,088h,078h,008h,070h	; y
	db    000h,000h,0F8h,010h,020h,040h,0F8h,000h	; z
	db    000h,038h,020h,0C0h,020h,020h,038h,000h	; {
	db    000h,020h,020h,020h,020h,020h,020h,000h	; |
	db    000h,0E0h,020h,018h,020h,020h,0E0h,000h	; }
	db    000h,028h,050h,000h,000h,000h,000h,000h	; ~
	db    030h,048h,0B4h,0C4h,0C4h,0B4h,048h,030h	; DEL
.LIST
; end zg6x8.inc