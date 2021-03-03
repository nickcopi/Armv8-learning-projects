.data

msg:
	.ascii		"Hello. Enter a number and I will say if it is divisble by 8.\n"
len = . - msg

divis_text:
	.ascii		"Yes!\n"
divis_text_len = . - divis_text

indivis_text:
	.ascii		"No!\n"
indivis_text_len = . - indivis_text

input_len = 24
input:
	.space input_len

.text

.globl _start
_start:
	bl _print_welcome
	bl _read_input
	bl _ascii_to_int
	//check if divisibly by 8 and print appropriate result
	and x0,x0,#7
	cmp x0,#0
	b.eq .divisible
	bl _print_indivisible
	b .exit
	.divisible:
	bl _print_divisible
	.exit:
	//call exit syscall (93)
	mov	 x0, #0	
	mov	 w8, #93
	svc	 #0



//str ptr ends up on x1 with length read on x0
_read_input:
	mov	 x0, #1	
	ldr	 x1, =input  
	ldr	 x2, =input_len
	mov	 w8, #63
	svc	 #0
	ret

_print_welcome:
	mov	 x0, #1
	ldr	 x1, =msg
	ldr	 x2, =len
	mov	 w8, #64
	svc	 #0
	ret

_print_divisible:
	mov	 x0, #1
	ldr	 x1, =divis_text
	ldr	 x2, =divis_text_len
	mov	 w8, #64
	svc	 #0
	ret

_print_indivisible:
	mov	 x0, #1
	ldr	 x1, =indivis_text
	ldr	 x2, =indivis_text_len
	mov	 w8, #64
	svc	 #0
	ret

/*Assumes x0 holds length and x1 holds ptr, will write to x0 the int value*/
_ascii_to_int:
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
	mov x0,x5
	ret
