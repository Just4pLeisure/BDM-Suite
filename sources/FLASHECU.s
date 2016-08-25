* =============== P R O	G R A M =============================================
* ===========================================================================
* =============== FLASHECU ==================================================
* ===========================================================================
*
* A Target-Resident Command Driver program for use with Scott Howard's BD32
* Background mode Debuggger (BDM) for Motorola CPU32 processor cores used in
* SAAB Engine Control Units (ECU)
*
* This program can update the entire FLASH memory in Saab T5.2, T5.5, T7 and
* T8 ECUs. Subroutines within the program determine the ECU and type of FLASH
* chip automatically. The user need only provide a filename for the FLASH
* BIN file when prompted.
*
* ===========================================================================
*
* How to use:
*   do prep  // sets up ECU's CPU to run the flashecu program
*   flashecu // enter a filename for your BIN file when prompted
*   
* ===========================================================================
*
* Created by Sophie Dexter
*
* Part of the 'Universal BDM scripts for Trionic' 
*
* This would not have been posssible without Patrik Servin's original work
* or subsequent contributions from J.K. Nillson, Dilemma, General Failure,
* johnc, uglybug., krzykoz and many others - please accept my apologies if
* I haven't given you credit.
*
* ===========================================================================
* Version 1.0
* 06-Sep-2012
* ===========================================================================
* Version 1.1
* 26-May-2013
*
* Bugfixes:
* Added missing test for unknown FLASH chips and exit with an error message
*
* Improvements:
* Removal of odd bits of unnecessary code and other changes to reduce size
* Use PLL lock status bit to test for a stable clock signal in T8 ECUs
* Enable backspace to allow editing/correction of BIN file's filename
* Turn off FLASH programming voltage when not needed
* Added the ability to FLASH 2 copies of a T5.2 BIN file to a T5.5 ECU
* ===========================================================================
* ===========================================================================
*
* WARNING: Use at your own risk, sadly this software comes with no guarantees
* This software is provided 'free' and in good faith, but the author does not
* accept liability for any damage arising from its use.
*
* ===========================================================================
* ===========================================================================
*
		EVEN
*
START			dc.l	PROG_START	
*
Start_Msg		dc.b	'Trionic ECU FLASH script',$0D,$0A,$0
Program_Msg		dc.b	'Programming FLASH chip addresses:',$0D,$0A,$0
End_Msg   		dc.b	'Trionic ECU FLASH chips updated - enjoy :-)',$0D,$0A,$0
*
FLASH_Size_Msg	dc.b	'FLASH size: 0x'
Bytes_Msg		dc.b	'0Cafe0 Bytes'
CR_LF			dc.b	$0D,$0A,$0
*
Progress_Msg	dc.b	'0x'
Progress_Msg1	dc.b	'0Cafe0-0Babe0',$0D,$0
*
FMODE			dc.b	'rb',0			* Binary read mode
*
* ===========================================================================
*
* Equates used to improve readability
*
		EVEN
*
		include ipd.inc					* BD32 function call constants
		include buffers.inc				* Storage buffer constants
		include timers.inc				* Delay loop constants
		include flash.inc				* FLASH chip constants
* ---------------------------------------------------------------------------
*
* Subroutine function modules:
*
		EVEN
*
		include 6hex2asc.s
		include spinner.s
		include prepecu.s
		include flashid.s
		include showecu.s
		include getfname.s
		include erase.s
		include program.s
* ---------------------------------------------------------------------------
*
		EVEN
*
PROG_START:
		lea.l	(STACK,pc),a7			* Stack pointer definition
		clr.l	(FILE,a5)				* File pointer 
		clr.l	d7						* No errors
*
* Display start message
*
		lea.l	(Start_Msg,pc),a0		* Show what the program does
		moveq	#BD_PUTS,d0				* BD32 display string function call
		bgnd
*
* Configure MC68332 registers
*
		jsr		(Preparation,pc).w
*
* Work out what type and size of FLASH chip(s) are fitted
*
		jsr		(Get_FLASH_Id,pc).w
* ---------------------------------------------------------------------------
* Check that FLASH is recognised
Check_FLASH_OK:
		tst.w	d2						* d2 has FLASH_type, 0 means unknown
		beq.w	Unknown_FLASH
* ---------------------------------------------------------------------------
Identified_FLASH:
*
* Display a message showing what type of ECU is connected
*
		jsr		(Show_ECU_Type,pc).w
*
* Display FLASH / BIN file size message
*
		lea.l	(Bytes_Msg,pc),a0
		move.l	(FLASH_Size,pc),d2
		jsr		(hex2ascii,pc).w
		lea.l	(FLASH_Size_Msg,pc),a0	* Show FLASH/BIN size in Hex
		moveq	#BD_PUTS,d0				* BD32 display string function call
		bgnd
