#define JTAG_UART_BASE 0xFF201000  

void putchar_jtag(char c) {
    volatile char *JTAG_UART_DATA = (char *)(JTAG_UART_BASE);
    *JTAG_UART_DATA = c;
}

int main(){
    const char c = 'A';
    putchar_jtag(c);
    return 0;
}