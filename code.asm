INCLUDE Irvine32.inc
main	EQU start@0

.DATA

a WORD 1920 DUP(0)  ; Framebuffer (24x80)

tR BYTE 16d         ; Snake tail row number
tC BYTE 47d         ; Snake tail column number
hR BYTE 13d         ; Snake head row number
hC BYTE 47d         ; Snake head column number
fR BYTE 0           ; Food row
fC BYTE 0           ; Food column
fRY BYTE 0           ; Food row
fCY BYTE 0           ; Food column
fRR BYTE 0           ; Food row
fCR BYTE 0           ; Food column

tmpR BYTE 0         ; Temporary variable for storing row indexes
tmpC BYTE 0         ; Temporary variable for storing column indexes

rM BYTE 0d          ; Index of row above current row (row minus)
cM BYTE 0d          ; Index of column left of current column (column minus)
rP BYTE 0d          ; Index of row below current row (row plus)
cP BYTE 0d          ; Index of column right of current column (column plus)

eTail   BYTE    1d  ; Flag for indicating if tail should be deleted or not
search  WORD    0d  ; Variable for storing value of next snake segment
eGame   BYTE    0d  ; Flag for indicating that game should be ended (collision)
cScore  DWORD   0d  ; Total score

d       BYTE    'w' ; Variable for holding the current direction of the snake
newD    BYTE    'w' ; Variable for holding the new direction specified by input
delTime DWORD   100 ; Delay time between frames (game speed)

; Strings for menu display
;space 	BYTE 0Dh, 0Ah,0
menuS04   BYTE "		|----------------------------------------------------------------------------------|", 0Dh, 0Ah, 0
menuS03   BYTE "		'----------------------------------------------------------------------------------'", 0Dh, 0Ah, 0
menuS02   BYTE "		.----------------------------------------------------------------------------------.", 0Dh, 0Ah, 0
menuS01   BYTE "		| **      **                                                            **      ** |", 0Dh, 0Ah, 0
menuS0   BYTE "		|            /|||||\  |\\      /[]\      /|||\       /||\  /]  /|||||||\           |", 0Dh, 0Ah, 0
menuS1   BYTE "		|           ||/   |/  |\\\     ||||     /|||||\       ||  //   ||||||||/           |", 0Dh, 0Ah, 0
menuS2   BYTE "		|           |||       ||\\\    \||/    |||||||||      || //    ||                  |", 0Dh, 0Ah, 0
menuS3   BYTE "		|           ||\       || \\\    ||    ||||   ||||     ||//     ||                  |", 0Dh, 0Ah, 0
menuS4   BYTE "		|           \\|||||\  ||  \\\   ||   |||||   |||||    ||\\     ||\\\\\             |", 0Dh, 0Ah, 0
menuS5   BYTE "		|                \||  ||   \\\  ||  |||||||||||||||   || \\    ||/////             |", 0Dh, 0Ah, 0
menuS6   BYTE "		|                |||  ||    \\\ ||  |||||||||||||||   ||  \\   ||                  |", 0Dh, 0Ah, 0
menuS7   BYTE "		|           /|   /||  ||     \\|||  |||/       \|||   ||   \\  ||                  |", 0Dh, 0Ah, 0
menuS8   BYTE "		|           \||||||/  \/      \\||   \|         |/   \||/   \] \|||||||/           |", 0Dh, 0Ah, 0
menuS9   BYTE "		|                                                                                  |", 0Dh, 0Ah, 0

menuS10  BYTE "		|	 			       Start Game	 			   |", 0Dh, 0Ah,
			  "		|			      (PRESS '1' TO START THE GAME)   			   |", 0Dh, 0Ah,0

menuS11  BYTE "		|	 			      Select Speed	 			   |", 0Dh, 0Ah,
			  "		|			       (PRESS '2' TO SELECT SPEED)    			   |", 0Dh, 0Ah,0
			  
menuS12  BYTE "		|				      Select Level	 			   |", 0Dh, 0Ah,
			  "		|			       (PRESS '3' TO SELECT LEVEL)    			   |", 0Dh, 0Ah,0
			  
menuS13  BYTE "		|				          Exit	 			           |",0Dh, 0Ah,
			  "		|			           (PRESS '4' TO EXIT)    			   |", 0Dh, 0Ah,0
			  
levelS1  BYTE "		|	 			         level1                                    |", 0Dh, 0Ah,
			  "		|			               (PRESS '1')     			           |", 0Dh, 0Ah,0 
			  
levelS2  BYTE "		|	 			         level2                                    |", 0Dh, 0Ah,
			  "		|			               (PRESS '2')     			           |", 0Dh, 0Ah,0
			  
levelS3  BYTE "		|	 			         level3                                    |", 0Dh, 0Ah,
			  "		|			               (PRESS '3')    			           |", 0Dh, 0Ah,0
			  

speedS1  BYTE "		|	 			          Slow      	 			   |", 0Dh, 0Ah,
			  "		|			        (PRESS '1' FOR SLOW SPEED)    			   |", 0Dh, 0Ah,0
									                             
speedS2  BYTE "		|	 			         Medium                                    |", 0Dh, 0Ah,
			  "		|			       (PRESS '2' FOR MEDIUM SPEED)   			   |", 0Dh, 0Ah,0
			  
