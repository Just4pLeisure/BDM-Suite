* =============== I N C L U D E   F I L E ===================================
* ===========================================================================
* =============== Equates for storage buffer constants ======================
* ===========================================================================
*
* ===========================================================================
* Created by Sophie Dexter
* Version 1.0
* 17-Jul-2012
* ===========================================================================
*
* BUFF_SIZE is the size of each 'chunk' of the BIN file that I transfer at a
* time. It is a compromise between updating the display often so that I can
* see that the program is working, but not so frequently that too much time
* is wasted showing progress. In the end I had to use a value of $100 (256)
* because that was all that was left after the program code!
* 
BUFF_SIZE		EQU	$100				* 256
*
* ===========================================================================
