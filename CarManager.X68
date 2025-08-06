*-----------------------------------------------------------
* Title      :Car Manager
* Written by : Brynn LeBlanc
* Date       : 6/2/2025
* Description: Handles the movement, rendering, and collision detection of cars in the game. 
;                Cars move from right to left across the screen, and their position is updated 
;                based on a time-based velocity system. If a car and the cat overlap on both the
;                x- and y-axes, a collision occurs—reducing the cat’s lives and triggering a 
;                reaction animation. The program ensures that only visible portions of cars are drawn,
;                and cars are reset or stopped once fully offscreen. It also prevents repeated life
;                loss from a single collision by tracking overlapping states. 
*-----------------------------------------------------------

*Car dimensions
CAR_OFF_SCREEN_FULLY            EQU     41
BITMAP_END_X                    EQU     411
CAR_WIDTH                       EQU     75 
CAR_HEIGHT                      EQU     46
CAR_START_X                     EQU     0

*Screen dimensions
SCREEN_START_X                  EQU     115
SCREEN_END_X                    EQU     526

*Physics
VELOCITY                        EQU     $0003   ;75 pixels per second

*Fixed point
SHIFT_OUT_DECIMALS              EQU     2

*Indexing
DISTANCE_BTWN_CAR_POINTERS      EQU     20


REDRAW_CAR_BACKGROUND
    LEA GameBackground, A0

    MOVE.L A0,A2                             
    MOVE.W (A0)+, D0            ;Get header
    
    LEA SpritePositioning, A4
    LEA CarXScreenIndex, A3
    CLR.L D7
    MOVE.W (A3),D7
    ADDI.L #4, D7
    ADDA.L D7, A4
    MOVE.W (A4),-(SP)           ;TOP LEFT X CHUNK
    SUBA.L #8, A4
    MOVE.W (A4)+,-(SP)          ;CHUNK WIDTH
    MOVE.W (A4),-(SP)           ;CHUNK HEIGHT
    ADDA.L #8, A4
    MOVE.W (A4),-(SP)           ;TOP LEFT Y CHUNK
    SUBA.L #6, A4
    MOVE.W (A4)+,-(SP)          ;TOP LEFT X SCREEN
    MOVE.W (A4),-(SP)           ;TOP LEFT Y SCREEN
    MOVE.L A0,-(SP)
        
    JSR    READ_THROUGH_HEADER
    ADDA.L #16, A7
   
    RTS   
*-----------------------------------------------------------
* Decides where or not we should be redrawing the car
*-----------------------------------------------------------     
UPDATE_CAR
    LEA SpritePositioning,A4
    
    LEA CarXScreenIndex, A3
    CLR.L D7
    MOVE.W (A3),D7
    ADDA.L D7, A4
    
    ADDA.L #10,A4                 ;get car moving boolean
    CMP.W #0,(A4)
    BNE CAR_NOT_MOVING                    ;return if car is not moving
    RTS
CAR_NOT_MOVING
    SUBA.L #10,A4
    
    CMPI.W #SCREEN_START_X, (A4)  ;redraw background if car is partially on screen
    BEQ REDRAW_CAR_BACKGROUND_LAST
    
    ADDA.L #4,A4
    
    CMPI.W #BITMAP_END_X,(A4)
    BEQ UPDATE_CAR_POSITION       ;Don't redraw background if object is not on screen

    JSR REDRAW_CAR_BACKGROUND
    
    LEA SpritePositioning,A4
    
    LEA CarXIndex, A3
    MOVE.W (A3),D7
    
    ADDA.L D7, A4               ;Gets Car X position
    ADDA.L #4, A4               ;CAR WIDTH                       
    CMPI.W #CAR_WIDTH,(A4)      ;COMPARE CHUNK WIDTH WITH ORIGINAL WIDTH OF CAR TO SEE IF CAR WIDTH WAS CHANGED TO PARTIAL          
    JSR CHANGE_WIDTH_BACK
    