speedS3  BYTE "		|	 			          Fast      	 			   |",0Dh, 0Ah,
			  "		|			        (PRESS '3' FOR FAST SPEED)    			   |", 0Dh, 0Ah,0
			  
speedS4  BYTE "		|	 			       Very fast	 			   |", 0Dh, 0Ah,
			  "		|			     (PRESS '4' FOR VERY FAST SPEED)   			   |", 0Dh, 0Ah,0
			 
styleS	BYTE "1. Colorful!", 0Dh, 0Ah,  "2. Normal", 0Dh, 0Ah, 0
hitS    BYTE "Game Over!", 0
scoreS  BYTE "Score: 0", 0

myHandle DWORD ?    ; Variable for holding the terminal input handle
numInp   DWORD ?    ; Variable for holding number of bytes in input buffer
temp BYTE 16 DUP(?) ; Variable for holding data of type INPUT_RECORD
bRead    DWORD ?    ; Variable for holding number of read input bytes

.CODE

main PROC
; The main procedure is for printing menus 

    menu:
    CALL Randomize              ;random food generation
    CALL Clrscr 
	; Clear terminal screen 
	call crlf
							;the menu style
	MOV EDX, OFFSET menuS02       
    CALL WriteString
	MOV EDX, OFFSET menuS9       
    CALL WriteString
	MOV EDX, OFFSET menuS0       
    CALL WriteString
	MOV EDX, OFFSET menuS1       
    CALL WriteString
	MOV EDX, OFFSET menuS2       
    CALL WriteString
	MOV EDX, OFFSET menuS3       
    CALL WriteString
	MOV EDX, OFFSET menuS4       
    CALL WriteString
	MOV EDX, OFFSET menuS5       
    CALL WriteString  
	MOV EDX, OFFSET menuS6       
    CALL WriteString
	MOV EDX, OFFSET menuS7       
    CALL WriteString
	MOV EDX, OFFSET menuS8       
    CALL WriteString  
	MOV EDX, OFFSET menuS9       
    CALL WriteString
	MOV EDX, OFFSET menuS04       
    CALL WriteString
	MOV EDX, OFFSET menuS01       
    CALL WriteString
							;the word in first menu
	MOV EDX, OFFSET menuS10       
    CALL WriteString
	MOV EDX, OFFSET menuS01       
    CALL WriteString	
	
	MOV EDX, OFFSET menuS11       
    CALL WriteString
	MOV EDX, OFFSET menuS01       
    CALL WriteString	
	
	MOV EDX, OFFSET menuS12       
    CALL WriteString
	MOV EDX, OFFSET menuS01       
    CALL WriteString	
	
	MOV EDX, OFFSET menuS13       
    CALL WriteString
	MOV EDX, OFFSET menuS01       
    CALL WriteString

	MOV EDX, OFFSET menuS03       
    CALL WriteString
	

    wait1:                      ; Loop for reading menu choices
    CALL ReadChar

    CMP AL, '1'                 ; Check if start game was selected
    JE startG

    CMP AL, '2'                 ; Check if speed settig was selected
    JE speed

    CMP AL, '3'                 ; Check if level choice was selected
    JE level

    CMP AL, '4'                 ; If any other character was read,
    JNE wait1                   ; continue loop until a valid character
                                ; has been given, else exit program
    EXIT

    level:                      ; Level chooser section
    CALL Clrscr                 ; Clear terminal screen
	call crlf
							;the menu style
	MOV EDX, OFFSET menuS02       
    CALL WriteString
	MOV EDX, OFFSET menuS9       
    CALL WriteString
	MOV EDX, OFFSET menuS0       
    CALL WriteString
	MOV EDX, OFFSET menuS1       
    CALL WriteString
	MOV EDX, OFFSET menuS2       
    CALL WriteString
	MOV EDX, OFFSET menuS3       
    CALL WriteString
	MOV EDX, OFFSET menuS4       
    CALL WriteString
	MOV EDX, OFFSET menuS5       
    CALL WriteString  
	MOV EDX, OFFSET menuS6       
    CALL WriteString
	MOV EDX, OFFSET menuS7       
    CALL WriteString
	MOV EDX, OFFSET menuS8       
    CALL WriteString  
	MOV EDX, OFFSET menuS9       
    CALL WriteString
	MOV EDX, OFFSET menuS04       
    CALL WriteString
	MOV EDX, OFFSET menuS01       
    CALL WriteString
							;the word in level
    MOV EDX, OFFSET levelS1      
    CALL WriteString            
	MOV EDX, OFFSET menuS01       
    CALL WriteString
	
	MOV EDX, OFFSET levelS2      
    CALL WriteString            
	MOV EDX, OFFSET menuS01       
    CALL WriteString
	
	MOV EDX, OFFSET levelS3      
    CALL WriteString            
	MOV EDX, OFFSET menuS01       
    CALL WriteString
	
	MOV EDX, OFFSET menuS03       
    CALL WriteString

    wait2:                      ; Wait for valid input for level choice
    CALL ReadChar

    CMP AL, '1'                 ; No obsacles level
    JE level1

    CMP AL, '2'                 ; Box level
    JE level2

    CMP AL, '3'                 ; Rooms level
    JE level3

    JMP wait2                   ; Invalid choice, continue loop

    level1:                     
    CALL clearMem               
    MOV AL, 1                   
    CALL GenLevel               
    JMP menu

    level2:                    
    CALL clearMem               
    MOV AL, 2                   
    CALL GenLevel               
    JMP menu

    level3:                     
    CALL clearMem              
    MOV AL, 3                   
    CALL GenLevel               
    JMP menu

    speed:                   ; This section of code selects the game speed
    CALL Clrscr                 
	call crlf
							;the menu style
	MOV EDX, OFFSET menuS02       
    CALL WriteString
	MOV EDX, OFFSET menuS9       
    CALL WriteString
	MOV EDX, OFFSET menuS0       
    CALL WriteString
	MOV EDX, OFFSET menuS1       
    CALL WriteString
	MOV EDX, OFFSET menuS2       
    CALL WriteString
	MOV EDX, OFFSET menuS3       
    CALL WriteString
	MOV EDX, OFFSET menuS4       
    CALL WriteString
	MOV EDX, OFFSET menuS5       
    CALL WriteString  
	MOV EDX, OFFSET menuS6       
    CALL WriteString
	MOV EDX, OFFSET menuS7       
    CALL WriteString
	MOV EDX, OFFSET menuS8       
    CALL WriteString  
	MOV EDX, OFFSET menuS9       
    CALL WriteString
	MOV EDX, OFFSET menuS04       
    CALL WriteString
	MOV EDX, OFFSET menuS01       
    CALL WriteString
							;the word for speed menu
    MOV EDX, OFFSET speedS1      
    CALL WriteString            
	MOV EDX, OFFSET menuS01       
    CALL WriteString
	
	MOV EDX, OFFSET speedS2      
    CALL WriteString            
	MOV EDX, OFFSET menuS01       
    CALL WriteString
	
	MOV EDX, OFFSET speedS3      
    CALL WriteString            
	MOV EDX, OFFSET menuS01       
    CALL WriteString
	
	MOV EDX, OFFSET speedS4      
    CALL WriteString            
	MOV EDX, OFFSET menuS01       
    CALL WriteString

	MOV EDX, OFFSET menuS03       
    CALL WriteString

    wait3:                      ; Wait for valid input for speed choice
    CALL ReadChar

    CMP AL, '1'                 ; Slow speed
    JE speed1

    CMP AL, '2'                 ; Normal speed
    JE speed2

    CMP AL, '3'                 ; Fast speed
    JE speed3

    CMP AL, '4'                 ; Invalid choice, continue loop
    JE speed4
    JMP wait3

    speed1:                     ; Set refresh rate of game to 150ms
    MOV delTime, 150
    JMP menu

    speed2:                     ; Set refresh rate of game to 100ms
    MOV delTime, 100
    JMP menu

    speed3:
    MOV delTime, 50             ; Set refresh rate of game to 50ms
    JMP menu

    speed4:
    MOV delTime, 35             ; Set refresh rate of game to 35ms
    JMP menu                    ; Go back to main menu
	
    startG:                     ; This section sets  the necessary flags
								; and calls the main infinite loop
    CALL Clrscr                 
    MOV EDX, OFFSET styleS      
    CALL WriteString            

    wait4:                      ; Wait for valid input for level choice
    CALL ReadChar

    CMP AL, '1'                 ; colorful Level
    JE Color

    CMP AL, '2'                 ; normal level
    JE Normal

    JMP wait4                   ; Invalid choice, continue loop

    Color:                     ; No obstacles level
    MOV EAX, 0                  
    MOV EDX, 0
    CALL Clrscr                 
	CALL initSnake              
	CALL EPaint                  
	CALL createFood            
	CALL ERcreateFood             
	CALL EYcreateFood             
	CALL EstartGame              
	MOV EAX, white + (black * 16)
    CALL SetTextColor           ; Game was exited, reset screen color
    JMP menu                    ; jump back to main menu
	
    Normal:                     ; Box obstacle level
	MOV EAX, 0                  
    MOV EDX, 0
    CALL Clrscr                 
    CALL initSnake              
    CALL Paint                  
    CALL createFood             
    CALL startGame              
    MOV EAX, white + (black * 16)
    CALL SetTextColor           ;Game was exited, reset screen color
    JMP menu                    ;jump back to main menu

