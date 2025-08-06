*-----------------------------------------------------------
* Title      :HeaderCalculations
* Written by :Brynn LeBlanc
* Date       :6/2/2025
* Description:Reads through the header of a bitmap file. Verifies the signature is correct,
*             gets the padding and the offset of the colors in the file
*-----------------------------------------------------------
TOP_LEFT_X_BITMAP_CHUNK         EQU     0
TOP_LEFT_Y_BITMAP_CHUNK         EQU     0
CHUNK_WIDTH_INDEX               EQU     16
CHUNK_HEIGHT_INDEX              EQU     14
THIRTHY_TWO_BITS                EQU     32

READ_THROUGH_HEADER
    
    ADDA.L #8, A0                                   ;Pass up the size of the file and the reserved data
    MOVE.L (A0)+, D0                                ;the offset of the file
    MOVE.L A0, A1    
    
    MOVE.L D0, D7                                   ;convert offset to big endian
    JSR CONVERT_LONG_LE_TO_BE
    MOVE.L D7, D0
    
    MOVE.L A2, D1       
    MOVE.L #0, A2
    ADD.L D0, D1                                    ;add offset to starting file location
    MOVE.L D1, A0                                   ;Get the start of the colors
    
    ADDA.L #4, A1                                   ;pass over the size of the header
    MOVE.L (A1)+, D7                                ;Bitmap width 
    JSR CONVERT_LONG_LE_TO_BE
    MOVE.L D7,D5
    MOVE.L D7,D1
    
    AND #3, d7                                      ;BITHMAP WIDTH / 4 remainder for padding
    MOVE.L D7, A3                                   ;A3 is padding

    MOVE.W D5, D6                                   ;used for calculating pixels between end of chunk and bitmap
    
    MOVE.W TOP_LEFT_X_BITMAP_CHUNK_INDEX(SP),A4     ;Top LEFT x value bitmap chunk
    MOVE.W A4, D3
    MOVE.W CHUNK_WIDTH_INDEX(SP),A6                 ;CHUNK WIDTH
    MOVE.W A6, A2
    MOVE.W A6,D7
    ADD.L D3,D7                                     ;TOP_RIGHT X VALUE
    SUB.L D7,D6                                     ;pixels between end of chunk and bitmap
    ADD.L D3, D6                                    ;pixels between end of chunk and bitmap ON BOTH ENDS

    MOVE.W TOP_LEFT_X_SCREEN_INDEX(SP),A5           ;X COORDINATE OF SCREEN
    MOVE.W A5, D3
    MOVE.L (A1)+, D7                                ;Bitmap height
    ADDA.L #2, A1                                   ;pass over number of color planes
    JSR CONVERT_LONG_LE_TO_BE                       ;Convert to big endian
    MOVE.L D7, D4                                   ;BITMAP height
    CLR.L D2
    MOVE.W TOP_LEFT_Y_BITMAP_CHUNK_INDEX(SP),D2     ;TOP LEFT Y VALUE CHUNK
    MOVE.W CHUNK_HEIGHT_INDEX(SP),D7                ;CHUNK HEIGHT
    ADD.L D7, D2                                    ;BOTTOM LEFT Y VALUE SCREEN
    
    SUB.L D2,D4                                     ;Distance between BOTTOM of bitmap and BOTTOM of chunk
    MULU D4,D5                                      ;gets the number of pixels passed over below the chunk
    
    CLR.L D1
    MOVE.W (A1)+,D1                                 ;Get number of bits per pixel
    ROR.W #8, D1                                    ;Convert to big endian
     
    CLR.L D7
    MOVE.W A4,D7                                    ;top left x bitmap
    ADD.L D7, D5                                    ;Number of pixels passed over below the chunk plus the first row
    
    MOVE.W TOP_LEFT_Y_SCREEN_INDEX(SP),D2
    MOVE.W CHUNK_HEIGHT_INDEX(SP),D7
    ADD.L D7, D2                                    ;BOTTOM Y-SCREEN VALUE
           
    MOVE.W D7,A4                                    ;BITMAP HEIGHT
    SUBA.L #1, A4                                   ;for dbra in bitmap subroutine
    
    
    LEA CarHeaderState, A1
    CMPI.W #1,(A1)                              
    BNE SKIP_STORE_HEADER                           ;If we aren't reading the bitmap chunk for the full car width, don't save
    
    MOVE.W #2,(A1)
    LEA FullCarWidthCalculations, A1
    MOVEM.L HEADER_REG, (A1)                           ;Save all the calculations for the full car width 
    
SKIP_STORE_HEADER    
    MOVE.L #THIRTHY_TWO_BITS, D4 
    CMP D1,D4
    BEQ THIRTY_TWO_BIT_BITMAP
    
    
    LEA     ErrorMessage_WrongFileSize, A1
    MOVE.L	#PRINT_STRING_CR_LF,D0
    TRAP    #15
    SIMHALT





paddingword10                        ds.w 1
FullCarWidthCalculations            ds.l 13









*~Font name~Courier New~
*~Font size~10~
*~Tab type~1~
*~Tab size~4~
