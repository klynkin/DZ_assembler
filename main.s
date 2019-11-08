	PRESERVE8							; 8-битное выравнивание стека
	THUMB								; Режим Thumb (AUL) инструкций

	GET	config.s						; include-файлы
	GET	stm32f10x.s	

	AREA RESET, CODE, READONLY

	; Таблица векторов прерываний
	DCD STACK_TOP						; Указатель на вершину стека
	DCD Reset_Handler					; Вектор сброса
		
	ENTRY								; Точка входа в программу
	
Reset_Handler	PROC					; Вектор сброса
	
	EXPORT  Reset_Handler				; Делаем Reset_Handler видимым вне этого файла

main									; Основная подпрограмма
	MOV			r0,#-1							;массив 1
	STRH		r0,[sp,0x00]	
	MOV			r0,#2							
	STRH		r0,[sp,0x02]
	MOV			r0,#3							
	STRH		r0,[sp,0x04]
	MOV			r0,#4							
	STRH		r0,[sp,0x06]
	MOV			r0,#1							
	STRH		r0,[sp,0x08]
	MOV			r0,#2							
	STRH		r0,[sp,0x0A]
										
	MOV			r0,#1							
	STRH		r0,[sp,0x0C]				;массив 2
	MOV			r0,#2							
	STRH		r0,[sp,0x0E]
	MOV			r0,#3							
	STRH		r0,[sp,0x10]
	MOV			r0,#2							
	STRH		r0,[sp,0x12]
	MOV			r0,#2							
	STRH		r0,[sp,0x14]

	MOV32		r0,#0x0000							
	STR			r0,[sp,0x16]				;массив 2
	MOV32		r0,#0x00
	STR			r0,[sp,0x1A]
	MOV32		r0,#0x00							
	STR			r0,[sp,0x1E]
	MOV32		r0,#0x00							
	STR			r0,[sp,0x22]
	MOV32		r0,#0x00							
	STR			r0,[sp,0x26]
	MOV32		r0,#0x00							
	STR			r0,[sp,0x2A]
	MOV32		r0,#0x00							
	STR			r0,[sp,0x2E]
	MOV32		r0,#0x00							
	STR			r0,[sp,0x32]
	MOV32		r0,#0x00							
	STR			r0,[sp,0x36]
	MOV32		r0,#0x00							
	STR			r0,[sp,0x3A]
	
	mov	R2,#SIZE_1
	mov	R3,#SIZE_2
	mov32 R0,#STACK_TOP
	mov	R5,#2
	MLA	R1,R2,R5,R0
	MLA	R4,R3,R5,R1
	BL convolution
	
	
loop									; Бесконечный цикл

	B 		loop						; возвращаемся к началу цикла
	
	ENDP

convolution	PROC
	PUSH	{R0,R1,R2,R3,R4}
	MOV 	R6,#0						;n
	MOV 	R8,#0						;k
	MOV 	R12,#0						;k
	MOV 	R7,#SIZE_1
	ADD		R7,#SIZE_2
	SUB 	R7,#1
loop2	
	MOV 	R8,#0						;k=0
	
	CMP 	R6,R7
	IT		NE
	BNE		new_n
	B		out
new_n
	;POP	{R0,R1}
	;MLA	R1,R6,R5,R1						;b[n]
	;PUSH{R1,R0}
	CMP R8,R7							;k!=N+M-1?
	IT	NE
	BNE new_k
	B	zero_val
new_k
	
	CMP		R8,#SIZE_1
	IT		GE							
	BGE		next_k					;если k>N, то элемент свертки нулевой
	SUBS	R9,R6,R8					;n-k
	IT		LT
	BLT		next_k					;если n-k<0, то элемент свертки нулевой
	CMP		R9,#SIZE_2
	IT		GE							
	BGE		next_k						;если n-k>M, то элемент свертки нулевой
	
	POP		{R0,R1}
	PUSH	{R0,R1}
	MLA	R0,R8,R5,R0					;a[k]
	LDRH	R10,[R0]
	MLA	R1,R9,R5,R1					;b[n-k]
	LDRH	R11, [R1]
	MLA	R12,R10,R11,R12
	STRH R12,[R4]
next_k	
	ADD	R8,#1
	B new_n
	
zero_val
	MOV	R12,#0
	ADD R6,#1
	ADD	R4,#4					;a[k]
	B	loop2
	
	
	
out
	POP {R0,R1,R2,R3,R4}
	BX	LR
	ENDP

    END