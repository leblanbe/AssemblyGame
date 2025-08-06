*-----------------------------------------------------------
* Title      :Draw Border
* Written by :Brynn LeBlanc
* Date       :6/2/2025
* Description: Responsible for rendering the visual border and interface elements of a game. 
;                It draws all four sides of the border using filled rectangles, then overlays
;                directional instructions and interactive UI components like the Start and Restart button. 
*-----------------------------------------------------------
COLORS
WHITE                           EQU     $FFFFFF
BORDER_COLOR                    EQU     $D4A665 
OUTER_BUTTON_PEN_COLOR          EQU     $6F6F73 
OUTER_BUTTON_FILL_COLOR         EQU     $D9D9D9
INNER_BUTTON_PEN_COLOR          EQU     $9F9FAA
BLACK                           EQU     $000000

*COMMANDS
SET_PEN_WIDTH_COMMAND           EQU     93
DRAW_FILLED_RECTANGLE_COMMAND   EQU     87
SET_FILL_COLOR_COMMAND          EQU     81
SET_PEN_COLOR_COMMAND           EQU     80
SET_FONT_COMMAND                EQU     21


*DIMENSIONS
LEFT_BORDER_LEFT_X              EQU     0
LEFT_BORDER_RIGHT_X             EQU     116
LEFT_BORDER_BOTTOM_Y            EQU     480
TOP_BORDER_RIGHT_X              EQU     680
TOP_BORDER_BOTTOM_Y             EQU     66
RIGHT_BORDER_LEFT_X             EQU     525
BOTTOM_BORDER_TOP_Y             EQU     415

DIRECTIONS_TOP_SCREEN_X         EQU     169
DIRECTIONS_TOP_SCREEN_Y         EQU     25
DIRECTIONS_BOTTOM_SCREEN_X      EQU     10
DIRECTIONS_BOTTOM_SCREEN_Y      EQU     434

START_BOX_LINE_WIDTH            EQU     2
START_BUTTON_INNER_LEFT_X       EQU     273
START_BUTTON_INNER_TOP_Y        EQU     273
START_BUTTON_INNER_RIGHT_X      EQU     367
START_BUTTON_INNER_BOTTOM_Y     EQU     298
START_BUTTON_TEXT_X             EQU     293
START_BUTTON_TEXT_Y             EQU     274

START_BUTTON_OUTER_LEFT_X       EQU     270
START_BUTTON_OUTER_RIGHT_X      EQU     370
START_BUTTON_OUTER_TOP_Y        EQU     270
START_BUTTON_OUTER_BOTTOM_Y     EQU     300

ARE_YOU_SURE_INNER_RIGHT_X      EQU     377
ARE_YOU_SURE_OUTER_RIGHT_X      EQU     380

LIVES_TEXT_X                    EQU     275
LIVES_TEXT_Y                    EQU     30

RESTART_BUTTON_TEXT_X           EQU     575
RESTART_BUTTON_TEXT_Y           EQU     10
RESTART_BUTTON_LEFT_X           EQU     583
RESTART_BUTTON_TOP_Y            EQU     10
RESTART_BUTTON_RIGHT_X          EQU     638
RESTART_BUTTON_BOTTOM_Y         EQU     25


LOADING_TEXT_X                  EQU     280

