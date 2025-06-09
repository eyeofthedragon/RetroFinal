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



do ;move sprite down across whole screen
    for Y,0,to,255
        store Y
        setSpriteY 1,Y

        tya
        adc #40
        setSpriteY 2,A

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

collision_detection:
    asl $d019 ;clear interrupt
    ldx $d01e ;sprite collision register
    bne collision
    jmp $ea31

collision:
    ldy #2 ;red
    sty $d020


read_input:
    asl $d019 ;clear interrupt

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