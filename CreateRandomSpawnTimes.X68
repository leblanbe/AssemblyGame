*-----------------------------------------------------------
* Title      : RandomNumber
* Written by : Ustab and edited by Brynn LeBlanc
* Date       : 5/30
* Description: Introduces slight variability to car spawn 
;                times by generating a small random delay. The GET_RANDOM_NUM 
;                subroutine seeds a pseudo-random number using the system clock, 
;                processes it to isolate a value between 0 and 300 hundredths of 
;                a second, and adds that offset to the initial spawn times of cars 
;                appearing on screen. The added randomness helps make spawn behavior 
;                feel more dynamic and less predictable during gameplay.
*----------------------------------------------------------
GET_RANDOM_NUM
        JSR     SEED_RANDOM_NUM         ;Seed 
        CLR.L   D6
        JSR     GET_RANDOM_BYTE_INTO_D6 ;Get a random byte into D6

        AND.B   #3,D6                  ;Keep only the lowest 2 bits (00 to 11)
        MULU #100,D6                  ;Convert to hundreths of a second
        JSR ASSIGN_SPAWN_TIMES
        RTS

SEED_RANDOM_NUM
        MOVEM.L ALL_REG,-(sp)
        CLR.L   D6
        MOVE.B  #GET_TIME_COMMAND,D0
        TRAP    #15                     ;Get time into D1
        MOVE.L  D1,RandomVal
        MOVEM.L (SP)+,ALL_REG
        RTS
        
GET_RANDOM_BYTE_INTO_D6
        MOVEM.L d0,-(sp)
        MOVEM.L d1,-(sp)
        MOVEM.L d2,-(sp)

        MOVE.L  RandomVal,d0
        MOVEQ   #$AF-$100,d1            ; = $AF
        MOVEQ   #18,D2
        

NINC0
        ADD.L   D0,D0
        BCC     Ninc1
        EOR.B   D1,D0
        
NINC1
        DBF     D2,Ninc0

        MOVE.L  D0,RandomVal
        CLR.L   D6
        MOVE.B D0,D6

        MOVEM.L (SP)+,D2
        MOVEM.L (SP)+,D1
        MOVEM.L (SP)+,D0
        RTS

ASSIGN_SPAWN_TIMES
    LEA CarSpawnTimes, A0
    MOVE.L A0, A1
    ADDA.L #4, A1      ;end of the first 3 cars
    
ADD_RANDOM_TIME 
    ADD.W D6,(A0)+
    CMPA.L A0, A1
    BGT ADD_RANDOM_TIME
    RTS
    




paddingword3                ds.w 1
RandomVal                   ds.l 1








*~Font name~Courier New~
*~Font size~10~
*~Tab type~1~
*~Tab size~8~
