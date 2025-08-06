*-----------------------------------------------------------
* Title      : Cat Manager
* Written by : Brynn LeBlanc
* Date       : 6/2/2025
* Description: Handles all logic related to the cat's movement and animation in a sprite-based game.
;                It covers upward and downward movement checks, collision detection with cars,
;                and appropriate visual state transitions. The system prevents the cat from moving 
;                into occupied lanes and ensures proper redrawing of the background and cat sprite 
;                depending on whether a collision has occurred. Cat states are updated between idle, 
;                running, and hit states.
*-----------------------------------------------------------

*Indexing
CAT_X_BITMAP_INDEX              EQU     12
CAT_Y_SCREEN_INDEX              EQU     10

*Screen positioning
CAT_BOTTOM_LANE_MAX             EQU     309
CAT_TOP_LANE_MAX                EQU     221
HIT_TOP_Y                       EQU     266
HIT_BOTTOM_Y                    EQU     356
LOWER_LANE_Y                    EQU     310
LOWER_LANE_Y_SHOCK              EQU     356
CHANGE_LANE_AMOUNT              EQU     90
COLLISION_Y_SHIFT_AMOUNT        EQU     46
JUMPING_CAT_FINAL_POSITION      EQU     125

*Cat dimensions
CAT_HEIGHT                      EQU     51
JUMPING_CAT_X                   EQU     0
JUMPING_CAT_Y                   EQU     0
CAT_WIDTH                       EQU     56

*Physics
JUMPING_CAT_ACCELERATION        EQU     2       ;4 pixels per second squared


REDRAW_BACKGROUND_CAT
    LEA GameBackground, A0

    MOVE.L A0,A2                             
    MOVE.W (A0)+, D0                ;Get header
    
    LEA SpritePositioning, A4       ;Contains the data structure that holds the positioning of the cat on screen and on the bitmap
    
    ADDA.L #CAT_X_BITMAP_INDEX, A4  ;Gets the X coordinate of the cat on the background bitmap, so we know which section of the background we are redrawing
    
    MOVE.W (A4),-(SP)               ;TOP LEFT X CHUNK
    SUBA.L #8, A4
    MOVE.W (A4),-(SP)               ;CHUNK WIDTH
    MOVE.W #CAT_HEIGHT,-(SP)        ;CHUNK HEIGHT
    ADDA.L #10, A4
    MOVE.W (A4),-(SP)               ;TOP LEFT Y CHUNK
    SUBA.L #6, A4
    MOVE.W (A4)+,-(SP)              ;TOP LEFT X SCREEN
    MOVE.W (A4),-(SP)               ;TOP LEFT Y SCREEN
    MOVE.L A0,-(SP)
    
    JSR    READ_THROUGH_HEADER
    ADDA.L #16, A7                  ;Reset Stack
    RTS
    
DRAW_CAT

    MOVE.L A0,A2                             
    MOVE.W (A0)+, D0                ;Get header
    
    LEA SpritePositioning, A4
    
    MOVE.W (A4),-(SP)               ;TOP LEFT X CHUNK
    ADDA.L #4, A4
    MOVE.W (A4),-(SP)               ;CHUNK WIDTH
    MOVE.W #CAT_HEIGHT,-(SP)        ;CHUNK HEIGHT
    MOVE.W -(A4),-(SP)              ;TOP LEFT Y CHUNK
    ADDA.L #6, A4
    MOVE.W (A4)+,-(SP)              ;TOP LEFT X SCREEN
    MOVE.W (A4),-(SP)               ;TOP LEFT Y SCREEN
    MOVE.L A0,-(SP)
    
    JSR READ_THROUGH_HEADER
    ADDA.L #16, A7
    RTS

