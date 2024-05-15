.global _start

.equ PixelBuffer, 0xc8000000 
.equ CharacterBuffer, 0xc9000000
.equ ps2, 0xff200100

.equ purple, 0xd99d59

_start:

        bl VGA_clear_pixelbuff_ASM  
		bl GoL_draw_grid_ASM
		bl GoL_draw_board_ASM
		
			
GoLBoard:
	//  x 0 1 2 3 4 5 6 7 8 9 a b c d e f    y
	.word 1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0 // 0
	.word 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0 // 1
	.word 0,0,0,0,0,0,0,1,0,0,0,0,0,0,0,0 // 2
	.word 0,0,0,0,0,0,0,1,0,0,0,0,0,0,0,0 // 3
	.word 0,0,0,0,0,0,0,1,0,0,0,0,0,0,0,0 // 4
	.word 0,0,0,0,0,0,0,1,1,1,1,1,0,0,0,0 // 5
	.word 0,0,0,0,1,1,1,1,1,0,0,0,0,0,0,0 // 6
	.word 0,0,0,0,0,0,0,0,1,0,0,0,0,0,0,0 // 7
	.word 0,0,0,0,0,0,0,0,1,0,0,0,0,0,0,0 // 8
	.word 0,0,0,0,0,0,0,0,1,0,0,0,0,0,0,0 // 9
	.word 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0 // a
	.word 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0 // b
		
end:
        b       end


GoL_draw_board_ASM:
//fills grid locations (x, y), 0 ≤ x < 16, 0 ≤ y < 12 
//with color c if GoLBoard[y][x] == 1.

	push {a1, a2, a3, r3, r4, r5, r6, r7, r8, r9, r10, r11, r12, lr}
	
	ldr r12, =GoLBoard
	
	mov a1, #0	//x counter
	mov a2, #0	//y counter
	mov a3, #0	//counter
	
	
	iter:
	
	ldr r7, [r12, a3, lsl#2]
	
	cmp r7, #1
	moveq r4, a1
	moveq r5, a2
	bleq GoL_fill_gridxy_ASM
	
	add a3, a3, #1
	add a1, a1, #1
	cmp a1, #16
	addeq a2, a2, #1
	moveq a1, #0
	
	cmp a3, #192
	bne iter
	
	pop {a1, a2, a3, r3, r4, r5, r6, r7, r8, r9, r10, r11, r12, lr}
	bx lr 
	
	
GoL_fill_gridxy_ASM:
	
	mov r6, #20
	
	mul r8, r4, r6		//x1
	mul r9, r5, r6		//y1
	mul r10, r4, r6		
	add r10, r10, #20	//x2
	mul r11, r5, r6		
	add r11, r11, #20	//y2
	push {lr}
	bl VGA_draw_rect_ASM
	pop {lr}
	bx lr 


VGA_draw_rect_ASM: //draws a rectangle from pixel
//(x1, y1) to (x2, y2) in color c.

	push {lr}
	 
	mov R6, R10
	
	line:
	cmp R6, R10
	poplt {lr}
	bxlt lr
	 
	mov R10, R8
	bl VGA_draw_line_ASM
	add r8, r8, #1
	B line
	 

GoL_draw_grid_ASM:

	push {r4, r5, r6, r7, r8, r9, r10, r11, lr}
	
	mov r8, #0		//x1
	mov r9, #0		//y1
	mov r10, #0		//x2
	mov r11, #240	//y2
		
	x_axis:
	
	cmp r10, #320
	bge exit
	bllt VGA_draw_line_ASM
	add R8, R8, #20
	add R10, R10, #20
	B x_axis
	
	exit:
	
	mov r8, #0		//x1
	mov r9, #0		//y1
	mov r10, #320	//x2
	mov r11, #0		//y2
	
	y_axis:
	
	cmp r9, #240
	bge out
	bllt VGA_draw_line_ASM
	add r9, r9, #20
	add r11, r11, #20
	b y_axis
	
	out:
	pop {r4, r5, r6, r7, r8, r9, r10, r11, lr}
	

VGA_draw_line_ASM:

	push {r0-r5}
	
	cmp r8, r10
	bne not_equal
	moveq r4, r9
		
		for_1:

		ldr r5, =purple
		cmp r4, r11
		movle A1, r8
		movle A2, r4
		movle A3, r5
		pushle {lr}
		blle VGA_draw_point_ASM 
		cmp r4, r11
		pople {lr}
		add r4, r4, #1
		cmp r4, r11
		ble for_1

not_equal:
	cmp r9, r11
	bne hop_out
	moveq r4, r8
	
		for_2:

		ldr r5, =purple
		cmp r4, r10
		movle A1, r4
		movle A2, r9
		movle A3, r5
		pushle {lr}
		blle VGA_draw_point_ASM
		cmp r4, r10
		pople {lr}
		add r4, r4, #1
		cmp r4, r10
		ble for_2
	
hop_out:
	pop {r0-r5}
	bx lr	
	

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
	
	pop {a1, a2, a3, lr}
	bx lr
	
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