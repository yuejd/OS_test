[BITS 32]

[global _start]
[extern k_main] ; this is in the c file

_start:

mov esp, 0x90000
call k_main

jmp $ 
