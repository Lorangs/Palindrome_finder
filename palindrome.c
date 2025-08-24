// Palindrome high-level structurale code
// This code checks if a given string is a palindrome.
#include <stdio.h>
#include <string.h>
#include <assert.h>
#include <stdlib.h>


int main(int argc, char *argv[]) {
    assert(argc > 1 && "No input string provided");

    // combine all arguments into a single string
    char *input = malloc(128 * sizeof(char)); // allocate enough space for the input
    if (input == NULL) {
        fprintf(stderr, "Memory allocation failed\n");
        return 1;
    }
    
    for (int i = 1; i < argc; i++) {
        strcat(input, argv[i]);
    }
    
    //printf("Input string: %s\n", input);

    // convert the input string to lowercase
    for (size_t i = 0; input[i]; i++) {
        input[i] = tolower((unsigned char)input[i]);
    }
    
    // check if the input string is a palindrome
    size_t input_len = strlen(input);

    if (input_len % 2 == 0) {
        // even length
        for (size_t i = 0; i < input_len / 2; i++) {

            // check if characters match or are '?' or '#'
            // '?' and '#' are considered wildcards that can match any character
            if (   input[i] != input[input_len - 1 - i] 
                && input[i] != '?' 
                && input[input_len - 1 - i] != '?' 
                && input[i] != '#' 
                && input[input_len - 1 - i] != '#'
            ){
                // printf("The input string is not a palindrome.\n");
                free(input);
                return 2;
            }
        }
    } else {
        // odd length
        for (size_t i = 0; i < (input_len - 1) / 2; i++){
            if (   input[i] != input[input_len - 1 - i] 
                && input[i] != '?' 
                && input[input_len - 1 - i] != '?' 
                && input[i] != '#' 
                && input[input_len - 1 - i] != '#'
            ){
                // printf("The input string is not a palindrome.\n");
                free(input);
                return 2;
            }
        }
    }
    // printf("The input string is a palindrome.\n");
    free(input);
    return 0;
}