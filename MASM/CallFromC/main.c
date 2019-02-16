/*************************************************************/
// Call an assembler procedure from a C program
/*************************************************************/
#include <stdio.h>

// Note: you get "C" convention by default
extern void PrintString(const char*);
extern int AddInt(int, int);
unsigned long long AddLong(long, long);

int main(int argc, char* argv[]) {

	printf("Before call PrintString routine.\n");
	PrintString("Hola from the world of 64 bit assembler!\n");
	printf("After call PrintString routine.\n");
	
	printf("Before call AddInt routine.\n");
	int result = AddInt(10, 20);
	printf("Result of 10 + 20 = %d.\n", result);

	printf("Before call AddLong routine.\n");
	unsigned long long lResult = AddLong(4294967290, 4294967290);
	printf("Result of 4,294,967,290 + 4,294,967,290 = %lld.\n", lResult);

	return 0;
}