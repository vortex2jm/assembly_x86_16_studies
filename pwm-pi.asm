; Exercício Controle, por PWM, de um forno de 4 zonas.
; Portas:
;**************************************************************
; 20h -> PIC8259, IRQx>IRQy e IRQx=28h
; 40h -> saída, [sel2 sel1 sel0 IC PWM4 PWM3 PWM2 PWM1].
; 80h -> entrada, [D7 D6 D5 D4 D3 D2 D1 D0]

segment code
..start:
	CLI
	MOV		AX,data
	MOV 	DS,AX
	MOV 	AX,stack
	MOV 	SS,AX
	MOV 	SP,stacktop
							; Programando o controlador de Interrupções: PIC8259
	MOV 	AL,13h			; programando registrador ICW1
	OUT 	20h,AL			; (A0=0, por isso o endereço é igual a 20h)
	MOV 	AL,IRQ_CLK		; programando registrador ICW2 IRQ_CLK = 28h
	OUT 	21h,AL			; (A0=1, por isso o endereço é igual a 21h)
	MOV 	AL,1			; programando registrador ICW4
	OUT 	21h,AL			; (A0=1, por isso o endereço é igual a 21h)
	MOV 	AL,11111100b	; programando registrador OCW1. Aceita IRQ0 e IRQ1
	OUT 	21h,AL			; (A0=1, por isso o endereço é iguAL a 21h)
							; Preenchendo a Tabela de Interrupções com as
							; localizações em memória RAM das rotinas de Interrupções (ISR’s) "pwm" e "le_adc"
	XOR 	AX,AX
	MOV 	ES,AX
	MOV 	word[ES:IRQ_CLK*4],pwm		; IRQ_ADC = 28h
	MOV 	word[ES:IRQ_CLK*4+2],CS
	MOV 	word[ES:IRQ_ADC*4],le_adc	; IRQ_ADC = 29h
	MOV 	word[ES:IRQ_ADC*4+2],CS
	STI

Inicio:
	MOV 	byte[tique],0
	MOV 	AL,00001111b	; Observe que 1<=thi<=250; começa com IC=0 (bit 4 da porta 40h) 
	OUT 	40h,AL			; e SEL0-2=000b (bits 5 a 7 porta 40h)
	MOV 	byte[espelho],AL
	XOR 	SI,SI 			; SI é usado para Indexar os vetores "erro" e "s_erro", do tipo word.
	XOR 	DI,DI 			; DI é usado para Indexar o vetor "th", do tipo byte.
	CALL 	Dispara_adc
	MOV 	AX,word[Temp]
	MOV 	word[Tref],AX
	MOV 	CX,4
Volta:
	CALL 	Dispara_adc
	CALL 	Calcula_PI
	ADD 	SI,2
	INC 	DI
	LOOP 	Volta
Volta_tique:
	CMP 	byte[tique],250
	JB 		Volta_tique
	JMP 	Inicio			
	
;********************* rotinas e ISR´s**********************************
le_adc:						; Essa é a rotina ISR de tratamento da Interrupção de hardware IRQ1
	PUSH 	AX
	IN 		AL,80h
	XOR 	AH,AH
	MOV 	word[Temp],AX
	MOV 	byte[adc_conv],1
	MOV 	AL,eoi ; AL = 20h libera o controladOR de INterrupções, colocado na pORta 20h, para aceitar novas INterrupções.
	OUT 	20h,AL ; Ao colocar AL=20 na pORta de E/S no endereço 20h, programa-se OCW2 = 20h no controladOR de Interrupção.
	POP 	AX
	IRET;
	****************************************************************************************************

Dispara_adc:
	PUSH 	AX
	MOV 	byte[adc_conv],0
	MOV 	AL,byte[espelho]
								; Gerando a borda de Subida para Disparar o ADC.
	AND 	AL,11101111b		; Faz IC=0.
	OUT 	40h,AL
	OR 		AL,00010000b		; Faz IC=1 => essa transição de IC Dispara o A/D.
	OUT 	40h,AL
