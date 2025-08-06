*-----------------------------------------------------------
* Title      : Background Manager 
* Written by : Brynn LeBlanc
* Date       : 6/2/2025
* Description: Manages the game’s background rendering, transitions, and animated sequences, particularly during
;                 state changes like winning, losing, or starting the game. Draws specific bitmap sections based
;                 on sprite positions, and controls sequences like the animated "jumping cat" intro through multiple
;                 stages of movement and poses. Handles screen-clearing visuals (like the screen),
;                 triggers associated sounds, and responds to mouse inputs for restarting the game. Additionally, it
;                 resets key gameplay variables (e.g., cat state, car spawn timers, sprite positioning) to ensure a
;                 consistent initial state upon restart. 
*-----------------------------------------------------------

*Indexing
BACKGROUND_X_INDEX              EQU     18

*Screen positioning
BITMAP_START_Y                  EQU     65
BITMAP_END_Y                    EQU     415

BACKGROUND_START   
    MOVE.L A0,A2                ;get another base location for the offset                                         
    MOVE.W (A0)+, D0            ;Get header

    
    CLR.L D1
    CLR.L D2
    
    LEA SpritePositioning, A4   
    
    ADDA.L #BACKGROUND_X_INDEX, A4
    MOVE.W (A4),-(SP)       ;TOP LEFT X CHUNK
    ADDA.L #4, A4
    MOVE.W (A4)+,-(SP)      ;CHUNK WIDTH
    MOVE.W (A4),-(SP)       ;CHUNK HEIGHT
    SUBA.L #4, A4
    MOVE.W (A4),-(SP)       ;TOP LEFT Y CHUNK
    ADDA.L #6, A4
    MOVE.W (A4)+,-(SP)      ;TOP LEFT X SCREEN
    MOVE.W (A4),-(SP)       ;TOP LEFT Y SCREEN
    MOVE.L A0,-(SP)
    
    JSR    READ_THROUGH_HEADER
    ADDA.L #16, A7
    RTS

WIN_SCREEN
    
    JSR STOP_BACKGROUND_MUSIC
    JSR WIN_SOUND
    LEA WinScreen, A0
    
    BRA END_GAME
    
LOSE_SCREEN
        
    JSR STOP_BACKGROUND_MUSIC
    JSR LOSE_SOUND
    LEA LoseScreen, A0
    
*-----------------------------------------------------------    
* Prints the corresponding ending screen with the gameplay result.
* Waits until the restart button is pressed to restart the game. 
*-----------------------------------------------------------
END_GAME
    JSR LOADING_SCREEN_POST_START
    CLR.L D0
    CLR.L D1
    CLR.L D2
    
     *copies buffer
     MOVE.B  #94,D0
     TRAP    #15
    
    ;BITMAP IS PASSED INTO A0
    MOVE.L A0,A2                   
    MOVE.W (A0)+, D0            ;Get header
    
    LEA SpritePositioning, A4   
    
    ADDA.L #BACKGROUND_X_INDEX, A4
    MOVE.W (A4),-(SP)           ;TOP LEFT X CHUNK
    ADDA.L #4, A4
    MOVE.W (A4)+,-(SP)          ;CHUNK WIDTH
    MOVE.W (A4),-(SP)           ;CHUNK HEIGHT
    SUBA.L #4, A4
    MOVE.W (A4),-(SP)           ;TOP LEFT Y CHUNK
    ADDA.L #6, A4
    MOVE.W (A4)+,-(SP)          ;TOP LEFT X SCREEN
    MOVE.W (A4),-(SP)           ;TOP LEFT Y SCREEN
    MOVE.L A0,-(SP)
    
    JSR    READ_THROUGH_HEADER
    ADDA.L #16, A7
    
    *copies buffer
    MOVE.B  #94,D0
    TRAP    #15
    
    ADDA #4, A7
    
    JSR CHECK_RESTART_AFTER_WIN_LOSE
    
    BRA START

