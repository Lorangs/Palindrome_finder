.global _start

.text

/*
    subroutine to turn on either the 5 leftmost, or 5 rightmost LEDs at memory address 0xff200000 badesd on input r0.
    0 in r0 means leftmost, 1 means rightmost. No return value.
    No other LEDs should be affected.
*/
turn_on_leds:
    stmfd sp!, {r4-r11, lr} // Save old registers and lr on stack (sp = sp - 36)
    ldr r4, =0xFF200000	// LED base address

    mov r5, #0		// r5 will hold the bitmask for the LEDs
    str r5, [r4]	// Clear all LEDs before setting new ones

    cmp r0, #0		// Check if we want leftmost or rightmost LEDs
    beq turn_on_leftmost

turn_on_rightmost:
    eor r5, r5, #0x1F	// Bitmask for rightmost 5 LEDs
    b write_leds

turn_on_leftmost:
    eor r5, r5, #0x3E0	// Bitmask for leftmost 5 LEDs

write_leds:
    str r5, [r4]	// Write bitmask to LED register
    ldmfd sp!, {r4-r11, pc} // Restore old registers and return (sp = sp + 36)



/*
	main program starts here. No arguments, no return value
*/
_start:
	ldr sp, =0x3ffffff0		// Set up stack pointer to safe memory area	
    ldr r0, #0        // r0 = 0 to turn on leftmost LEDs
    bl turn_on_leds   // Turn on leftmost LEDs
    ldr r0, #1        // r0 = 1 to turn on rightmost LEDs
    bl turn_on_leds   // Turn on rightmost LEDs
_end:
	b .			// return to caller