*-----------------------------------------------------------
* Updates the car position based on the veolcity of the car, 
* and the difference in time from the last game loop. Changes
* the width of the car if the car is partially offscreen. 
* Handles the collision between the cat and the car.
*-----------------------------------------------------------   
UPDATE_CAR_POSITION
    LEA DeltaTime,A0
    MOVE.L (A0),D1
    
    *Calculate pixels
    MULU #VELOCITY, D1
    
    *update position based on velocity      
    LEA SpritePositioning,A4
    CLR.L D7
    LEA CarXScreenIndex, A3
    MOVE.W (A3),D7
    ADDA.L D7, A4                       ;Gets Car X position ON SCREEN
    LSR #SHIFT_OUT_DECIMALS, D1         ;Shift out decimals
    ADDA.L #4, A4                       ;Background chunk screen x
    SUB.W D1,(A4)                       ;moves background redraw position
    SUBA.L #4, A4                       ;Gets Car X position on screen
    SUB.W D1,(A4)                       ;Pixels MINUS current position (MOVING LEFT), y doesn't change

    *Check if car is fully off screen
    CMPI.W #CAR_OFF_SCREEN_FULLY,(A4)
    BLT REDRAW_CAR_BACKGROUND_LAST
    
    *Check if car is partially on screen (TO THE LEFT)
    MOVE.W (A4),D7                      ;New left X position
    MOVE.W D7, D2
    CMPI.W #SCREEN_START_X,(A4)
    BLT CAR_PARTIALLY_ON_SCREEN_LEFT

    *Check if car is partially on screen (TO THE RIGHT)
    SUBA.L #4, A4                       ;Width of car
    ADD.W (A4),D7                       ;New right x position
    CMPI.W #SCREEN_END_X,D7
    BGT CAR_PARTIALLY_ON_SCREEN_RIGHT
    
    LEA SpritePositioning, A3
    ADDA.L #4, A3                       ;Gets width of cat
    MOVE.W (A3),D0 
    ADDA.L #4, A3                       ;Gets left X coordinate of cat
    MOVE.W (A3)+,D1
    ADD.W D1, D0                        ;Gets right x coordinate of cat
    
    *see if cat and car collide
    CMP.W D0, D2                        ;comparing right x coordinate of cat with left x coordinate of car
    BLT COLLISION_X_AXIS
    
    SUB.W D1,D0
    CMP.W D0,D7                         ;comparing left coordinate of cat with right coordinate of car
    
    LEA CarXScreenIndex, A2
    MOVE.W (A2),D7
    ADDI.L #8, D7                       ;get car overlapping bit
    LEA SpritePositioning,A3  
                                   
    ;If it had been overlapping, move state to no longer overlapping
    ADDA.L D7, A3                       ;OVERLAPPING BIT
    MOVE.W #0,(A3)
    
DRAW_CAR
    LEA GreenPickupTruck, A0   
    
    MOVE.L A0,A2                             
    MOVE.W (A0)+, D0            ;Get header
    
    LEA SpritePositioning, A4
    LEA CarXIndex, A3
    MOVE.W (A3),D7
    
    ADDA.L D7, A4               ;GET CAR X INDEX
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
    
    SUBA.L #6, A4               ;Bitmap Width
    
    LEA CarHeaderState, A1      ;boolean for whether or not the car has been read
    CMPI.W #2,(A1)          
    BNE CHECK_WIDTH_0
       
    CMPI.W #CAR_WIDTH,(A4)      ;See if we are reading the bitmap for the full width car
    BNE NO_RESTORE
    
    LEA FullCarWidthCalculations, A1
    
    *The position of the car on screen changes, so we need to update this if we are going to restore the other paramters gathered int he first read header
    ADDA.L #4, A4               ;Get left x screen
    MOVE.W (A4),D3
    MOVE.W (A4)+,A5             
    MOVE.W (A4),D2              ;Top Y Screen
    ADDI.W #CAR_HEIGHT,D2       ;Bottom Y Screen

    MOVEM.L (A1),HEADER_REG     ;Restore the header calculations for full width car bitmap
    JSR SKIP_STORE_HEADER       ;Skip over header calculations
    ADDA.L #16, A7
    RTS

CHECK_WIDTH_0
    CMPI.W #CAR_WIDTH,(A4)      ;See if we are reading the bitmap for the full width car
    BNE NO_RESTORE
    MOVE.W #1,(A1)              ;If we are reading full width car for the first time, set state to 1, so we know to store header calculations info

NO_RESTORE    
    JSR    READ_THROUGH_HEADER
    ADDA.L #16, A7              ;Reset Stack
    RTS        
    
CAR_PARTIALLY_ON_SCREEN_RIGHT
    ADDA.L #4, A4
    MOVE.W (A4),D7                  ;Leftmos position of car on screen
    CLR.L D6
    MOVE.W #SCREEN_END_X, D6
    SUB.W D7,D6    
    SUBA.L #4, A4
    MOVE.W D6,(A4)                  ;Set width of car to be however much of the car is on the "screen" so it doesn't print off screen
    CMPI #0, D6
    BGT DRAW_CAR
    RTS
    
