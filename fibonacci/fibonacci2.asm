; Programa para calcular a serie de Fibonacci (AX<-val anterior; BX<-Val atual)
; Uso de INT 21h (AH<-09h;DX<-label/ponteiro do String/endereço) para imprimir mensagem em tela
; Uso de funções (CALL) e uso de Pilha 

segment code
..start:
; iniciar os registros de segmento DS e SS e o ponteiro de pilha SP.
	MOV 	AX,dados			; AX <- dados. Carrega o endereço de dados em AX.
	MOV 	DS,AX				; DS <- AX. Move o conteudo de AX para DS.
	MOV 	AX,stack			; AX <- stack. Carrega o endereço de stack em AX.
	MOV 	SS,AX				; SS <- AX. Move o conteudo de AX para SS.
	MOV 	SP,stacktop			; SP <- stacktop. Carrega o endereço de stacktop em SP.
	
;****************CODIGO COMEÇA AQUI*******************************
	MOV 	DX,mensini 			; mensagem de inicio
	MOV 	AH,9				; AH <- 9. Passa valor 9 para AH.
	INT 	21h					; INT 21h / AH=9 - mostra a string disponível em DS:DX. Obs: a string deve terminar em '$'.
	MOV 	AX,0 				; primeiro elemento da série
	MOV 	BX,1 				; segundo elemento da série
	MOV 	word[saida],AX		; [saida]<- AX. Armazena valor de AX como conteudo em saida (primeiro elemento da série).
	CALL 	imprimenumero		; Chama imprimenumero
	MOV 	word [saida],BX		; [saida]<- BX. Armazena valor de BX como conteudo em saida (segundo elemento da série).
	CALL 	imprimenumero		; Chama imprimenumero
L10:
	MOV 	DX,AX				; DX <- AX. Passa valor de AX (elemento i-2) para DX (elemento i).
	ADD 	DX,BX 				; DX <- DX+BX. calcula novo elemento da série DX(i) = (AX(i-2)+BX(i-1)).
	MOV 	word[saida],DX		; [saida]<- DX. Armazena valor de DX como conteudo em saida. 
	CALL 	imprimenumero		; Chama imprimenumero
	MOV 	AX,BX				; AX <- BX. Passa valor de BX para AX (atualiza para a proxima iteração).
	MOV 	BX,DX				; BX <- DX. Passa valor de DX para BX (atualiza para a proxima iteração).
	CMP 	DX,0x8000			; Compara valor atual da serie com valor definido para interromper.
	jb 		L10					; pula se primeiro operando for abaixo do segundo. jl L10-> com sinal | JB L10 ->  Sem sinal

;*****************************************************************
exit:
	MOV 	DX,mensfim 			; mensagem de fim.
	MOV 	AH,9				; AH <- 9. Passa valor 9 para AH.
	INT 	21h					; INT 21h / AH=9 - mostra a string disponível em DS:DX. Obs: a string deve terminar em '$'.
quit:
	MOV 	AH,4CH 				; RETorna para o DOS com código 0
	INT 	21h					; INT 21h / AH=4Ch - devolver o controle ao sistema operacional (parar o programa).

;*****************************************************************
	
imprimenumero: 					; Rotina
								; Aqui, você deve salvar o contexto
	PUSH 	AX 					; Armazena AX na pilha.
	PUSH 	BX 					; Armazena BX na pilha.
	PUSH 	CX					; Armazena CX na pilha.
	PUSH 	DX					; Armazena DX na pilha.
	PUSH 	DI					; Armazena DI na pilha.
	
	MOV 	DI,saida			; DI <- saida. Passa endereço de saida para DI.
	PUSH 	DI					; Armazena DI na pilha.
	CALL 	bin2ascii			; Chama a rotina bin2ascii.
	MOV 	DX,saida			; DX <- saida. Passa endereço de saida para DX.
	MOV 	AH,9				; AH <- 9. Passa valor 9 para AH.
	INT 	21h					; INT 21h / AH=9 - mostra a string disponível em DS:DX. Obs: a string deve terminar em '$'.
								; Aqui, você deve recuperar o contexto
	POP 	DI					; Obtem DI da pilha.
	POP 	DX					; Obtem DX da pilha.
	POP 	CX					; Obtem CX da pilha.
	POP 	BX					; Obtem BX da pilha.
	POP 	AX					; Obtem AX da pilha.
	RET							; RETorna para onde foi chamada.
 
