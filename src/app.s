
.equ SCREEN_WIDTH, 		640
.equ SCREEN_HEIGHT,		480
.equ SCALE_FACTOR,      10
.equ BITS_PER_PIXEL,  	32
.equ MAX_WIDTH,         SCREEN_WIDTH / SCALE_FACTOR - 1
.equ MAX_HEIGHT,        SCREEN_HEIGHT / SCALE_FACTOR - 1

.equ BLACK, 0x00000000
.equ WHITE, 0x00FFFFFF

.data
    gb_green: .word 0x00CADC9F
    cyan:     .word 0x0046878F

.text
.globl main
main:
    mov x20, x0 /* FRAMEBUFFER */

    mov x0, x20
    ldr w3, gb_green
    bl init_screen

    mov x0, x20
    mov x1, MAX_WIDTH
    mov x2, MAX_HEIGHT
    ldr w3, cyan
    bl point

    mov x0, x20
    mov x1, 0
    mov x2, 0
    ldr w3, cyan
    bl point

InfLoop:
    b InfLoop


/*
    Subroutine: pixel

    Brief:
        Draw a pixel into the framebuffer

    Params:
        x0 - framebuffer
        x1 - x pos
        x2 - y pos
        w3 - color
*/
pixel:
    sub sp, sp, 8
    str x19, [sp]

    mov x19, SCREEN_WIDTH
    mul x2, x2, x19
    add x1, x1, x2

    str w3, [x0, x1, lsl 2]

_pixel:
    ldr x19, [sp]
    add sp, sp, 8

    ret

/*
    Subroutine: point

    Brief:
        Draw a point into the framebuffer based on the scale factor

    Params:
        x0 - framebuffer
        x1 - x pos
        x2 - y pos
        w3 - color

    Notes:
        The point coords should be choosen from 0,0 to MAX_WIDTH,MAX_HEIGHT
*/
point:
    sub sp, sp, 48
    str x19, [sp, 32]
    str x20, [sp, 24]
    str x21, [sp, 16]
    str x22, [sp, 8]
    str x30, [sp]

    mov x19, SCALE_FACTOR

    mul x20, x1, x19  /* x min */
    add x21, x20, x19 /* x max */
    sub x20, x20, 1

    mul x22, x2 , x19 /* y min */
    add x12, x22, x19 /* y max */
    mov x13, x22      /* y temp */


point_loopx:
    add x20, x20, 1
    cmp x20, x21
    beq _point

    mov x22, x13

point_loopy:
    cmp x22, x12
    beq point_loopx

    mov x1, x20
    mov x2, x22
    bl pixel

    add x22, x22, 1
    b point_loopy

_point:
    ldr x30, [sp]
    ldr x22, [sp, 8]
    ldr x21, [sp, 16]
    ldr x20, [sp, 24]
    ldr x19, [sp, 32]
    add sp, sp, 48

    ret

/*
    Subroutine: init_screen

    Brief:
        Paint the entire screen with a color

    Params:
        x0 - framebuffer
        w3 - color
*/
init_screen:
    sub sp, sp, 24
    str x19, [sp, 16]
    str x20, [sp, 8]
    str lr,  [sp]

    mov x19, SCREEN_WIDTH
init_screen_loopx:
    subs x19, x19, 1
    blt _init_screen

    mov x20, SCREEN_HEIGHT
init_screen_loopy:
    subs x20, x20, 1
    blt init_screen_loopx

    mov x1, x19
    mov x2, x20
    bl pixel

    b init_screen_loopy

_init_screen:
    ldr lr,  [sp]
    ldr x20, [sp, 8]
    ldr x19, [sp, 16]
    add sp, sp, 24

    ret
