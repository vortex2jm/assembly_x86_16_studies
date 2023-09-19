org 0x100

section .data
    int_number db 145
    char_number db '000', 0xd, 0xa, '$'

section .text
    mov cx, 3       ;Loop vai rodar 3 vezes
    mov ax, 145     ;Valor a ser impresso
    mov bl, 100     ;Dividendo
    mov si, 0x0     ;Offset de byte de char_number
    
main:
    div bl          ;Dividindo 145          
    call convert    
    call print
    loop main
    mov ah, 0x4c
    int 0x21

convert:
    add al, 0x30                    ;Convertendo decimal para char
    mov byte [char_number+si], al   ;Adicionando o numero na string
    mov al, ah                      ;Movendo o resto para AL
    xor ah, ah                      ;Limpando AH
    push ax                         ;Empilhando AX
    mov al, bl                      ;Movendo bl para al para dividir 100/10/1
    mov bl, 10                      ;movendo 10 para BL para ser o dividendo
    div bl                          ;Executando a divisão
    mov bl, al                      ;Retornando o valor da divisão para BL
    pop ax                          ;Desempilhando o resto da divisão
    inc si                          ;Incrementando o offset de byte da string final
    ret                             ;Retornando para a main

print:
    xor dx, dx              ;Limpando DX
    mov dx, char_number     ;Colocando endereço da string em DX
    push ax                 ;Empilhando o resto da divisão
    mov ah, 9               ;Imprimindo a string
    int 0x21
    pop ax                  ;Desempilhando o resto da divisão
    ret                     ;Retornando para a main
