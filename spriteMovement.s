.include "LAMAlib.inc"
.include "LAMAlib-sprites.inc"
SCREEN_BASE=$400

sei
ldax #read_input ;interrupt routine
stax $314
cli

clrscr ;clear screen

;****************************************************
;PLAYER SPRITE 0
;****************************************************

setSpriteCostume 0,$3000
setSpriteColor 0,5
enableMultiColorSprite 0

enableXexpandSprite 0
enableYexpandSprite 0

setSpriteXY 0,200,200

showSprite 0

;****************************************************
;FLOWER SPRITE 1 (good)
;****************************************************

setSpriteCostume 1,$3040
setSpriteColor 1,5
enableMultiColorSprite 1
setSpriteMultiColor1 9

enableXexpandSprite 1
enableYexpandSprite 1

rand16 256
setSpriteX 1,AX
setSpriteY 1,0

showSprite 1

;****************************************************
;FLOWER SPRITE 2 (evil)
;****************************************************

;setSpriteCostume 1,$3080
lda #195
sta 2042

setSpriteColor 2,5
enableMultiColorSprite 2
setSpriteMultiColor2 7

enableXexpandSprite 2
enableYexpandSprite 2

rand16 256
setSpriteX 2,AX
setSpriteY 2,40

showSprite 2

;****************************************************
;DATE SPRITE 3
;****************************************************

;setSpriteCostume 1,$3120
lda #194
sta 2043

setSpriteColor 3,5
enableMultiColorSprite 3

enableXexpandSprite 3
enableYexpandSprite 3

rand16 256
setSpriteX 3,AX
setSpriteY 3,40

showSprite 3

;****************************************************
; SPRITE MOVEMENT
;****************************************************

;SCORE

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


do ;move sprite down across whole screen
    for Y,0,to,255
        store Y
        setSpriteY 1,Y

        tya
        adc #40
        setSpriteY 2,A

        ;make sure each sprite loops once it hits the bottom of the screen
        sbc #254
        if ge ;if a > 255
            rand16 256
            setSpriteX 2,AX
	        showSprite 2
        endif
        adc #255

        adc #40
        setSpriteY 3,A

        sbc #254
        if ge
            rand16 256
            setSpriteX 3,AX
            showSprite 3
        endif
        adc #255

        sync_to_rasterline256
        restore Y
    next

    rand16 256 ;puts a random number from 0 to 255 in AX
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
    jmp $ea31

collisionMinus:
    ldy #2 ;red
    sty $d020
    hideSprite 2
    jmp $ea31

collisionOver:
    ldy #0 ;black
    sty $d020
    hideSprite 3
    jmp $ea31


    ldx currentScore
    inx
    stx 1459
    stx currentScore

    ;sprite collision register
    ldax $d01E
    cmpax #3
    beq collisionPlus
    cmpax #5
    beq collisionMinus
    cmpax #9
    beq collisionOver


    ;player movement
    read_keys_WASDspace
    and $dc00
    and $dc01

    sta joyvalue
    lsr joyvalue

    lsr joyvalue ;can't move up

    lsr joyvalue ;can't move down

    if cc
        dec $d000 ;move left
    endif
    lsr joyvalue
    if cc
        inc $d000 ;move right
    endif

    jmp $ea31

joyvalue: .byte 00
currentScore: .byte 00 ;girl I have no idea