DRAW_BORDER 
    ;Set pen color   
    MOVE.L  #BORDER_COLOR,D1
    MOVE.B  #SET_PEN_COLOR_COMMAND,D0
    TRAP    #15
    
    ;Set fill color 
    MOVE.B #SET_FILL_COLOR_COMMAND, D0
    MOVE.L #BORDER_COLOR, D1
    TRAP #15
    
    ;draw lefthand side
    MOVE.W  #LEFT_BORDER_LEFT_X,D1
    MOVE.W  #LEFT_BORDER_LEFT_X,D2
    MOVE.W  #LEFT_BORDER_RIGHT_X,D3
    MOVE.W  #LEFT_BORDER_BOTTOM_Y,D4
    MOVE.B  #DRAW_FILLED_RECTANGLE_COMMAND, D0
    TRAP    #15
    
    ;draw top side
    MOVE.W  #LEFT_BORDER_RIGHT_X,D1
    MOVE.W  #LEFT_BORDER_LEFT_X,D2
    MOVE.W  #TOP_BORDER_RIGHT_X,D3
    MOVE.W  #TOP_BORDER_BOTTOM_Y,D4
    MOVE.B  #DRAW_FILLED_RECTANGLE_COMMAND, D0
    TRAP    #15
    
    ;draw righthand side
    MOVE.W  #RIGHT_BORDER_LEFT_X,D1
    MOVE.W  #TOP_BORDER_BOTTOM_Y,D2
    MOVE.W  #TOP_BORDER_RIGHT_X,D3
    MOVE.W  #LEFT_BORDER_BOTTOM_Y,D4
    MOVE.B  #DRAW_FILLED_RECTANGLE_COMMAND, D0
    TRAP    #15
    
    ;draw bottom side
    MOVE.W  #LEFT_BORDER_RIGHT_X,D1
    MOVE.W  #BOTTOM_BORDER_TOP_Y,D2
    MOVE.W  #RIGHT_BORDER_LEFT_X,D3
    MOVE.W  #LEFT_BORDER_BOTTOM_Y,D4
    MOVE.B  #DRAW_FILLED_RECTANGLE_COMMAND, D0
    TRAP    #15
    
    MOVE.L #WHITE, D1
    CLR.L D2
    MOVE.B #4, D2       ;FONT STYLE
    LSL #8, D2
    MOVE.B #10, D2      ;FONT SIZE
    LSL.L #8, D2
    LSL.L #8, D2
    
    MOVE.L #SET_FONT_COMMAND, D0
    TRAP    #15
    
    LEA DirectionsTop, A1   
    
    MOVE.W #DIRECTIONS_TOP_SCREEN_X, D1
    MOVE.W #DIRECTIONS_TOP_SCREEN_Y, D2
    MOVE.L #DRAW_TEXT_COMMAND, D0
    TRAP #15
     
    LEA DirectionsBottom, A1   
    
    MOVE.W #DIRECTIONS_BOTTOM_SCREEN_X, D1
    MOVE.W #DIRECTIONS_BOTTOM_SCREEN_Y, D2
    TRAP #15
    
    MOVE.L #OUTER_BUTTON_PEN_COLOR, D1
    MOVE.L #SET_PEN_COLOR_COMMAND, D0
    TRAP #15
    
    MOVE.L  #START_BOX_LINE_WIDTH,D1
    MOVE.B  #SET_PEN_WIDTH_COMMAND,D0
    TRAP    #15
    
    MOVE.L #OUTER_BUTTON_FILL_COLOR, D1
    MOVE.L #SET_FILL_COLOR_COMMAND, D0
    TRAP #15
    
    MOVE.W  #START_BUTTON_OUTER_LEFT_X ,D1
    MOVE.W  #START_BUTTON_OUTER_TOP_Y ,D2
    MOVE.W  #START_BUTTON_OUTER_RIGHT_X,D3
    MOVE.W  #START_BUTTON_OUTER_BOTTOM_Y,D4
    MOVE.B  #DRAW_FILLED_RECTANGLE_COMMAND, D0
    TRAP    #15
    
    MOVE.L #INNER_BUTTON_PEN_COLOR, D1
    MOVE.L #SET_PEN_COLOR_COMMAND, D0
    TRAP #15
    
    MOVE.L #WHITE, D1
    MOVE.L #SET_FILL_COLOR_COMMAND, D0
    TRAP #15
    
    MOVE.W  #START_BUTTON_INNER_LEFT_X ,D1
    MOVE.W  #START_BUTTON_INNER_TOP_Y ,D2
    MOVE.W  #START_BUTTON_INNER_RIGHT_X,D3
    MOVE.W  #START_BUTTON_INNER_BOTTOM_Y,D4
    MOVE.B  #DRAW_FILLED_RECTANGLE_COMMAND, D0
    TRAP    #15
    
    MOVE.L #BLACK, D1
    CLR.L D2
    MOVE.B #6, D2
    LSL #8, D2
    MOVE.B #14, D2
    LSL.L #8, D2
    LSL.L #8, D2
    
    MOVE.L #SET_FONT_COMMAND, D0
    TRAP    #15
    
    LEA StartText,A1
    MOVE.W #START_BUTTON_TEXT_X, D1
    MOVE.W #START_BUTTON_TEXT_Y, D2
    MOVE.L #DRAW_TEXT_COMMAND, D0
    TRAP #15
    
    *MODIFYING RESTART BUTTON FONT
    LSR #8, D2
    LSR #8, D2
    MOVE.B #10, D2  ;FONT SIZE
    LSL.L #8, D2
    LSL.L #8, D2 
    
    MOVE.L #SET_FONT_COMMAND, D0
    TRAP    #15
    
    LEA RestartText, A1
    MOVE.W #RESTART_BUTTON_TEXT_X, D1
    MOVE.W #RESTART_BUTTON_TEXT_Y, D2
    MOVE.L #DRAW_TEXT_COMMAND, D0
    TRAP #15

    RTS
    
    
CLEAR_DIRECTIONS
    ;Set pen color   
    MOVE.L  #BORDER_COLOR,D1
    MOVE.B  #SET_PEN_COLOR_COMMAND,D0
    TRAP    #15
    
    ;Set fill color 
    MOVE.B #SET_FILL_COLOR_COMMAND, D0
    TRAP #15
     
    ;draw top side
    MOVE.W  #LEFT_BORDER_RIGHT_X,D1
    MOVE.W  #LEFT_BORDER_LEFT_X,D2
    MOVE.W  #RIGHT_BORDER_LEFT_X,D3
    MOVE.W  #TOP_BORDER_BOTTOM_Y,D4
    MOVE.B  #DRAW_FILLED_RECTANGLE_COMMAND, D0
    TRAP    #15
    
    ;draw bottom side
    MOVE.W  #LEFT_BORDER_LEFT_X,D1
    MOVE.W  #BOTTOM_BORDER_TOP_Y,D2
    MOVE.W  #TOP_BORDER_RIGHT_X ,D3
    MOVE.W  #LEFT_BORDER_BOTTOM_Y,D4
    MOVE.B  #DRAW_FILLED_RECTANGLE_COMMAND, D0
    TRAP    #15
    
    RTS