main ENDP

initSnake PROC USES EBX EDX
; This procedure initializes the snake to the default position

    MOV DH, 13      
    MOV DL, 47      
    MOV BX, 1       
    CALL saveIndex  ; Write to framebuffer

    MOV DH, 14      
    MOV DL, 47      
    MOV BX, 2       
    CALL saveIndex  ; Write to framebuffer

    MOV DH, 15      
    MOV DL, 47      
    MOV BX, 3       
    CALL saveIndex  ; Write to framebuffer

    MOV DH, 16      
    MOV DL, 47      
    MOV BX, 4       
    CALL saveIndex  ; Write to framebuffer

    RET

initSnake ENDP

clearMem PROC
;clears the framebuffer, resets the snake position and length,set all flags to default

    MOV DH, 0               ; Set the row register to zero
    MOV BX, 0               ; Set the data register to zero

    oLoop:                  ; Outer loop for matrix indexing (for rows)
        CMP DH, 24          
                            
        JE endOLoop

        MOV DL, 0           

        iLoop:              
            CMP DL, 80      
            JE endILoop     

            CALL saveIndex  
                            
            INC DL          
            JMP iLoop       

    endILoop:               
        INC DH              
        JMP oLoop           

endOLoop:                   
    MOV tR, 16              
    MOV tC, 47              
    MOV hR, 13              
    MOV hC, 47             

    MOV eGame, 0            
    MOV eTail, 1            
    MOV d, 'w'              
    MOV newD, 'w'           
    MOV cScore, 0           

    RET
