.global _start
// Reserve space for buffer
.section .data
.org 0x00000200 // Ensure buffer is in a safe memory area
.align 2
buffer: .space 512      // -byte global buffer, zero-initialized


.text

/*
    Subroutine to fill the buffer with numbers from 0 to 99 as ASCII characters.
    Takes r0 as buffer pointer, Returns pointer to buffer in r0.
*/
put_numbers_in_buffer:
    stmfd sp!, {r4-r11, lr} // Save old registers and lr on stack (sp = sp - 36)
    mov  r4, r0             // r4 = buffer pointer
    mov r5, #0              // r5 = outer index
    mov r6, #0              // r6 = inner index
    mov r7, #0              // r7 = buffer index
    mov r9, #0x20           // r9 = space character

count_outer_loop:
    cmp r5, #10             // Compare index with 10
    bge count_done          // If index >= 10, exit loop
    mov r6, #0             // Reset inner index

count_inner_loop:
    cmp r6, #10            // Compare inner index with 10
    bge count_outer_next   // If inner index >= 10, go to next outer

    add r8, r5, #0x30      // Convert first number to ASCII character
    strb r8, [r4, r7]      // Store first character in buffer
    add r7, r7, #1         // Increment buffer index
    add r8, r6, #0x30      // Convert second number to ASCII character
    strb r8, [r4, r7]      // Store second character in buffer
    add r7, r7, #1         // Increment buffer index
    strb r9, [r4, r7]      // Store space character in buffer
    add r7, r7, #1         // Increment buffer index
    add r6, r6, #1         // Increment inner index
    b count_inner_loop           // Repeat inner loop

count_outer_next:
    add r5, r5, #1         // Increment outer index
    b count_outer_loop     // Repeat outer loop

count_done:
    mov r6, #0
    strb r6, [r4, r7]      // Null-terminate buffer


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
	argument: r0 = pointer to buffer, returns pointer to buffer in r0
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
    mov  r0, r4          // Return buffer pointer in r0
	ldmfd sp!, {r4-r11, pc} // Restore old registers and return (sp = sp + 36)




/*
	main program starts here. No arguments, no return value
*/
_start:
	ldr sp, =0x3ffffff0		// Set up stack pointer to safe memory area	
    ldr r0, =buffer        // r0 = buffer pointer
    bl  overwrite_buffer   //   call subroutine to overwrite the buffer with null characters
	bl  put_numbers_in_buffer  //   call subroutine to fill the buffer with numbers from 0 to 99
	bl	print_buffer		// call subroutine to print the buffer to JTAG UART
	bl  overwrite_buffer		// call subroutine to overwrite the buffer with null characters

_end:
	b .			// return to caller

