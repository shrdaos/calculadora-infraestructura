
section .data
    msg_num1 db "Ingrese primer numero: ", 0 ; Mensaje para ingresar el primer numero
    len_msg_num1 equ $ - msg_num1             ; longitud del mensaje
    
    msg_num2 db "Ingrese segundo numero: ", 0 ; Mensaje para ingresar el segundo numero
    len_msg_num2 equ $ - msg_num2           ; longitud del mensaje
    
    msg_op db "Ingrese operacion (+,-,*,/,%): ", 0 ; Menu para seleccionar la operacion
    len_msg_op equ $ - msg_op               ; longitud del mensaje
    
    msg_result db "Resultado: ", 0          ; Mensaje que muestra el resultado
    len_msg_result equ $ - msg_result       ; longitud del mensaje
    
    msg_error db "Error: Operacion invalida!", 10 ; Mensaje de error operacion invalida
    len_msg_error equ $ - msg_error             ;longitud del mensaje
    
    msg_div_error db "Error: Division por cero!", 10 ; Mensaje error division por cero
    len_msg_div_error equ $ - msg_div_error         ; longitud del mensaje
    
    msg_continue db "¿Continuar? (s/n): ", 0 ; Mensaje para continuar o salir del programa si o no
    len_msg_continue equ $ - msg_continue       ;longitud del mensaje 

section .bss
    num1 resq 1        ; Numero 1 (64 bits)
    num2 resq 1        ; Numero 2 (64 bits)
    resultado resq 1   ; Resultado (64 bits)
    operador resb 1    ; Operador
    input_buffer resb 20 ; Buffer para entrada
    input_len resq 1    ; Longitud de entrada

section .text
    global _start

_start:
    mov rbp, rsp       ; Guardar stack pointer

main_loop:
    ; Solicitar primer número
    mov rax, 1         ; syscall write
    mov rdi, 1         ; stdout
    mov rsi, msg_num1  ; dirección del mensaje
    mov rdx, len_msg_num1 ; longitud del mensaje
    syscall ; llamada al sistema
    
    ; Leer primer número
    call read_num ;Llama a la funcion para leer el numero
    mov [num1], rax ;Guarda el numero leido en num1
    
    ; Solicitar segundo número
    mov rax, 1  ; syscall write
    mov rdi, 1  ; stdout
    mov rsi, msg_num2 ; direccion del mensaje
    mov rdx, len_msg_num2 ; longitud del mensaje
    syscall ; llamada al sistema 
    
    ; Leer segundo número
    call read_num ; llama a la funcion para leer el numero
    mov [num2], rax ; Guarda el numero leido en num1
    
    ; Solicitar operador
    mov rax, 1 ; syscall write
    mov rdi, 1 ; stdout
    mov rsi, msg_op ; mensaje
    mov rdx, len_msg_op
    syscall
    
    ; Leer operador
    mov rax, 0         ; syscall read
    mov rdi, 0         ; stdin
    mov rsi, operador  ; buffer
    mov rdx, 2         ; leer 2 bytes (char + newline)
    syscall
    
    ; Realizar operación
    mov al, [operador]
    cmp al, '+'
    je suma
    cmp al, '-'
    je resta
    cmp al, '*'
    je multiplicacion
    cmp al, '/'
    je division
    cmp al, '%'
    je modulo

error:  ; <- Agregada etiqueta error cuando es operacion invalida
    mov rax, 1 ; syscall write
    mov rdi, 1 ; stdout
    mov rsi, msg_error ; mensaje de error 
    mov rdx, len_msg_error 
    syscall
    jmp continuar

suma:
    mov rax, [num1]
    add rax, [num2]
    mov [resultado], rax
    jmp mostrar_resultado

resta:
    mov rax, [num1]
    sub rax, [num2]
    mov [resultado], rax
    jmp mostrar_resultado

multiplicacion:
    mov rax, [num1]
    imul rax, [num2]
    mov [resultado], rax
    jmp mostrar_resultado

division:
    mov rax, [num1]
    mov rbx, [num2]
    cmp rbx, 0 ; comprobar division por cero
    je error_division
    cqo                 ; Extender RAX a RDX:RAX para la division
    idiv rbx
    mov [resultado], rax
    jmp mostrar_resultado

modulo: ; calcular el modulo del num1 por num2
    mov rax, [num1]
    mov rbx, [num2]
    cmp rbx, 0 ; comprobar division por cero 
    je error_division
    cqo
    idiv rbx
    mov [resultado], rdx    ; Guardar el residuo 
    jmp mostrar_resultado

error_division: ; manejar error de division por cero
    mov rax, 1 ; syscall write
    mov rdi, 1 ;stdout
    mov rsi, msg_div_error ; Mensaje de error
    mov rdx, len_msg_div_error 
    syscall
    jmp continuar

mostrar_resultado: ; Mostrar el resultado de la operación 
    mov rax, 1 ; syscall write
    mov rdi, 1 ; stdout
    mov rsi, msg_result ; mensaje
    mov rdx, len_msg_result
    syscall
    
    mov rax, [resultado]
    call print_num

continuar: ; Preguntar si desea continuar 
    mov rax, 1 ; syscall write
    mov rdi, 1 ;stdout
    mov rsi, msg_continue ; mensaje 
    mov rdx, len_msg_continue
    syscall
    
    mov rax, 0 ; syscall read
    mov rdi, 0 ; stdin
    mov rsi, input_buffer ; buffer para leer
    mov rdx, 2 
    syscall
    
    cmp byte [input_buffer], 's'
    je main_loop

exit: ; Salir del programa 
    mov rax, 60        ; syscall exit
    mov rdi, 0         ; código de salida
    syscall

; Función para leer número
read_num:
    ; Guardar registros
    push rbx
    push rcx
    push rdx
    
    ; Leer input
    mov rax, 0 ; syscall read
    mov rdi, 0 ; stdin
    mov rsi, input_buffer ; buffer 
    mov rdx, 20 ; longitud del buffer
    syscall
    
    ; Convertir string a número
    xor rax, rax ; Resultado
    xor rbx, rbx ; Multiplicador
    xor rcx, rcx ; contador 
    mov rcx, input_buffer
    
.next_digit: ; comprobar si el numero es negativo
    movzx rdx, byte [rcx] 
    cmp dl, 10         ; newline
    je .done
    cmp dl, 0          ; null
    je .done
    
    sub dl, '0'        ; convertir ASCII a número
    imul rax, 10
    add rax, rdx
    
    inc rcx
    jmp .next_digit
    
.done:
    pop rdx
    pop rcx
    pop rbx
    ret

; Función para imprimir número
print_num: 
; guardar registros 
    push rax
    push rbx
    push rcx
    push rdx
    
    mov rcx, input_buffer
    add rcx, 19        ; Empezar desde el final del buffer
    mov byte [rcx], 0  ; Null terminator
    mov byte [rcx-1], 10 ; Newline
    dec rcx
    
    mov rbx, 10
    
.next_digit:
    xor rdx, rdx
    div rbx
    add dl, '0'        ; Convertir a ASCII
    dec rcx
    mov [rcx], dl
    test rax, rax
    jnz .next_digit
    
    ; Imprimir resultado
    mov rax, 1  ; syscall write
    mov rdi, 1  ; stdout
    mov rsi, rcx ; buffer
    mov rdx, input_buffer
    add rdx, 20
    sub rdx, rcx
    syscall
    
    pop rdx
    pop rcx
    pop rbx
    pop rax
    ret