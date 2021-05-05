CSEG AT 0h
Port0 EQU 80h
Port1 EQU 90h
Port2 EQU 0A0h

MCol EQU 21h
MRow EQU 22h
MOVE_STATE EQU 20h
MOVE_STATE_left EQU MOVE_STATE.0
MOVE_STATE_right EQU MOVE_STATE.1
MOVE_STATE_up EQU MOVE_STATE.2
MOVE_STATE_down EQU MOVE_STATE.3

setb MCol.3
setb MRow.4

; Init
lcall setTimer
lcall startTimer
ljmp main

; Timer
setTimer:
mov TMOD, #01h ; Timer0, 16bit
clr TF0
mov TL0, #0EBh; Timer low
mov TH0, #0FFh; Timer high
; setb ET0
; setb EA
ret

startTimer:
setb TR0
ret

; Light up Matrix
updateMatrixLed:
mov Port0, MRow
mov Port1, MCol
ret

updateSnake:
jnb TF0, endUpdateSnake
lcall setTimer
; ...
endUpdateSnake:
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
mov A, MCol
RR A
mov MCol, A
ret

setRight:
mov MOVE_STATE, #00000010b ; MOVE_STATE_RIGHT
ret

moveRight:
clr C
mov A, MCol
RL A
mov MCol, A
ret

setUp:
mov MOVE_STATE, #00000100b ; MOVE_STATE_UP
ret

moveUp:
clr C
mov A, MRow
RR A
mov MRow, A
ret

setDown:
mov MOVE_STATE, #00001000b ; MOVE_STATE_DOWN
ret

moveDown:
clr C
mov A, MRow
RL A
mov MRow, A
ret


; ------------------------- MAIN ---------------------------------
main:
matrixCheckRight:
mov P2, #00001111b
jb Port2.1, matrixCheckUp ; Port2.1 is 0 if button "4" or "6" is pressed
mov P2, #11110000b
jb Port2.6, matrixCheckLeft ; Port2.6 is 0 if button "6" is pressed
call setRight
ljmp callMove

matrixCheckLeft:
jb Port2.4, matrixCheckDown ; Port2.4 is 0 if button "4" is pressed
call setLeft
ljmp callMove

matrixCheckUp:
mov P2, #11110000b
jb Port2.5, callMove ; Port2.5 is 0 if button "2" or "8" is pressed
mov P2, #00001111b
jb Port2.0, matrixCheckDown ; Port2.0 is 0 if button "2" is pressed
call setUp
ljmp callMove

matrixCheckDown:
jb Port2.2, callMove ; Port2.2 is 0 if button "8" is pressed
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
call updateMatrixLed
call updateSnake

ljmp main