.global _start


//array of 8 numbers 
array: .word 0, 1, 2, 3, 4, 5, 6, 7

//int x
x: .word 1

//unsigned int lowIdx
lowidx: .word 0

//unsigned int highIdx
highidx: .word 7

	

binarysearch:
	PUSH {V1-V3}
	CMP A3, A4
	BGE if
	B mid

if: 

	LDR V2, [A1, A3, lsl #2]	//load array[lowidx]
	CMP A2, V2					//X =? V2
	BEQ return					//B RETURN
	MOV A2, #0					//move 0 into A2
	SUB A1, A2, #1				//A2-1 => return -1

mid: 

	ADD V1, A3, A4	//LOWIDX+HIGHIDX
	LSR V1, V1, #1	//SHIFT RIGHT, mid = V1
	B early
	
early:

	LDR V3, [A1, V1, lsl #2]	//load array[mid]
	CMP V3, A2					// X =? V3
	BEQ returnmid				// x == array[mid] -> branch
	
	CMP A2, V3					//x =? array[mid]
	ADDGT A3, V1, #1			// lowidx = mid+1
	SUBLE A4, V1, #1				//highidx = mid-1
	POP {V1-V3}
	PUSH {LR}
	BL binarysearch
	POP {LR}
	BX LR 
	
returnmid:
	
	MOV A1, V1					//return mid
	B end

return:
	
	MOV A1, A3					//return lowIdx
	B end
	
end:
	POP {V1-V3}
	BX LR 

_start:
	LDR A1, =array	//address of array 
	LDR A2, x		//x in A2
	LDR A3, lowidx	//lowidx in A3
	LDR A4, highidx	//highidx in A4
	BL binarysearch
	
infinity:
	B infinity
	
