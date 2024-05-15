.global _start
.equ HEX0, 0xFF200020
.equ HEX1, 0xFF200021
.equ HEX4, 0xFF200030
.equ HEX5, 0xFF200031
.equ CONTROL_ADDR, 0xFFFEC608
.equ CURRENT_ADDR, 0xFFFEC604
.equ SW_ADDR, 0xFF200040
.equ PB_MEMORY, 0xff20005C

_start:
	
	mov R8, #0 //initialize mole
	
	MOV A1, #0 //SCORE
	
	mov R7, #30	//counter
	
	LDR R11, =CONTROL_ADDR
	
	BL ARM_TIM_config_ASM
	BL mole
	B poll
	
poll:

	// poll pb 
	BL PB_is_pressed
	
	//poll timer 
	BL ARM_TIM_read_INT_ASM
	CMP R10, #0x00000001
	BNE poll
	
	BLEQ ARM_TIM_clear_INT_ASM
	BLEQ ARM_TIM_config_ASM
	BLEQ HEX_write_ASM
	SUB R7, R7, #1
	BL read_slider_switches_ASM
	BL mole
	cmp R7, #-1
	BLEQ score_write

	
	B poll

mole:

	PUSH {LR}
	BL clear_mole
	PUSH {R7, R9, R11, R12}
	LDR R11, =CURRENT_ADDR
	LDR R11, [R11]
	AND R12, R11, #0b11

	LDR R7, =HEX0
	MOV R9, #0x5C
	STRB R9, [R7, R12]

	POP {R7, R9, R11, R12}
	POP {LR}
	BX LR 
	
