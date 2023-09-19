; Este porgrama controla um motor DC (ventilador) para controlar
; a temperatura de um sistema com as seguintes carateristicas:
; Se 0°C ≤Temperatura< 50°C então motor liga por 10 segundos 
; e desliga por 140 segundos;
; Se 50°C ≤Temperatura< 100°C então motor liga por 75 segundos 
; e desliga por 75 segundos;
; Se Temperatura> 100°C então motor liga por 140 segundos 
; e desliga por 10 segundos.
; O sistema é interrumpido a cada 10 ms (clk = 100 Hz)
; Porta 40h bit 7 controle on-off do motor e bit 0 controle inicio de conversão
; Porta 50h leitura do ADC com 8 bits de resolução. O sistema mede de 0 até 255 graus
; Porta 60h bit 7 fim de conversão do ADC e bit 0 Clock de 100 Hz 

segment code
..start:
	MOV		AX,dados		; Inicializa o registrador de Segmento de Dados DS
	MOV		DS,AX
	MOV		AX,stack		; Inicializa o registrador de Segmento de Pilha SS
	MOV		SS,AX
	MOV 	SP,stacktop		; Inicializa o apontador de Pilha SP

	MOV 	AL,0			; Zero porta 40h, Motor = off e ADC = off
	OUT 	40h,AL
volta0:
	MOV 	AL,1			; Ligo o ADC
	OUT 	40h,AL
volta1: 
	IN 		AL,60h			; Le o conteúdo da porta 60h 
	test 	AL,80h 			; Faz AL & 10000000b - "fim da conversão" 
	JZ		volta1			; Se a condição for verdadeira fica neste loop
	IN		AL,50h			; Le o valor do ADC - porta 50h
	CMP		AL,50			; Compara o valor do ADC com 50
	JB 		L10D140			; Pula para L10D140 se é menor de 50
	CMP 	AL,100			; Compara o valor do ADC com 100	
	JB 		L75D75 			; Pula para L75D75 se é menor de 100 (e maior ou igual de 50)
	MOV 	AL,80h			; Se as duas condições não são verdadeiras
	OUT 	40h,AL			; Liga o motor, se a temp não for < 50 ou < 100, então é maior do que 100
	MOV 	CX,28000		; Carrega o valor do delay para ser 140 segundos ligado => 1 s = (10 ms)*100 então 140 s = (10 ms)*14000*2; Vece 2 porque o loop acontece nas duas transições - alto e baixo
	CALL 	Delay			; Chama a função Delay
	MOV 	AL,0			; Carrega AL com 0 e
	OUT 	40h,AL			; Desliga o motor
	MOV 	CX,2000			; Carrega o valor do delay 
	CALL 	Delay			; Chama função Delay
	JMP 	volta0			; Volta ao Loop principal e repete o processo
L10D140:
	MOV 	AL,80h
	OUT 	40h,AL
	MOV 	CX,2000
	CALL 	Delay
	MOV 	AL,0
	OUT 	40h,AL
	MOV 	CX,28000
	CALL 	Delay
	JMP 	volta0
L75D75:
	MOV 	AL,80h
	OUT 	40h,AL
	MOV 	CX,15000
	CALL 	Delay
	MOV 	AL,0
	OUT 	40h,AL
	MOV 	CX,15000
	CALL 	Delay
	JMP 	volta0

Delay:
		IN 		AL,60h			; Le porta 60h
		AND		AL,1			; Filtra o valor com 0x01 para pegar só o estado do relógio
		MOV 	AH,AL			; Carrega o estado do clock em AH
	v2: IN 		AL,60h			; Le porta 60h de novo
		AND 	AL,1			
		CMP 	AL,AH			; Compara estado atual com estado anterior
		JE		v2				; Fica no loop V2 até ter uma mudança de estado 0->1 ou 1->0
		IN 		AL,60h			; Le porta 60h de novo
		AND		AL,1			
	v4: MOV 	AH,AL			; Carrega o estado do clock em AH	
	v3: IN 		AL,60h			; Le porta 60h de novo
		AND 	AL,1
		CMP 	AL,AH			; Compara estado atual com estado anterior
		JE 		v3				; Fica no loop V4 até ter uma mudança de estado 1->0 ou 0->1
		LOOP 	v4				; Fica no loop 4 CX veces
		RET

segment dados
	valor	dw 0
	tensao	db 0
	temperatura db  0

segment stack stack
	resb 256
stacktop: