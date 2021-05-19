CSEG AT 0h

COMPARE EQU Buffer1X

; Snake Calculation
Buffer1X EQU 20h; Col
Buffer1Y EQU 21h; Row
Buffer2X EQU 22h; Col
Buffer2Y EQU 23h; Row

; Lenght 3
mov 2Ah ,#08h; 3
mov 2Bh, #20h; F
mov 2Ch, #08h; 3
mov 2Dh, #40h; G

; Starting point
HeadX EQU 28h; Keep in sync with incrementor initial value (!!!)
HeadY EQU 29h
setb HeadX.3; 3
setb HeadY.4; E
mov Buffer1X, HeadX
mov Buffer1Y, HeadY

; Snake on grid with LEDs
SnakeLedRepresentationX EQU 24h
SnakeLedRepresentationY EQU 25h


MOVE_STATE EQU 27h
MOVE_STATE_left EQU MOVE_STATE.0
MOVE_STATE_right EQU MOVE_STATE.1
MOVE_STATE_up EQU MOVE_STATE.2
MOVE_STATE_down EQU MOVE_STATE.3
setb MOVE_STATE_UP


; Init
lcall setTimer
lcall startTimer
ljmp main

; Timer
setTimer:
mov TMOD, #01h ; Timer0, 16bit
clr TF0
mov TL0, #000h; Timer low
mov TH0, #0FFh; Timer high
; setb ET0
; setb EA
ret

startTimer:
setb TR0
ret

; Light up Matrix
;updateMatrixLed:
;mov P0, SnakeLedRepresentationY
;mov P1, SnakeLedRepresentationX
;ret



updateSnake:
;;;;;;;;;;;;;;;; Check for game over ;;;;;;;;;;;;;;;;;;;;;;;;;
mov R1, #2Ah

gameOverCheckLoop:
isXEqual:
mov A, @R1
jz SnakeLengthener ; check if we are at the end of the snake limbs
inc R1
inc R1
cjne A, Buffer1X, gameOverCheckLoop
isYEqual:
dec R1
mov A, @R1
inc R1
cjne A, Buffer1Y, gameOverCheckLoop

lcall gameOver


SnakeLengthener:
; Storage: starting from 28h
mov R1, #28h
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;; Snake Follow Loop ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
SnakeFollowLoop:
; R1 is our incrementor
; Given Buffer1 filled
; Save old Head to Buffer2

mov Buffer2X, @R1
inc R1
mov Buffer2Y, @R1

;;;;;;;;;;;;;;;;;;;;; Buffer1 X/Y ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Move Buffer1 to Head (Update first element with Buffer1)
; mov A, Buffer1X ; OR: Buffer1X, SnakeLedRepresentationX -> Save in SnakeLedRepresentationX
; orl SnakeLedRepresentationX, A
dec R1
mov @R1, Buffer1X

; mov A, Buffer1Y ; OR: Buffer1Y, SnakeLedRepresentationY -> save in SnakeLedRepresentationY
; orl SnakeLedRepresentationY, A
inc R1
mov @R1, Buffer1Y
inc R1

; Update snake with pos from buffer 1
mov P0, Buffer1Y
mov P1, Buffer1X


;;;;;;;;;;;;;;;;;;;;;;;;;; Break? ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Check if next element is 0
mov A, @R1
jz endUpdateSnakeFromBreak

;;;;;;;;;;;;;;;;;;;;; Buffer2 X/Y ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Store second element in Buffer1
mov Buffer1X, @R1
inc R1
mov Buffer1Y, @R1

; Move buffer2 to second element
dec R1
mov @R1, Buffer2X
; mov A, Buffer2X ; OR: Buffer2X, SnakeLedRepresentationX -> save in SnakeLedRepresentationX
; orl SnakeLedRepresentationX, A 
inc R1
mov @R1, Buffer2Y
inc R1
; mov A, Buffer2Y ; OR: Buffer2Y, SnakeLedRepresentationY -> save in SnakeLedRepresentationY
; orl SnakeLedRepresentationY, A 

; Update snake with pos from buffer 2
mov P0, Buffer2Y
mov P1, Buffer2X

;;;;;;;;;;;;;;;;;;;;;; End loop ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Start with loop again
mov A, @R1
jnz SnakeFollowLoop

endUpdateSnakeFromEndOfLoop:
; Check if timer is triggered
jnb TF0, returnFromSnake
lcall setTimer ; Reset timer

; Lengthen snake using buffer 1
mov @R1, buffer1X
inc R1
mov @R1, buffer1Y

mov P0, Buffer1Y
mov P1, Buffer1X

lcall returnFromSnake

endUpdateSnakeFromBreak:
; Check if timer is triggered
jnb TF0, returnFromSnake
lcall setTimer ; Reset timer

; Lengthen snake using buffer 2
mov @R1, buffer2X
inc R1
mov @R1, buffer2Y

mov P0, Buffer2Y
mov P1, Buffer2X

returnFromSnake:
; Move HEAD to Buffer1, so that move operations still work
mov Buffer1X, HeadX
mov Buffer1Y, HeadY
ret


;;;; Move Lookup table
; Register 20h
; Left  - #00000001b - bit 0
; Right - #00000010b - bit 1
; Up    - #00000100b - bit 2
; Down  - #00001000b - bit 3

setLeft:
mov MOVE_STATE, #00000001b ; MOVE_STATE_LEFT
ret

moveLeft:
clr C
mov A, Buffer1X
RR A
mov Buffer1X, A
ret

setRight:
mov MOVE_STATE, #00000010b ; MOVE_STATE_RIGHT
ret

moveRight:
clr C
mov A, Buffer1X
RL A
mov Buffer1X, A
ret

setUp:
mov MOVE_STATE, #00000100b ; MOVE_STATE_UP
ret

moveUp:
clr C
mov A, Buffer1Y
RR A
mov Buffer1Y, A
ret

setDown:
mov MOVE_STATE, #00001000b ; MOVE_STATE_DOWN
ret

moveDown:
clr C
mov A, Buffer1Y
RL A
mov Buffer1Y, A
ret


; ------------------------- MAIN ---------------------------------
main:
matrixCheckRight:
mov P2, #00001111b
jb P2.1, matrixCheckUp ; P2.1 is 0 if button "4" or "6" is pressed
mov P2, #11110000b
jb P2.6, matrixCheckLeft ; P2.6 is 0 if button "6" is pressed
call setRight
ljmp callMove

matrixCheckLeft:
jb P2.4, matrixCheckDown ; P2.4 is 0 if button "4" is pressed
call setLeft
ljmp callMove

matrixCheckUp:
mov P2, #11110000b
jb P2.5, callMove ; P2.5 is 0 if button "2" or "8" is pressed
mov P2, #00001111b
jb P2.0, matrixCheckDown ; P2.0 is 0 if button "2" is pressed
call setUp
ljmp callMove

matrixCheckDown:
jb P2.2, callMove ; P2.2 is 0 if button "8" is pressed
call setDown
; no ljmp callMove needed



callMove:
checkLeft:
jnb MOVE_STATE_LEFT, checkRight
call moveLeft
ljmp todo

checkRight:
jnb MOVE_STATE_RIGHT, checkUp
call moveRight
ljmp todo

checkUp:
jnb MOVE_STATE_UP, checkDown
call moveUp
ljmp todo

checkDown:
jnb MOVE_STATE_DOWN, todo
call moveDown

todo:
call updateSnake
; call updateMatrixLed

ljmp main


gameOver:
mov P0, #0FFh
mov P1, #0FFh
mov P0, #00h
mov P1, #00h
nop
jmp gameOver