*-----------------------------------------------------------
* Whenever there is user input on the up and down arrow keys, 
* We check to see if the cat can be moved in the corresponding
* direction. The cat can be moved if there is not a car in the
* space it wants to move, and also if there is road space to move
* into (ie you can't move down if you're in the bottom lane).
* MOVE_CAT_DOWN_CHECK and MOVE_CAT_UP_CHECK confirm these things 
* are true before moving the position of the cat, otherwise the
* cat is not moved, and we return to the game loop.
*-----------------------------------------------------------    
MOVE_CAT_DOWN_CHECK
    LEA SpritePositioning, A4
    MOVE.L A4,A5
    
    ADDA.L #10, A4                  ;Y screen
    CMPI.W #CAT_BOTTOM_LANE_MAX,(A4)
    BLT NOT_IN_BOTTOM_LANE          ;Check failing means we shouldn't move the cat and should return to main game loop
    RTS
    
NOT_IN_BOTTOM_LANE                  ;IF THERE IS A CAR BELOW THE CAT, DO NOT MOVE IT
    LEA CarXScreenIndex, A2
    CLR.L D7
    MOVE.W (A2),D7                  ;Get the pointer to the x coordinate for the car in the lower lane
    ADDI.W #DISTANCE_BTWN_CAR_POINTERS,D7 
    ADDA.L D7, A5                   ;left x value of car below cat
    SUBA.L #2, A4                   ;Left x coordinate of cat on screen
    CLR.L D1
    MOVE.W (A4),D1
    ADDI.W #CAT_WIDTH, D1           ;Right x coordinate of cat
    CMP.W (A5),D1                   ;compare left x of car with right point of cat
    BLT DOWN_CHECK_PASSED
    
    SUBI.L #CAT_WIDTH, D1           ;Left x coordinate of cat
    CLR.L D6
    MOVE.W (A5),D6                  ;left x coordinate of car
    SUBA.L #4, A5
    ADD.W (A5),D6                   ;Right x coordinate of car
    CMP.W D6, D1                    ;Compare right coordinate of car with left coordinate of cat
    BGT DOWN_CHECK_PASSED           ;Check failing means we shouldn't move the cat and should return to main game loop
    RTS
    
DOWN_CHECK_PASSED    
    JSR REDRAW_BACKGROUND_CAT
    
    LEA SpritePositioning, A4 
    ADDA.L #CAT_Y_SCREEN_INDEX, A4
    
    ADDI.W #CHANGE_LANE_AMOUNT, (A4)
    ADDA.L #4, A4                    ;Y coordinate on bitmap
    ADDI.W #CHANGE_LANE_AMOUNT, (A4)    
    
    RTS
    
    
MOVE_CAT_UP_CHECK    
    LEA SpritePositioning, A4
    MOVE.L A4,A5
    
    ADDA.L #10, A4                  ;Y screen
    CMPI.W #CAT_TOP_LANE_MAX,(A4)   ;can't go up if you are in top lane
    BGT NOT_IN_TOP_LANE             ;Check failing means we shouldn't move the cat and should return to main game loop
    RTS
    
NOT_IN_TOP_LANE                     ;IF THERE IS A CAR ABOVE THE CAT, DO NOT MOVE IT
    LEA CarXScreenIndex, A2
    CLR.L D7
    MOVE.W (A2),D7                  ;Get the x coordinate for the car in the lower lane
    ADDA.L D7, A5                   ;left x value of car below cat
    SUBA.L #2, A4                   ;Left x coordinate of cat on screen
    CLR.L D1
    MOVE.W (A4),D1
    ADDI.W #CAT_WIDTH, D1           ;Right x coordinate of cat
    CMP.W (A5),D1                   ;compare left x of car with right point of cat
    BLT UP_CHECK_PASSED
    
    SUBI.L #CAT_WIDTH, D1           ;Left x coordinate of cat
    CLR.L D6
    MOVE.W (A5),D6                  ;left x coordinate of car
    SUBA.L #4, A5
    ADD.W (A5),D6                   ;Right x coordinate of car
    CMP.W D6, D1                    ;Compare right coordinate of car with left coordinate of cat
    BGT UP_CHECK_PASSED             ;Check failing means we shouldn't move the cat and should return to main game loop
    RTS
    
