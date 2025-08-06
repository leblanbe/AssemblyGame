*-----------------------------------------------------------
* Title      :Seven Segment Display
* Written by : Brynn LeBlanc
* Date       : 6/9/2025
* Description: This routine draws a number (passed in via register D7) 
;                onto the screen using a seven-segment display format. It 
;                first uses the number as an index to retrieve a segment encoding 
;                from a lookup table. Then, for each segment (A–G), it checks whether
;                that segment should be lit and draws the corresponding line using 
;                screen coordinates. The routine also clears the previous number display 
;                and sets the appropriate pen colors for visual clarity. It is worth noting
;                that SS stands for Seven Segment
*-----------------------------------------------------------
DRAW_LINE_COMMAND               EQU     84
A_X1                            EQU     389
A_Y1                            EQU     37
A_X2                            EQU     395
D_Y2                            EQU     47


LOAD_SS
    ;NUMBER TO PRINT IS PASSED IN THROUGH D7
    LEA SevenSegment, A0
    LSL.W #2, D7 ;OFFSET
    ADDA.L D7, A0 ;GETS THE NUMBER TO PRINT
    MOVE.L (A0),D7
    MOVE.L #1,D5
    
    ;Set pen color   
    MOVE.L  #BORDER_COLOR,D1
    MOVE.B  #SET_PEN_COLOR_COMMAND,D0
    TRAP    #15
    
    ;CLEAR EXISTING NUMBER 
    MOVE.L #A_X1,D1
    MOVE.L #A_Y1,D2
    MOVE.L #A_X2,D3
    MOVE.L #D_Y2,D4
    MOVE.L #DRAW_FILLED_RECTANGLE_COMMAND, D0
    TRAP #15
    
    ;Set pen color   
    MOVE.L  #BLACK,D1
    MOVE.B  #SET_PEN_COLOR_COMMAND,D0
    TRAP    #15
    
    MOVE.L #DRAW_LINE_COMMAND,D0
    
    LEA SevenSegmentDimensions, A0
    MOVE.L A0,A1
    ADDA.L #56, A1 ;Used to keep track of the end of the array
    
    
PRINT_SEGMENT    
    MOVE.L D5, D6
    AND D7, D6
    CMP.B #1, D6
    BNE INCREASE_A0
    
    MOVE.W (A0)+,D1
    MOVE.W (A0)+,D2
    MOVE.W (A0)+,D3
    MOVE.W (A0)+,D4
    TRAP #15
    LSR #1,D7
    CMPA.L A0,A1
    BGT PRINT_SEGMENT
    RTS
    
INCREASE_A0
    LSR #1,D7
    ADDA.L #8,A0
    CMPA.L A0,A1
    BGT PRINT_SEGMENT
    RTS
    

paddingword                 ds.w 1

SevenSegment 
*Seven segment display segments   
    dc.l $7E, $30, $6D, $79, $33, $5B, $5F, $70, $7F, $7B


SevenSegmentDimensions
*G F E D C B A: X1,Y1,X2,Y2
    dc.w 390,42,395,42,  390,37,390,42,   390,42,390,47,   389,47,395,47,   395,42,395,47,   395,37,395,42,   389,37,395,37





*~Font name~Courier New~
*~Font size~10~
*~Tab type~1~
*~Tab size~4~