Espera:
	CMP 	byte[adc_conv],0
	jz 		Espera				;
	ADD 	AL,00100000b		; Incrementa SEL0-2 para a próxima leitura do ADC.
	MOV 	byte[espelho],AL
	POP 	AX;
	RET
	;****************************************************************************************************
Calcula_PI:
	PUSH 	AX
	MOV 	AX,word[Tref]
	SUB 	AX,word[Temp] 		; gera erro: erroi(n)= Tref(n) – Tmedi(n), em que 1<=i<=4 (4 zonas) e n indexa a o instante n.
	MOV 	word[erro+SI],AX
	ADD 	word[s_erro+SI],AX
	MOV 	BX,10
	IMUL 	BX					; Faz DX:AX = AX*BX
	PUSH 	AX 					; Empilha o termo 10*erroi(n)
	CMP 	word[s_erro+SI],10000
	JNG 	testa_neg10000		; Pula se o primeiro operando no e maior que o segundo operando
	MOV 	word[s_erro+SI],10000
	JMP 	segue_Calcula_PI
testa_neg10000:
	CMP 	word[s_erro+SI],-10000
	JNL 	segue_Calcula_PI
	MOV 	word[s_erro+SI],-10000
segue_Calcula_PI:
	MOV 	BX,100
	MOV 	AX,word[s_erro+SI]
	CWD 						; Converte word (em AX) para double word (DX:AX) levando-se em conta o SINAL de AX;
	IDIV 	BX					; (DX:AX)/BX → Quociente em AX é resto da Divisão em BX
	POP 	BX 					; desempilha o AX empilhado na lINha 95
	ADD 	AX,BX
	CMP 	AX,250
	JNG 	Testa_limite_inferior_thi
	MOV 	AX,250
	JMP 	Fim_PI
Testa_limite_inferior_thi:
	CMP 	AX,1
	JNL 	Fim_PI
	MOV 	AX,1
Fim_PI:
	MOV 	byte[th+DI],AL
	POP 	AX
	RET

;****************************************************************************************************;****************************************************************************************************
pwm: 									; ESSa é a rotina de tratamento da Interrupção de hardware IRQ0
	PUSH 	AX;
	PUSH 	BX;
	INC 	byte[tique];
	MOV 	AL,byte[espelho]
	MOV 	BL,byte[th];
	CMP 	byte[tique],BL
	JNE 	segue_pwm2;
	AND 	AL,11111110b;
segue_pwm2:
	MOV 	BL,byte[th+1]
	CMP 	byte[tique],BL
	JNE 	segue_pwm3
	AND 	AL,11111101b
segue_pwm3:
	MOV 	bl,byte[th+2];
	CMP 	byte[tique], bl
	JNE 	segue_pwm4;
	AND 	AL,11111011b;
segue_pwm4:
	MOV 	bl,byte[th+3];
	CMP 	byte[tique], bl
	JNE 	segue_pwm;
	AND 	AL,11110111b;
segue_pwm:
	MOV 	byte[espelho],AL;
	OUT 	40H,AL;
	MOV 	AL,eoi ; AL = 20h libera o controladOR de INterrupções, colocado na pORta 20h, para aceitar novas INterrupções.
	OUT 	20h,AL ; Ao colocar AL=20 na pORta de E/S no endereço 20h, programa-se OCW2 = 20h no controladOR de Interrupção.
	POP		BX
	POP		AX;
	IRET
;****************************************************************************************************
segment data
	IRQ_CLK EQU	28h
	IRQ_ADC EQU	29h
	eoi		EQU 20h
	Temp 	dw 0
	Tref 	dw 0
	espelho db 0
	th 		db 0, 0, 0, 0
	erro 	dw 0, 0, 0, 0
	s_erro 	dw 0, 0, 0, 0
	tique 	db 0
	adc_conv db 0
;*************************************************************************
segment stack stack
	resb 512
stacktop: