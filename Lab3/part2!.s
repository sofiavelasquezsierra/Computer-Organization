.global _start

.equ PixelBuffer, 0xc8000000 
.equ CharacterBuffer, 0xc9000000
.equ ps2, 0xff200100

_start:
        bl      input_loop
end:
        b       end

@ TODO: copy VGA driver here.

VGA_draw_point_ASM:	//draws a point on the screen at the specified 
//(x, y) coordinates in the indicated color c.  Hint: This subroutine should only access the pixel buffer.

	push {R4, R5, R6, R7}
	
	// check if coordinates are valid 
	cmp A1, #320		
	popge {r4, r5, r6, r7}
	bxge lr
	
	cmp A2, #240
	popge {r4, r5, r6, r7}
	bxge lr
	
	// draw point on screen at (x,y)
	ldr r7, =PixelBuffer
	lsl r4, r0, #1		//x
	lsl r5, r1, #10		//y
	add r6, r4, r5		//x, y offset
	add r6, r6, r7
	strh A3, [r6]
	pop {r4, r5, r6, r7}
	bx lr
	
	
VGA_clear_pixelbuff_ASM:	

	push {a1, a2, a3, lr}
	
	mov A1, #0		//x
	mov A2, #0		//y
	mov A3, #0		//color c
	
	coordy:
		cmp A2, #240
		popeq {a1, a2, a3, lr}
		bxeq lr
	
	coordx:
		cmp A1, #320
		moveq A1, #0
		addeq A2, A2, #1
		beq coordy
	
		BL VGA_draw_point_ASM
	
		add A1, A1, #1
		b coordx
	
VGA_write_char_ASM:

	push {r4, r5, r6, r7}
	
	//check if coordinates are valid 
	cmp A1, #80		//x
	popeq {r4, r5, r6, r7}
	bxge lr
	
	cmp A2, #60
	popge {r4, r5, r6, r7}
	bxge lr
	
	//write ASCII code 
	ldr r7, =CharacterBuffer
	mov r4, A1
	lsl r5, A2, #7
	add r6, r4, r5
	add r6, r6, r7
	strb A3, [r6]
	pop {r4, r5, r6, r7}
	bx lr
	

VGA_clear_charbuff_ASM:

	push {A1, A2, A3, lr}
	
	mov A1, #0
	mov A2, #0
	mov A3, #0
	
	coord_x:
	cmp A2, #60
	addeq A2, A2, #1
	beq coord_x
	
	coord_y:
	cmp A1, #80
	moveq A1, #0
	popeq {A1, A2, A3, lr}
	bxeq lr
	
	bl VGA_write_char_ASM
	
	add A1, A1, #1
	b coord_y
	

@ TODO: insert PS/2 driver here.

read_PS2_data_ASM:
	push {r7, r8}
	
	ldr r7, =ps2
	ldr r7, [r7]
	lsr r8, r7, #15
	//mov r8, r7
	
	and r8, r8, #1
	cmp r8, #1
	//movne r8, #0
	streqb r7, [r0]
	mov r0, r8
	
	pop {r7, r8}
	bx lr

write_hex_digit:
        push    {r4, lr}
        cmp     r2, #9
        addhi   r2, r2, #55
        addls   r2, r2, #48
        and     r2, r2, #255
        bl      VGA_write_char_ASM
        pop     {r4, pc}
write_byte:
        push    {r4, r5, r6, lr}
        mov     r5, r0
        mov     r6, r1
        mov     r4, r2
        lsr     r2, r2, #4
        bl      write_hex_digit
        and     r2, r4, #15
        mov     r1, r6
        add     r0, r5, #1
        bl      write_hex_digit
        pop     {r4, r5, r6, pc}
input_loop:
        push    {r4, r5, lr}
        sub     sp, sp, #12
        bl      VGA_clear_pixelbuff_ASM
        bl      VGA_clear_charbuff_ASM
        mov     r4, #0
        mov     r5, r4
        b       .input_loop_L9
.input_loop_L13:
        ldrb    r2, [sp, #7]
        mov     r1, r4
        mov     r0, r5
        bl      write_byte
        add     r5, r5, #3
        cmp     r5, #79
        addgt   r4, r4, #1
        movgt   r5, #0
.input_loop_L8:
        cmp     r4, #59
        bgt     .input_loop_L12
.input_loop_L9:
        add     r0, sp, #7
        bl      read_PS2_data_ASM
        cmp     r0, #0
        beq     .input_loop_L8
        b       .input_loop_L13
.input_loop_L12:
        add     sp, sp, #12
        pop     {r4, r5, pc}
