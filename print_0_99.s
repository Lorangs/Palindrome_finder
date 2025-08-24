.global _start
JTAG_UART_BASE = 0xFF201000
DDR_END = 0x3FFFFFFF
TEXT_STRING = 0x3FFFFFF0 // Address to store "hello world" string
MAX_STRING_LENGTH = 100 // Maximum length of the string

_start:
	/* set up stack pointer */
    LDR SP, =DDR_END
    
    /* loop to read characters from JTAG UART until null character and store string on stack*/
    LDR R4, =TEXT_STRING // R4 points to the start of the string in DDR
    MOV R2, #0 // Initialize index to 0

    BL LOOP_READ // Read characters from JTAG UART
    MOV R0, R4 // Move the address of the string to R0 for printing
    BL PUT_JTAG // Print the string to JTAG UART
    MOV R0, #0 // Reset index for printing
    B _end // End of program


LOOP_READ:
    BL GET_JTAG // read a character from JTAG UART  
    STRB R0, [R4, R2] // store the character in DDR
    ADD R2, R2, #1 // increment index
    CMP R0, #0 // check if a character was read
    BEQ LOOP_END_READ // if null character, end reading
    CMP R2, #MAX_STRING_LENGTH // check if we reached the maximum length
    BNE LOOP_READ // if not, continue reading
LOOP_READ_END:
    MOV R0, #0 // reset index for printing
    BX LR // return from subroutine


_end:
    B .


/********************************************************************************
* Subroutine to print a string to the JTAG UART
* Expects the address of the string in R0
********************************************************************************/
.global PUT_JTAG
PUT_JTAG:
	LDR R1, =JTAG_UART_BASE // JTAG UART base address
	LDR R2, [R1, #4] // read the JTAG UART control register
	LDR R3, =0xFFFF0000
	ANDS R2, R2, R3 // check for write space
	BEQ END_PUT // if no space, ignore the character
	STR R0, [R1] // send the character
END_PUT:
	BX LR
	


/********************************************************************************
* Subroutine to get a character from the JTAG UART
* returns the character read in R0
********************************************************************************/
.global GET_JTAG
GET_JTAG:
	LDR R1, =JTAG_UART_BASE // JTAG UART base address
	LDR R0, [R1] // read the JTAG UART data register
	ANDS R2, R0, #0x8000 // check if there is new data
	BEQ RET_NULL // if no data, return 0
	AND R0, R0, #0x00FF // return the character
	B END_GET
RET_NULL:
	MOV R0, #0
END_GET:
	BX LR