*
* Enter a filename for the BIN file
*
		jsr		(Get_filename,pc).w
		tst.w	d0
		beq		File_Open_Error			* Error: file could not be opened
*
* Erase FLASH
*
		jsr (Erase_FLASH_Chips,pc).w
		tst.b	d0
		bne	ERASE_ERR
*
* ===========================================================================
*
* Program FLASH
*
* ===========================================================================
*
*	d0 - used for BD32 function calls and
*		 to store a copy of word read back from FLASH during polling loop
*	d1 - used for BD32 function calls
*	d2 - used for BD32 function calls and
*		 displaying progress message addresses
*	d3 - used for BD32 function calls
*
*	a0 - used for BD32 function calls and
*		 is the address of the data buffer
*	a1 - is the address of FLASH to program
*	a5 - is the Base Address of FLASH
*
* ===========================================================================
*
Program_FLASH:
		lea.l	(Program_Msg,pc),a0
		moveq	#BD_PUTS,D0				* BD32 display sring function call
		bgnd
		lea.l	$0,a1					* Base address of FLASH
Program_FLASH_loop:
		lea.l	(BUFFER,pc),a0			* Intermediate buffer
		move.l	#BUFF_SIZE,d2			* Number of bytes to put in RAM buffer
		move.l	(FILE,pc),d1			* File handle
		moveq	#BD_FREAD,d0			* BD32 File read function call
		bgnd
		cmpi.w	#BUFF_SIZE,d0
		bne.b	Check_T52_to_T55
* ---------------------------------------------------------------------------
		lea.l	(Progress_Msg1,pc),a0
		move.l	a1,d2					* Start address of FLASH 'chunk'
		jsr 	(hex2ascii,pc).w
		addq	#$1,a0	
		addi.w	#BUFF_SIZE-1,d2			* End address of FLASH 'chunk'
		jsr		(hex2ascii,pc).w
		lea.l	(Progress_Msg,pc),a0	* Show FLASH 'chunk' message
		moveq	#BD_PUTS,d0				* BD32 display string function call
		bgnd
* ---------------------------------------------------------------------------
		jsr		(Flash_Programming,pc).w
		tst.b	d0
		bne.b	PROG_ERR

		adda.w	#BUFF_SIZE,a1
		cmp.l	(FLASH_Size,pc),a1
		bne		Program_FLASH_loop		* Refill RAM buffer
*
* Programming complete, display end message
*
		lea.l	(End_Msg,pc),a0
		moveq	#BD_PUTS,d0				* BD32 display string function call
		bgnd
		bra.b	Close_File
* ---------------------------------------------------------------------------
* Special feature to program 2 T5.2 images to a T5.5 ECU
Check_T52_to_T55:
		clr.l	d7						* No errors
		cmp.l	#$40000,(FLASH_Size,pc)	* Check to see if this is a T5.5 ECU
		bne.b	File_Read_Error
		cmp.l	#$20000,a1				* Check if we reached the end of a T5.2 BIN file
		bne.b	File_Read_Error
		moveq 	#0,d3					* seek in file relative to file start
		moveq 	#0,d2					* offset 0 
		move.l 	(FILE,pc),d1			* File handle
		moveq	#BD_FSEEK,d0			* BD32 file seek ('rewind' to start)
		bgnd
		move.w	#$AAAA,d7				* preserve 29Fxxx unlock sequence
		bra.b	Program_FLASH_loop
* ---------------------------------------------------------------------------
*
ERASE_ERR:
		addq	#1,d7					* Error 5! Unable to erase FLASH
PROG_ERR:
		addq	#1,d7					* Error 4! Unable to program FLASH
Unknown_FLASH:
		addq	#1,d7					* Error 3! Unknown FLASH chips 
File_Open_Error:
		addq	#1,d7					* Error 2! Could not open file
File_Read_Error:
		addq	#1,d7					* Error 1! Could not write to file
*
Close_File:
		move.l	(FILE,pc),d1			* File handle
		beq.b	Leave_Resident_Driver	* Check if file is open
		moveq	#BD_FCLOSE,d0			* Close file
		bgnd
Leave_Resident_Driver:
		move.l	d7,d1					* Exit code, !=0 is an error
		moveq	#BD_QUIT,d0				* Finished
		bgnd
*
BUFFER			ds.b	BUFF_SIZE		* Data buffer
* Reserve 4 Words for the Stack
				dc.b	'STACK_'
STACK			ds.w	1
*
	END
