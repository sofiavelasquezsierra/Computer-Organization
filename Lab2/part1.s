.global _start

.equ PB_MEMORY, 0xff20005C
.equ SW_ADDR, 0xFF200040
.equ HEX0, 0xFF200020
.equ HEX1, 0xFF200021
.equ HEX2, 0xFF200022
.equ HEX3, 0xFF200023
.equ HEX4, 0xFF200030
.equ HEX5, 0xFF200031

_start:
	LDR R2, =HEX0
	
	MOV R3, #0
	//currently displayed value 
//mov R0, R9 //state of PB

	BL HEX_clear_ASM	//clear HEX display
	
polling:	
	//BL switch_input
	BL PB_edgecp_is_pressed_ASM
	BL released
	B polling

HEX_clear_ASM: //turn off all segments if the selected HEX display 
// receives selected HEX display indices through register A1 as an argument
	PUSH {R2}
	LDR R2, =HEX0
	MOV R3, #0
	MOV R8, #0x3F
	
	STRB R8, [R2], #1
	STRB R8, [R2], #1
	STRB R8, [R2], #1
	STRB R8, [R2], #13
	STRB R8, [R2], #1
	STRB R9, [R2], #1
	
	SUB R2, R2, #18
	
	POP {R2}
	BX LR

HEX_flood_ASM: // turns on all the segments of the selected HEX displays
//receives selected HEX display indices through register A1 as an argument
	PUSH {R2}
	LDR R2, =HEX0
	
	TST R4, #0x00000001 //add with HEX0
	STRNEB R6, [R2]
	ADD R2, R2, #1

	TST R4, #0x00000002 //add with HEX1
	STRNEB R6, [R2]
	ADD R2, R2, #1

	TST R4, #0x00000004 //add with HEX2
	STRNEB R6, [R2]
	ADD R2, R2, #1

	TST R4, #0x00000008 //add with HEX3
	STRNEB R6, [R2]
	ADD R2, R2, #13

	TST R4, #0x00000010 //add with HEX4
	STRNEB R6, [R2]
	ADD R2, R2, #1

	TST R4, #0x00000020 //add with HEX5
	STRNEB R6, [R2]
	
	SUB R2, R2, #17
	
	POP {R2}
	BX LR


HEX_write_ASM: //receives HEX display indices and an integer value 0-15 to display
//passed in reg A1 and A2
		
	PUSH {LR}
	BL input
	PUSH {A1}
	MOV A1, A2
	
	BL HEX_flood_ASM
	
	POP {A1}
	POP {LR}
	BX LR
	
	
	TST A1, #0x00000001 //add with HEX0
	BL input
	STRNEB A2, [R4]

	TST A1, #0x00000002 //add with HEX1
	BL input
	STRNEB A2, [R5]

	TST A1, #0x00000004 //add with HEX2
	BL input
	STRNEB A2, [R6]

	TST A1, #0x00000008 //add with HEX3
	BL input
	STRNEB A2, [R7]

	TST A1, #0x00000010 //add with HEX4
	BL input
	STRNEB A2, [R8]

	//sign
	TST A1, #0x00000020 //add with HEX5
	STRNEB R9, [R7]
	
	POP {R4, R8}

input:

	cmp A2, #0
	MOVEQ R6, #0x3F
	BXEQ LR
	
	cmp A2, #1
	MOVEQ R6, #0x06
	BXEQ LR
	
	cmp A2, #2
	MOVEQ R6, #0x5B
	BXEQ LR
	
	cmp A2, #3
	MOVEQ R6, #0x4F
	BXEQ LR
	
	cmp A2, #4
	MOVEQ R6, #0x66
	BXEQ LR
	
	cmp A2, #5
	MOVEQ R6, #0x6D
	BXEQ LR
	
	cmp A2, #6
	MOVEQ R6, #0x7D
	BXEQ LR
	
	cmp A2, #7
	MOVEQ R6, #0x07
	BXEQ LR
	
	cmp A2, #8
	MOVEQ R6, #0x7F
	BXEQ LR
	
	cmp A2, #9
	MOVEQ R6, #0x67
	BXEQ LR
	
	cmp A2, #10
	MOVEQ R6, #0x77
	BXEQ LR
	
	cmp A2, #11
	MOVEQ R6, #0x7C
	BXEQ LR
	
	cmp A2, #12
	MOVEQ R6, #0x39
	BXEQ LR
	
	cmp A2, #13
	MOVEQ R6, #0x5E
	BXEQ LR
	
	cmp A2, #14
	MOVEQ R6, #0x79
	BXEQ LR
	
	cmp A2, #15
	MOVEQ R6, #0x71
	BXEQ LR
	
	BX LR
	
	
