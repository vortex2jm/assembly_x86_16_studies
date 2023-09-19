segment code
..start:
	MOV 	AX,dados			; AX <- dados. Carrega o endereço de dados em AX.
	MOV 	DS,AX				; DS <- AX. Move o conteudo de AX para DS.
	MOV 	AX,stack			; AX <- stack. Carrega o endereço de stack em AX.
	MOV 	SS,AX				; SS <- AX. Move o conteudo de AX para SS.
	MOV 	SP,stacktop			; SP <- stacktop. Carrega o endereço de stacktop em SP.
	
	MOV		AX,5				; Numero a ser convertido
	MOV		CX,5				; CX <- 5. Cinco algarismos precisa de 5 ciclos
	MOV 	SI,0				; SI <- 0. É usado como offset
	MOV 	BX,10000			; BX <- 10000. Passa valor 10000 para BX.
Conv:	
	XOR 	DX,DX				; DX <- DX XOR DX. Zera o registrador DX.
	DIV 	BX					; AX <- (DX AX) / BX | DX <- Resto. Divide DX:AX por BX.
	ADD	 	AL,0x30				; AL <- AL+0x30. Soma 0x30 em AL (0x30 = '0').
	MOV 	byte[saida+SI],AL	; [saida] <- AL. Escrevento o numero em ASCII na variavel 'saida'.
	
	PUSH	DX					; Empilha DX, Resto da divisão
	XOR 	DX,DX				; É necessário limpar o registrador para fazer a operação de divisão
	MOV		AX,BX				; Divide o Dividendo, ou seja 10000/10, 1000/10, 100/10 e 10/10
	MOV 	BX,10
	DIV		BX
	MOV		BX,AX				; Atualiza o dividendo
	POP		DX					; Desempilha DX, Resto da divisão do valor en conversão
	INC		SI					; SI <- SI+1. Incrementa o offset da variável saída 
	MOV 	AX,DX				; AX <- DX. Passa valor de DX para AX. Atualiza o valor da conversão
	LOOP	Conv
	
exit:
	MOV 	DX,saida 			; mensagem de fim.
	MOV 	AH,9				; AH <- 9. Passa valor 9 para AH.
	INT 	21h					; INT 21h / AH=9 - mostra a string disponível em DS:DX. Obs: a string deve terminar em '$'.
quit:
	MOV 	AH,4CH 				; RETorna para o DOS com código 0
	INT 	21h					; INT 21h / AH=4Ch - devolver o controle ao sistema operacional (parar o programa).

segment dados 					; Segmento de dados inicializados
 
 mensini: 	db 'Programa que calcula a Serie de Fibonacci. ',13,10,'$'	; Mensagem que aparece quando inicia o programa.
 mensfim: 	db 'bye',13,10,'$'											; Mensagem que aparece ao terminar de executar.
 saida: 	db '00000',13,10,'$'											; Espaço da memória destinado a armazenar o numero que será mostrado.
 Divisor:   dw 10000
 segment stack stack
	RESB 256 			; reserva 256 bytes para formar a pilha
 stacktop: 				; posição de memória que indica o topo da pilha=SP