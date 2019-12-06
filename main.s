	PRESERVE8							; 8-битное выравнивание стека
										; Режим Thumb (AUL) инструкций

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
	MOV32		r1,#ARRAY_POINTER
	MOV			r0,#1					;массив 1
	STRH		r0,[r1,#0x00]	
	MOV			r0,#2							
	STRH		r0,[r1,#0x02]
	MOV			r0,#3							
	STRH		r0,[r1,#0x04]
	MOV			r0,#4							
	STRH		r0,[r1,#0x06]
	MOV			r0,#1							
	STRH		r0,[r1,#0x08]
	MOV			r0,#2							
	STRH		r0,[r1,#0x0A]
										
	MOV			r0,#1							
	STRH		r0,[r1,#0x0C]				;массив 2
	MOV			r0,#2							
	STRH		r0,[r1,#0x0E]
	MOV			r0,#3							
	STRH		r0,[r1,#0x10]
	MOV			r0,#2							
	STRH		r0,[r1,#0x12]
	MOV			r0,#2							
	STRH		r0,[r1,#0x14]

	MOV32		r0,#0x0000							
	STR			r0,[r1,#0x16]				;массив результатов
	MOV32		r0,#0x00
	STR			r0,[r1,#0x1A]
	MOV32		r0,#0x00							
	STR			r0,[r1,#0x1E]
	MOV32		r0,#0x00							
	STR			r0,[r1,#0x22]
	MOV32		r0,#0x00							
	STR			r0,[r1,#0x26]
	MOV32		r0,#0x00							
	STR			r0,[r1,#0x2A]
	MOV32		r0,#0x00							
	STR			r0,[r1,#0x2E]
	MOV32		r0,#0x00							
	STR			r0,[r1,#0x32]
	MOV32		r0,#0x00							
	STR			r0,[r1,#0x36]
	MOV32		r0,#0x00							
	STR			r0,[r1,#0x3A]
	
	mov	R2,#SIZE_1				;размер первого массива N
	mov	R3,#SIZE_2				;размер второго массива	M
	mov32 R0,#ARRAY_POINTER		;указатель на первый массив
	mov	R5,#2					;2 байта
	MLA	R1,R2,R5,R0				;указатель на второй массив
	MLA	R4,R3,R5,R1				;указатель на массив результата
	BL convolution				;подпрограмма свертки
	
	
loop							; Бесконечный цикл
	B 		loop				; возвращаемся к началу цикла
	ENDP
		
convolution	PROC				;подпрограмма свертки
	PUSH	{R0,R1,R2,R3,R4}
	MOV 	R6,#0				;n
	MOV 	R8,#0				;k
	MOV 	R12,#0						
	MOV 	R7,#SIZE_1
	ADD		R7,#SIZE_2
	SUB 	R7,#1				;R7=N-M+1
loop2	
	MOV 	R8,#0				;k=0
	CMP 	R6,R7						
	IT		NE							
	BNE		new_n
	B		out
new_n
	CMP R8,R7					;k!=N+M-1?
	IT	NE
	BNE new_k
	B	zero_val
new_k
	
	CMP		R8,#SIZE_1
	IT		GE							
	BGE		next_k				;если k>=N, то элемент свертки нулевой
	SUBS	R9,R6,R8			;n-k
	IT		LT
	BLT		next_k				;если n-k<0, то элемент свертки нулевой
	CMP		R9,#SIZE_2
	IT		GE							
	BGE		next_k				;если n-k>M, то элемент свертки нулевой
	
	POP		{R0,R1}
	PUSH	{R0,R1}
	MLA		R0,R8,R5,R0				;a[k]
	LDRH	R10,[R0]
	MLA		R1,R9,R5,R1				;b[n-k]
	LDRH	R11, [R1]
	PUSH	{R5}
	LSL		R11,#16
	LSL		R10,#16
	SMLAL 	R5,R12,R11,R10
	POP		{R5}
	STR		R12,[R4]
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