UP_CHECK_PASSED    
    JSR REDRAW_BACKGROUND_CAT
    
    LEA SpritePositioning, A4 
    ADDA.L #CAT_Y_SCREEN_INDEX, A4
    
    SUBI.W #CHANGE_LANE_AMOUNT, (A4)
    ADDA.L #4, A4                               ;Y coordinate on bitmap
    SUBI.W #CHANGE_LANE_AMOUNT, (A4)    

    
    RTS                                         ;We are done moving the cat position to a new lane and can return to main

*-----------------------------------------------------------
* Throughout the game, the state of the cat changes frequently, 
* whether for running, or being in shock. Update cat, reads 
* which state the cat is in, and draws the corresponding bitmap.
* If the car and the cat have collided, we do not want to redraw
* the cat because then it will overwrite the car image. UPDATE_CAT
* also handles this. 
*-----------------------------------------------------------
UPDATE_CAT
    LEA SpritePositioning, A4
    MOVE.L A4, A5
    MOVE.L A4, A2
    
    LEA CatState, A2
    CMP.W #2,(A2)
    BNE CAR_AND_CAT_DONT_OVERLAP
    MOVE.L A4, A2
    
                                                ;If cat has not been drawn into state 2, draw it
    ADDA.L #10, A2                              ;get y position on screen
    
    CMP.W #HIT_TOP_Y,(A2)
    BLT CAR_AND_CAT_DONT_OVERLAP

    CMP.W #LOWER_LANE_Y,(A2)
    BEQ CAR_AND_CAT_DONT_OVERLAP  
    
                                                ;if cat has already been drawn into state 2, but is still overlapping with car, don't redraw cat
    ADDA.L #8, A5                               ;gets left x position of cat on screen
    CLR.L D4
    MOVE.W (A5),D4
    SUBA.L #4, A5                               ;cat width
    ADD.W (A5),D4                               ;rightmost x position of cat on screen
    CLR.L D7
    CLR.L D6
    LEA CarXScreenIndex, A3
    MOVE.W (A3),D7
    ADDI.L #8, D7                               ;get overlap bool of first car
    ADDA.L D7,A4
    CMP.W #1,(A4)
    BEQ CAR_AND_CAT_STILL_OVERLAP  
    
                                                ;need to check if overlapping with both cars
    ADDA.L #DISTANCE_BTWN_CAR_POINTERS, A4      ;overlap boolean of second car
    CMP.W #1,(A4)
    BEQ CAR_AND_CAT_STILL_OVERLAP  

CAR_AND_CAT_DONT_OVERLAP
    JSR REDRAW_BACKGROUND_CAT
    
    LEA SpritePositioning, A4
    ADDA.L #CAT_Y_SCREEN_INDEX, A4
    
    CMPI.W #HIT_TOP_Y,(A4)
    BEQ POST_COLLISION_SHIFT_UP   
    
    CMPI.W #HIT_BOTTOM_Y,(A4)
    BNE NO_POST_COLLISION_SHIFT
    
POST_COLLISION_SHIFT_UP    
    SUBI.W #COLLISION_Y_SHIFT_AMOUNT,(A4)  
    ADDA.L #4, A4
    SUBI.W #COLLISION_Y_SHIFT_AMOUNT,(A4) 
    
    LEA CatState, A1 
    MOVE.W #0, (A1)                             ;cat is now in state 0
    
NO_POST_COLLISION_SHIFT
    LEA CatState, A1
    CMP #2, (A1)
    BEQ MOVE_CAT_TO_2                           ;when cat is hit by car we shouldn't redraw background because car is (partially) background
    
    CMP #1, (A1)
    BEQ MOVE_CAT_TO_0
    
MOVE_CAT_TO_1
     *REDRAW CAT
    LEA CatRunningFrame2, A0
    JSR DRAW_CAT
    
    LEA CatState, A1 
    MOVE.W #1, (A1)                             ;cat is now in state 1
       
    RTS

MOVE_CAT_TO_0
    *REDRAW CAT
    LEA CatRunningFrame1, A0
    JSR Draw_Cat
    
    LEA CatState, A1 
    MOVE.W #0, (A1)                             ;cat is now in state 1
    RTS

