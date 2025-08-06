*-----------------------------------------------------------
* Title      :Draw Border
* Written by :Brynn LeBlanc
* Date       :6/2/2025
* Description: Draws the border for the game
*-----------------------------------------------------------
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
    MOVE.W  #0,D1
    MOVE.W  #0,D2
    MOVE.W  #115,D3
    MOVE.W  #480,D4
    MOVE.B  #DRAW_FILLED_RECTANGLE_COMMAND, D0
    TRAP    #15
    
    ;draw top side
    MOVE.W  #115,D1
    MOVE.W  #0,D2
    MOVE.W  #680,D3
    MOVE.W  #65,D4
    MOVE.B  #DRAW_FILLED_RECTANGLE_COMMAND, D0
    TRAP    #15
    
    ;draw righthand side
    MOVE.W  #526,D1
    MOVE.W  #65,D2
    MOVE.W  #680,D3
    MOVE.W  #480,D4
    MOVE.B  #DRAW_FILLED_RECTANGLE_COMMAND, D0
    TRAP    #15
    
    ;draw bottom side
    MOVE.W  #115,D1
    MOVE.W  #415,D2
    MOVE.W  #526,D3
    MOVE.W  #480,D4
    MOVE.B  #DRAW_FILLED_RECTANGLE_COMMAND, D0
    TRAP    #15
    
    LEA DirectionsTop, A0   
    
    MOVE.L A0,A2                             
    MOVE.W (A0)+, D0            ;Get header
    
    LEA PixiePositioning, A4
    
    ADDA.L #DIRECTIONS_TOP_X_INDEX, A4
    MOVE.W (A4),-(SP) ;TOP LEFT X CHUNK
    ADDA.L #4, A4
    MOVE.W (A4)+,-(SP) ;CHUNK WIDTH
    MOVE.W (A4),-(SP) ;CHUNK HEIGHT
    SUBA.L #4, A4
    MOVE.W (A4),-(SP) ;TOP LEFT Y CHUNK
    ADDA.L #6, A4
    MOVE.W (A4)+,-(SP) ;TOP LEFT X SCREEN
    MOVE.W (A4),-(SP) ;TOP LEFT Y SCREEN
    MOVE.L A0,-(SP)
    
    JSR    READ_THROUGH_HEADER
    ADDA.L #16, A7
    
    LEA DirectionsBottom, A0   
    
    MOVE.L A0,A2                             
    MOVE.W (A0)+, D0            ;Get header
    
    LEA PixiePositioning, A4
    
    ADDA.L #DIRECTIONS_BOTTOM_X_INDEX, A4
    MOVE.W (A4),-(SP) ;TOP LEFT X CHUNK
    ADDA.L #4, A4
    MOVE.W (A4)+,-(SP) ;CHUNK WIDTH
    MOVE.W (A4),-(SP) ;CHUNK HEIGHT
    SUBA.L #4, A4
    MOVE.W (A4),-(SP) ;TOP LEFT Y CHUNK
    ADDA.L #6, A4
    MOVE.W (A4)+,-(SP) ;TOP LEFT X SCREEN
    MOVE.W (A4),-(SP) ;TOP LEFT Y SCREEN
    MOVE.L A0,-(SP)
    
    JSR    READ_THROUGH_HEADER
    ADDA.L #16, A7
    
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
    
    ;restart button font properties
    LSR #8, D2
    LSR #8, D2
    MOVE.L #10, D2      ;size
    LSL.L #8, D2
    LSL.L #8, D2
    MOVE.L #SET_FONT_COMMAND, D0
    TRAP    #15
    
    LEA RestartText, A1
    MOVE.W #RESTART_BUTTON_TEXT_X, D1
    MOVE.W #RESTART_BUTTON_TEXT_Y, D2
    MOVE.L #DRAW_TEXT_COMMAND, D0
    TRAP #15
    
    ;RESTART BUTTON BOX
    MOVE.L #WHITE, D1
    MOVE.L #SET_PEN_COLOR_COMMAND, D0
    TRAP #15
    
    MOVE.W  #RESTART_BUTTON_LEFT_X ,D1
    MOVE.W  #RESTART_BUTTON_TOP_Y ,D2
    MOVE.W  #RESTART_BUTTON_RIGHT_X,D3
    MOVE.W  #RESTART_BUTTON_BOTTOM_Y,D4
    MOVE.B  #DRAW_UNFILLED_RECTANGLE_COMMAND, D0
    TRAP    #15
    
    
    RTS
    
    
CHECK_RESTART 
    MOVE.L #MOUSE_READ_COMMAND, D0
    MOVE.B #2, D1
    TRAP #15
    
    CMP.W #START_BUTTON_OUTER_LEFT_X, D1
    BLT GAME_LOOP
    
    CMP.W  #RESTART_BUTTON_RIGHT_X, D1
    BGT GAME_LOOP
    
    SWAP D1
    CMP.W #RESTART_BUTTON_TOP_Y, D1
    BLT GAME_LOOP
    
    CMP.W #RESTART_BUTTON_BOTTOM_Y, D1
    BGT GAME_LOOP

    BRA START




*~Font name~Courier New~
*~Font size~10~
*~Tab type~1~
*~Tab size~4~
