* =============== S U B	R O U T	I N E =======================================
* ===========================================================================
* =============== Get_filename ==============================================
* ===========================================================================
*
* @brief		Display a message asking for a name for the BIN file
*				and then try to open it.
*
*				The filename must follow DOS rules and be a maximum
*				of 8 characters, The .BIN extension is added automatically
*
* @param		VOID		No input parameters
*
* @registers	d0			Holds Filename Characters as they are entered
*				d1			Holds Filename Characters as they are displayed
*				d4			Holds a counter for the number of characters
*
*				a0			Holds message and filename string addresses
*
* @return		FILE		A DOS File handle for the BIN filename
*				d0			FILE, 0x00 if the file could not be opened
* @return		FILE_NAME	The full DOS filename for the BIN file
*
* ===========================================================================
* Created by Sophie Dexter
* Version 1.0
* 27-Jul-2012
* ===========================================================================
* Version 1.1
* 26-May-2013
*
* Added the ability to edit the filename as it is typed 
* ===========================================================================
* Version 1.2
* 28-Nov-2013
*
* Improved filename editing
* ===========================================================================
*
		EVEN
*
FILE			ds.l	1				* DOS - File handle
*FMODE			dc.b	'rb',0			* Binary read mode
*FMODE			dc.b	'wb',0			* Write privileges for file
*
FILE_NAME		dc.b	'FILENAME.BIN',$0
File_Msg		dc.b	'Enter a filename (up to 8 characters): ',$0
*
* ===========================================================================
*
		EVEN
*
Get_filename:
		lea.l	(File_Msg,pc),a0		* Show a prompt for the file name
		moveq	#BD_PUTS,d0				* BD32 display string function call
		bgnd
		lea.l 	(FILE_NAME,pc),a0		* Get ready to store a filename
		moveq	#8,d4
Filename_loop:
		moveq	#BD_GETCHAR,d0			* BD32 get character function call
		bgnd							* Get one character at a time
		cmpi.b	#$d,d0					* test for enter (carriage return)
		beq.b	Got_Filename
		cmpi.b	#'.',d0					* test for '.'
		beq.b	Got_Filename
		cmpi.b	#$8,d0					* test for backspace
		bne.b	Store_Character
		cmp.b	d0,d4					* backspace is also max file length
		beq.b	Filename_loop
		subq	#1,a0					* move back 1 character in
*										* FILE_NAME string
		addq	#2,d4					* increase by 2 for deleted char and
*										* backspace
		bra.b	Display_Character
Store_Character:
		tst.b	d4						* Is this be the last character
		beq.b	Got_Filename
		move.b	d0,(a0)+				* store the character
Display_Character:
		move.b	d0,d1
		moveq	#BD_PUTCHAR,d0			* BD32 display character function call
		bgnd							* and display it
		dbra	d4,Filename_loop
Got_Filename:
		move.b	#'.',(a0)+
		move.b	#'B',(a0)+
		move.b	#'I',(a0)+
		move.b	#'N',(a0)+
		move.b	#0,(a0)
		subq.l	#4,a0					* display file extension '.BIN'
		moveq	#BD_PUTS,d0				* BD32 display string function call
		bgnd
		lea.l	(CR_LF,pc),a0
		moveq	#BD_PUTS,d0				* BD32 display string function call
		bgnd
* Try to open the writable file 'FILENAME.BIN' 
		lea.l	(FILE_NAME,pc),a0
		lea.l	(FMODE,pc),a1			* Open the file using correct mode
		moveq	#BD_FOPEN,d0			* BD32 File open function call
		bgnd
		lea.l	(FILE,pc),a0
		move.l	d0,(a0)					* Store the FILE handle
		rts
*
* ===========================================================================
* =============== End of Get_filename =======================================
* ===========================================================================
