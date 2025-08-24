.global _start
// Reserve space for buffer
.section .data
.org 0x00000200 // Ensure buffer is in a safe memory area
.align 2
buffer: .space 128      // 128-byte global buffer, zero-initialized


.text

/*
	Subroutine to read all available characters from JTAG UART into buffer.
	Returns pointer to buffer in r0.
*/
get_all_chars_jtag:
	stmfd sp!, {r4-r11, lr}		 // Save old registers and lr on stack (sp = sp - 36)

    ldr  r4, =buffer        // r4 = buffer pointer
    mov  r5, #0             // r5 = index

    ldr  r6, =0xFF201000    // JTAG UART data register

read_loop:
    ldr  r7, [r6]           // Read data register
    mov  r8, r7, lsr #15    // Shift RVALID to bit 0
    and  r8, r8, #0x1 		// Mask out all but bit 0
    cmp  r8, #0
    beq  done_reading       // If no more data, exit

    and  r9, r7, #0xFF      // Extract character
    strb r9, [r4, r5]       // Store in buffer
    add  r5, r5, #1         // Increment index
    cmp  r5, #127         // Prevent buffer overflow
    bge  done_reading
    b    read_loop

done_reading:
    mov  r9, #0
    strb r9, [r4, r5]       // Null-terminate buffer
    mov  r0, r4             // Return pointer to buffer
	ldmfd sp!, {r4-r11, pc} // Restore old registers and return (sp = sp + 36)





/*
    Subroutine to print all characters in the buffer.
    Argument: r0 = pointer to buffer (null-terminated)
    No return value.
*/
print_buffer:
	stmfd sp!, {r4-r11, lr}	// Save old registers and lr on stack (sp = sp - 36)
    mov  r4, r0          // r4 = buffer pointer

print_loop:
    ldrb r5, [r4], #1    // Load byte from buffer and increment pointer
    cmp  r5, #0          // Check for null terminator
    beq  print_done
    mov  r0, r5          // Move character to r0 for putchar_jtag
    bl   putchar_jtag    // Print character
    b    print_loop

print_done:
	ldmfd sp!, {r4-r11, pc} // Restore old registers and return (sp = sp + 36)



/*
	subroutine to output a character to the JTAG UART
	argument in r0, no return value
*/
putchar_jtag:
	stmfd sp!, {r4-r11, lr}	// Save old registers and lr on stack (sp = sp - 36)
	ldr r4, =0xff201000	// JTAG UART base address
	ldr r5, =0xff201004	// JTAG UART control register

wait_uart_ready:
	ldr r6, [r5]		// read the JTAG UART control register
	mov r7, r6, lsr #16	// shift upper 16 bits (WSPACE) down to lower 16 bits
	cmp r7, #0		// compare with 0
	beq wait_uart_ready	// if 0, no space, wait

	str r0, [r4]		// send the character to JTAG UART

	ldmfd sp!, {r4-r11, pc} // Restore old registers and return (sp = sp + 36)


/*
    subroutine to overwrite the buffer with null characters
	argument: r0 = pointer to buffer
*/
overwrite_buffer:
	stmfd sp!, {r4-r11, lr} // Save old registers and lr on stack (sp = sp - 36)

	mov  r4, r0          // r4 = buffer pointer
	mov  r5, #0          // r5 = null character
	mov  r6, #0          // r6 = index
clear_loop:
	cmp  r6, #127        // Prevent buffer overflow
	bge  clear_done
	strb r5, [r4, -r6]    // Store null character in buffer
	add  r6, r6, #1      // Increment index
	b    clear_loop
clear_done:
	ldmfd sp!, {r4-r11, pc} // Restore old registers and return (sp = sp + 36)




/*
	main program starts here. No arguments, no return value
*/
_start:
	ldr sp, =0x3ffffff0		// Set up stack pointer to safe memory area	
	bl overwrite_buffer		// call subroutine to overwrite the buffer with null characters
	bl  get_all_chars_jtag  // call subroutine to read character into buffer, address returned in r0
	bl	print_buffer		// call subroutine to print the buffer to JTAG UART
	bl overwrite_buffer		// call subroutine to overwrite the buffer with null characters

_end:
	bx lr			// return to caller

