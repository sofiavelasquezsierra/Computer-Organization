	
	.global _start

//initialize memory
ma: .short -1, 2, 3, -4	//matrix a
mb: .short 6, -3, 2, 4	//matrix b
mc: .short 0, 0, 0, 0	//matrix c

size: .word 2
	
wmm22:

	PUSH {V1-V8} 
	
	//u = (cc-aa)*(CC-DD)
	LDRSH V1, [A1, #4]	//cc
	LDRSH V2, [A1]	//aa
	LDRSH V3, [A2, #2]	//CC
	LDRSH V4, [A2, #6]	//DD
	SUB V5, V1, V2		//cc-aa
	SUB V6, V3, V4//CC-DD
	MUL V5, V5, V6		// (cc-aa)*(CC-DD) = u = V5
	
	//v = (cc + dd)*(CC - AA)
	LDRSH V6, [A1, #6]	//dd
	LDRSH V7, [A2]	//AA
	ADD V8, V1, V6		//cc+dd
	SUB A4, V3, V7		//CC-AA
	MUL V8, V8, A4	//(cc + dd)*(CC - AA) = v = V8
	
	//w = aa*AA + (cc + dd - aa)*(AA + DD - CC);
	MUL A4, V2, V7		//aa*AA
	ADD V6, V1, V6		//cc+dd
	SUB V6, V6, V2		//(cc + dd - aa)
	ADD V2, V7, V4		//AA+DD
	SUB V2, V2, V3		//AA + DD - CC
	MUL V2, V6, V2		//(cc + dd - aa)*(AA + DD - CC)
	ADD V2, A4, V2		//aa*AA + (cc + dd - aa)*(AA + DD - CC) = w = V2
	
	//*c = aa*AA + bb*BB;
	LDRSH V6, [A1, #2]	//bb
	LDRSH V1, [A2, #4]	//BB
	MUL V1, V6, V1		//bb*BB
	ADD V1, A4, V1		//aa*AA + bb*BB = V1
	STRH V1, [A3]	//first element in matrix c 
	
	//*(c + 0*2 + 1) = w + v + (aa + bb - cc - dd)*DD;
	LDRSH V1, [A1]	//aa
	ADD V1, V1, V6 		//aa+bb
	LDRH V3, [A1, #4]	//cc
	SUB V1, V1, V3		//aa+ bb - cc
	LDRSH V3, [A1, #6]	//dd
	SUB V1, V1, V3		//aa+ bb - cc - dd
	MUL V1, V1, V4		//(aa + bb - cc - dd)*DD
	ADD V3, V2, V8		// w + v
	ADD V1, V1, V3		//(aa + bb - cc - dd)*DD + w + v = V3
	STRH V1, [A3, #2] 	//2nd element fo 1st row matrix c
	
	//*(c + 1*2 + 0) = w + u + dd*(BB + CC - AA - DD);
	LDRSH V3, [A2, #2]	//CC
	LDRSH V1, [A2, #4]	//BB
	ADD V3, V3, V1 		//CC+BB
	SUB V3, V3, V7		//CC+BB-AA
	LDRSH V7, [A2, #6]	//DD
	SUB V3, V3, V7		//CC+BB-AA-DD
	LDRSH V7, [A1, #6]	//dd
	MUL V3, V3, V7		//dd*(BB + CC - AA - DD)
	ADD V3, V3, V5		//dd*(BB + CC - AA - DD) + u
	ADD V3, V3, V2		//dd*(BB + CC - AA - DD) + u + w = R1 
	STRH V3, [A3, #4]	//1st element of 2nd row of matrix c
	
	//*(c + 1*2 + 1) = w + u + v;
	ADD V1, V2, V8		// w + v
	ADD V1, V1, V5 		//w + u + v = V5	
	STRH V1, [A3, #6]	//2nd element of 2nd row of matrix c 
	
	POP {V1-V8}
	
	BX LR
	
	end:

_start:
    LDR A1, =ma        //address of matrix a in A1
    LDR A2, =mb     //address of matrix b in A2
    LDR A3, =mc     //address of matrix c in A3
    
    BL wmm22

stop:
    B stop
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
