/*
	subroutine to output a character to the JTAG UART
	argument in r0, no return value
*/
putchar_jtag:
	push {fp, lr}		// save the current fp and lr on the stack
	add fp, sp, #4			// set up frame pointer to point to lr of caller
	sub sp, fp, #4			// reserve 4 bytes on the stack for local variables
	
	ldr r1, =0xff201000	// JTAG UART base address
	ldr r2, =0xff201004	// JTAG UART control register

wait_uart_ready:
	ldr r3, [r2]		// read the JTAG UART control register
	mov r4, r3, lsr #16	// shift upper 16 bits (WSPACE) down to lower 16 bits
	cmp r4, #0		// compare with 0
	beq wait_uart_ready	// if 0, no space, wait

	str r0, [r1]		// send the character to JTAG UART
	
	add sp, fp, #4			// deallocate local variables
	pop {fp, pc}			// restore old fp and return pc to caller



/*
	subroutine to read a character from the JTAG UART
	returns the character read in r0
*/
getchar_jtag:
	push {fp, lr}		// save the current fp and lr on the stack
	add fp, sp, #4			// set up frame pointer to point to lr of caller
	sub sp, fp, #4			// reserve 4 bytes on the stack for local variables		

	ldr r1, =0xff201000	// JTAG UART base address

wait_for_data:
	ldr r2, [r1]		// read data register
	mov r3, r2, lsr #15 // shift bit 15 (RVALID) down to bit 0
	and r3, r3, #1		// mask out all bits except bit 0
	cmp r3, #0		// is RVALID set?
	beq wait_for_data	// if not, wait

	and r0, r2, #0xff	// Extract the character from the lower 8 bits of r2. Return character in r0

	add sp, fp, #4			// deallocate local variables
	pop {fp, pc}			// restore old fp and return pc to caller


/*
	Subroutine to read all available characters from JTAG UART into a buffer.
	The buffer is null-terminated. The address of the buffer is returned in r0.
*/