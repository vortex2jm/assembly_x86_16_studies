extern convert, print
global char_number
; org 0x100

section .data
    int_number db 145
    char_number db '000', 0xd, 0xa, '$'

section .text
    global _start
_start:
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
