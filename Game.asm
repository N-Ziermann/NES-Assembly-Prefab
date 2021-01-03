
setINesHeader:
	.inesprg 1   ; 1 bank of code
	.ineschr 1   ; 1 bank of spr/bkg data
	.inesmir 1   ; always 1
	.inesmap 0   ; we use mapper 0

configureStartup:
	.bank 1   	; following goes in bank 1
	.org $FFFA  ; start at $FFFA
	.dw 0    		; give 0 as address for NMI routine
	.dw Start 	; give address of start of our code for execution on reset of NES.
	.dw 0   		; give 0 for address of VBlank interrupt handler, we tell PPU not to make an interrupt for VBlank.

initCodeArea:
	.bank 0
	.org $8000  ; code starts at $8000

Start:
Variables:


Sprites:
	lda #20
	sta $0300		; Sprite1 Y
	lda #1
	sta $0301		; Sprite1 tile
	lda #%01000011
	sta $0302		; Sprite1 special byte (last two bits=palette selection)
	lda #20
	sta $0303		; Sprite1 X

PPUSetup:
	lda #%00001000
	sta $2000
	lda #%00011110
	sta $2001

	ldx #$00    ; restart counter variable x

	lda #$3F    ; use address $2006 to tell the ppu where to write visual values
	sta $2006   ; written manually to $2007 to
	lda #$00    ; ($3F00)
	sta $2006

loadpal:
	lda tilepal, x
	sta $2007
	inx
	cpx #32 		; continue until all 32 colors were loaded
	bne loadpal

prepareBackgroundAddress:
	lda #$20
	sta $2006 	; give $2006 both parts of address $2000.
	lda #$00
	sta $2006

mapPart0:
	ldx #$0			; prepare counter variable
loadNames0:
	lda map0, X ; load A with a byte from address (ourMap + X)
	inx
	sta $2007
	cpx #224
	bne loadNames0 ; if whole map-part was gone though

mapPart1:
	ldx #$0			; prepare counter variable
loadNames1:
	lda map1, X ; load A with a byte from address (ourMap + X)
	inx
	sta $2007
	cpx #224
	bne loadNames1 ; if whole map-part was gone though

mapPart2:
	ldx #$0			; prepare counter variable
loadNames2:
	lda map2, X ; load A with a byte from address (ourMap + X)
	inx
	sta $2007
	cpx #224
	bne loadNames2 ; if whole map-part was gone though

mapPart3:
	ldx #$0			; prepare counter variable
loadNames3:
	lda map3, X ; load A with a byte from address (ourMap + X)
	inx
	sta $2007
	cpx #224
	bne loadNames3 ; if whole map-part was gone though

mapPart4:
	ldx #$0			; prepare counter variable
loadNames4:
	lda map4, X ; load A with a byte from address (ourMap + X)
	inx
	sta $2007
	cpx #64
	bne loadNames4 ; if whole map-part was gone though
setBackgroundColor:
	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	;; byte value: 11 10 01 00	(each tuple = one square)	;;
	;;																										;;
	;;	00 01																							;;
	;; 	10 11																							;;
	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	ldx #0
bgParameterLoop:
	lda mapParameters, X
	inx
	sta $2007
	cpx #240
	bne bgParameterLoop

infin:

ControllerInput:

LoadButtonsHeld:
	lda #1
	sta $4016
	lda #0
	sta $4016

ReadButtonsHeld:
	lda $4016	; A
	and #1		; pressed?
	beq notA
	; if pressed here

isJumping:
notA:
	lda $4016	; B
	and #1		; pressed?
	beq notB
	; if pressed her

notB:
	lda $4016	; SELECT
	and #1		; pressed?
	beq notSelect
	; if pressed her

notSelect:
	lda $4016	; START
	and #1		; pressed?
	beq notStart
	; if pressed her

notStart:
	lda $4016	; UP
	and #1		; pressed?
	beq notUp
	; if pressed her

notUp:
	lda $4016	; DOWN
	and #1		; pressed?
	beq notDown
	; if pressed her

notDown:
	lda $4016	; LEFT
	and #1		; pressed?
	beq notLeft
	; if pressed her

notLeft:
	lda $4016	; RIGHT
	and #1		; pressed?
	beq notRight
	; if pressed here

notRight:
;;;;;;;;;;;;;;;;;;;;;
;;LOGIC STARTS HERE;;
;;;;;;;;;;;;;;;;;;;;;

;;;;;;;;;;;;;;;;;;;;;
;; LOGIC ENDS HERE ;;
;;;;;;;;;;;;;;;;;;;;;

waitblank:        ; this is the wait for VBlank code
	lda $2002  			; these 3 lines wait for VBlank
	bpl waitblank

setSpriteLocation:
	lda #$3
	sta $4014
	jmp infin				; END OF LOOP

; include all graphics files
tilepal: .incbin "our.pal"
map0: .incbin "map/0.map"
map1: .incbin "map/1.map"
map2: .incbin "map/2.map"
map3: .incbin "map/3.map"
map4: .incbin "map/4.map"
mapParameters: .incbin "map/parameters.map"
	.bank 2
	.org $0000
	.incbin "our.bkg"
	.incbin "our.spr"
