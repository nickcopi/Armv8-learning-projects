.data

msg:
	.ascii		"Test text, hello!\n"
len = . - msg

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



//reads top 32 bytes off stack as size and str ptr
_read:
	mov	 x0, #0
	ldr x1, [sp], #16 
	ldr x2, [sp], #16 
	mov	 w8, #63
	svc	 #0
	ret

//reads top 32 bytes off stack as size and str ptr
_print:
	mov	 x0, #1
	ldr x1, [sp], #16 
	ldr x2, [sp], #16 
	mov	 w8, #64
	svc	 #0
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
