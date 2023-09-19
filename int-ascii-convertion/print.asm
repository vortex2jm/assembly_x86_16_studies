global print
extern char_number

print:
    xor dx, dx              ;Limpando DX
    mov dx, char_number     ;Colocando endereço da string em DX
    push ax                 ;Empilhando o resto da divisão
    mov ah, 9               ;Imprimindo a string
    int 0x21
    pop ax                  ;Desempilhando o resto da divisão
    ret                     ;Retornando para a main
