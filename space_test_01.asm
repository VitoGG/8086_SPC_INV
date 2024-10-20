DATA_SEG    SEGMENT
    BACKGROUND_COLOR DB 00h  ; cor do fundo
    
    ; VARIAVEIS DA Nave
    NAVE_X DW 0Ah        ; posicao X (coluna) da Nave
    NAVE_Y DW 0Ah        ; posicao y (linha) da Nave
    NAVE_WIDTH DW 06h         ; largura
    NAVE_HEIGHT DW 08h        ; altura
    NAVE_VELOCITY DW 03h
    
    ; VARIAVEIS Do tiro
    TIRO_X DW 50h        ; posicao X (coluna) da tiro
    TIRO_Y DW 50h        ; posicao y (linha) da tiro
    TIRO_SIZE DW 02h     ; 4pixels width e height (16pixels no total)    
    TIRO_VELOCITY_X DW 0Ah  ; TIRO SE MOVIMENTA 10 PIXELS POR SEGUNDO, UMA BALA
    
    DISPARADO DB 0         ; VARIVEL QUE DIZ SE O TIRO FOI DISPARADO
    EM_MOVIMENTO DB 0
    
    WINDOW_WIDTH DW 140h   ; 320 em hexadecimal
    WINDOW_HEIGHT DW 0C8h   ; x 200 em hexadecimal
    WINDOW_BOUNDS DW 4     ; CHECA COLISAO ANTES 
    
    TIME_AUX DB 0        ; variavel auxiliar de tempo (usada para checar o tempo que passou)

    TARGET_HIT DW 0

    ; Estruturas para objetos INIMIGOS
    OBJETOS_ARRAY LABEL BYTE
        OBJ1_X DW 0c8h  ; Posição X do primeiro objeto
        OBJ1_Y DW 14h   ; Posição Y do primeiro objeto
        OBJ1_STATUS DB 1 ; status do primeiro objeto

        OBJ2_X DW 240    ; Posição X do segundo objeto
        OBJ2_Y DW 98    ; Posição Y do segundo objeto
        OBJ2_STATUS DB 1 ; status do segundo objeto

        OBJ3_X DW 170   ; Posição X do terceiro objeto
        OBJ3_Y DW 180   ; Posição Y do terceiro objeto
        OBJ3_STATUS DB 1 ; status do terceiro objeto
        ; Quantidade de objetos no array
        NUM_OBJETOS DB 3
DATA_SEG    ENDS

