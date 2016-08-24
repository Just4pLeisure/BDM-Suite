* ipd.inc - equates for BD32 systems calls

BD_QUIT         equ     0       quit - return to BD32
BD_PUTS         equ     1       puts - put string to console
BD_PUTCHAR      equ     2       putchar - print character on console
BD_GETS         equ     3       gets - get string from user
BD_GETCHAR      equ     4       getchar - get single character from user
BD_GETSTAT      equ     5       getstat - return 1 if character waiting from user
BD_FOPEN        equ     6       fopen - open disk file with specified mode
BD_FCLOSE       equ     7       fclose - close disk file
BD_FREAD        equ     8       fread - read from disk file
BD_FWRITE       equ     9       fwrite - write to disk file
BD_FTELL        equ     10      ftell - report current pointer position
BD_FSEEK        equ     11      fseek - seek disk file to given position
BD_FGETS        equ     12      fgets - read string from file
BD_FPUTS        equ     13      fputs - write string to file
BD_EVAL         equ     14      eval - evaluate arithmetic expression
BD_FREADSREC    equ     15      read s-record

* end of ipd.inc
