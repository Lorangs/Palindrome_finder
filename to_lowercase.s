.global _start

.text

/*
    subroutine to convert a character to lowercase.
    Argument: r0 = character to convert
    Returns: r0 = converted character
*/
to_lowercase
    stmfd sp!, {r4-r11, lr} // Save old registers and lr on stack (sp = sp - 36)
    cmp r0, #0x41     // Compare with ascii 'A'
    blt done_lowercase // If less than 'A', not uppercase, skip conversion
    cmp r0, #0x5a     // Compare with ascii 'Z'
    bgt done_lowercase // If greater than 'Z', not uppercase, skip conversion

    add r0, r0, 0x20    // convert letter from uppercase to lowercase

done_lowercase:
    ldmfd sp!, {r4-r11, pc} // Restore old registers and return (sp = sp + 36)



/*
	main program starts here. No arguments, no return value
*/
_start:

    
_end:
	b .			// return to caller