CODE_SEG    SEGMENT
    ASSUME CS: CODE_SEG, DS:DATA_SEG
    START:
        MOV   AX, DATA_SEG
        MOV   DS, AX
        
        CALL CLEAR_SCREEN
        
        CHECK_TIME:
            ; pega o time do sistema
            MOV AH, 2Ch 
            INT 21h                 ; time do sistema
            
            ; if 60 segundos se passaram (tempo atual == (time_aux) ?)
            CMP DL, TIME_AUX
            JE CHECK_TIME       ; se for mesmo time, checa de novo
            
            MOV TIME_AUX, DL
            CALL CHECK_INPUT
            CALL MOVE_TIRO  
            CALL DRAW_FRAME
            JMP CHECK_TIME   ; checa o time de novo (request animation frame)
        RET                  ; EU ESQUECI DISSO KKKKKK TEM Q COLOCAR P NAO PARAR DE FUNCIONAR
        
        DRAW_FRAME PROC NEAR
            CALL CLEAR_SCREEN
            CALL DRAW_NAVE   ; DESENHA O FRAME
            CALL DRAW_INIMIGOS
            CALL DRAW_TIRO 
        DRAW_FRAME ENDP

        CHECK_INPUT PROC NEAR
            ; -------INT 16 KEYBOARD BIOS SERVICES--------- https://www.stanislavs.org/helppc/int_16-1.html
            ; @AH = 01
            ; ZF = 0 (KEY PRESSED)
            ; AH = 00
            ; AH = (SCAN CODE)
            ; AL = (ASCII CHAR)

            ; verifica se uma tecla foi pressionada
            MOV AH, 01h
            INT 16h
            JZ NO_KEY_PRESSED      ; se nenhuma tecla foi pressionada, sai

            ; obtém o código da tecla pressionada
            MOV AH, 00h
            INT 16h

            ; movimentação para cima (W ou w)
            CMP AL, 77h ; 'w'
            JE MOVE_NAVE_UP
            CMP AL, 57h ; 'W'
            JE MOVE_NAVE_UP

            ; movimentação para baixo (S ou s)
            CMP AL, 73h ; 's'
            JE MOVE_NAVE_DOWN
            CMP AL, 53h ; 'S'
            JE MOVE_NAVE_DOWN

            ; dispara o tiro ao pressionar espaço
            CMP AL, 20h ; espaço
            JE SET_DISPARO

            NO_KEY_PRESSED:
                RET

            MOVE_NAVE_UP:
                ; move a nave para cima se não estiver no limite superior
                MOV AX, NAVE_VELOCITY
                SUB NAVE_Y, AX
                MOV BX, WINDOW_BOUNDS
                CMP NAVE_Y, BX
                JGE VALID_MOVE_UP
                MOV NAVE_Y, BX ; limite superior alcançado

            VALID_MOVE_UP:
                RET

            MOVE_NAVE_DOWN:
                ; move a nave para baixo se não estiver no limite inferior
                MOV AX, NAVE_VELOCITY
                ADD NAVE_Y, AX
                MOV BX, WINDOW_HEIGHT
                SUB BX, WINDOW_BOUNDS
                SUB BX, NAVE_HEIGHT
                CMP NAVE_Y, BX
                JLE VALID_MOVE_DOWN
                MOV NAVE_Y, BX ; limite inferior alcançado

            VALID_MOVE_DOWN:
                RET

            SET_DISPARO:
                CMP DISPARADO, 0
                JNE SKIP_DISPARO ; não permite múltiplos tiros

                ; inicializa o tiro na posição da nave
                MOV AX, NAVE_X
                MOV TIRO_X, AX
                MOV AX, NAVE_Y
                MOV TIRO_Y, AX
                MOV DISPARADO, 1
                MOV EM_MOVIMENTO, 1

            SKIP_DISPARO:
                RET
        CHECK_INPUT ENDP
        
        DRAW_NAVE PROC NEAR
            MOV CX, NAVE_X          ; POSICAO X inicial
            MOV DX, NAVE_Y          ; POSICAO Y inicial

            DRAW_NAVE_X:
                MOV AH, 0Ch
                MOV AL, 02h             ; COR DO PIXEL
                MOV BH, 00h             ; NUMERO DA PAGINA
                INT 10h

                INC CX
                MOV AX, CX
                SUB AX, NAVE_X
                CMP AX, NAVE_WIDTH       ; CX - TIRO_X > TIRO_SIZE ( Y++ desenha na proxima linha
                JNG DRAW_NAVE_X
                
                MOV CX, NAVE_X          ; o registrador CX volta para a coluna inicial
                INC DX                   ; incrementa Y ( que esta em DX )
                
                ; DX - TIRO_Y > TIRO_SIZE (FInaliza, se n?o, vai para proxima linha)
                MOV AX, DX
                SUB AX, NAVE_Y
                CMP AX, NAVE_HEIGHT
                JNG DRAW_NAVE_X
            RET
        DRAW_NAVE endp
        

        DRAW_TIRO PROC NEAR
            CMP DISPARADO, 1
            JNE SKIP_DRAW_TIRO

            MOV CX, TIRO_X          ; posição X do tiro
            MOV DX, TIRO_Y          ; posição Y do tiro

            DRAW_TIRO_X:
                MOV AH, 0Ch
                MOV AL, 0Fh             ; cor do tiro (branco)
                MOV BH, 00h             ; página de vídeo
                INT 10h

                INC CX
                MOV AX, CX
                SUB AX, TIRO_X
                CMP AX, TIRO_SIZE
                JNG DRAW_TIRO_X

                MOV CX, TIRO_X          ; volta para a coluna inicial
                INC DX

                MOV AX, DX
                SUB AX, TIRO_Y
                CMP AX, TIRO_SIZE
                JNG DRAW_TIRO_X

            SKIP_DRAW_TIRO:
                RET
        DRAW_TIRO ENDP
        
        MOVE_TIRO PROC NEAR
            CMP DISPARADO, 1
            JNE SKIP_MOVE_TIRO

            ; apaga o tiro na posição anterior
            MOV CX, TIRO_X
            MOV DX, TIRO_Y
            MOV AH, 0Ch
            MOV AL, BACKGROUND_COLOR ; cor de fundo para apagar
            MOV BH, 00h
            INT 10h

            ; move o tiro para a direita
            MOV AX, TIRO_VELOCITY_X
            ADD TIRO_X, AX

            CALL VERIFICAR_COLISAO
            
            ; verifica colisão com a borda direita
            MOV AX, WINDOW_WIDTH
            SUB AX, TIRO_SIZE
            CMP TIRO_X, AX
            JG RESET_TIRO
            
            JMP SKIP_MOVE_TIRO

            SKIP_MOVE_TIRO:
                RET

            RESET_TIRO:
                MOV DISPARADO, 0
                MOV EM_MOVIMENTO, 0
                RET
        MOVE_TIRO ENDP
        
        VERIFICAR_COLISAO PROC NEAR
            PUSH SI
            MOV SI, OFFSET OBJETOS_ARRAY
            MOV CL, NUM_OBJETOS          

            VERIFICAR_OBJETO:
                ; Verifica se o objeto está ativo
                MOV DL, [SI+4]      ; DL = STATUS
                CMP DL, 1
                JNE PROXIMO_OBJ

                ; Verifica colisão do tiro com o objeto atual
                MOV AX, [SI]        ; AX = X do objeto
                MOV BX, [SI+2]      ; BX = Y do objeto
                MOV CX, 8           ; Tamanho do quadrado (8x8 pixels)

                ; Verifica colisão em X
                MOV DX, TIRO_X
                CMP DX, AX
                JL PROXIMO_OBJ
                MOV DI, AX
                ADD DI, CX
                CMP DX, DI
                JGE PROXIMO_OBJ

                ; Verifica colisão em Y
                MOV DX, TIRO_Y
                CMP DX, BX
                JL PROXIMO_OBJ
                MOV DI, BX
                ADD DI, CX
                CMP DX, DI
                JGE PROXIMO_OBJ

                ; Colisão detectada, destruir o objeto
                CALL DESTRUIR_TARGET
                JMP TERMINA_VERIFICACAO

            PROXIMO_OBJ:
                ADD SI, 5            ; Avança para o próximo objeto
                DEC CL
                JNZ VERIFICAR_OBJETO

            TERMINA_VERIFICACAO:
                POP SI
                RET
        VERIFICAR_COLISAO ENDP

        DESTRUIR_TARGET PROC NEAR
            MOV BYTE PTR [SI+4], 0   ; definir STATUS para 0, ou seja, morreu
            CALL RESET_TIRO          ; aparentemente dá para chamar label de outras proc
            RET
        DESTRUIR_TARGET ENDP

        DRAW_INIMIGOS PROC NEAR
            PUSH SI
            PUSH AX
            PUSH BX
            
            MOV SI, OFFSET OBJETOS_ARRAY
            MOV CL, NUM_OBJETOS ; Número de objetos no array

        DESENHAR_OBJETOS:
            MOV DL, [SI + 4]      ; Carrega o status do objeto

            CMP DL, 0
            JE PROXIMO_OBJETO  ; Se status zero, pula para o próximo objeto

            ; Else, desenha o objeto
            CALL DRAW_OBJECT

        PROXIMO_OBJETO:
            ; Avança para a próxima estrutura (5 bytes para cada objeto)
            ADD SI, 5

            ; Decrementa contador de objetos e repete se houver mais
            DEC CL
            JNZ DESENHAR_OBJETOS

            ; Fim da rotina
            POP BX
            POP AX
            POP SI
            RET

        ; Rotina para desenhar um objeto individual
        DRAW_OBJECT PROC NEAR
            PUSH CX
            PUSH DX
            MOV CX, [SI]          ; POSICAO X inicial
            MOV DX, [SI + 2]      ; POSICAO Y inicial

        DRAW_OBJECT_X:
            MOV AH, 0Ch
            MOV AL, 03h             ; COR DO PIXEL
            MOV BH, 00h             ; NUMERO DA PAGINA
            INT 10h

            INC CX
            MOV AX, CX
            SUB AX, [SI]
            CMP AX, 08h       ; CX - X inicial < 8?
            JL DRAW_OBJECT_X

            MOV CX, [SI]          ; O registrador CX volta para a coluna inicial
            INC DX                ; Incrementa Y (que está em DX)

            MOV AX, DX
            SUB AX, [SI + 2]
            CMP AX, 08h
            JL DRAW_OBJECT_X

            POP DX
            POP CX
            RET
        DRAW_OBJECT ENDP

        CLEAR_SCREEN PROC NEAR
            MOV AH, 00h             ; Modo gráfico
            MOV AL, 13h             ; 320x200 modo gráfico
            INT 10h
            RET
        CLEAR_SCREEN ENDP
        
CODE_SEG    ENDS
   END  START
