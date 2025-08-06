*-----------------------------------------------------------
* Title      : Game Status
* Written by : Brynn LeBlanc
* Date       : 6/2/2025
* Description: File ensures the game is still in gameplay mode.
*                Once out of gameplay mode the file resets the variables 
*                required to restart the game.
*-----------------------------------------------------------
CAR_X_INDEX                     EQU     36 ;Used for resetting after pressing restart
CAR_X_SCREEN_INDEX              EQU     44      ;Used for resetting after pressing restart
NUM_LIVES                       EQU     2
MOUSE_READ_COMMAND              EQU     61

CHECK_RESTART
    
    MOVE.L #MOUSE_READ_COMMAND, D0
    MOVE.B #2, D1
    TRAP #15
    
    
    CMP.W #RESTART_BUTTON_LEFT_X, D1
    BLT CHECK_GAME_LOOP_DELAY
    
    CMP.W #RESTART_BUTTON_RIGHT_X, D1
    BGT CHECK_GAME_LOOP_DELAY
    
    SWAP D1
    CMP.W #RESTART_BUTTON_TOP_Y, D1
    BLT CHECK_GAME_LOOP_DELAY
    
    CMP.W #RESTART_BUTTON_BOTTOM_Y, D1
    BGT CHECK_GAME_LOOP_DELAY
    
    JSR LOADING_SCREEN_POST_START
    CLR.L D0
    CLR.L D1
    CLR.L D2
    
    JSR COPY_BUFFER
     
    MOVE.L #0, D1                       ;reference to background music
    MOVE.L #PLAY_SOUND_COMMAND,D0
    MOVE.L #2, D2                       ;Stop sound
    TRAP #15
    
    JSR PRINT_TOM
    
    JSR RESET_VARIABLES
    
    BRA START


CHECK_RESTART_AFTER_WIN_LOSE
    MOVE.L #MOUSE_READ_COMMAND, D0
    MOVE.B #0, D1
    TRAP #15
    
    CMP #1, D0
    BNE CHECK_RESTART_AFTER_WIN_LOSE
    
    CMP.W #RESTART_BUTTON_LEFT_X, D1
    BLT CHECK_RESTART_AFTER_WIN_LOSE
    
    CMP.W #RESTART_BUTTON_RIGHT_X, D1
    BGT CHECK_RESTART_AFTER_WIN_LOSE
    
    SWAP D1
    CMP.W #RESTART_BUTTON_TOP_Y, D1
    BLT CHECK_RESTART_AFTER_WIN_LOSE
    
    CMP.W #RESTART_BUTTON_BOTTOM_Y, D1
    BGT CHECK_RESTART_AFTER_WIN_LOSE
    
    JSR LOADING_SCREEN_POST_START
    CLR.L D0
    CLR.L D1
    CLR.L D2
    
    *copies buffer
    MOVE.B  #94,D0
    TRAP    #15
    
     JSR PRINT_TOM
     
     *copies buffer
     MOVE.B  #94,D0
     TRAP    #15
     
    MOVE.L #0, D1                       ;reference to background music
    MOVE.L #PLAY_SOUND_COMMAND,D0
    MOVE.L #2, D2                       ;Stop sound
    TRAP #15
    
    JSR RESET_VARIABLES
    
    RTS
    
*-----------------------------------------------------------
* Resets all of the variables and positions of sprites. 
* It is worth noting that we do not reset the CarHeader State,
* which allows us for faster processing on the second run of 
* the game.
*-----------------------------------------------------------
RESET_VARIABLES
    LEA LivesLeft,A0
    MOVE.W #NUM_LIVES,(A0)
    
    LEA JumpingCatState,A0
    MOVE.W #1,(A0)
    
    LEA JumpingCatVelocity,A0
    MOVE.W #0,(A0)
    
    LEA CatState,A0
    MOVE.W #1,(A0)
    
    LEA CarXIndex,A0
    MOVE.W #CAR_X_INDEX,(A0)
    
    LEA CarXScreenIndex,A0
    MOVE.W #CAR_X_SCREEN_INDEX,(A0)
    
    ;Reset the spawn times of the two cars after the first one
    LEA CarSpawnTimes, A0
    LEA CarSpawnTimesReset,A1
    MOVE.W (A1)+,(A0)+
    MOVE.W (A1)+,(A0)+    
    MOVE.W (A1)+,(A0)+
    MOVE.W (A1)+,(A0)+
    
    LEA JumpingCat, A0
    LEA JumpingCatReset,A1
    MOVE.W (A1)+,(A0)+
    MOVE.W (A1)+,(A0)+
    MOVE.W (A1)+,(A0)+
    MOVE.W (A1),(A0)
    
    LEA SpritePositioning,A1
    LEA SpritePositioningReset,A2
   
RESET_PIXIES    
    MOVE.W (A2)+,(A1)+
    CMP.W #$FFFF,(A2) ;A2 is the last variable declared, so anything after it should be untouched, or equivalent to FFFF
    BNE RESET_PIXIES 
    RTS

START_SCREEN_LOOP
    MOVE.L #MOUSE_READ_COMMAND,D0
    MOVE.B #0, D1
    TRAP #15
    
    CMP #1,D0
    BNE START_SCREEN_LOOP
    
    CMP.W #START_BUTTON_OUTER_LEFT_X,D1
    BLT START_SCREEN_LOOP
    
    CMP.W #START_BUTTON_OUTER_RIGHT_X,D1
    BGT START_SCREEN_LOOP
    
    SWAP D1
    CMP.W #START_BUTTON_OUTER_TOP_Y,D1
    BLT START_SCREEN_LOOP
    
    CMP.W #START_BUTTON_OUTER_BOTTOM_Y,D1
    BGT START_SCREEN_LOOP
    
    RTS
    
CHECK_ARE_YOU_SURE
    MOVE.L #MOUSE_READ_COMMAND,D0
    MOVE.B #0, D1
    TRAP #15
    
    CMP #1, D0
    BNE CHECK_ARE_YOU_SURE
    
    CMP.W #START_BUTTON_OUTER_LEFT_X,D1
    BLT CHECK_ARE_YOU_SURE
    
    CMP.W #ARE_YOU_SURE_OUTER_RIGHT_X,D1
    BGT CHECK_ARE_YOU_SURE
    
    SWAP D1
    CMP.W #(START_BUTTON_OUTER_TOP_Y+75),D1
    BLT CHECK_ARE_YOU_SURE
    
    CMP.W #(START_BUTTON_OUTER_BOTTOM_Y+75),D1
    BGT CHECK_ARE_YOU_SURE
    
    CLR.L D1
    
    RTS
    
paddingword4                ds.w 1

;used for resetting variables after restart button is pressed
CarSpawnTimesReset
*only need to reset tha values that are changed by the random number
    dc.w 500,800,    850,1150     
     
JumpingCatReset
    dc.w 165,350,50,285
    
SpritePositioningReset
    dc.w 0,0,56,51,145,220,30,155,0,    0,0,411,350,115,65,0,0,0,     0,0,75,46,526,220,411,155,0,1,     0,0,75,46,526,310,411,245,0,0











*~Font name~Courier New~
*~Font size~10~
*~Tab type~1~
*~Tab size~4~
