*-----------------------------------------------------------
* Title      : InputManager
* Written by : Brynn LeBlanc
* Date       : 6/23/2025
* Description: Handles user input for cat moving lanes. If the user presses the
*              down arrow key, the cat moves into the bottom lane, assuming it 
*               is not already in the bottom lane or there are no cars below it.
*               Vice versa for an up arrow input. 
*-----------------------------------------------------------
UP_KEY                  EQU  $26
DOWN_KEY                EQU  $28
LEFT_KEY                EQU  $25
RIGHT_KEY               EQU  $27

HANDLE_USER_INPUT
    MOVE.L #KEY_INPUT_COMMAND, D0
    MOVE.L #UP_KEY<<24+LEFT_KEY<<16+RIGHT_KEY<<8+DOWN_KEY,D1   ;Puts UP,LEFT,RIGHT,DOWN into D1
    TRAP #15   
    CMP.L #UP, D1                  ;Check for input
    BNE CHECK_FOR_DOWN_INPUT
    JSR MOVE_CAT_UP_CHECK
    
CHECK_FOR_DOWN_INPUT
    CMP.L #DOWN, D1
    BEQ DOWN_INPUT_PRESENT
    RTS
DOWN_INPUT_PRESENT
    JSR MOVE_CAT_DOWN_CHECK
    
    RTS



*~Font name~Courier New~
*~Font size~10~
*~Tab type~1~
*~Tab size~4~
