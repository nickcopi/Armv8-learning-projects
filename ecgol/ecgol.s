.data

board_size = 16
board:
	.space board_size * board_size

empty_square:
	.ascii "."
full_square:
	.ascii "O"
newline:
	.ascii "\n"

.text

.globl _start
_start:
	bl _clear_board
	bl _init_board
	bl _print_board
	.exit:
	//call exit syscall (93)
	mov	 x0, #0	
	mov	 w8, #93
	svc	 #0

_clear_board:
	ldr x0, =board
	ldr x1, =board_size
	mov w2, #0
	mov x3, #0
	mul x1, x1, x1
	.clear_loop:
		strb w2, [x0]
		add x0,x0,#1
		add x3,x3,#1
		cmp x3, x1
		b.lt .clear_loop
	ret

_print_board:
	ldr x3, =board
	ldr x4, =board_size
	mov x6, x4
	mul x4, x4, x4
	mov x5, #0
	//set x0 and x2 for write svc routine
	mov x0, #1
	mov x2, #1
	mov w8, #64
	.print_loop:
		ldrb w1, [x3]
		cmp w1, #0
		b.eq .print_empty
		ldr x1, =full_square
		b .continue_print
		.print_empty:
			ldr x1, =empty_square
		.continue_print:
			svc #0
			add x5,x5,#1
			add x3,x3,#1

			//see about printing new line
			mov x7, x5
			and x7, x7, #15
			cmp x7, #0
			b.ne .check_loop
			ldr x1, =newline
			svc #0
			//check if we loop again
			.check_loop:
				cmp x5,x4
				b.lt .print_loop
	ret


_init_board:
	mov x7,lr
	mov w4,#1
	mov x0,#3
	mov x1,#3
	bl _board_at
	strb w4,[x0]
	mov lr,x7
	ret
//x0 is set to a ptr to the board at a given x (x0) and y (x1)
_board_at:
	ldr x2, =board_size
	ldr x3, = board
	mul x1, x1, x2
	add x0,x0,x1
	add x0,x0,x3
	ret