CAR_PARTIALLY_ON_SCREEN_LEFT
    CLR.L D6
    MOVE.W #SCREEN_START_X, D6
    
    LEA SpritePositioning, A4
    CLR.L D7
    
    LEA CarXScreenIndex, A3
    MOVE.W (A3),D7

    ADDA.L D7, A4
    CLR.L D7
    MOVE.W (A4),D7
    MOVE.L D7, D5                   ;left X position of car on screen
    SUBA.L #4,A4                    ;WIDTH OF CAR
    ADD.W (A4),D7                   ;D7 IS LEFTMOST POSITION OF CAR ON SCREEN, BECOMES RIGHT MOST X
    SUB.W D6,D7                     ;New car width
    MOVE.W D7,(A4)                  ;Set width of car to be however much of the car is on the "screen" so it doesn't print off screen    
    
    MOVE.L #SCREEN_START_X, D3
    SUB.L D5, D3
    
    ADDA #4, A4                     ;car x screen
    
    CMP.W #SCREEN_START_X, (A4)
    BGT CAR_NOT_OFF_SCREEN
    
    MOVE.W #SCREEN_START_X, (A4)
    ADDA.L #4,A4
    MOVE.W #0,(A4)
    
CAR_NOT_OFF_SCREEN    
    LEA GreenPickupTruck, A0   
    MOVE.L A0,A2                             
    MOVE.W (A0)+, D0                ;Get header
    
    MOVE.W D3,-(SP)                 ;TOP LEFT X CHUNK
    MOVE.W D7,-(SP)                 ;CHUNK WIDTH
    SUBA.L #6, A4
    MOVE.W (A4),-(SP)               ;CHUNK HEIGHT
    SUBA.L #4, A4
    MOVE.W (A4),-(SP)               ;TOP LEFT Y CHUNK
    ADDA.L #6, A4
    MOVE.W (A4)+,-(SP)              ;TOP LEFT X SCREEN
    MOVE.W (A4),-(SP)               ;TOP LEFT Y SCREEN
    MOVE.L A0,-(SP)
    
    JSR    READ_THROUGH_HEADER
    ADDA.L #16, A7
    
    RTS

REDRAW_CAR_BACKGROUND_LAST
    CLR.L D0
    CLR.L D1
    CLR.L D2
    MOVE.L #0, A1
    
    JSR REDRAW_CAR_BACKGROUND
    
    LEA SpritePositioning,A4
    
    LEA CarXIndex, A3
    MOVE.W (A3),D7
    ADDA.L D7, A4               ;Gets Car X position
    
    MOVE.W #CAR_START_X,(A4)
    ADDA.L #4,A4
    MOVE.W #CAR_WIDTH,(A4)
    ADDA.L #4,A4
    MOVE.W #SCREEN_END_X,(A4)
    ADDA.L #4,A4
    MOVE.W #BITMAP_END_X,(A4)    
    ADDA.L #4,A4
    MOVE.L #0,(A4)              ;RESET CAR TO BE NO LONGER MOVING    
 
    RTS
    
COLLISION_X_AXIS
    *CHECK FOR COLLISION ON y-AXIS AS WELL
    ADDA.L #6, A4               ;y coordinate of car
    MOVE.W (A3),D7              ;Y COORDINATE OF CAT
    MOVE.W (A4),D6
    CMP.W D7,D6                 ;Compare y values of cat and car 
    BNE DRAW_CAR

*-----------------------------------------------------------
* If the cat and the car collide, we first ensure that they 
* have not already been marked as colliding, so we don't update 
* the variables more than once. If the cat and the car have not
* already been maarked as colliding, we change the states of both
* the cat and the car to be in the colliding states. We then check 
* If the cat still has enough lives left to continue playing, if not,
* we transition to the lose screen, if yes, we update the cat 
* position, and continue back to the game loop. 
*-----------------------------------------------------------     
COLLISION_Y_AXIS
    ADDA.L #6, A4               ;OVERLAPPING BIT
    CMP.W #1,(A4)               ;IF EQUAL, CAT AND CAR HAVE ALREADY COLLIDED FOR 1 FRAME
    BEQ UPDATE_CAT              ;IF CAT AND CAR ARE CURRENTLY IN THE SHOCK STATE, DO NOT REDRAW IT
    
    LEA CatState, A1
    MOVE.W #2,(A1)
    MOVE.W #1,(A4)              ;Car is in overlap state
    
     ;CALCULATE NUMBER OF LIVES LEFT
    CLR.L D7                  
    LEA LivesLeft,A0
    SUBI.W #1,(A0)
    MOVE.W (A0),D7
   
    JSR LOAD_SS                 ;Print lives left

    ;if lives left is 0, game over
    LEA LivesLeft,A1                       
    CMP.W #0,(A1)
    BEQ LOSE_SCREEN
    
    JSR CAT_SCREAM
        
    CMP.W #0,(A1)
    BNE UPDATE_CAT 
    
    
SET_CAR_UPPER_TO_MOVING
    LEA CarXIndex, A6
    LEA CarXScreenIndex,A1 
    SUBI.W #20,(A1)
    SUBI.W #20,(A6)
    
    LEA SpritePositioning, A5
    CLR.L D7
    MOVE.W (A6),D7
    ADDI.L #18, D7               ;Bring pointer to moving bool
    ADDA.L D7, A5
    
    MOVE.W #1,(A5)
    
    ADDI.W #20,(A1)
    ADDI.W #20,(A6)
    
    RTS