clearMem ENDP

startGame PROC USES EAX EBX ECX EDX

; This is the main process

        MOV EAX, white + (black * 16)       ; Set text color to white on black
        CALL SetTextColor
        MOV DH, 24                          ; Move cursor to bottom left side
        MOV DL, 0                           ; of screen, to write the score
        CALL GotoXY                         ; string
        MOV EDX, OFFSET scoreS
        CALL WriteString

        ; Get console input handle and store it in memory
        INVOKE getStdHandle, STD_INPUT_HANDLE
        MOV myHandle, EAX
        MOV ECX, 10

        ; Read two events from buffer
        INVOKE ReadConsoleInput, myHandle, ADDR temp, 1, ADDR bRead
        INVOKE ReadConsoleInput, myHandle, ADDR temp, 1, ADDR bRead

       ; Main infinite loop
    more:

        ; Get number of events in input buffer
        INVOKE GetNumberOfConsoleInputEvents, myHandle, ADDR numInp
        MOV ECX, numInp

        CMP ECX, 0                          
        JE done                             

        ; Read one event from input buffer and save it at temp
        INVOKE ReadConsoleInput, myHandle, ADDR temp, 1, ADDR bRead
        MOV DX, WORD PTR temp               
        CMP DX, 1                           
        JNE SkipEvent                      

            MOV DL, BYTE PTR [temp+4]       
            CMP DL, 0
            JE SkipEvent
                MOV DL, BYTE PTR [temp+10]  ; Copy pressed key into DL

                CMP DL, 1Bh                 ; Check if ESC key was pressed and
                JE quit                     

                CMP d, 'w'                  
                JE case1                   
                CMP d, 's'                
                JE case1      

                JMP case2               
                                          
                case1:
                    CMP DL, 25h            
                    JE case11
                    CMP DL, 27h          
                    JE case12
                    JMP SkipEvent         
                                            
                    case11:
                        MOV newD, 'a'       ; Set new direction to left
                        JMP SkipEvent
                    case12:
                        MOV newD, 'd'       ; Set new direction to right
                        JMP SkipEvent

                case2:
                    CMP DL, 26h            
                    JE case21
                    CMP DL, 28h            
                    JE case22
                    JMP SkipEvent           
                                            
                    case21:
                        MOV newD, 'w'       ; Set new direction to up
                        JMP SkipEvent
                    case22:
                        MOV newD, 's'       ; Set new direction to down
                        JMP SkipEvent

    SkipEvent:
        JMP more                            ; Continue main loop

    done:

        MOV BL, newD                        
        MOV d, BL
        CALL MoveSnake                      
        MOV EAX, DelTime                    
        CALL Delay                         

        MOV BL, d                           
        MOV newD, BL                        

        CMP eGame, 1                        
        JE quit                             

        JMP more                            ; Continue main loop

        quit:
        CALL clearMem                       ; Set all to default
        MOV delTime, 100                    
    RET

startGame ENDP

EstartGame PROC USES EAX EBX ECX EDX
        MOV EAX, lightMagenta + (black * 16)      
        CALL SetTextColor
        MOV DH, 24                        
        MOV DL, 0                          
        CALL GotoXY                        
        MOV EDX, OFFSET scoreS
        CALL WriteString
        INVOKE getStdHandle, STD_INPUT_HANDLE
        MOV myHandle, EAX
        MOV ECX, 10
        INVOKE ReadConsoleInput, myHandle, ADDR temp, 1, ADDR bRead
        INVOKE ReadConsoleInput, myHandle, ADDR temp, 1, ADDR bRead
    more:
        INVOKE GetNumberOfConsoleInputEvents, myHandle, ADDR numInp
        MOV ECX, numInp
        CMP ECX, 0                         
        JE done                            
        INVOKE ReadConsoleInput, myHandle, ADDR temp, 1, ADDR bRead
        MOV DX, WORD PTR temp              
        CMP DX, 1                          
        JNE SkipEvent                       
            MOV DL, BYTE PTR [temp+4]       
            CMP DL, 0
            JE SkipEvent
                MOV DL, BYTE PTR [temp+10]  
                CMP DL, 1Bh                 
                JE quit                     
                CMP d, 'w'                 
                JE case1                   
                CMP d, 's'                 
                JE case1                   
                JMP case2                  
                case1:
                    CMP DL, 25h             
                    JE case11
                    CMP DL, 27h             
                    JE case12
                    JMP SkipEvent           
                    case11:
                        MOV newD, 'a'      
                        JMP SkipEvent
                    case12:
                        MOV newD, 'd'      
                        JMP SkipEvent
                case2:
                    CMP DL, 26h             
                    JE case21
                    CMP DL, 28h            
                    JE case22
                    JMP SkipEvent           
                    case21:
                        MOV newD, 'w'      
                        JMP SkipEvent
                    case22:
                        MOV newD, 's'      
                        JMP SkipEvent
    SkipEvent:
        JMP more                         
    done:
        MOV BL, newD                   
        MOV d, BL
        CALL EMoveSnake                     
        MOV EAX, DelTime                  
        CALL Delay                          
        MOV BL, d                          
        MOV newD, BL                    
        CMP eGame, 1                      
        JE quit                          
        JMP more                       
        quit:
        CALL clearMem                ; Set all to default      
        MOV delTime, 100                  
    RET
