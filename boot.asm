;Bootloader for Orion (role: Print "Welcome to Orion!" then boot kernel)

;BIOS loads us into 0x7c00 - so that needs to be the address. However, since we can't know what the BIOS will initialize segment registers to, it
; is better to set the segment registers to 0x7c00 and our origin "offset" to 0.
ORG 0

;Tell the assembler that we are using a 16-bit architecture (When the CPU is running in real-mode, it is using a 16-bit architecture, regardless of its true architecture)
BITS 16
; Some BIOS will attempt to fill in a BPB (Bios Parameter Block). We must prevent this from corrupting our code. Fills in the null bytes we create below.
_start:
    jmp short start
    nop

times 33 db 0
start:

    jmp 0x7c0:step2

step2:
    ; Clear interrupts, change the segment registers and then enable them again. Prevents hardware from interrupting the process.
    cli

    mov ax, 0x7c0
    mov ds, ax
    mov es, ax

    mov ax, 0x00
    mov ss, ax
    mov sp, 0x7c00
    sti
    ; Move the address of our message label into the si register.
    mov si, message
    call print
    ;Ensure that we don't run the part of the code that includes our boot signature, by continuously jumping to the same point.
    jmp $

print:
    mov bx, 0
.loop:
    ; lodsb loops over all of the characters, adding them to the al register and then incrementing. Therefore, we compare the contents of the
    ; al register to 0 (the null/terminating character), and if it isn't 0 we keep looping. While it isn't 0, we call our print_char subroutine to print that char.
    ;Once it is 0, we call our "done" subroutine.
    lodsb 
    cmp al, 0
    je .done
    call print_char
    jmp .loop
.done:
    ret
print_char: 
    ; The second line calls the video output subroutine in the bios. The bios sees the 0eh in the ah register, and knows we want to output a character.
    ; It takes the character in the al register and outputs it to the screen.
    mov ah, 0eh
    int 0x10
    ret
message: db 'Welcome to Orion!', 0




;Pads all the bytes until the end (since our boot signature needs to be at the end), and then we add the boot signature.
times 510-($ - $$) db 0
dw 0xAA55

