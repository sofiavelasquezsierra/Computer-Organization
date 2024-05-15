.global _start
.equ PixelBuffer, 0xc8000000 
.equ CharacterBuffer, 0xc9000000

_start:
        bl      draw_test_screen
end:
        b       end

@ TODO: Insert VGA driver functions here.

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
	

draw_test_screen:
        push    {r4, r5, r6, r7, r8, r9, r10, lr}
        bl      VGA_clear_pixelbuff_ASM
        bl      VGA_clear_charbuff_ASM
        mov     r6, #0
        ldr     r10, .draw_test_screen_L8
        ldr     r9, .draw_test_screen_L8+4
        ldr     r8, .draw_test_screen_L8+8
        b       .draw_test_screen_L2
.draw_test_screen_L7:
        add     r6, r6, #1
        cmp     r6, #320
        beq     .draw_test_screen_L4
.draw_test_screen_L2:
        smull   r3, r7, r10, r6
        asr     r3, r6, #31
        rsb     r7, r3, r7, asr #2
        lsl     r7, r7, #5
        lsl     r5, r6, #5
        mov     r4, #0
.draw_test_screen_L3:
        smull   r3, r2, r9, r5
        add     r3, r2, r5
        asr     r2, r5, #31
        rsb     r2, r2, r3, asr #9
        orr     r2, r7, r2, lsl #11
        lsl     r3, r4, #5
        smull   r0, r1, r8, r3
        add     r1, r1, r3
        asr     r3, r3, #31
        rsb     r3, r3, r1, asr #7
        orr     r2, r2, r3
        mov     r1, r4
        mov     r0, r6
        bl      VGA_draw_point_ASM
        add     r4, r4, #1
        add     r5, r5, #32
        cmp     r4, #240
        bne     .draw_test_screen_L3
        b       .draw_test_screen_L7
.draw_test_screen_L4:
        mov     r2, #72
        mov     r1, #5
        mov     r0, #20
        bl      VGA_write_char_ASM
        mov     r2, #101
        mov     r1, #5
        mov     r0, #21
        bl      VGA_write_char_ASM
        mov     r2, #108
        mov     r1, #5
        mov     r0, #22
        bl      VGA_write_char_ASM
        mov     r2, #108
        mov     r1, #5
        mov     r0, #23
        bl      VGA_write_char_ASM
        mov     r2, #111
        mov     r1, #5
        mov     r0, #24
        bl      VGA_write_char_ASM
        mov     r2, #32
        mov     r1, #5
        mov     r0, #25
        bl      VGA_write_char_ASM
        mov     r2, #87
        mov     r1, #5
        mov     r0, #26
        bl      VGA_write_char_ASM
        mov     r2, #111
        mov     r1, #5
        mov     r0, #27
        bl      VGA_write_char_ASM
        mov     r2, #114
        mov     r1, #5
        mov     r0, #28
        bl      VGA_write_char_ASM
        mov     r2, #108
        mov     r1, #5
        mov     r0, #29
        bl      VGA_write_char_ASM
        mov     r2, #100
        mov     r1, #5
        mov     r0, #30
        bl      VGA_write_char_ASM
        mov     r2, #33
        mov     r1, #5
        mov     r0, #31
        bl      VGA_write_char_ASM
        pop     {r4, r5, r6, r7, r8, r9, r10, pc}
.draw_test_screen_L8:
        .word   1717986919
        .word   -368140053
        .word   -2004318071