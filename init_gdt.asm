BOTPAK	EQU		0	
MYOS    EQU     0x8400

CYLS	EQU		0x8000		
LEDS	EQU		0x8001
VMODE	EQU		0x8002		
SCRNX	EQU		0x8004		
SCRNY	EQU		0x8006		
VRAM	EQU		0x8008		

		ORG		0x8200		
        JMP     LABEL_BEGIN
GDT0:
        dw      0,0,0,0
		DW		0xffff,0x0000,0x9200,0x00cf
		DW		0xffff,0x0000,0x9a00,0x0047

GDTR0:
		DW		8*3
		DD		GDT0

[BITS 16]
LABEL_BEGIN:
		MOV		AL,0x13		
		MOV		AH,0x00
		INT		0x10
		MOV		BYTE [VMODE],8
		MOV		WORD [SCRNX],320
		MOV		WORD [SCRNY],200
		MOV		DWORD [VRAM],0x000a0000

		MOV		AH,0x02
		INT		0x16 		
		MOV		[LEDS],AL

		MOV		AL,0xff
		OUT		0x21,AL  ;禁止主pic的全部中断
		NOP				 ;防止连续执行out指令	
		OUT		0xa1,AL  ;禁止从pic的全部中断

		CLI				 ;禁止cpu级别中断	

        ;让cpu能够访问1MB以上的内存空间,设定A20GATE
		CALL	waitkbdout
		MOV		AL,0xd1
		OUT		0x64,AL
		CALL	waitkbdout
		MOV		AL,0xdf		
		OUT		0x60,AL
		CALL	waitkbdout

pipelineflush:
		MOV		AX,0		
		MOV		DS,AX
		MOV		ES,AX
		MOV		FS,AX
		MOV		GS,AX
		MOV		SS,AX

		MOV		SI,MYOS
        mov     ax,BOTPAK
        mov     es,ax
        mov     di,BOTPAK
		MOV		CX,2048
        rep     movsd

        ;设定GDT,进入保护模式
		LGDT	[GDTR0]	
        mov eax, cr0
        or eax,1
        mov cr0, eax
		MOV		AX,8		
		MOV		DS,AX
		MOV		ES,AX
		MOV		FS,AX
		MOV		GS,AX
		MOV		SS,AX
		JMP		DWORD 16:0x14c0
        ;偏移地址通过查看二进制文件得到

        ;等待指令执行完成
waitkbdout:
		IN		 AL,0x64
		AND		 AL,0x02
		JNZ		waitkbdout	
		RET
