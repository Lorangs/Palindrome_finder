.global _start
.section .data
.org 0x00001024 // Ensure buffer is in a safe memory area
.align 2
buffer: 				 .space 128      // 128-byte global buffer, zero-initialized
not_palindrome_str:      .asciz "Not a palindrome"
palindrome_str:          .asciz "String is a Palindrome"
input_not_valid_str:   	 .asciz "Input string too short"
input:   				 .asciz "Grav ned den varg"





.text

/*
	subroutine for traversing a vector of char to check if it is a palindrome.
	vector must be null-terminated. 
	Special characters: ' ' (space) are ignored.
						'?' and '#' are wildcards and match any character.

	Arguments: 	r0 = pointer to vector
	returns: 	r0 = 1 if string is palindrome. 0 if it's not
*/

palindrome_check:
    stmfd sp!, {r4-r11, lr} // Save old registers and lr on stack (sp = sp - 36)
	mov r4, r0              // r4 = index start pointer of string
	mov r5, #0             // r5 = index end of string
	mov r6, #1              // Assume it's a palindrome (r6 = 1)
find_end:
	ldrb r7, [r4, r5]      // Load char at start + index
	cmp r7, #0              // Compare with null terminator
	beq find_end_done		// If null terminator, we found the end
	add r5, r5, #1          // Increment index
	b find_end              // Repeat
find_end_done:
	sub r5, r5, #1          // r5 = index of last character (not null terminator)
	add r5, r4, r5	        // r5 = pointer to end of string (start + index)
check_character_loop:
	cmp r4, r5              // Compare start index with end index
	bge palindrome_check_done // If start >= end, we're done checking
	ldrb r0, [r4]           // Load char at start index
	cmp r0, #0x20           // Compare with space
	beq skip_r4_char_space     // If space, skip it
	cmp r0, #0x3F           // Compare with '?'
	beq skip_r4_char_wildcard     // If '?', skip it (wildcard)
	cmp r0, #0x23           // Compare with '#'
	beq skip_r4_char_wildcard     // If '#', skip it (wildcard)
	bl to_lowercase         // Convert to lowercase
	mov r8, r0              // r8 = char at start index (lowercase)

	ldrb r0, [r5]          // Load char at end index
	cmp r0, #0x20           // Compare with space
	beq skip_r5_char_space       // If space, skip it
	cmp r0, #0x3F           // Compare with '?'
	beq skip_r5_char_wildcard       // If '?', skip it (wildcard)
	cmp r0, #0x23           // Compare with '#'	
	beq skip_r5_char_wildcard       // If '#', skip it (wildcard)
	bl to_lowercase         // Convert to lowercase

	cmp r8, r0              // Compare chars
	bne not_palindrome      // If not equal, it's not a palindrome
	add r4, r4, #1          // Increment start index
	sub r5, r5, #1          // Decrement end index
	b check_character_loop  // Repeat
skip_r4_char_space:
	add r4, r4, #1          // Increment start index
	b check_character_loop  // Repeat
skip_r4_char_wildcard:
	add r4, r4, #1          // Increment start index
	sub r5, r5, #1          // Decrement end index
	b check_character_loop  // Repeat
skip_r5_char_space:
	sub r5, r5, #1          // Decrement end index
	b check_character_loop  // Repeat
skip_r5_char_wildcard:
	add r4, r4, #1		  // Increment start index
	sub r5, r5, #1          // Decrement end index
	b check_character_loop  // Repeat
not_palindrome:
	mov r6, #0              // Set r6 = 0 (not a palindrome)
palindrome_check_done:
	mov r0, r6              // Move result to r0
	ldmfd sp!, {r4-r11, pc} // Restore old registers and return (sp = sp + 36)







/*
    subroutine to convert a character to lowercase.
    Argument: r0 = character to convert
    Returns: r0 = converted character
*/
to_lowercase:
    stmfd sp!, {r4-r11, lr} // Save old registers and lr on stack (sp = sp - 36)
    cmp r0, #0x41     // Compare with ascii 'A'
    blt done_lowercase // If less than 'A', not uppercase, skip conversion
    cmp r0, #0x5a     // Compare with ascii 'Z'
    bgt done_lowercase // If greater than 'Z', not uppercase, skip conversion

    add r0, r0, #0x20    // convert letter from uppercase to lowercase

done_lowercase:
    ldmfd sp!, {r4-r11, pc} // Restore old registers and return (sp = sp + 36)







