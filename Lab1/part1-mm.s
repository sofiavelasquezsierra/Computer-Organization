.global _start

//initialize memory 
//matrix a: int16_t a[2][2] = {{-1, 2}, {3, -4}};
ma: .short -1, 2, 3, -4 

//matrix b: int16_t b[2][2] = {{6, -3}, {2, 4}};
mb: .short 6, -3, 2, 4 

//matrix c: int16_t c[2][2] = {{0, 0,}, {0, 0}};
mc: .short 0, 0, 0, 0

//unsigned int size = 2
size: .word 2

//matrix multiplication

	
mm:
	PUSH {V1-V8} //push used registers onto stack 
	
	MOV V1, #0 		//row = 0
LOOP1:
	// for (unsigned int row=0; row<size; row++)
	SUB V2, V1, A4	// row<size
	CMP V2, #0
	BGE mmDone
	MOV V3, #0 		//col = 0

mmIter:
	
	// for (unsigned int col=0; col<size; col++)
	SUB V4, V3, A4	//col<size
	CMP V4, #0
	ADDGE V1, V1, #1//if not, row++ 
	BGE LOOP1			//if not, branch to mm
	// *(c + row*size + col) = 0
	MUL V7, V1, A4	//row*size
	ADD V8, V7, V3	//row*size + col
	LSL V8, V8, #1	//shift by 1
	ADD V8, A3, V8 // c+
	MOV V6, #0
	STRH V6, [V8]

	MOV V5, #0 		//iter = 0

mmLoop:
	
	// for (unsigned int iter=0; iter<size; iter++)
	//SUB V7, V5, A4	//iter<size
	CMP V5, A4
	ADDGE V3, V3, #1//if not, col++
	BGE mmIter		//if not, branch to mmIter
	
	// *(c + row*size + col) += *(a + row*size + iter) * *(b + iter*size + col);
	MUL V8, V1, A4 //row*size
	ADD V7, V8, V5 //row*size + iter
	LSL V7, V7, #1 //shift by 1
	ADD V7, V7, A1 // +a
	LDRSH V7, [V7]
	
	MUL V4, V5, A4 //iter*size
	ADD V4, V4, V3 //+col
	LSL V4, V4, #1 //shift by 1
	ADD V4, V4, A2 //+b
	LDRSH V4, [V4]
	
	MUL V4, V4, V7 //*(a + row*size + iter) * *(b + iter*size + col)
	
	ADD V8, V8, V3	//row*size + col
	LSL V8, V8, #1
	ADD V2, A3, V8 // +c
	LDRSH V7, [V2]
	ADD V7, V7, V4	//*(c + row*size + col)
	STRH V7, [V2]
	
	ADD V5, V5, #1
	B mmLoop
	
mmDone:
	
	POP {V1-V8}
	
	BX LR

_start:
    LDR A1, =ma        //address of matrix a in A1
    LDR A2, =mb     //address of matrix b in A2
    LDR A3, =mc     //address of matrix c in A3
    LDR A4, size     //size in A4
    BL mm             //call function

infinite:
    B infinite
