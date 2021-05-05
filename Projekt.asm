Port0 EQU 80h
Port1 EQU 90h
Port2 EQU 0A0h
MD EQU Port0.3
M3 EQU Port1.3
MOVE_STATE EQU 20h
MOVE_STATE_left EQU MOVE_STATE.0
MOVE_STATE_right EQU MOVE_STATE.1
MOVE_STATE_up EQU MOVE_STATE.2
MOVE_STATE_down EQU MOVE_STATE.3

; Light up Matrix D3
mov Port0, #00h
mov Port1, #00h
setb MD
setb M3

; Jump to main
jmp main


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

ret

setRight:
mov MOVE_STATE, #00000010b ; MOVE_STATE_RIGHT
ret

moveRight:
ret

setUp:
mov MOVE_STATE, #00000100b ; MOVE_STATE_UP
ret

moveUp:
ret

setDown:
mov MOVE_STATE, #00001000b ; MOVE_STATE_DOWN
ret

moveDown:
ret

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
main:
matrixCheckRight:
mov P2, #00001111b
jb Port2.1, matrixCheckUp ; Port2.1 is 0 if button "4" or "6" is pressed
mov P2, #11110000b
jb Port2.6, matrixCheckLeft ; Port2.6 is 0 if button "6" is pressed
call setRight
ljmp move

matrixCheckLeft:
jb Port2.4, matrixCheckDown ; Port2.4 is 0 if button "4" is pressed
call setLeft
ljmp move

matrixCheckUp:
mov P2, #11110000b
jb Port2.5, move ; Port2.5 is 0 if button "2" or "8" is pressed
mov P2, #00001111b
jb Port2.0, matrixCheckDown ; Port2.0 is 0 if button "2" is pressed
call setUp
ljmp move

matrixCheckDown:
jb Port2.2, move ; Port2.2 is 0 if button "8" is pressed
call setDown

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
move:
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
nop


ljmp main
