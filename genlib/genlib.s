.data

msg:
	.ascii		"\337\33[20;20Htest"
len = . - msg

pxy1:
	.ascii		"\337\33["
pxy1_len = . - pxy1

pxy2:
	.ascii		";"
pxy2_len = . - pxy2

pxy3:
	.ascii		"H"
pxy3_len = . - pxy3

pxy4:
	.ascii		"\338"
pxy4_len = . - pxy4

input_len = 24
input:
	.space input_len

.text

.globl _start
_start:
	bl _call_funcs
	.exit:
	//call exit syscall (93)
	mov	 x0, #0	
	mov	 w8, #93
	svc	 #0


_call_funcs:
	mov	x1, #1337
	ldr	 x2, =input
	str lr, [sp, #-16]! 
	str x2, [sp, #-16]! 
	str x1, [sp, #-16]! 
	bl _itoa
	ldr lr, [sp], #16 

	ldr	 x1, =input
	ldr	 x2, =input_len
	str lr, [sp, #-16]! 
	str x2, [sp, #-16]! 
	str x1, [sp, #-16]! 
	bl	_print
	ldr lr, [sp], #16 
	ret
	/*
	//call print with msg and len
	ldr	 x1, =msg
	ldr	 x2, =len
	str lr, [sp, #-16]! 
	str x2, [sp, #-16]! 
	str x1, [sp, #-16]! 
	bl	_print
	ldr lr, [sp], #16 
	//call read
	ldr	 x1, =input  
	ldr	 x2, =input_len
	str lr, [sp, #-16]! 
	str x2, [sp, #-16]! 
	str x1, [sp, #-16]! 
	bl _read
	ldr lr, [sp], #16 
	//call atoi
	ldr	 x1, =input  
	ldr	 x2, =input_len
	str lr, [sp, #-16]! 
	str x2, [sp, #-16]! 
	str x1, [sp, #-16]! 
	bl _atoi
	ldr x13, [sp], #16 
	ldr lr, [sp], #16 
	*/



//reads top 32 bytes off stack as size and str ptr
_read:
	mov	 x0, #0
	ldr x1, [sp], #16 
	ldr x2, [sp], #16 
	mov	 w8, #63
	svc	 #0
	ret

//reads top 32 bytes off stack as x and y
_print_x_y:
	ret

//reads top 32 bytes off stack as size and str ptr
_print:
	mov	 x0, #1
	ldr x1, [sp], #16 
	ldr x2, [sp], #16 
	mov	 w8, #64
	svc	 #0
	ret

//2 things off stack, first ptr, second length, modifies str in ptr to be reversed
_str_rev:
	//pop off str ptr
	ldr x1, [sp], #16 
	//pop off str length
	ldr x2, [sp], #16 
	cmp x2,#2
	b.lt .exit_str_rev
	//ptr to end of str
	add x3, x1,x2
	sub x3,x3,#1
	.str_rev_loop:
		ldrb w4, [x1]
		ldrb w5, [x3]
		strb w5, [x1]
		strb w4, [x3]
		add x1,x1,#1
		sub x3,x3,#1
		sub x6, x3,x1
		cmp x6,#0
		b.gt .str_rev_loop
	.exit_str_rev:
	ret

//pops first two things off stack, first being a string ptr, second being an int and converts int to ascii string
_itoa:
	//pop off int
	ldr x1, [sp], #16 
	//pop off dest str ptr
	ldr x2, [sp], #16 
	mov x8, x2
	mov x3, #10
	mov x6, #10
	mov x7, #0
	
	//loop until x1 value is 0
	.itoa_loop:
		//mod x1 by x3 into x4

		//x1/x3 -> x4
		//x4 * x3 -> x4
		//x1-x4 -> x4

		//x1%x3 -> x4

		udiv x4,x1,x3
		mul x4,x4,x3
		sub x4,x1,x4

		//remove mod result from int
		sub x1,x1,x4
		//reduce result to a single number
		udiv x5,x3,x6
		udiv x4,x4,x5
		//add ascii offset
		add x4,x4,0x30
		//store ascii byte back to memory
		strb w4, [x2]
		//increment str ptr
		add x2,x2,#1
		//multiply mod
		mul x3,x3,x6
		//increment counter
		add x7,x7,#1
		cmp x1,#0
		b.ne .itoa_loop
	mov w4,#0
	strb w4, [x2]
	//reverse result
	str lr, [sp, #-16]! 
	str x7, [sp, #-16]! 
	str x8, [sp, #-16]! 
	bl _str_rev
	ldr lr, [sp], #16 

	ret


/*Assumes x0 holds length and x1 holds ptr, will write to x0 the int value*/
//reads top 32 bytes off stack as length and str ptr and writes 16 bytes back to the stack with the result
_atoi:
	ldr x1, [sp], #16 
	ldr x2, [sp], #16 
	mov x6,#10
	mov x5,#0
	mov x3,#1
	sub x0,x0,#2
	add x1,x1,x0
	.loop:
		//read what x1 points to into x4
		ldr x4,[x1]
		//and off last byte
		and x4,x4,#255
		//convert ascii to decimal
		sub x4,x4,#48
		//set place value properly
		mul x4,x4,x3
		//add dude to sum
		add x5,x5,x4
		//increase 10s place
		mul x3,x3,x6
		//decrement counter
		sub x0,x0,#1
		//decrement input ptr
		sub x1,x1,#1
		//see if last op is negative, if so, we are done, otherwise, jump back to loop start
		cmp x0,#0
		//loop if makes sense
		b.ge .loop
	str x5, [sp, #-16]! 
	ret
