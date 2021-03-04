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
screen_clear:
	.ascii "\033c"

.text

.globl _start
_start:
	bl _clear_board
	bl _init_board
	.play_game:
		bl _print_board
		bl _trash_sleep
		bl _run_conway
		b .play_game
	.exit:
	//call exit syscall (93)
	mov	 x0, #0	
	mov	 w8, #93
	svc	 #0

_run_conway:
	mov x7,lr
	ldr x0, =board
	ldr x1, =board_size
	mov x6,x1
	mul x1,x1,x1
	mov x2,#0
	//x
	mov x3,#0
	//y
	mov x4,#0
	.update_loop:
		//neighbor sum
		mov w13,#0
		//ix
		sub x8,x3,#1
		.x_loop:
			cmp x8,#-1
			b.eq .end_x_check
			cmp x8,x6
			b.gt .end_x_check
			//iy
			sub x9,x4,#1
			.y_loop:
				cmp x9,#-1
				b.eq .end_check
				cmp x8,x6
				b.gt .end_check
				cmp x8,x3
				b.ne .continue_check
				cmp x9,x4
				b.eq .end_check
				.continue_check:
					bl _board_at
					ldrb w12, [x10]
					and w12,w12,#1
					add w13,w13,w12
				.end_check:
					//perform check
					add x9,x9,#1
					add x11,x4,#1
					cmp x11,x9
					b.ge .y_loop
		.end_x_check:
			add x8,x8,#1
			add x11,x3,#1
			cmp x11,x8
		b.ge .x_loop
		//handle sum
		mov x8,x3
		mov x9,x4
		bl _board_at
		ldrb w12,[x10]
		and w12,w12,#1
		cmp w12,#0
		b.eq .handle_dead
		//handle living cell checks
		cmp w13,#2
		b.eq .done_cell_update
		cmp w13,#3
		b.eq .done_cell_update
		orr w12,w12,#2
		b .done_cell_update
		.handle_dead:
			cmp w13,#3
			b.ne .done_cell_update
			orr w12,w12,#2
		//write back value
		.done_cell_update:
		strb w12,[x10]
		//increment loop
		add x2,x2,#1
		add x3,x3,#1
		cmp x3,x6
		b.ne .no_change_y
		mov x3,#0
		add x4,x4,#1
		.no_change_y:
			cmp x2, x1
			b.lt .update_loop

	//loop back over cells and flip the last bit of those with the second to last bit set
	mov x2,#0
	.flip_loop:
		ldrb w12,[x0]
		and w11,w12,#2
		cmp w11,#0
		b.eq .increment_flip_loop
		eor w12,w12,#1
		and w12,w12,#1
		strb w12,[x0]
		.increment_flip_loop:
		//increment loop
		add x2,x2,#1	
		add x0,x0,#1
		cmp x2,x1
		b.lt .flip_loop

	mov lr,x7
	ret

_trash_sleep:
	mov x0,0xfffffff
	sleep_loop:
		subs x0,x0,#1
		b.gt sleep_loop
	ret

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
	mov x2, #2
	ldr x1, =screen_clear
	mov w8, #64
	svc #0
	mov x2, #1
	.print_loop:
		ldrb w1, [x3]
		and w1, w1, #1
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
	mov w5,#1
	//set board at 3,3
	mov x8,#3
	mov x9,#1
	bl _board_at
	strb w5,[x10]
	//set board at 3,4
	mov x8,#3
	mov x9,#2
	bl _board_at
	strb w5,[x10]
	//set board at 3,5
	mov x8,#3
	mov x9,#3
	bl _board_at
	strb w5,[x10]
	mov lr,x7
	ret
//x10 is set to a ptr to the board at a given x (x8) and y (x9)
_board_at:
	ldr x12, =board_size
	ldr x11, =board
	mul x12, x9, x12
	add x12,x12,x8
	add x10,x12,x11
	ret