LOADING_SCREEN_POST_START
    ;Set pen color   
    MOVE.L  #WHITE,D1
    MOVE.B  #SET_PEN_COLOR_COMMAND,D0
    TRAP    #15
    
    ;Set fill color 
    MOVE.B #SET_FILL_COLOR_COMMAND, D0
    MOVE.L #WHITE, D1
    TRAP #15
    
    MOVE.L #(SCREEN_START_X+1),D1
    MOVE.L #(BITMAP_START_Y+2),D2
    MOVE.L #(SCREEN_END_X-1),D3
    MOVE.L #BITMAP_END_Y,D4
    
    MOVE.B  #DRAW_FILLED_RECTANGLE_COMMAND, D0
    TRAP    #15
    
    MOVE.L #BLACK, D1   ;set text color to black
    CLR.L D2
    MOVE.B #6, D2
    LSL #8, D2
    MOVE.B #14, D2      ;size 14 font
    LSL.L #8, D2
    LSL.L #8, D2
    
    MOVE.L #SET_FONT_COMMAND, D0
    TRAP    #15

    LEA LoadingText,A1
    MOVE.W #LOADING_TEXT_X, D1
    MOVE.W #START_BUTTON_TEXT_Y, D2
    MOVE.L #DRAW_TEXT_COMMAND, D0
    TRAP #15
    
    RTS

OKAY_SCREEN
        ;Set pen color   
    MOVE.L  #WHITE,D1
    MOVE.B  #SET_PEN_COLOR_COMMAND,D0
    TRAP    #15
    
    ;Set fill color 
    MOVE.B #SET_FILL_COLOR_COMMAND, D0
    MOVE.L #WHITE, D1
    TRAP #15
    
    MOVE.L #SCREEN_START_X,D1
    MOVE.L #BITMAP_START_Y,D2
    MOVE.L #SCREEN_END_X,D3
    MOVE.L #BITMAP_END_Y,D4
    
    MOVE.B  #DRAW_FILLED_RECTANGLE_COMMAND, D0
    TRAP    #15
    
    MOVE.L #BLACK, D1   ;set text color to black
    CLR.L D2
    MOVE.B #6, D2
    LSL #8, D2
    MOVE.B #14, D2      ;size 14 font
    LSL.L #8, D2
    LSL.L #8, D2
    
    MOVE.L #SET_FONT_COMMAND, D0
    TRAP    #15

    LEA OkayText,A1
    MOVE.W #LOADING_TEXT_X, D1
    MOVE.W #START_BUTTON_TEXT_Y, D2
    MOVE.L #DRAW_TEXT_COMMAND, D0
    TRAP #15
    
    RTS
PRINT_TOM
    LEA NotATomPhoto, A0
    CLR.L D0
    MOVE.L A0,A2                ;get another base location for the offset                                         
    MOVE.W (A0)+, D0            ;Get header

    CLR.L D1
    CLR.L D2

    LEA RestartImageDimensions, A4
    MOVE.W (A4)+,-(SP)  ;Bitmap x
    MOVE.W (A4)+,-(SP)  ;width
    MOVE.W (A4)+,-(SP)  ;height
    MOVE.W (A4)+,-(SP)  ;Bitmap y
    MOVE.W (A4)+,-(SP)  ;screen x
    MOVE.W (A4)+,-(SP)  ;screen y
    MOVE.L A0,-(SP)
    
    JSR    READ_THROUGH_HEADER
    ADDA.L #16, A7
    
    JSR PRINT_ARE_YOU_SURE
    
    JSR COPY_BUFFER
    
    JSR CHECK_ARE_YOU_SURE 
    
    JSR OKAY_SCREEN
    
    JSR COPY_BUFFER
    
    JSR LETS_GO_SOUND
    
    RTS


RestartImageDimensions
    *x, y, width, height, screen x, screen y
    dc.w 0,187,349,0,220,65

OkayText                 dc.l 'Okay ...', 0  




*~Font name~Courier New~
*~Font size~10~
*~Tab type~1~
*~Tab size~4~
