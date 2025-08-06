*-----------------------------------------------------------
* Title      : TimeManager
* Written by : Brynn LeBlanc
* Date       : 6/18/2025
* Description: Helps to manage the capturing and handling of time throughout the game.
*-----------------------------------------------------------
MAX_FRAME_TIME                  EQU     28      ;In centiseconds
DELAY_TIME_COMMAND              EQU     23


GET_DELTA_TIME_LOOP
    *get delta time for one game loop
    CLR.L D1
    MOVE.B #GET_TIME_COMMAND, D0
    TRAP #15
    LEA CurrentTime,A0
    LEA DeltaTime, A1
    MOVE.L (A0),D7
    MOVE.L D1,(A0)                  ;Update Current time
    SUB.L D7, D1                    ;Delta time
    MOVE.L D1,(A1)                  ;Set Delta Time
    RTS

GET_DELTA_TIME_TOTAL
    CLR.L D1
    *get time overlapped since the start of the game
    MOVE.B #GET_TIME_COMMAND, D0    ;Get new time
    TRAP #15
    LEA StartTime,A0
    MOVE.L (A0),D7
    SUB.L D7, D1                    ;Total Delta time (over whole game not game loop)
    RTS
    

CHECK_GAME_LOOP_DELAY
    LEA CurrentTime, A0
    CLR.L D1
    MOVE.B #GET_TIME_COMMAND, D0
    TRAP #15
    SUB.L (A0),D1                   ;Time from the top of the loop
    MOVE.L #MAX_FRAME_TIME, D2
    SUB.L D1, D2
    BLT GAME_LOOP
    
    MOVE.L D2,D1
    MOVE.L #DELAY_TIME_COMMAND, D0  ;IF time spent in loop is less than average, delay
    TRAP #15
    BRA GAME_LOOP


GET_GAME_START_TIME
    LEA CurrentTime, A0
    LEA StartTime, A1
    MOVE.B #GET_TIME_COMMAND, D0
    TRAP #15
    MOVE.L D1, (A0)  ;Gets the start time, THIS IS UPDATED IN CARMANAGER 
    MOVE.L D1,(A1)
    
    RTS

paddingword8                ds.w 1
CurrentTime                 ds.l 1
StartTime                   ds.l 1
DeltaTime                   ds.l 1
MaxDeltaTime                dc.l 0



*~Font name~Courier New~
*~Font size~10~
*~Tab type~1~
*~Tab size~4~
