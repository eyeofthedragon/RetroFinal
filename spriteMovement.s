.include "LAMAlib.inc"
.include "LAMAlib-sprites.inc"

SCREEN_BASE=$400
SPRITE_BASE=$3000
MUSIC_BASE=$c000

install_file "FlowerGathering.prg"

sei
ldax #read_input ;interrupt routine
stax $314
cli

init:
    lda #$00 ;select first line
    jsr MUSIC_BASE ;init music


clrscr ;clear screen

lda #14
sta $d020
lda #13
sta $d021

;****************************************************
;PLAYER SPRITE 0
;****************************************************

setSpriteCostume 0,SPRITE_BASE ;3040 is second costume

setSpriteColor 0,3
enableMultiColorSprite 0

setSpriteMultiColor1 0
setSpriteMultiColor2 8

enableXexpandSprite 0
enableYexpandSprite 0

setSpriteXY 0,200,200

showSprite 0

;****************************************************
;RED FLOWER SPRITE 1 (good)
;****************************************************

setSpriteCostume 1,SPRITE_BASE+3*$40

setSpriteColor 1,2
enableMultiColorSprite 1

rand16 216
adcax #40
setSpriteX 1,AX
setSpriteY 1,0

showSprite 1

;****************************************************
;DATE SPRITE 2
;****************************************************

setSpriteCostume 2,SPRITE_BASE+2*$40

setSpriteColor 2,4
enableMultiColorSprite 2

enableXexpandSprite 2
enableYexpandSprite 2

rand16 216
adcax #40
setSpriteX 2,AX
setSpriteY 2,40

showSprite 2

;****************************************************
;WHITE FLOWER SPRITE 3 (bad)
;****************************************************

setSpriteCostume 3,SPRITE_BASE+4*$40

setSpriteColor 3,1
enableMultiColorSprite 3

rand16 216
adcax #40
setSpriteX 3,AX
setSpriteY 3,40

showSprite 3

;****************************************************
;SCORE
;****************************************************

lda #14 ;N
sta 1297
lda #21 ;U
sta 1298
lda #13 ;M
sta 1299
lda #2 ;B
sta 1300
lda #5 ;E
sta 1301
lda #18 ;R
sta 1302

lda #15 ;O
sta 1339
lda #6 ;F
sta 1340

lda #6 ;F
sta 1376
lda #12 ;L
sta 1377
lda #15 ;O
sta 1378
lda #23 ;W
sta 1379
lda #5 ;E
sta 1380
lda #18 ;R
sta 1381
lda #19 ;S
sta 1382
lda #58 ;:
sta 1383


lda #48 ;0
sta 1459

;****************************************************
; SPRITE MOVEMENT - move sprite down across whole screen
;****************************************************
do
    for Y,0,to,255
        store Y
        setSpriteY 1,Y

        tya
        adc #30
        setSpriteY 2,A

        ;make sure each sprite loops once it hits the bottom of the screen
        sbc #254
        if ge ;if a > 255
            rand16 216
	    adcax #40
            setSpriteX 2,AX
	    showSprite 2
        endif
        adc #255

        setSpriteY 3,A

        sbc #254
        if ge
            rand16 216
	    adcax #40
            setSpriteX 3,AX
            showSprite 3
        endif
        adc #255

	;animation of player sprite
	mod16 #20
    cmpax #0
    if eq
        setSpriteCostume 0,SPRITE_BASE+$40
    endif
    cmpax #10
    if eq
        setSpriteCostume 0,SPRITE_BASE
    endif

        sync_to_rasterline256
        restore Y
    next

    rand16 216 ;puts a random number from 0 to 215 in AX
    adcax #40
    setSpriteX 1,AX
    showSprite 1
loop

rts

;****************************************************
; COLLISIONS AND INTERRUPT
;****************************************************

collisionPlus:
    ldy #5 ;green
    sty $d020
    hideSprite 1

    ldx currentScore
    inx
    stx 1459
    stx currentScore

    jmp $ea31

collisionMinus:
    ldy #2 ;red
    sty $d020
    hideSprite 3

    ldx currentScore
    txa
    sbc #49
    if ge ;don't decrement if we're already at 0
        dex
    endif
    stx 1459
    stx currentScore

    jmp $ea31


read_input:
    asl $d019 ;clear interrupt

    ;sprite collision register
    ldax $d01E
    cmpax #3
    beq collisionPlus
    cmpax #9
    beq collisionMinus
    cmpax #5
    longif eq ;game over
	    ldy #0 ;black
    	sty $d020
    	hideSprite 1
        hideSprite 2
        hideSprite 3
        print "oh no! "
        print "game over"
        delay_ms 3000
        rts
    endif

    ; win condition	
    lda currentScore
    cmp #56
    longif eq
        ldx #0
        stx currentScore
        hideSprite 1
        hideSprite 2
        hideSprite 3
        print "you win!"
        delay_ms 3000
        rts
    endif

    ;player movement
    read_keys_WASDspace
    and $dc00
    and $dc01

    sta joyvalue
    lsr joyvalue

    lsr joyvalue ;can't move up

    lsr joyvalue ;can't move down

    if cc
	lda $d000
	cmp #20
	if ge
        dec $d000 ;move left
	endif
    endif
    lsr joyvalue
    if cc
	lda $d000
	cmp #254
	if lt
        inc $d000 ;move right
	endif
    endif

    ;music
    asl $d019
    jsr MUSIC_BASE+3

    jmp $ea31

joyvalue: .byte 00
currentScore: .byte 48