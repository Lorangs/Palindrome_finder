.global _start

.section .data
.align 2
.org 0x00000300 // Ensure buffer is in a safe memory area
buffer: .space 256
not_palindrome_str:      .asciz "Not a palindrome"
palindrome_str:          .asciz "String is a Palindrome"






.text



/*
    Subroutine to store a result string in buffer based on r0.
    Argument:   r0 = pointer to buffer
                r1 = 1 if palindrome, 0 if not            
    No return value.
*/
store_result_string:
    stmfd sp!, {r4-r11, lr}

    cmp r1, #0
    beq store_not_palindrome

    ldr r2, =palindrome_str
    b copy_string

store_not_palindrome:
    ldr r2, =not_palindrome_str

copy_string:
    mov r3, #0          // index

copy_loop:
    ldrb r4, [r2, r3]
    strb r4, [r0, r3]
    add r3, r3, #1
    cmp r4, #0
    bne copy_loop

    ldmfd sp!, {r4-r11, pc}


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
_start_loop:
    ldr r9, =buffer         // r4 = pointer to buffer
    mov r0, r9              // r0 = pointer to buffer
	bl overwrite_buffer     // call subroutine to overwrite the buffer with null characters
    mov r0, r9              // r0 = pointer to buffer
    mov r1, #0             // r1 = 0 (not palindrome by default)
    bl store_result_string // store result string in buffer, pointer returned in r0
    mov r0, r9             // r4 = pointer to buffer
    bl print_buffer        // print the buffer

    mov r0, r9              // r0 = pointer to buffer
    mov r1, #1             // r0 = 1 (palindrome)
    bl store_result_string // store result string in buffer, pointer returned in r0
    bl print_buffer        // print the buffer

_end:
	b .                     // loop here forever