/*
    Subroutine to store a result string in buffer based on r0.
    Argument:   r0 = pointer to buffer
                r1 = 2 if text in buffer are to be used as input. 1 if palindrome, 0 if not,             
    Returns: r0 = pointer to buffer, or -1 if input string too short
*/
store_string:
    stmfd sp!, {r4-r11, lr}
	mov r9, r0			  // r9 = pointer to buffer
    cmp r1, #0
    beq store_not_palindrome

    cmp r1, #1
	beq store_palindrome
	b store_input         //Default case if r1 is not 0, 1

store_input:
	ldr r2, =input
	mov r4, #0		  // index counter

check_length_loop:
	ldrb r5, [r2, r4]   // Load byte from input string
	cmp r5, #0          // Check for null terminator
	beq input_not_valid // If null terminator, input is too short
	add r4, r4, #1      // Increment index
	cmp r4, #2          // Prevent buffer overflow (leave space for null terminator)
	blt check_length_loop
	b copy_string  

input_not_valid:
	mov r0, #-1 		// Indicate invalid input
	ldr r2, =input_not_valid_str
	b copy_string

store_not_palindrome:
    ldr r2, =not_palindrome_str
	b copy_string

store_palindrome:
	ldr r2, =palindrome_str

copy_string:
    mov r3, #0          // index

copy_loop:
    ldrb r4, [r2, r3]
    strb r4, [r9, r3] 			// Store in buffer
    add r3, r3, #1
    cmp r4, #0
    bne copy_loop

    ldmfd sp!, {r4-r11, pc}







/*
    Subroutine to print all characters in the buffer.
    Argument: r0 = pointer to buffer (null-terminated)
    returns: r0 = pointer to buffer
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
	mov r0, r4             // Return pointer to buffer
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
	returns: r0 = pointer to buffer
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
	mov r0, r4             // Return pointer to buffer
	ldmfd sp!, {r4-r11, pc} // Restore old registers and return (sp = sp + 36)






/*
    subroutine to turn on either the 5 leftmost, or 5 rightmost LEDs at memory address 0xff200000 badesd on input r0.
	Arguments: r0 = 0 for leftmost, 1 for rightmost, 2 for no LEDs.
	No return value.
*/
turn_on_leds:
    stmfd sp!, {r4-r11, lr} // Save old registers and lr on stack (sp = sp - 36)
    ldr r4, =0xFF200000		// LED base address
    mov r5, #0				// r5 will hold the bitmask for the LEDs
    cmp r0, #0				// Check if we want leftmost or rightmost LEDs
    beq turn_on_leftmost
	cmp r0, #1				// Check if we want rightmost LEDs
	beq turn_on_rightmost
	b write_leds			// If r0 is 2 or anything else, turn off all LEDs

turn_on_rightmost:
    eor r5, r5, #0x1F		// Bitmask for rightmost 5 LEDs
    b write_leds

turn_on_leftmost:
    eor r5, r5, #0x3E0		// Bitmask for leftmost 5 LEDs

write_leds:
    str r5, [r4]			// Write bitmask to LED register
    ldmfd sp!, {r4-r11, pc} // Restore old registers and return (sp = sp + 36)





/*
	main program starts here. No arguments, no return value
*/
_start:
	ldr sp, =0x3ffffff0		// Set up stack pointer to safe memory area	
	ldr r11, =buffer         // r11 = pointer to buffer
	mov r0, r11             // r0 = pointer to buffer
	bl  overwrite_buffer	// call subroutine to overwrite the buffer with null characters
	mov r1, #2              // r1 = 2 to use input string
	bl  store_string 		// store input string in buffer, pointer returned in r0
	cmp r0, #-1            // Check if input was valid
	beq _end_input_invalid // If not valid, end program

	bl  palindrome_check    // call subroutine to check if buffer is palindrome, result in r0
	bl  turn_on_leds        // call subroutine to turn on LEDs based on r0 (0 = left, 1 = right)
	mov r1, r0 		  		// r0 = result from palindrome_check. r1 as argument to store_result_string
	mov r0, r11             // r0 = pointer to buffer
	bl  store_string 		// store result string in buffer, pointer returned in r0
	bl  print_buffer        // print the buffer
	bl  overwrite_buffer		// call subroutine to overwrite the buffer with null characters

_end:
	b .                     // loop here forever

_end_input_invalid:
	mov r0, r11             // r0 = pointer to buffer
	bl  print_buffer        // print the buffer
	mov r0, #2      		// r0 = 2 to turn off all LEDs
	bl turn_on_leds        // turn off all LEDs
	bl  overwrite_buffer    // call subroutine to overwrite the buffer with null characters
	b _end                 // Go to end loop