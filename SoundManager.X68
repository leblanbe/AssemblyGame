*-----------------------------------------------------------
* Title      : SoundManager
* Written by : Brynn LeBlanc
* Date       : 6/6/2025
* Description: Loads in sound files into the DirectX sound memory as well as plays them.
;                Loads in sounds for background music, a cat screaming on collision with a
;                car, and sounds for winning and losing the game. Also handles stopping the 
;                background music for when the game is over or when restarted. 
*-----------------------------------------------------------
LOAD_SOUND_COMMAND              EQU     74
PLAY_SOUND_COMMAND              EQU     77

PLAY_BACKGROUND_MUSIC
    CLR.L D1
    LEA BackgroundMusic, A1
    MOVE.L #LOAD_SOUND_COMMAND, D0
    TRAP #15
    
    MOVE.L #PLAY_SOUND_COMMAND,D0
    MOVE.L #0, D2                       ;Play sound once
    TRAP #15
    RTS
STOP_BACKGROUND_MUSIC
    MOVE.L #0, D1                       ;reference to background music
    MOVE.L #PLAY_SOUND_COMMAND,D0
    MOVE.L #2, D2                       ;Stop all sounds 
    TRAP #15
    RTS
    
CAT_SCREAM
    CLR.L D1
    MOVE.L #1, D1                       ;Loading sound into index 1
    LEA CatScream, A1
    MOVE.L #LOAD_SOUND_COMMAND, D0
    TRAP #15
    
    MOVE.L #PLAY_SOUND_COMMAND,D0
    MOVE.L #0, D2                       ;Play sound once
    TRAP #15
    RTS
    
WIN_SOUND
    CLR.L D1
    MOVE.L #2, D1                       ;Loading sound into index 2
    LEA GameWin, A1
    MOVE.L #LOAD_SOUND_COMMAND, D0
    TRAP #15
    
    MOVE.L #PLAY_SOUND_COMMAND,D0
    MOVE.L #0, D2                       ;Play sound once
    TRAP #15
    RTS
    
LOSE_SOUND
    CLR.L D1
    MOVE.L #3, D1                       ;Loading sound into index 3
    LEA GameOver, A1
    MOVE.L #LOAD_SOUND_COMMAND, D0
    TRAP #15
    
    MOVE.L #PLAY_SOUND_COMMAND,D0
    MOVE.L #0, D2                       ;Play sound once
    TRAP #15
    RTS
    
LETS_GO_SOUND
    CLR.L D1
    MOVE.L #4, D1                       ;Loading sound into index 3
    LEA LetsGo, A1
    MOVE.L #LOAD_SOUND_COMMAND, D0
    TRAP #15
    
    MOVE.L #PLAY_SOUND_COMMAND,D0
    MOVE.L #0, D2                       ;Play sound once
    TRAP #15
    
    RTS
    
*Sound files
BackgroundMusic             dc.l 'Game-Soundtrack.wav',0
CatScream                   dc.l 'cat_screaming.wav',0
GameWin                     dc.l 'happy-cat.wav',0
GameOver                    dc.l 'game-over.wav',0
LetsGo                      dc.l 'LetsGo.wav',0



*~Font name~Courier New~
*~Font size~10~
*~Tab type~1~
*~Tab size~4~
