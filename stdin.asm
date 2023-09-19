;Programa para ler um caracter do teclado e imprimi-lo
org  0x100

section .text
    mov ah, 7  
    int 0x21                ;Lê um caracter do teclado e armazena em AL
    mov [ds:0x0], al        ;Colocando O conteúdo de AL em DS:0x0
    mov word [ds:0x1], 'E$' ;Armazena 2 bytes no endereço específicado 
    mov dx, 0x0             ;Colocando o offset da mensagem em dx
    mov ah, 9       
    int 0x21                ;Serviço de impressao de string (terminada em $)
    mov ah, 0x4c            
    int 0x21                ;Serviço de fim de programa