EstartGame ENDP

MoveSnake PROC USES EBX EDX

;updates the framebuffer, moving the snake

    CMP eTail, 1            
    JNE NoETail            

        MOV DH, tR          
        MOV DL, tC         
        CALL accessIndex    
        DEC BX              
                           
        MOV search, BX     

        MOV BX, 0           
        CALL saveIndex      

        CALL GotoXY       
        MOV EAX, white + (black * 16)
        CALL SetTextColor
        MOV AL, ' '
        CALL WriteChar

        PUSH EDX           
        MOV DL, 79
        MOV DH, 23
        CALL GotoXY
        POP EDX

        MOV AL, DH          
        DEC AL              
        MOV rM, AL          
        ADD AL, 2          
        MOV rP, AL          

        MOV AL, DL          
        DEC AL              
        MOV cM, AL          
        ADD AL, 2           
        MOV cP, AL          

        CMP rP, 24          
        JNE next1
            MOV rP, 0      

        next1:
        CMP cP, 80          
        JNE next2
            MOV cP, 0       

        next2:
        CMP rM, 0          
        JGE next3
            MOV rM, 23      

        next3:
        CMP cM, 0           
        JGE next4
            MOV cM, 79      

        next4:

        MOV DH, rM         
        MOV DL, tC         
        CALL accessIndex    
        CMP BX, search     
        JNE melseif1
            MOV tR, DH      
            JMP mendif

        melseif1:
        MOV DH, rP         
        CALL accessIndex    
        CMP BX, search      
        JNE melseif2
            MOV tR, DH      
            JMP mendif

        melseif2:
        MOV DH, tR          
        MOV DL, cM          
        CALL accessIndex   
        CMP BX, search      
        JNE melse
            MOV tC, DL     
            JMP mendif

        melse:
            MOV DL, cP      
            MOV tC, DL

        mendif:

    NoETail:

    MOV eTail, 1            
    MOV DH, tR              
    MOV DL, tC              
    MOV tmpR, DH            
    MOV tmpC, DL          

    whileTrue:              
                            
        MOV DH, tmpR        
        MOV DL, tmpC       
        CALL accessIndex    
        DEC BX             
                           
        MOV search, BX      

        PUSH EBX           
        ADD BX, 2           
        CALL saveIndex      
        POP EBX

        CMP BX, 0           
        JE break            

        MOV AL, DH         
        DEC AL            
        MOV rM, AL          
        ADD AL, 2           
        MOV rP, AL          

        MOV AL, DL         
        DEC AL              
        MOV cM, AL          
        ADD AL, 2           
        MOV cP, AL          

        CMP rP, 24          
        JNE next21
            MOV rP, 0       

        next21:
        CMP cP, 80          
        JNE next22
            MOV cP, 0       

        next22:
        CMP rM, 0           
        JGE next23
            MOV rM, 23     

        next23:
        CMP cM, 0           
        JGE next24
            MOV cM, 79     

        next24:

        MOV DH, rM         
        MOV DL, tmpC        
        CALL accessIndex    
        CMP BX, search      
        JNE elseif21
            MOV tmpR, DH    
            JMP endif2

        elseif21:
        MOV DH, rP          
        CALL accessIndex    
        CMP BX, search      
        JNE elseif22
            MOV tmpR, DH    
            JMP endif2

        elseif22:
        MOV DH, tmpR        
        MOV DL, cM         
        CALL accessIndex    
        CMP BX, search      
        JNE else2
            MOV tmpC, DL   
            JMP endif2

        else2:
            MOV DL, cP      
            MOV tmpC, DL

        endif2:
        JMP whileTrue       

    break:

    MOV AL, hR             
    DEC AL                  
    MOV rM, AL             
    ADD AL, 2               
    MOV rP, AL              

    MOV AL, hC              
    DEC AL                  
    MOV cM, AL            
    ADD AL, 2              
    MOV cP, AL             

    CMP rP, 24              
    JNE next31
        MOV rP, 0           

    next31:
    CMP cP, 80              
    JNE next32
        MOV cP, 0          

    next32:
    CMP rM, 0               
    JGE next33
        MOV rM, 23         

    next33:
    CMP cM, 0               
    JGE next34
        MOV cM, 79         

    next34:

    CMP d, 'w'             
    JNE elseif3
        MOV AL, rM         
        MOV hR, AL         
        JMP endif3

    elseif3:
    CMP d, 's'              
    JNE elseif32
        MOV AL, rP         
        MOV hR, AL          
        JMP endif3

    elseif32:
    CMP d, 'a'             
    JNE else3
        MOV AL, cM          
        MOV hC, AL          
        JMP endif3

    else3:
        MOV AL, cP          
        MOV hC, AL          

    endif3:

    MOV DH, hR              
    MOV DL, hC              

    CALL accessIndex        
    CMP BX, 0               
    JE NoHit               
                           
    MOV EAX, 4000           
    MOV DH, 24              
    MOV DL, 11            
    CALL GotoXY
    MOV EDX, OFFSET hitS
    CALL WriteString

    CALL Delay              
    MOV eGame, 1            

    RET                    

    NoHit:                  
    MOV BX, 1               
    CALL saveIndex        

    MOV cl, fC              
    MOV ch, fR           

    CMP cl, DL             
    JNE foodNotGobbled    
    CMP ch, DH             
    JNE foodNotGobbled     

    CALL createFood         
    MOV eTail, 0           

    MOV EAX, white + (black * 16)
    CALL SetTextColor       

    PUSH EDX                

    MOV DH, 24             
    MOV DL, 7
    CALL GotoXY
    MOV EAX, cScore         
    INC EAX
    CALL WriteDec
    MOV cScore, EAX         

    POP EDX                 

    foodNotGobbled:        
    CALL GotoXY            
    MOV EAX, blue + (white * 16)
    CALL setTextColor       
    MOV AL, ' '            
    CALL WriteChar
    MOV DH, 24              
    MOV DL, 79
    CALL GotoXY

    RET                     ; Exit procedure