MOVE_CAT_TO_2
    LEA SpritePositioning, A4
    ADDA.L #CAT_Y_SCREEN_INDEX, A4              ;Shift below car
    
    ADDI.W #COLLISION_Y_SHIFT_AMOUNT, (A4) 
    ADDA.L #4, A4
    ADDI.W #COLLISION_Y_SHIFT_AMOUNT, (A4)
    
    LEA CatCollision, A0 
    JSR DRAW_CAT
    JSR DRAW_CAR
    RTS
    
CAR_AND_CAT_STILL_OVERLAP  
    RTS    

*-----------------------------------------------------------
* On the start screen, there is a small animation of the cat 
* jumping. The following code is for printing the jumping cat 
* animation on the start screen in addition to calculating its
* velocity and acceleration for shifting the image. 
*-----------------------------------------------------------
JUMPING_CAT_START_SCREEN
    LEA JumpingFrame1, A0
    
    MOVE.L A0,A2                             
    MOVE.W (A0)+, D0                ;Get header
    
    ;draw stage 1 of jump (cat sitting)
    LEA JumpingCat, A4
    CLR.L D2
    MOVE.W #JUMPING_CAT_X,-(SP)     ;TOP LEFT X CHUNK
    MOVE.W #CAT_WIDTH,-(SP)         ;CHUNK WIDTH
    MOVE.W #CAT_HEIGHT,-(SP)        ;CHUNK HEIGHT
    MOVE.W #JUMPING_CAT_Y,-(SP)     ;TOP LEFT Y CHUNK
    MOVE.W (A4)+,-(SP)              ;TOP LEFT X SCREEN
    MOVE.W (A4),-(SP)               ;TOP LEFT Y SCREEN
    MOVE.L A0,-(SP)
    JSR    READ_THROUGH_HEADER
    ADDA.L #16, A7
    
    MOVE.B  #94,D0
    TRAP    #15
    
    JSR REDRAW_CAT_JUMPING          ;Redraw Cat
    
JUMPING_CAT_2    
    
    JSR INCREASE_JUMP_CAT_X_NO_CHANGE_Y
    
    ;draw stage 2 of cat jumping (cat with feet together)
    LEA CatRunningFrame2, A0
    JSR DRAW_JUMPING_CAT 

JUMPING_CAT_3    
    
    JSR INCREASE_JUMP_CAT_X_DECREASE_Y  
   
    ;draw stage 3 of jumping (vertical jump)
    LEA JumpingFrame3, A0
    JSR DRAW_JUMPING_CAT 
    
JUMPING_CAT_4    
    JSR INCREASE_JUMP_CAT_X_DECREASE_Y  
  
    ;draw stage 4 of jumping (horizontal jump)
    LEA JumpingFrame4, A0
    JSR DRAW_JUMPING_CAT 
    
HORIZONTAL_SHIFT    
    ;Shift horizontal jump with acceleration
    LEA JumpingCat, A4
    LEA JumpingCatVelocity, A1
    ADD.W #JUMPING_CAT_ACCELERATION,(A1)
    CLR.L D7
    MOVE.W (A1),D7
    ADD.W D7,(A4)           ;shift jumping cat to the right based off velocity and acceleration
    ADDA.L #4,A4
    MOVE.L A4, A5
    ADD.W D7,(A4)+           ;shift bitmap in addition to screen
    
    LEA JumpingFrame4, A0
    
    CMP.W #JUMPING_CAT_FINAL_POSITION,(A5)
    BLT DRAW_JUMPING_CAT
    
    LEA JumpingCatState, A2
    ADD.W #1,(A2)

    JSR DRAW_JUMPING_CAT
    
JUMPING_CAT_5
    
    JSR INCREASE_JUMPING_CAT_X_Y
      
    ;draw stage 5 of jumping (vertical slide)
    LEA JumpingFrame5, A0
    JSR DRAW_JUMPING_CAT  
  
