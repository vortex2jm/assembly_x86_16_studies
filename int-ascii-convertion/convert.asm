global convert
extern char_number

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