clear_mole:
	
	PUSH {R7, R8}
	LDR R7, =HEX0
	mov R8, #0

	STRB R8, [R7]
	STRB R8, [R7, #1]
	STRB R8, [R7, #2]
	STRB R8, [R7, #3]

	POP {R7, R8}
	BX LR

read_slider_switches_ASM:

	PUSH {R9, R11, LR}
	LDR R9, =SW_ADDR     // load the address of slider switch state
    LDR R11, [R9]         // read slider switch state 
	
	AND R9, R11, #0x0000000F	
	
	CMP R9, #0
	BLNE whack_mole  
	
	POP {R9, R11, LR}
	BX  LR

whack_mole:
	
	PUSH {R5, LR}
	LDR R5, =HEX0
	
	cmp R9, #1
	LDREQB R5, [R5]
	BLEQ hit_mole
	
	cmp R9, #2
	LDREQB R5, [R5, #1]
	BLEQ hit_mole
	
	cmp R9, #4
	LDREQB R5, [R5, #2]
	BLEQ hit_mole
	
	cmp R9, #8
	LDREQB R5, [R5, #3]
	BLEQ hit_mole	
	
	POP {R5, LR}
	BX LR
 
hit_mole:

	PUSH {LR}
	//MOV A1, #0
	
	cmp R5, #0x5C
	ADDEQ A1, A1, #1
	BLEQ clear_mole
	POP {LR}
	BX LR

PB_is_pressed:

	PUSH {R5, LR}
	LDR R5, =PB_MEMORY
	LDR R6, [R5]
	STR R6, [R5]
	CMP R6, #0
	BLNE released
	POP {R5, LR}
	BX LR
	
released:
//label for operations with PBs
//check for each PB if it has been pressed

	PUSH {LR}
	CMP R6, #0x00000002
	BLEQ stop
	
	CMP R6, #0x00000004
	BLEQ reset

	POP {LR}
	BX LR

stop:
	
	PUSH {LR}
	BL PB_is_pressed
	CMP R6, #0x1
	POPEQ {LR}
	BXEQ LR
	POP {LR}
	BNE stop

reset:

	B _start
	

ARM_TIM_config_ASM:
//This subroutine is used to configure the timer. 
	
	PUSH {A2, A3, R5}
	LDR A3, =0xFFFEC600	//base address
	LDR R5, =200000000	//A1 - passes argument of initial count value
	STR R5, [A3]
	mov A2, #0b111	//A2 - passes configuration bit arguments (stored in control register)	
	STR A2, [R11]
	POP {A2, A3, R5}
	BX LR
	
ARM_TIM_read_INT_ASM:

	PUSH {R2}
	LDR R2, =0xFFFEC60C	//base address
	LDR R10, [R2]	//interrupt status
	
	POP {R2}
	BX LR

ARM_TIM_clear_INT_ASM:

	PUSH {R3}
	LDR R2, =0xFFFEC60C	//base address
	mov R3, #0x00000001
	STR R3, [R2]	//interrupt status
	POP {R3}
	BX LR
	
HEX_write_ASM: 

	PUSH {R3, R4, R5, LR}
	LDR R4, =HEX4
	LDR R5, =HEX5
	BL convert
	AND R3, R12, #0x0000000F
	BL input 
	STRB R6, [R4]
	AND R3, R12, #0X00000F0
	LSR R3, #4
	BL input
	STRB R6, [R5]
	POP {R3, R4, R5, LR}
	BX LR
	
score_write:

	PUSH {A2, A3, R3, R6, R8, LR}

	LDR A2, =HEX0
	LDR A3, =HEX1
	
	AND R3, A1, #0x0000000F
	BL input 
	STRB R6, [A2]
	
	AND R3, A1, #0X00000F0
	LSR R3, #4
	BL input
	STRB R6, [A3]
	
	MOV R8, #0x39
	STRB R8, [A2, #2]
	
	MOV R8, #0x6D
	STRB R8, [A2, #3]
	
	
	POP {A2, A3, R3, R6, R8, LR}
	
	BX LR
	
input:

	cmp R3, #0
	MOVEQ R6, #0x3F
	
	cmp R3, #1
	MOVEQ R6, #0x06
	
	cmp R3, #2
	MOVEQ R6, #0x5B
	
	cmp R3, #3
	MOVEQ R6, #0x4F
	
	cmp R3, #4
	MOVEQ R6, #0x66
	
	cmp R3, #5
	MOVEQ R6, #0x6D
	
	cmp R3, #6
	MOVEQ R6, #0x7D
	
	cmp R3, #7
	MOVEQ R6, #0x07
	
	cmp R3, #8
	MOVEQ R6, #0x7F
	
	cmp R3, #9
	MOVEQ R6, #0x67
	
	BX LR	
	
convert:

	cmp R7, #0
	MOVEQ R12, #0x0
	BXEQ LR
	
	cmp R7, #1
	MOVEQ R12, #0x1
	BXEQ LR
	
	cmp R7, #2
	MOVEQ R12, #0x2
	BXEQ LR
	
	cmp R7, #3
	MOVEQ R12, #0x3
	BXEQ LR
	
	cmp R7, #4
	MOVEQ R12, #0x4
	BXEQ LR
	
	cmp R7, #5
	MOVEQ R12, #0x5
	BXEQ LR
	
	cmp R7, #6
	MOVEQ R12, #0x6
	BXEQ LR
	
	cmp R7, #7
	MOVEQ R12, #0x7
	BXEQ LR
	
	cmp R7, #8
	MOVEQ R12, #0x8
	BXEQ LR
	
	cmp R7, #9
	MOVEQ R12, #0x9
	BXEQ LR
	
	cmp R7, #10
	MOVEQ R12, #0x10
	BXEQ LR
	
	cmp R7, #11
	MOVEQ R12, #0x11
	BXEQ LR
	
	cmp R7, #12
	MOVEQ R12, #0x12
	BXEQ LR
	
	cmp R7, #13
	MOVEQ R12, #0x13
	BXEQ LR
	
	cmp R7, #14
	MOVEQ R12, #0x14
	BXEQ LR
	
	cmp R7, #15
	MOVEQ R12, #0x15
	BXEQ LR
	
	cmp R7, #16
	MOVEQ R12, #0x16
	BXEQ LR
	
	cmp R7, #17
	MOVEQ R12, #0x17
	BXEQ LR
	
	cmp R7, #18
	MOVEQ R12, #0x18
	BXEQ LR
	
	cmp R7, #19
	MOVEQ R12, #0x19
	BXEQ LR
		
	cmp R7, #20
	MOVEQ R12, #0x20
	BXEQ LR
	
	cmp R7, #21
	MOVEQ R12, #0x21
	BXEQ LR
		
	cmp R7, #22
	MOVEQ R12, #0x22
	BXEQ LR
	
	cmp R7, #23
	MOVEQ R12, #0x23
	BXEQ LR
	
	cmp R7, #24
	MOVEQ R12, #0x24
	BXEQ LR
	
	cmp R7, #25
	MOVEQ R12, #0x25
	BXEQ LR
	
	cmp R7, #26
	MOVEQ R12, #0x26
	BXEQ LR
		
	cmp R7, #27
	MOVEQ R12, #0x27
	BXEQ LR
	
	cmp R7, #28
	MOVEQ R12, #0x28
	BXEQ LR
		
	cmp R7, #29
	MOVEQ R12, #0x29
	BXEQ LR
	
	cmp R7, #30
	MOVEQ R12, #0x30
	BXEQ LR
	
infinte:
	BL PB_is_pressed
	B infinte