MoveSnake ENDP

EMoveSnake PROC USES EBX EDX
    CMP eTail, 1            
    JNE NoETail             
        MOV DH, tR          
        MOV DL, tC        
        CALL accessIndex    
        DEC BX            
                            
        MOV search, BX    
        MOV BX, 0           
        CALL saveIndex     
        CALL GotoXY         
        MOV EAX, white + (black * 16)
        CALL SetTextColor
        MOV AL, ' '
        CALL WriteChar

        PUSH EDX            
        MOV DL, 79
        MOV DH, 23
        CALL GotoXY
        POP EDX

        MOV AL, DH         
        DEC AL           
        MOV rM, AL        
        ADD AL, 2          
        MOV rP, AL         

        MOV AL, DL          
        DEC AL              
        MOV cM, AL         
        ADD AL, 2           
        MOV cP, AL         

        CMP rP, 24          
        JNE next1
            MOV rP, 0       

        next1:
        CMP cP, 80        
        JNE next2
            MOV cP, 0       

        next2:
        CMP rM, 0           
        JGE next3
            MOV rM, 23     

        next3:
        CMP cM, 0           
        JGE next4
            MOV cM, 79     

        next4:

        MOV DH, rM          
        MOV DL, tC         
        CALL accessIndex    
        CMP BX, search     
        JNE melseif1
            MOV tR, DH    
            JMP mendif

        melseif1:
        MOV DH, rP         
        CALL accessIndex    
        CMP BX, search     
        JNE melseif2
            MOV tR, DH      
            JMP mendif

        melseif2:
        MOV DH, tR         
        MOV DL, cM          
        CALL accessIndex   
        CMP BX, search     
        JNE melse
            MOV tC, DL      
            JMP mendif

        melse:
            MOV DL, cP      
            MOV tC, DL

        mendif:

    NoETail:

    MOV eTail, 1            
    MOV DH, tR             
    MOV DL, tC             
    MOV tmpR, DH            
    MOV tmpC, DL            

    whileTrue:              
                            
        MOV DH, tmpR        
        MOV DL, tmpC      
        CALL accessIndex    
        DEC BX              
                           
        MOV search, BX      

        PUSH EBX            
        ADD BX, 2           
        CALL saveIndex      
        POP EBX

        CMP BX, 0           
        JE break            

        MOV AL, DH          
        DEC AL             
        MOV rM, AL   
        ADD AL, 2       
        MOV rP, AL        

        MOV AL, DL         
        DEC AL             
        MOV cM, AL         
        ADD AL, 2           
        MOV cP, AL          

        CMP rP, 24          
        JNE next21
            MOV rP, 0      

        next21:
        CMP cP, 80         
        JNE next22
            MOV cP, 0      

        next22:
        CMP rM, 0          
        JGE next23
            MOV rM, 23      

        next23:
        CMP cM, 0          
        JGE next24
            MOV cM, 79     

        next24:

        MOV DH, rM          
        MOV DL, tmpC        
        CALL accessIndex   
        CMP BX, search     
        JNE elseif21
            MOV tmpR, DH    
            JMP endif2

        elseif21:
        MOV DH, rP          
        CALL accessIndex    
        CMP BX, search      
        JNE elseif22
            MOV tmpR, DH    
            JMP endif2

        elseif22:
        MOV DH, tmpR        
        MOV DL, cM         
        CALL accessIndex    
        CMP BX, search      
        JNE else2
            MOV tmpC, DL   
            JMP endif2

        else2:
            MOV DL, cP     
            MOV tmpC, DL

        endif2:
        JMP whileTrue      

    break:

    MOV AL, hR              
    DEC AL                  
    MOV rM, AL              
    ADD AL, 2             
    MOV rP, AL              

    MOV AL, hC              
    DEC AL                 
    MOV cM, AL            
    ADD AL, 2              
    MOV cP, AL            

    CMP rP, 24              
    JNE next31
        MOV rP, 0          

    next31:
    CMP cP, 80              
    JNE next32
        MOV cP, 0          

    next32:
    CMP rM, 0               
    JGE next33
        MOV rM, 23          

    next33:
    CMP cM, 0              
    JGE next34
        MOV cM, 79          

    next34:

    CMP d, 'w'              
    JNE elseif3
        MOV AL, rM          
        MOV hR, AL         
        JMP endif3

    elseif3:
    CMP d, 's'             
    JNE elseif32
        MOV AL, rP          
        MOV hR, AL          
        JMP endif3

    elseif32:
    CMP d, 'a'              
    JNE else3
        MOV AL, cM          
        MOV hC, AL          
        JMP endif3

    else3:
        MOV AL, cP          
        MOV hC, AL          

    endif3:

    MOV DH, hR              
    MOV DL, hC             

    CALL accessIndex        
    CMP BX, 0               
    JE NoHit                
                            
    MOV EAX, 4000           
    MOV DH, 24              
    MOV DL, 11              
    CALL GotoXY
    MOV EDX, OFFSET hitS
    CALL WriteString

    CALL Delay            
    MOV eGame, 1            

    RET                    

    NoHit:                 
    MOV BX, 1               
    CALL saveIndex          

    MOV cl, fC              ; Copy food column to memory
    MOV ch, fR              ; Copy food row to memory

    CMP cl, DL              
    JNE BNotGobbled      
    CMP ch, DH              
    JNE BNotGobbled      
	CALL createFood         ; Food has been eaten, create new food location
	JMP GotFood
	
	BNotGobbled:
	MOV cl, fCY              ; Copy food column to memory
    MOV ch, fRY              ; Copy food row to memory
	CMP cl, DL              
    JNE RNotGobbled      ; Food has not been eaten
    CMP ch, DH              
    JNE RNotGobbled      ; Food has not been eaten
	CALL EYcreateFood         ; Food has been eaten, create new food location
	JMP GotFood
	
	RNotGobbled:
	MOV cl, fCR              ; Copy food column to memory
    MOV ch, fRR              ; Copy food row to memory
	CMP cl, DL              
    JNE foodNotGobbled      ; Food has not been eaten
    CMP ch, DH              
    JNE foodNotGobbled      ; Food has not been eaten
	CALL ERcreateFood         ; Food has been eaten, create new food location
    GotFood:
    MOV eTail, 0            ; Clear erase tail flag, so that snake grows in
                           

    PUSH EDX                

    MOV DH, 24             
    MOV DL, 7
    CALL GotoXY
    MOV EAX, cScore        
    INC EAX
    CALL WriteDec
    MOV cScore, EAX         

    POP EDX                 

    foodNotGobbled:         
    CALL GotoXY             
	mov  eax,100     
    call RandomRange 
	shl eax,4
    add EAX, blue 
    CALL setTextColor       
    MOV AL, ' '             
    CALL WriteChar
    MOV DH, 24              
    MOV DL, 79
    CALL GotoXY

    RET                     ; Exit procedure

