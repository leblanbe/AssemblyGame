*-----------------------------------------------------------
* Title      : Bitmap Chunk Subroutine
* Written by : Brynn LeBlanc
* Date       : 5/22/2025
* Description:

*A subroutine that can display
*   a chunk of a .bmp file at a location on the screen.
* The arguments for your subroutine are:
*   - Pointer to .bmp file (NOT a pointer to the pixel data)
*   - Top, Left corner (x,y) of the bitmap chunk you want to display
*   - Width and Height of the bitmap chunk you want to display
*   - Top, Left corner (x,y) on the output screen to display your chunk
* Can handle 24-bit and 32-bit bitmaps
*-----------------------------------------------------------

*Colors
GREEN_SKIP_COLOR                EQU     $FF3B

*Indexing
TOP_LEFT_X_SCREEN_INDEX         EQU     10
TOP_LEFT_Y_SCREEN_INDEX         EQU     8
TOP_LEFT_X_BITMAP_CHUNK_INDEX   EQU     18
TOP_LEFT_Y_BITMAP_CHUNK_INDEX   EQU     12

*Commands
DRAW_PIXEL_COMMAND              EQU     82

CONVERT_LONG_LE_TO_BE
    ;Converts a long in little endian to big endian
    ROR.W #8, D7                                    ;TRANSFORM for little endian 
    SWAP D7
    ROR.W #8, D7
    RTS
    
DRAW_CHUNK_THIRTY_TWO
    JSR GET_COLOR
    ADDA #1, A0                                     ;Trash alpha
    JSR SET_COLOR_AND_DRAW
    
    CMP.L #0, A2                                    ;Comparing the width with 0
    BNE DRAW_CHUNK_THIRTY_TWO
       
    MOVE.L D6,D7                                    ;PIXELS * 4 FOR 4 BYTES PER PIXEL
    LSL.L #2, D7                        
    
    ADDA D7, A0                                     ;End of row + beginning of next row
    CLR.L D3
    MOVE.W A5,D3                                    ;Reset x screen
    MOVE.W A6,A2                                    ;Reset width counter
    
    SUBI.L #1, D2                                   ;DECREMENT SCREEN Y COORDINATE
    
    DBRA D5, DRAW_CHUNK_THIRTY_TWO
    RTS
        
SET_COLOR_AND_DRAW
    CMPI.L #$FF3B, D1
    BEQ SKIP_COLOR
    
    MOVE.B  #SET_PEN_COLOR_COMMAND,D0
    TRAP    #15
    
    MOVE.L D3,D1                ;Move X SCREEN value into D1 for draw pixel command
    
    MOVE.B #DRAW_PIXEL_COMMAND, D0
    TRAP #15
    
SKIP_COLOR    
    ADDI #1,D3                  ;Increment X coordinate screen
    SUBA #1, A2                 ;subtract 1 from the width
    RTS 
    
GET_COLOR
    MOVE.W (A0)+, D1            ;BLUE
    LSL.L #8, D1
    MOVE.B (A0)+, D1            ;BLUE + GREEN + RED
    
    RTS
                 
THIRTY_TWO_BIT_BITMAP
    LSL.L #2, D5                ;number of bytes passed over (4 bytes per pixel)
    ADDA.L D5, A0               ;Gets the location of the top left pixel in memory
    MOVE.L A4, D5
    JSR DRAW_CHUNK_THIRTY_TWO
    RTS
    
    




































*~Font name~Courier New~
*~Font size~10~
*~Tab type~1~
*~Tab size~4~
