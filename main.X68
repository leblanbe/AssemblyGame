*-----------------------------------------------------------
* Title      : Mittens on the Move
* Written by : Brynn LeBlanc
* Date       : 5/30
* Description: Mittens on the Move is a 68k assembly game where players control 
;                a cat attempting to cross a busy road by jumping between lanes to 
;                avoid oncoming vehicles. The game features animated bitmap graphics, 
;                interactive start and win/lose screens, sound effects, a seven-segment 
;                display for lives, and precise collision and time-based mechanics. The 
;                main file initializes memory and game constants, handles input, manages
;                cat and car updates, detects win/loss conditions, and integrates supporting
;                modules for graphics, sound, and logic control.
*-----------------------------------------------------------
    ORG    $500
*User input
UP                              EQU     $FF000000
DOWN                            EQU     $000000FF

*Commands
GET_TIME_COMMAND                EQU     8
PRINT_STRING_CR_LF              EQU     13
DISPLAY_STRING_COMMAND          EQU     14
KEY_INPUT_COMMAND               EQU     19
DRAW_TEXT_COMMAND               EQU     95
SET_DOUBLE_BUFFER               EQU     92
COPY_DOUBLE_BUFFER              EQU     94

*registers
ALL_REG         REG     D0-D7/A0-A6
HEADER_REG      REG     D0-D1/D4-D7/A0-A4/A6


    ORG    $1000
START:
    JSR DISPLAY_LOADING
    
    JSR SET_BUFFER
    
    LEA StartScreen, A0         ;Bitmap to be displayed is passed in as a paramter in a0 
    
    JSR BACKGROUND_START        ;Prints a full bitmap to the screen not including the border
    
    JSR DRAW_BORDER             ;Draws the blue border around the play screen 
    
    JSR JUMPING_CAT_START_SCREEN 
     
    JSR START_SCREEN_LOOP       ;loop that continuously checks for the start button to have been pressed, once pressed, we enter the game

ENTER_GAME
    JSR CLEAR_DIRECTIONS        
    
    JSR LOADING_SCREEN_POST_START
    
    JSR COPY_BUFFER
     
    ;Print number of lives left
    JSR PRINT_LIVES_TEXT
    
    LEA LivesLeft, A0
    MOVE.W (A0),D7
    JSR LOAD_SS
    
    JSR PRINT_GAMEPLAY_TIPS
    
    JSR GET_RANDOM_NUM          ;Assigns semi-random spawn times for cars 2 and 3 by getting a random number
    
    CLR.L D0
    MOVE.L #0, A1
    
    LEA GameBackground, A0
    JSR BACKGROUND_START        
    
    LEA CatRunningFrame1, A0
    JSR DRAW_CAT 
    
    JSR COPY_BUFFER
    
    JSR PLAY_BACKGROUND_MUSIC
    
    JSR GET_GAME_START_TIME

GAME_LOOP 
    JSR HANDLE_USER_INPUT
    
UPDATE
    JSR GET_DELTA_TIME_TOTAL
    
    LEA WinTime, A1                 ;There is a set amount of time per level
    MOVE.L (A1),D2
    CMP.L D2,D1
    BGT WIN_SCREEN

    JSR UPDATE_CAT
    
    JSR GET_DELTA_TIME_LOOP

    JSR UPDATE_CAR                  ;UPDATE CAR 1 (upper lane)
    
    JSR INCREASE_CAR_POINTER
    
    JSR UPDATE_CAR                  ;UPDATE CAR 2 (lower lane)
       
    JSR COPY_BUFFER

    JSR GET_DELTA_TIME_TOTAL
    
    JSR SPAWN_CARS
    
    JSR DECREASE_CAR_POINTER
   
    BRA CHECK_RESTART

     
WRONG_SIGNATURE
    LEA     ErrorMessage_WrongSignature, A1
    MOVE.L	#PRINT_STRING_CR_LF,D0
    TRAP    #15
    SIMHALT

    INCLUDE HeaderCalculations.X68
    INCLUDE BitmapSubroutine.X68
    INCLUDE CatManager.X68    
    INCLUDE BackgroundManager.X68
    INCLUDE CarManager.X68
    INCLUDE UIManager.X68
    INCLUDE SoundManager.X68
    INCLUDE SevenSegmentDisplay.X68
    INCLUDE CreateRandomSpawnTimes.X68
    INCLUDE TimeManager.X68
    INCLUDE InputManager.X68
    INCLUDE GameStatus.X68
    
    
    
    
*Bitmaps    
GameBackground              INCBIN "Game_background.bmp"
GreenPickupTruck            INCBIN "GreenPickupTruck75.bmp"
CatCollision                INCBIN "Shock.bmp"
StartScreen                 INCBIN "start_screen.bmp"
WinScreen                   INCBIN "win-screen.bmp"
LoseScreen                  INCBIN "lose-screen.bmp"
JumpingFrame1               INCBIN "Jump_1.bmp"
JumpingFrame3               INCBIN "Jump_3.bmp"
JumpingFrame4               INCBIN "Jump_4.bmp"
JumpingFrame5               INCBIN "Jump_5.bmp"
JumpingFrame7               INCBIN "Jump_7.bmp"
NotATomPhoto                INCBIN "NotSuspicious.bmp"


*Error Messages
FileSignature               dc.b    'BM'
ErrorMessage_WrongSignature dc.b 'Incorrect File Signature', 0
ErrorMessage_WrongFileSize  dc.b 'Incorrect Number of Bits per Pixel', 0

padding                     ds.w 1
WinTime                     dc.l 5500
CarXIndex                   dc.w 36
CarXScreenIndex             dc.w 44

JumpingCatVelocity          dc.w 0      ;Starts off not moving

*-----------------------------------------------------------
*     A B C D E F G
*0: 0 1 1 1 1 1 1 0 -> 7E
*1: 0 0 1 1 0 0 0 0 -> 30
*2: 0 1 1 0 1 1 0 1 -> 6D
*3: 0 1 1 1 1 0 0 1 -> 79
*4: 0 0 1 1 0 0 1 1 -> 33
*5: 0 1 0 1 1 0 1 1 -> 5B
*6: 0 1 0 1 1 1 1 1 -> 5F
*7: 0 1 1 1 0 0 0 0 -> 70
*8: 0 1 1 1 1 1 1 1 -> 7F
*9: 0 1 1 1 1 0 1 1 -> 7B
*-----------------------------------------------------------
     
SpritePositioning 
    *cat x, y, width, height, screen x, screen y, BACKGROUND CHUNK X, BACKGROUND CHUNK Y, overlap     
    *background x, y, width, height, screen x, screen y, color offset, color padding, T/F file been read 
    *car1 x, y, width, height, screen x, screen y, Background chunk x, Background chunk y, CAT_CAR_OVERLAP, MOVING
    *car2 x, y, width, height, screen x, screen y, Background chunk x, Background chunk y, CAT_CAR_OVERLAP, MOVING
    dc.w 0,0,56,51,145,220,30,155,0,    0,0,411,350,115,65,0,0,0,     0,0,75,46,526,220,411,155,0,1,     0,0,75,46,526,310,411,245,0,0

    
    END    START        ; last line of source












*~Font name~Courier New~
*~Font size~10~
*~Tab type~1~
*~Tab size~4~