JUMPING_CAT_6      

    JSR INCREASE_JUMPING_CAT_X_Y   
    
    ;draw stage 6 of jumping (walking image with feet apart)
    LEA CatRunningFrame1, A0
    JSR DRAW_JUMPING_CAT
    
JUMPING_CAT_7    
    
    JSR INCREASE_JUMP_CAT_X_NO_CHANGE_Y 
    
    ;draw stage 7 of jumping (cat sitting)
    LEA JumpingFrame7, A0
    JSR DRAW_JUMPING_CAT
    ADDA #4, A7
    RTS
    
INCREASE_JUMPING_CAT_X_Y
    ADD.W #20,(A4)+
    ADD.W #10,(A4)+
    ADD.W #20,(A4)+
    ADD.W #10,(A4)    
    RTS
    
INCREASE_JUMP_CAT_X_NO_CHANGE_Y
    ADD.W #20,(A4)
    ADDA.L #4, A4
    ADD.W #20,(A4)+
    RTS
    
INCREASE_JUMP_CAT_X_DECREASE_Y  
    ADD.W #20,(A4)+
    SUB.W #20,(A4)+
    ADD.W #20,(A4)+
    SUB.W #20,(A4)  
    RTS
    
DRAW_JUMPING_CAT
    MOVE.L A0,A2                             
    MOVE.W (A0)+, D0                ;Get header
    SUBA.L #6, A4                   ;Reset stack pointer to beginning
    CLR.L D2
    MOVE.W #JUMPING_CAT_X,-(SP)     ;TOP LEFT X CHUNK
    MOVE.W #CAT_WIDTH,-(SP)         ;CHUNK WIDTH
    MOVE.W #CAT_HEIGHT,-(SP)        ;CHUNK HEIGHT
    MOVE.W #JUMPING_CAT_Y,-(SP)     ;TOP LEFT Y CHUNK
    MOVE.W (A4)+,-(SP)              ;TOP LEFT X SCREEN
    MOVE.W (A4)+,-(SP)              ;TOP LEFT Y SCREEN
    MOVE.L A0,-(SP)
    JSR    READ_THROUGH_HEADER
    ADDA.L #16, A7
      
    MOVE.B  #94,D0
    TRAP    #15

REDRAW_CAT_JUMPING
    LEA StartScreen, A0
    MOVE.L A0,A2               
    MOVE.W (A0)+, D0                ;Get header
    
    LEA JumpingCat, A4
    CLR.L D2
    ADDA.L #4, A4
    
    MOVE.W (A4)+,-(SP)              ;TOP LEFT X CHUNK
    MOVE.W #CAT_WIDTH,-(SP)         ;CHUNK WIDTH
    MOVE.W #CAT_HEIGHT,-(SP)        ;CHUNK HEIGHT
    MOVE.W (A4),-(SP)               ;TOP LEFT Y CHUNK
    SUBA.L #6, A4
    MOVE.W (A4)+,-(SP)              ;TOP LEFT X SCREEN
    MOVE.W (A4),-(SP)               ;TOP LEFT Y SCREEN
    MOVE.L A0,-(SP)
    
    JSR    READ_THROUGH_HEADER
    ADDA.L #16, A7                  ;Reset Stack
    
    LEA JumpingCatState, A2
    LEA JumpingCat, A4
    
    ;we loop at 4 until horizontal cat has been shifted fully
    CMP.W #4,(A2)
    BEQ HORIZONTAL_SHIFT
    
    ADD.W #1,(A2)    
   
    RTS







*the running animation is 2 parts-one with the cat with its legs apart, and one with them together-these are CatRunning1 and CatRunning2
CatRunningFrame1            INCBIN "Running_1.bmp"  
CatRunningFrame2            INCBIN "Running_2.bmp"
CatState                    dc.w 0
JumpingCatState             dc.w 1
JumpingCat
*cat screen x, screen y, bitmap x, bitmap y
    dc.w 155,350,40,285














*~Font name~Courier New~
*~Font size~10~
*~Tab type~1~
*~Tab size~4~