bin2ascii:
								; Aqui, você deve salvar o contexto
	PUSH 	AX 					; Armazena AX na pilha.
	PUSH 	BX 					; Armazena BX na pilha.
	PUSH 	CX					; Armazena CX na pilha.
	PUSH 	DX					; Armazena DX na pilha.
	PUSH 	BP					; Armazena BP na pilha.

	MOV 	BP,SP				; BP <- SP. Pega valor do topo da pilha.
	MOV 	BX,word[BP+12]  	; BX <- [BP+12]. Recupera o valor de DI da pilha.
	MOV 	AX,[BX]				; AX <- [BX]. Passa o conteudo do endereço salvo em BX (saida) para AX.
	
	XOR 	DX,DX				; DX <- DX XOR DX. Zera o registrador DX.
	MOV 	BX,10000			; BX <- 10000. Passa valor 10000 para BX.
	DIV 	BX					; AX <- (DX AX) / BX | DX <- Resto. Divide DX:AX por BX.
	ADD	 	AL,0x30				; AL <- AL+0x30. Soma 0x30 em AL (0x30 = '0').
	MOV 	byte[saida],AL		; [saida] <- AL. Escrevento o numero em ASCII na variavel 'saida'.

	MOV 	AX,DX				; AX <- DX. Passa valor de DX para AX.
	XOR 	DX,DX				; DX <- DX XOR DX. Zera o registrador DX.
	MOV 	BX,1000				; BX <- 1000. Passa valor 1000 para BX.
	DIV 	BX					; AX <- (DX AX) / BX | DX <- Resto. Divide DX:AX por BX.
	ADD 	AL,0x30				; AL <- AL+0x30. Soma 0x30 em AL (0x30 = '0').
	MOV 	byte[saida+1],AL	; [saida+1] <- AL. Escrevento o numero em ASCII na variavel 'saida'. 

	MOV 	AX,DX				; AX <- DX. Passa valor de DX para AX.
	XOR 	DX,DX				; DX <- DX XOR DX. Zera o registrador DX.
	MOV 	BX,100				; BX <- 100. Passa valor 100 para BX.
	DIV 	BX					; AX <- (DX AX) / BX | DX <- Resto. Divide DX:AX por BX.
	ADD 	AL,0x30				; AL <- AL+0x30. Soma 0x30 em AL (0x30 = '0').
	MOV 	byte[saida+2],AL	; [saida+2] <- AL. Escrevento o numero em ASCII na variavel 'saida'. 

	MOV 	AX,DX				; AX <- DX. Passa valor de DX para AX.
	MOV 	BL,10				; BX <- 10. Passa valor 10 para BX.
	DIV 	BL					; AL <- AX / BL | AH <- Resto. Divide DX:AX por BX.
	ADD 	AL,0x30				; AL <- AL+0x30. Soma 0x30 em AL (0x30 = '0').
	ADD 	AH,0x30				; AH <- AH+0x30. Soma 0x30 em AH (0x30 = '0').
	MOV 	byte[saida+3],AL	; [saida+3] <- AL. Escrevento o numero em ASCII na variavel 'saida'. 
	MOV 	byte[saida+4],AH	; [saida+4] <- AL. Escrevento o numero em ASCII na variavel 'saida'. 	
								; Aqui, você deve recuperar o contexto
	POP 	BP					; Obtem BP da pilha.
	POP 	DX					; Obtem DX da pilha.
	POP 	CX					; Obtem CX da pilha.
	POP 	BX					; Obtem BX da pilha.
	POP 	AX					; Obtem AX da pilha.
	RET		2					; RETorna para onde foi chamada e SP <- SP+2.
 
 segment dados 					; Segmento de dados inicializados
 
 mensini: db 'Programa que calcula a Serie de Fibonacci. ',13,10,'$'	; Mensagem que aparece quando inicia o programa.
 mensfim: db 'bye',13,10,'$'											; Mensagem que aparece ao terminar de executar.
 saida: db '00000',13,10,'$'											; Espaço da memória destinado a armazenar o numero que será mostrado.
 
 segment stack stack
	RESB 256 			; reserva 256 bytes para formar a pilha
 stacktop: 				; posição de memória que indica o topo da pilha=SP