PRINT_LIVES_TEXT
    ;Set fill color
    MOVE.L  #BORDER_COLOR,D1 
    MOVE.B #SET_FILL_COLOR_COMMAND, D0
    TRAP #15
    
    LEA LivesText,A1
    MOVE.W #LIVES_TEXT_X, D1
    MOVE.W #LIVES_TEXT_Y, D2
    MOVE.L #DRAW_TEXT_COMMAND, D0
    TRAP #15
    
    RTS

PRINT_GAMEPLAY_TIPS   
    MOVE.L #WHITE, D1
    CLR.L D2
    MOVE.B #4, D2       ;FONT STYLE
    LSL #8, D2
    MOVE.B #10, D2      ;FONT SIZE
    LSL.L #8, D2
    LSL.L #8, D2
    
    MOVE.L #SET_FONT_COMMAND, D0
    TRAP    #15
     
    LEA GameplayDirections, A1   
    
    MOVE.W #DIRECTIONS_BOTTOM_SCREEN_X, D1
    MOVE.W #DIRECTIONS_BOTTOM_SCREEN_Y, D2
    MOVE.L #DRAW_TEXT_COMMAND, D0
    TRAP #15

    RTS


SET_BUFFER
    *set double buffered mode
    MOVE.L  #SET_DOUBLE_BUFFER ,D0
    MOVE.L  #17,D1
    TRAP    #15 
    RTS


COPY_BUFFER
    *copies buffer
    MOVE.B  #COPY_DOUBLE_BUFFER,D0
    TRAP    #15
    RTS



DISPLAY_LOADING
    LEA LoadingText, A1
    MOVE.L  #DISPLAY_STRING_COMMAND, D0
    TRAP #15
    RTS
    
PRINT_ARE_YOU_SURE
    MOVE.W  #START_BUTTON_OUTER_LEFT_X ,D1
    MOVE.W  #(START_BUTTON_OUTER_TOP_Y + 75),D2
    MOVE.W  #ARE_YOU_SURE_OUTER_RIGHT_X,D3
    MOVE.W  #(START_BUTTON_OUTER_BOTTOM_Y+75),D4
    MOVE.B  #DRAW_FILLED_RECTANGLE_COMMAND, D0
    TRAP    #15
    
    MOVE.L #INNER_BUTTON_PEN_COLOR, D1
    MOVE.L #SET_PEN_COLOR_COMMAND, D0
    TRAP #15
    
    MOVE.L #WHITE, D1
    MOVE.L #SET_FILL_COLOR_COMMAND, D0
    TRAP #15
    
    MOVE.W  #START_BUTTON_INNER_LEFT_X ,D1
    MOVE.W  #(START_BUTTON_INNER_TOP_Y + 75),D2
    MOVE.W  #ARE_YOU_SURE_INNER_RIGHT_X,D3
    MOVE.W  #(START_BUTTON_INNER_BOTTOM_Y+75),D4
    MOVE.B  #DRAW_FILLED_RECTANGLE_COMMAND, D0
    TRAP    #15
    
    MOVE.L #BLACK, D1
    CLR.L D2
    MOVE.B #6, D2
    LSL #8, D2
    MOVE.B #10, D2
    LSL.L #8, D2
    LSL.L #8, D2
    
    MOVE.L #SET_FONT_COMMAND, D0
    TRAP    #15
    
    LEA AreYouSureText,A1
    MOVE.W #(START_BUTTON_TEXT_X-15), D1
    MOVE.W #(START_BUTTON_TEXT_Y+80),D2
    MOVE.L #DRAW_TEXT_COMMAND, D0
    TRAP #15
    
    RTS

paddingword9                ds.w 1
*Strings
StartText                   dc.l 'Start', 0   
LoadingText                 dc.l 'Loading', 0  
RestarTText                 dc.l 'Restart', 0
LivesText                   dc.l 'Lives Left:', 0
AreYouSureText              dc.l 'Are You Sure?',0
DirectionsTop               dc.l 'OH NO! Mittens got lost on his way home.',0
DirectionsBottom            dc.l 'Use the Up and Down arrows to weave between traffic and help mittens get home',0
GameplayDirections          dc.l 'When navigating between lanes, hold the up or down arrow until mittens moves.',0








*~Font name~Courier New~
*~Font size~10~
*~Tab type~1~
*~Tab size~4~