EMoveSnake ENDP

createFood PROC USES EAX EBX EDX
;generates food for the snake.
    redo:                     
    MOV EAX, 24                
    CALL RandomRange           
    MOV DH, AL

    MOV EAX, 80                 
    CALL RandomRange            
    MOV DL, AL

    CALL accessIndex           

    CMP BX, 0                  
    JNE redo                   

    MOV fR, DH                 
    MOV fC, DL                 

    MOV EAX, black + (cyan * 16)
    CALL setTextColor
    CALL GotoXY                
    MOV AL, ' '                
    CALL WriteChar

    RET

createFood ENDP

EYcreateFood PROC USES EAX EBX EDX
    redo:                       
    MOV EAX, 24                 
    CALL RandomRange           
    MOV DH, AL

    MOV EAX, 80                 
    CALL RandomRange            
    MOV DL, AL
    CALL accessIndex            

    CMP BX, 0                  
    JNE redo                   

    MOV fRY, DH                 
    MOV fCY, DL                 

    MOV EAX, black + (yellow * 16)
    CALL setTextColor
    CALL GotoXY                 
    MOV AL, ' '                 
    CALL WriteChar

    RET

EYcreateFood ENDP

ERcreateFood PROC USES EAX EBX EDX
    redo:                       
    MOV EAX, 24                 
    CALL RandomRange            
    MOV DH, AL

    MOV EAX, 80                 
    CALL RandomRange           
    MOV DL, AL
    CALL accessIndex            

    CMP BX, 0                   
    JNE redo                    

    MOV fRR, DH                  
    MOV fCR, DL                  

    MOV EAX, black + (lightRed * 16)
    CALL setTextColor
    CALL GotoXY                 
    MOV AL, ' '                
    CALL WriteChar

    RET

ERcreateFood ENDP

