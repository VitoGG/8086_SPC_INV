DATA_SEG    SEGMENT
    BACKGROUND_COLOR DB 00h  ; cor do fundo
    
    ; VARIAVEIS DA Nave
    NAVE_X DW 32        ; posicao X (coluna) da Nave
    NAVE_Y DW 100        ; posicao y (linha) da Nave
    
    NAVE DB 1, 1, 1, 1, 1, 1, 1, 1, 1, 0, 0, 0, 0, 0, 0
         DB 0, 0, 1, 1, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
         DB 0, 0, 1, 1, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
         DB 0, 0, 1, 1, 1, 1, 1, 1, 1, 0, 0, 0, 0, 0, 0
         DB 0, 0, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1
         DB 0, 0, 1, 1, 1, 1, 1, 1, 1, 0, 0, 0, 0, 0, 0
         DB 0, 0, 1, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
         DB 0, 0, 1, 1, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
         DB 1, 1, 1, 1, 1, 1, 1, 1, 1, 0, 0, 0, 0, 0, 0
    
    length_nave dw $ - NAVE
    
    COR DB 0H
    
    TIME_AUX DB 0        ; variavel auxiliar de tempo (usada para checar o tempo que passou)

    TARGET_HIT DW 0
DATA_SEG    ENDS

CODE_SEG    SEGMENT
    ASSUME CS: CODE_SEG, DS:DATA_SEG
    START:
        MOV   AX, DATA_SEG
        MOV   DS, AX
    
        MOV AH, 00h             ; Modo gráfico
        MOV AL, 13h             ; 320x200 modo gráfico
        INT 10h
        CALL DRAW_NAVE
        
        
        ADD NAVE_X, 40
        CALL DRAW_NAVE

        RET
        ; CHECK_TIME:
        ;     ; pega o time do sistema
        ;     MOV AH, 2Ch 
        ;     INT 21h                 ; time do sistema
            
        ;     ; if 60 segundos se passaram (tempo atual == (time_aux) ?)
        ;     CMP DL, TIME_AUX
        ;     JE CHECK_TIME       ; se for mesmo time, checa de novo
            
        ;     MOV TIME_AUX, DL
  
        ;     CALL DRAW_FRAME

        ;     JMP CHECK_TIME   ; checa o time de novo (request animation frame)
        ; RET                  ; EU ESQUECI DISSO KKKKKK TEM Q COLOCAR P NAO PARAR DE FUNCIONAR
        
        ; DRAW_FRAME PROC NEAR
        ;     CALL CLEAR_SCREEN
        ;     CALL DRAW_NAVE   ; DESENHA O FRAME
        ; DRAW_FRAME ENDP

        DRAW_NAVE PROC NEAR
            MOV CX, NAVE_X           ; X - DESCOLAMENTO HORIZONTAL
            MOV DX, NAVE_Y          ; Y - DESLOCAMENTO VERTICAL

            MOV SI, OFFSET NAVE
            MOV BX, 0
            

            DESENHAR_LINHA:
                CMP BX, 15
                JE PROXIMA_LINHA

                MOV AH, 0Ch             ; PIXEL
                MOV AL, [SI]            ; COR DO PIXEL
                MOV BH, 00h             ; NUMERO DA PAGINA
                INT 10h 

                INC CX
                INC BX
                INC SI         
                jmp DESENHAR_LINHA

            PROXIMA_LINHA:
                CMP SI, length_nave
                JG TERMINAR

                MOV CX, NAVE_X
                INC DX
                MOV BX, 0
                JMP DESENHAR_LINHA
            TERMINAR:
                XOR SI, SI
                RET
        DRAW_NAVE ENDP
        
        CLEAR_SCREEN PROC NEAR

            RET
        CLEAR_SCREEN ENDP
CODE_SEG    ENDS
   END  START