SET_CAR_LOWER_TO_MOVING
    LEA SpritePositioning, A5
    LEA CarXIndex,A6
    LEA CarXScreenIndex,A1 
    
    CLR.L D7
    MOVE.W (A6),D7
    ADDI.L #18, D7               ;Bring pointer to moving bool
    ADDA.L D7, A5
    
    MOVE.W #1,(A5)
    
    RTS
    
*---------------------------------------------------------------
* For each car, there is a range in which the car is set to spawn,
* if the current time is in that range, we set the current state
* of the specified car to moving, so that it will be updated in 
* UPDATE_CAR.
*---------------------------------------------------------------
SPAWN_CARS
    LEA CarSpawnTimes, A0
    
    CMP.W (A0)+,D1
    BGT CHECK_TIME_2_CAR_2
    RTS
    
CHECK_TIME_2_CAR_2    
    CMP.W (A0)+,D1
    BLT SET_CAR_LOWER_TO_MOVING
    
    CMP.W (A0)+,D1
    BGT CHECK_TIME_2_CAR_3
    RTS
    
CHECK_TIME_2_CAR_3 
    CMP.W (A0)+,D1
    BLT SET_CAR_UPPER_TO_MOVING
    
    CMP.W (A0)+,D1
    BGT CHECK_TIME_2_CAR_4
    RTS
    
CHECK_TIME_2_CAR_4 
    CMP.W (A0)+,D1
    BLT SET_CAR_LOWER_TO_MOVING
    
    CMP.W (A0)+,D1
    BGT CHECK_TIME_2_CAR_5
    RTS
    
CHECK_TIME_2_CAR_5 
    CMP.W (A0)+,D1
    BLT SET_CAR_LOWER_TO_MOVING    
    
    CMP.W (A0)+,D1
    BGT CHECK_TIME_2_CAR_6
    RTS
    
CHECK_TIME_2_CAR_6 
    
    CMP.W (A0)+,D1
    BLT SET_CAR_UPPER_TO_MOVING    
    
    CMP.W (A0)+,D1
    BGT CHECK_TIME_2_CAR_7
    RTS
    
CHECK_TIME_2_CAR_7 
    
    CMP.W (A0)+,D1
    BLT SET_CAR_LOWER_TO_MOVING    
    
    CMP.W (A0)+,D1
    BGT CHECK_TIME_2_CAR_8
    RTS
    
CHECK_TIME_2_CAR_8 
    
    CMP.W (A0)+,D1
    BLT SET_CAR_UPPER_TO_MOVING    
    
    CMP.W (A0)+,D1
    BGT CHECK_TIME_2_CAR_9
    RTS
    
CHECK_TIME_2_CAR_9 
    
    CMP.W (A0)+,D1
    BLT SET_CAR_LOWER_TO_MOVING     
    
    CMP.W (A0)+,D1
    BGT CHECK_TIME_2_CAR_10
    RTS
    
CHECK_TIME_2_CAR_10 
    
    CMP.W (A0)+,D1
    BLT SET_CAR_UPPER_TO_MOVING   
 
    CMP.W (A0)+,D1
    BGT CHECK_TIME_2_CAR_11
    RTS
    
CHECK_TIME_2_CAR_11 
    
    CMP.W (A0)+,D1
    BLT SET_CAR_LOWER_TO_MOVING  
    RTS
    
CHANGE_WIDTH_BACK
    MOVE.W #CAR_WIDTH,(A4)
    RTS

DECREASE_CAR_POINTER
    LEA CarXIndex, A0
    LEA CarXScreenIndex,A1 
    SUBI.W #DISTANCE_BTWN_CAR_POINTERS,(A1)                 ;Decrease car pointer to point to car 1
    SUBI.W #DISTANCE_BTWN_CAR_POINTERS,(A0)
    RTS

INCREASE_CAR_POINTER
    LEA CarXIndex, A0       
    LEA CarXScreenIndex,A1
    ADDI.W #DISTANCE_BTWN_CAR_POINTERS,(A1)                 ;Increase car pointer to point to car 2
    ADDI.W #DISTANCE_BTWN_CAR_POINTERS,(A0)
    RTS



paddingword1                ds.w 1

LivesLeft                   dc.w 2

CarSpawnTimes
*For each car there is a time 1 and a time 2 to allow for a range of time in which the car can be spawned in
    dc.w 500,800,    850,1150,    1200,1500,    1900,2200,      2400,2700,    3000, 3300,     3400, 3700,     3770,4070,      4120, 4420,     4470, 4770,      5000, 5300                 


CarHeaderState              dc.w 0














*~Font name~Courier New~
*~Font size~10~
*~Tab type~1~
*~Tab size~4~
