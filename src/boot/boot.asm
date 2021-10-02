;Bootloader for Orion (role: Print "Welcome to Orion!" then boot kernel)

;BIOS loads us into 0x7c00 - so that needs to be the address. However, since we can't know what the BIOS will initialize segment registers to, it
; is better to set the segment registers to 0x7c00 and our origin "offset" to 0.
ORG 0x7c00

;Tell the assembler that we are using a 16-bit architecture (When the CPU is running in real-mode, it is using a 16-bit architecture, regardless of its true architecture)
BITS 16

CODE_SEG equ gdt_code - gdt_start
DATA_SEG equ gdt_data - gdt_start
; Some BIOS will attempt to fill in a BPB (Bios Parameter Block). We must prevent this from corrupting our code. Fills in the null bytes we create below.
_start:
    jmp short start
    nop

times 33 db 0
start:

    jmp 0:step2



step2:
    ; Clear interrupts, change the segment registers and then enable them again. Prevents hardware from interrupting the process.
    cli

    mov ax, 0x00
    mov ds, ax
    mov es, ax
    mov ss, ax
    mov sp, 0x7c00
    sti

    ;Ensure that we don't run the part of the code that includes our boot signature, by continuously jumping to the same point.
    jmp $

.load_protected:
    cli
    lgdt[gdt_descriptor]
    mov eax, cr0
    or eax, 0x1
    mov cr0, eax
    jmp CODE_SEG:load32




; GDT
gdt_start:
gdt_null:
    dd 0x0
    dd 0x0

; offset 0x8
gdt_code:
    dw 0xffff 
    dw 0    
    db 0    
    db 0x9a
    db 11001111b
    db 0
gdt_data:
    dw 0xffff 
    dw 0    
    db 0    
    db 0x92
    db 11001111b
    db 0

gdt_end:

gdt_descriptor:
    dw gdt_end - gdt_start-1
    dd gdt_start

[BITS 32]
load32:
    mov ax, DATA_SEG
    mov ds, ax
    mov es, ax
    mov fs, ax
    mov gs, ax
    mov ss, ax
    mov ebp, 0x00200000
    mov esp, ebp    

    ;A20 line
    in al, 0x92
    or al, 2
    out 0x92, al

    jmp $

;Pads all the bytes until the end (since our boot signature needs to be at the end), and then we add the boot signature.
times 510-($ - $$) db 0
dw 0xAA55