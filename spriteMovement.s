.include "LAMAlib.inc"
.include "LAMAlib-sprites.inc"


sei
ldax #read_input ;interrupt routine
stax $314
cli


lda #193 ;facing down
sta 2040 ;sprite at $3000

clrscr ;clear screen

enableXexpandSprite 0 ;set up turtle sprite
enableYexpandSprite 0

enableMultiColorSprite 0
setSpriteColor 0,5
setSpriteMultiColor1 9
setSpriteMultiColor2 7


showSprite 0

setSpriteX 0,80
setSpriteY 0,80


lda #196 ;snake
sta 2041 ;uhhhh

enableXexpandSprite 1 ;set up snake sprite
enableYexpandSprite 1

setSpriteColor 1,5

showSprite 1

setSpriteX 1,200
setSpriteY 1,150

do
    for Y,80,to,200
        store Y
        setSpriteY 0,Y
        sync_to_rasterline256
        restore Y
    next

    lda #194 ;facing right
    sta 2040 ;switch sprite

    for X,80,to,200
        store X
        txa
        ldx #0
        setSpriteX 0,AX
        sync_to_rasterline256
        restore X
    next

    lda #192 ;facing up
    sta 2040 ;switch sprite

    for Y,200,downto,80
        store Y
        setSpriteY 0,Y
        sync_to_rasterline256
        restore Y
    next

    lda #195 ;facing left
    sta 2040 ;switch sprite

    for X,200,downto,80
        store X
        txa
        ldx #0
        setSpriteX 0,AX
        sync_to_rasterline256
        restore X
    next

    lda #193 ;facing down
    sta 2040 ;switch sprite


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
    if cc
        dec $d003 ;move up
    endif
    lsr joyvalue
    if cc
        inc $d003 ;move down
    endif
    lsr joyvalue
    if cc
        dec $d002 ;move left
    endif
    lsr joyvalue
    if cc
        inc $d002 ;move right
    endif

    jmp $ea31

joyvalue: .byte 00