accessIndex PROC USES EAX ESI EDX
; This procedure accesses the framebuffer

    MOV BL, DH      
    MOV AL, 80     
    MUL BL          
    PUSH DX         
    MOV DH, 0      
    ADD AX, DX      
    POP DX         
    MOV ESI, 0     
    MOV SI, AX      
    SHL SI, 1       

    MOV BX, a[SI]  
    RET
accessIndex ENDP

saveIndex PROC USES EAX ESI EDX
; accesses the framebuffer and writes a value to the pixel

    PUSH EBX       
    MOV BL, DH     
    MOV AL, 80      
    MUL BL          
    PUSH DX        
    MOV DH, 0      
    ADD AX, DX     
    POP DX          
    MOV ESI, 0     
    MOV SI, AX      
    POP EBX         
    SHL SI, 1       
    MOV a[SI], BX   
    RET
saveIndex ENDP

Paint PROC USES EAX EDX EBX ESI
; reads the contents of the framebuffer, pixel by pixel, and giving it color

    MOV EAX, blue + (white * 16)    ; Set text color to blue on white
    CALL SetTextColor

    MOV DH, 0                       ; Set row number to 0

    loop1:                          ; Loop for indexing of the rows
        CMP DH, 24                  
        JGE endLoop1               

        MOV DL, 0                   ; Set column number to 0

        loop2:                      
            CMP DL, 80              
            JGE endLoop2            
            CALL GOTOXY            

            MOV BL, DH             
            MOV AL, 80             
            MUL BL
            PUSH DX                 
            MOV DH, 0               
            ADD AX, DX             
            POP DX                 
            MOV ESI, 0             
            MOV SI, AX              
            SHL SI, 1              
			
            MOV BX, a[SI]         

            CMP BX, 0           
            JE NoPrint             

            CMP BX, 0FFFFh        
            JE printHurdle         

            MOV AL, ' '            
            CALL WriteChar          
            JMP noPrint            

            PrintHurdle:           
            MOV EAX, blue + (gray * 16) 
            CALL SetTextColor

            MOV AL, ' '             
            CALL WriteChar

            MOV EAX, blue + (white * 16)    
            CALL SetTextColor               

            NoPrint:
            INC DL                 
            JMP loop2              

    endLoop2:                      
        INC DH                     
        JMP loop1                   

endLoop1:                           ; End of row loop

RET

Paint ENDP

EPaint PROC USES EAX EDX EBX ESI
    MOV EAX, blue + (white * 16)    ; Set text color to blue on white
    CALL SetTextColor

    MOV DH, 0                       

    loop1:                          
        CMP DH, 24                 
        JGE endLoop1             

        MOV DL, 0                 

        loop2:                    
            CMP DL, 80             
            JGE endLoop2           
            CALL GOTOXY             

            MOV BL, DH              
            MOV AL, 80              
            MUL BL
            PUSH DX                
            MOV DH, 0              
            ADD AX, DX              
            POP DX                 
            MOV ESI, 0             
            MOV SI, AX             
            SHL SI, 1               
   
            MOV BX, a[SI]         

            CMP BX, 0              
            JE NoPrint         

            CMP BX, 0FFFFh          
            JE printHurdle        

            MOV AL, ' '            
            CALL WriteChar        
            JMP noPrint             

            PrintHurdle:           
            MOV EAX, blue + (green * 16) 
            CALL SetTextColor

            MOV AL, ' '             
            CALL WriteChar

            MOV EAX, blue + (white * 16)    
            CALL SetTextColor              

            NoPrint:
            INC DL                  ; Increment the column number
            JMP loop2               ; Continue column indexing

    endLoop2:                       
        INC DH                      
        JMP loop1                  

endLoop1:                           ; End of row loop
RET
EPaint ENDP

GenLevel PROC
; generating the level obstacles. There are three

    CMP AL, 1               ; Check if level choice is without obstacles
    JNE nextL               

    RET                     

    nextL:                  
    CMP AL, 2
    JNE nextL2             

    MOV DH, 0               
    MOV BX, 0FFFFh          ; Set data to be written to framebuffer

    rLoop:                  ; Loop for generating vertical lines
        CMP DH, 24         
        JE endRLoop         

        MOV DL, 0           
        CALL saveIndex      
        MOV DL, 79          
        CALL saveIndex      
        INC DH             
        JMP rLoop           ; Continue loop
    endRLoop:

    MOV DL, 0               ; Set column index to 0

    cLoop:                  ; Loop for generating horizontal lines
        CMP DL, 80         
        JE endCLoop        

        MOV DH, 0           
        CALL saveIndex      
        MOV DH, 23          
        CALL saveIndex      
        INC DL             
        JMP cLoop           ; Continue loop

        endCLoop:

    RET

    nextL2:                 ; Section for generating rooms level

        MOV newD, 'd'      
        MOV DH, 11         
        MOV DL, 0           
        MOV BX, 0FFFFh     

        cLoop2:            
                            
            CMP DL, 80     
            JE endCLoop2

            CALL saveIndex  
            INC DL         
            JMP cLoop2      

        endCloop2:          
        MOV DH, 0           
        MOV DL, 39          

        rLoop2:             
            CMP DH, 24     
            JE endRLoop2

            CALL saveIndex  
            INC DH          
            JMP rLoop2      

        endRLoop2:          ; Return from procedure after painting both lines

    RET

GenLevel ENDP
END main