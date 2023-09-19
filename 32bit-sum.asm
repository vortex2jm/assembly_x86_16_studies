;Programa para somar um numero de 32 bits
org 0x100

section .data
    ; number1 db 0x77, 0x35, 0x94, 0x00   ;2.000.000.000
    ; number2 db 0x3b, 0x9a, 0xca, 0x00   ;1.000.000.000
    number1 dd 2000000000
    number2 dd 1000000000
    result dd 0x00000000
    final_char db '$'

section .text
    mov ax, [number1]
    mov bx, [number2]
    add ax, bx
    mov [result], ax
    mov ax, [number1 + 0x2]
    mov bx, [number2 + 0x2]
    mov [result + 0x2], ax
    mov dx, result
    mov ah, 9
    int 0x21
    mov ah, 0x4c
    int 0x21