PB_edgecp_is_pressed_ASM: 
	LDR R1, =PB_MEMORY
	LDR R2, [R1]
	STR R2, [R1]
	CMP R2, #0
	BEQ PB_edgecp_is_pressed_ASM
	BX LR


released:
//label for operations with PBs
//check for each PB if it has been released
	PUSH {LR}
	BL switch_input
	POP {LR}

	CMP R2, #0x00000001
	BEQ HEX_clear_ASM
	
	CMP R2, #0x00000002
	BEQ multiplication
	
	CMP R2, #0x00000004
	BEQ subtraction
	
	CMP R2, #0x00000008
	BEQ add
	

multiplication:
	
// if r > 0x000FFFFF or r < 0xFFF00001  -> ovrflo
	PUSH {LR}
	PUSH {R5}
	
	MUL R3, R11, R12	//r
	BL display
	LDR R5, =0x000FFFFF
	cmp R3, R5
	BLGT overflow
	
	LDR R5, =0xFFF00001
	cmp R3, R5
	BLLT overflow
	
	
	POP {R5}
	POP {LR}
	
	BX LR
	
overflow:

	PUSH {R7, R8}
	LDR R7, =HEX0

	MOV R8, #0x3F
	STRB R8, [R7]
	
	MOV R8, #0x38
	STRB R8, [R7, #1]!
	
	MOV R8, #0x71
	STRB R8, [R7, #1]!
	
	MOV R8, #0x77
	STRB R8, [R7, #1]!
	
	MOV R8, #0x3E
	STRB R8, [R7, #13]!
	
	MOV R8, #0x3F
	STRB R8, [R7, #1]
	
	POP {R7, R8}
	
	BX LR
	
subtraction:
	PUSH {LR}
	CMP R11, R12
	SUBGE R3, R11, R12
	SUBLT R3, R12, R11
	
	BLLT negative
	BL display
	POP {LR}
	
	BX LR

negative:
	
	PUSH {R4, R6}
	LDR R4, =HEX5
	MOV R6, #0x40
	STRB R6, [R4]
	POP {R4, R6}
	BX LR

add:
	PUSH {R4}
	PUSH {LR}
	
	LDR R4, =HEX5
	LDRB R4, [R4]
	
	cmp R4, #0x40
	ADDNE R3, R11, R12	
	
	BNE add2
	
	CMP R11, R12
	SUBLT R3, R11, R12
	BLLT remove_negative
	
	BL display
	POP {LR}
	POP {R4}
	
	BX LR

add2:
	POP {LR}
	POP {R4}
	B display

remove_negative:

	PUSH {R5, R6}
	LDR R5, =HEX5
	LDRB R5, [R5]
	MOV R6, #0
	STRB R6, [R5]
	
	POP {R5, R6}
	BX LR

display:

	PUSH {R0, R1, R3}
	PUSH {LR}
	
	//MOV R3, A2
	AND A2, R3, #0x0000000F
	mov R4, #0x00000001
	BL HEX_write_ASM
	
	AND A2, R3, #0x000000F0
	ASR A2, #4
	mov R4, #0x00000002
	BL HEX_write_ASM
	
	AND A2, R3, #0x00000F00
	ASR A2, #8
	mov R4, #0x00000004
	BL HEX_write_ASM
	
	AND A2, R3, #0x0000F000
	ASR A2, #12
	mov R4, #0x00000008
	BL HEX_write_ASM
	
	AND A2, R3, #0x000F0000
	ASR A2, #16
	mov R4, #0x00000010
	BL HEX_write_ASM
	
	POP {LR}
	POP {R0, R1, R3}
	BX LR 

switch_input:
	LDR R11, =SW_ADDR
	LDR R10, [R11]
	
	AND R11, R10, #0x0000000F	//n
	
	CMP R3, #0x0000
	
	//r=0, then take n and m
	ANDEQ R12, R10, #0X00000F0
	LSREQ R12, #4	//m
	
	//r!=0, take r as 2nd operand
	MOVNE R12, R11
	MOVNE R11, R3
	
	BX LR 
		