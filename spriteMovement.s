.include "LAMAlib.inc"
.include "LAMAlib-sprites.inc"


sei
ldax #read_input ;interrupt routine
stax $314
cli

clrscr ;clear screen

;PLAYER SPRITE
lda #196 ;snake
sta 2040 ;sprite at $3040

enableXexpandSprite 0
enableYexpandSprite 0

setSpriteColor 0,5

setSpriteX 0,200
setSpriteY 0,200

showSprite 0


;FLOWER SPRITES
lda #193 ;turtle facing down
sta 2041 ;sprite at $3000

enableXexpandSprite 1 ;set up turtle sprite
enableYexpandSprite 1

enableMultiColorSprite 1
setSpriteColor 1,5
setSpriteMultiColor1 9
setSpriteMultiColor2 7

rand16 256
setSpriteX 1,AX
setSpriteY 1,0

showSprite 1


lda #195 ;test sprite????
sta 2042 ;sprite at $3080

enableXexpandSprite 2 ;set up turtle sprite
enableYexpandSprite 2

enableMultiColorSprite 2
setSpriteColor 2,5
setSpriteMultiColor1 9
setSpriteMultiColor2 7

rand16 256
setSpriteX 2,AX
setSpriteY 2,40

showSprite 2


lda #194 ;test sprite????
sta 2043 ;sprite at $3080

enableXexpandSprite 3 ;set up turtle sprite
enableYexpandSprite 3

enableMultiColorSprite 3
setSpriteColor 3,5
setSpriteMultiColor1 9
setSpriteMultiColor2 7

rand16 256
setSpriteX 3,AX
setSpriteY 3,40

showSprite 3


;okay okay
;so to poke things onto the screen
;it's 1024 + some amount. so if I can just find the right spot
;it'll be >1024+255 which is uhhh 1279
;let's just try
;equiv of poke 1285,81 <-ball
;which is uh
;load 81 into A
;store value of a into 1285

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
        endif
        adc #255

        adc #40
        setSpriteY 3,A

        sbc #254
        if ge
            rand16 256
            setSpriteX 3,AX
        endif
        adc #255

        sync_to_rasterline256
        restore Y
    next

    rand16 256 ;puts a random number from 0 to 255 in AX
    setSpriteX 1,AX
loop

rts


collision:
    ldy #2 ;red
    sty $d020


    ldx currentScore
    inx
    stx 1459
    stx currentScore



read_input:
    asl $d019 ;clear interrupt
    ldx $d01e ;sprite collision register
    bne collision

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



