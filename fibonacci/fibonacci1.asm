; Programa para calcular a serie de Fibonacci (AX<-val anterior; BX<-Val atual)
; Uso de INT 21h (AH<-09h;DX<-label/ponteiro do String/endereço) para imprimir mensagem em tela
; Uso de funções (CALL) 

segment code
..start:
		MOV 	AX, dados		; Inicializa o registrador de Segmento de Dados DS		
		MOV 	DS, AX
		MOV 	AX, stack		; Inicializa o registrador de Segmento de Pilha SS
		MOV 	SS,AX
		MOV 	SP,stacktop 	; Inicializa o apontador de Pilha SP
		
 		MOV 	DX,mensini 		; Mensagem de inicio
		MOV 	AH,9			; Carrega em AH o valor de 09h
		INT 	21h				; Chama interrupção do DOS para imprimir mensagem em tela
					
		MOV 	AX,0 			; Primeiro elemento da série
		MOV 	BX,1 			; Segundo elemento da série
L10:
		MOV 	DX,AX			; Carrega em DX o valor a ser imprimido em tela
		CALL	imprimenumero	; Chama função imprimenumero 
		ADD 	DX,BX 			; Calcula novo elemento da série
		MOV 	AX,BX			; Carrega em AX o valor anterior da série
		MOV 	BX,DX			; Carrega em BX o valor atual
		
		CMP 	DX, 100			; Compara o valor anterior da série (DX) com um valor imediato
		JB 		L10				; Pula a L10 se o valor for menor do que o valor imediato (Vmax 65535)	

; ------ AQUI TERMINA A EXECUCAO DO PROGRAMA PRINCIPAL ------
exit:
		MOV 	DX,mensfim 		; Mensagem de final
		MOV 	AH,9
		INT	 	21h
quit:
		MOV 	AH,4CH 			; Retorna o controle para o DOS com código 0
		INT 	21h

;*****************************************************************

imprimenumero:
		PUSHF					; Salva o contexto = Empilha os registradores
		PUSH 	AX
		PUSH 	BX
		PUSH	CX
		PUSH 	DX
				
		MOV 	DI,saida		; Carrega em DI o label/endereço do String saida
		CALL 	bin2ascii		; Chama função bin2ascii para converter binario para ascii	

		MOV 	DX,saida		; Imprime numero da série em tela
		MOV 	AH,9h
		INT 	21h         

		POP 	DX				; Atualiza o contexto = Dezempilha registradores
		POP 	CX
		POP		BX
		POP 	AX
		POPF
		RET

bin2ascii:
		CMP		DX,10			; Compara o valor de DX com 10, 100, 1000 e 10000 
		JB		Uni				; e dependendo pula para conversão de:
		CMP		DX,100 			; UnidaDez (DX+30h)
		JB		Dez				; Decenas AX<-DX; DL=10 (AL=AX/DL; AL=quociente e AH=resto)
		CMP		DX,1000			; Centenas AX<-DX; DL=100 (AL=AX/DL; AL=quociente e AH=resto)
		JB		Cen				; Faz o processo duas veces, divide por 100 e depois por 10
		CMP		DX,10000		; Milhares AX<-DX; DX=1000 (AX=AX/DX; AX=quociente e DX=resto)
		JB		Mil				; Faz o processo três veces, divide por 1000, 100 e 10
		JMP		Dezmil
			
Uni:	
		ADD		DX,0x0030		; Acrescenta 30h para converter em ascii
		MOV 	byte [DI],DL	; Transfere resultado Unidades para saída (DI)	
		RET						; Retorna da função
Dez:
		MOV 	AX,DX			; Tem que transferir o valor de DX para AX para fazer a divisão
		MOV		BL,10			; Carrega em BL o Divisor
		DIV		BL				; Divide por 10
		ADD		AH,0x30			; Acrescenta 30h para converter o Resto em ascii
		ADD		AL,0x30			; Acrescenta 30h para converter o Quociente em ascii
		MOV 	byte [DI],AL	; Transfere resultado Dezenas para saída (DI)
		MOV 	byte [DI+1],AH  ; Transfere resultado Unidades para saída (DI)
		RET						; Retorna da função
Cen:		
		MOV 	AX,DX			; Tem que transferir o valor de DX para AX para fazer a divisão
		MOV		BL,100			; Carrega em BL o Divisor
		DIV		BL				; Divide por 100
		ADD		AL,0x30			; Acrescenta 30h para converter o Quociente em ascii
		MOV 	byte [DI],AL	; Transfere resultado Centenas para saída (DI)
		MOV 	AL,AH			; Substitui o Quociente pelo Resto 
		AND		AX,0x00FF		; Filtra o Resto (AH) de AX
		MOV		BL,10			; Carrega em BL o Divisor
		DIV		BL				; Divide por 10
		ADD		AH,0x30			; Acrescenta 30h para converter o Resto em ascii
		ADD		AL,0x30			; Acrescenta 30h para converter o Quociente em ascii
		MOV 	byte [DI+1],AL	; Transfere resultado Dezenas para saída (DI+1)	
		MOV 	byte [DI+2],AH	; Transfere resultado Unidades para saída (DI+2)
		RET						; Retorna da função
Mil:		
		MOV 	AX,DX
		MOV     DX,0
		MOV		BX,1000
		DIV		BX
		ADD		AL,0x30
		MOV 	byte [DI],AL
		MOV 	AX,DX
		MOV		BL,100
		DIV		BL
		ADD		AL,0x30
		MOV 	byte [DI+1],AL		
		MOV 	AL,AH
	    AND     AX,0x00FF
		MOV		BL,10
		DIV		BL
		ADD		AH,0x30
		ADD		AL,0x30
		MOV 	byte [DI+2],AL		
		MOV 	byte [DI+3],AH
		RET						; Retorna da função
Dezmil:
		MOV 	AX,DX
		MOV     DX,0
		MOV		BX,10000
		DIV		BX
		ADD		AL,0x30
		MOV 	byte [DI],AL
		MOV		AX,DX		
		MOV     DX,0
		MOV		BX,1000
		DIV		BX
		ADD		AL,0x30
		MOV 	byte [DI+1],AL
		MOV 	AX,DX
		MOV		BL,100
		DIV		BL
		ADD		AL,0x30
		MOV 	byte [DI+2],AL		
		MOV 	AL,AH
	    AND     AX,0x00FF
		MOV		BL,10
		DIV		BL
		ADD		AH,0x30
		ADD		AL,0x30
		MOV 	byte [DI+3],AL		
		MOV 	byte [DI+4],AH
		RET						; Retorna da função
		
segment dados ;segmento de dados inicializados
	CR 	EQU		13
	LF 	EQU		10
mensini: db 'Programa que calcula a Serie de Fibonacci. ',CR,LF,'$'
mensfim: db 'Fim da serie!!',CR,LF,'$'
;saida: db '00000',CR,LF,'$'
saida: 	resb 5 
        db CR,LF,'$'

segment stack stack
	resb 256 ; reserva 256 bytes para formar a pilha
stacktop: