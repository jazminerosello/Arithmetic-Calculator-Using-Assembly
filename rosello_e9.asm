global _start

section .data
    LF equ 10
    NULL equ 0
    SYS_EXIT equ 60
    STDOUT equ 1
    SYS_WRITE equ 1
    STDIN equ 0
    SYS_READ equ 0

    msg db "************MENU***********",LF,"[1] Addition",LF,"[2] Subtraction",LF,"[3] Integer Division",LF,"[0] Exit",LF,"**************************",NULL ; always end your strings with NULL
    msgLen equ $-msg
    msg2 db "Enter a two-digit number: ", NULL
    msg2Len equ $-msg2
    choiceMessage db "Choice: ", NULL
    cLen equ $-choiceMessage
    error db "Input valid number based on choices given!"
    errorLen equ $-error

     err db "00 cannot be the divisor!"
    errLen equ $-err

    
    newLine db LF, NULL
    newLineLen equ $-newLine

    choice db 0

    digit1 db 0
    digit2 db 0
    digit3 db 0
    digit4 db 0

    product1 db 0
    product2 db 0

    num1 db 0
    num2 db 0
    num3 db 0
    ml db 10

section .text
_start:
    ;write the msg 
    mov rax, SYS_WRITE
    mov rdi, STDOUT
    mov rsi, msg
    mov rdx, msgLen
    syscall

    mov rax, SYS_WRITE
    mov rdi, STDOUT
    mov rsi, newLine
    mov rdx, newLineLen
    syscall

     ;write the msg 
    mov rax, SYS_WRITE
    mov rdi, STDOUT
    mov rsi, choiceMessage
    mov rdx, cLen
    syscall

    ;read 
    mov rax, SYS_READ
    mov rdi, STDIN
    mov rsi, choice
    mov rdx, 2 ; one for the digit and one for the newline character
    syscall

    ;convert the value of choice into a decimal then move it into bl register
    sub byte[choice], 30h
    mov bl, byte[choice] ;compare bl if it is 0, if it is then exit_here na if not then go the ask label
    cmp bl, 0
    ; je exit_here
    jbe exit_here

    cmp bl, 4 ;in case 4 and above mailagay ni user, print proper message then
    jge printErrorMessage
    

ask:
    ;clear the registers used in performing arithmetic 
    mov ax, 0
    mov cx, 0

    ;write 
    mov rax, SYS_WRITE
    mov rdi, STDOUT
    mov rsi, msg2
    mov rdx, msg2Len
    syscall

   ; read 
    mov rax, SYS_READ
    mov rdi, STDIN
    mov rsi, digit1
    mov rdx, 1 ; one for the digit 
    syscall

    mov rax, SYS_READ
    mov rdi, STDIN
    mov rsi, digit2
    mov rdx, 2 ; one for another digit and one for the newline character
    syscall

    mov rax, SYS_WRITE
    mov rdi, STDOUT
    mov rsi, msg2
    mov rdx, msg2Len
    syscall

     ; read 
    mov rax, SYS_READ
    mov rdi, STDIN
    mov rsi, digit3
    mov rdx, 1; one for the digit
    syscall

    mov rax, SYS_READ
    mov rdi, STDIN
    mov rsi, digit4
    mov rdx, 2 ; one for another digit and one for the newline character
    syscall

    mov rax, SYS_WRITE
    mov rdi, STDOUT
    mov rsi, newLine
    mov rdx, newLineLen
    syscall

    ;convert the 4 digits into the decimal
    sub byte[digit1], 30h ; convert to decimal equivalent
    sub byte[digit2], 30h
    sub byte[digit3], 30h ; convert to decimal equivalent
    sub byte[digit4], 30h


    ; digit1 * 10 to convert it into tens then add the another digit which is the ones
    mov al, byte[digit1]
    mul byte[ml]
    mov cx, 0
    mov cl, byte[digit2]
    add al, cl
    mov byte[product1], al ;place the value of ax in product1

    mov ax, 0

    ; digit3 * 10 to convert it into tens then add the another digit which is the ones
    mov al, byte[digit3]
    mul byte[ml]
    mov cl, 0
    mov cl, byte[digit4]
    add al, cl

    ;compare the bl now kung ano ipeperform na arithmetic sa dalawang number
    cmp bl, 1 ;if 1 then go to add
    je add

    cmp bl, 2 ;if 2 then go to subtract
    je subTract

    cmp bl, 3 ;if 3 then go to integer division
    je intDiv
   
printErrorMessage: ;if the choice input is not 0,1,2,3 then print prompt message then ask again for the choice

    

   mov rax, SYS_WRITE
    mov rdi, STDOUT
    mov rsi, error
    mov rdx, errorLen
    syscall

    mov rax, SYS_WRITE
    mov rdi, STDOUT
    mov rsi, newLine
    mov rdx, newLineLen
    syscall

    mov rax, SYS_WRITE
    mov rdi, STDOUT
    mov rsi, newLine
    mov rdx, newLineLen
    syscall

    jmp _start

add: ;product1 + product2
    add al, byte[product1] ;add the prodcut1 sa al para sa summation nung 2 numbers input
    jmp getEveryDigitAndPrint ;then para maprint 'yung sagot punta lang sa getEveryDigit

subTract: ;product1 - product2

    mov byte[product2], al ;mov value ni al sa product 2 since from the previous computation, and value ng al ay for the 2nd number 

    mov ax, 0 ;clear the al register
    mov al, byte[product1] ;mov the product 1 sa al

    sub al, byte[product2] ;sub the prodcut2 sa al para sa difference ng 2 numbers input
    
    jmp getEveryDigitAndPrint  ;for printing the result

intDiv: ;product1 / product2

    cmp al, 00 ;compare if 'yung value ng al ay 00 kasi hindipwede madivide 'yon so if equal print error message
    je printErr

    mov byte[product2], al ;mov value ni al sa product2 since from the previous computation, and value ng al ay for the 2nd number 

    mov ax, 0;clear the al register
    mov al, byte[product1] ;mov the product 1 sa al
    
    
    div byte[product2]
    mov ah, 0 ;clear the ah register where the remainder will be stored
    ;divide the product1 sa product2
    
    jmp getEveryDigitAndPrint ;for printing the result

printErr: ;;for printing proper message when the divisor the user input is 00
    mov rax, SYS_WRITE
    mov rdi, STDOUT
    mov rsi, newLine
    mov rdx, newLineLen
    syscall

   mov rax, SYS_WRITE
    mov rdi, STDOUT
    mov rsi, err
    mov rdx, errLen
    syscall

    mov rax, SYS_WRITE
    mov rdi, STDOUT
    mov rsi, newLine
    mov rdx, newLineLen
    syscall

    jmp _start

getEveryDigitAndPrint:
   

    mov bl, 100 ; divide the sum in the al register by 100 to get the hundreds place values
    div bl
    mov byte[num1], al ; reuse num1 variable to store hundreds
    mov al, 0
    mov al, ah
    mov ah, 0
    mov cl, 10 ;divide again by 10 naman to get the tens and ones
    div cl
    mov byte[num2], al ;store tens here in num2
    mov byte[num3], ah ;store ones here in num3
    
    add byte[num1], 30h ; add 30h to get the numeric symbol equivalent of the decimal value
    add byte[num2], 30h
    add byte[num3], 30h
    
    mov rax, SYS_WRITE
    mov rdi, STDOUT
    mov rsi, num1
    mov rdx, 1
    syscall

    mov rax, SYS_WRITE
    mov rdi, STDOUT
    mov rsi, num2
    mov rdx, 1
    syscall

    mov rax, SYS_WRITE
    mov rdi, STDOUT
    mov rsi, num3
    mov rdx, 1
    syscall

    mov rax, SYS_WRITE
    mov rdi, STDOUT
    mov rsi, newLine
    mov rdx, newLineLen
    syscall

    mov rax, SYS_WRITE
    mov rdi, STDOUT
    mov rsi, newLine
    mov rdx, newLineLen
    syscall

    jmp _start

exit_here:
    mov rax, SYS_EXIT
    xor rdi, rdi
    syscall