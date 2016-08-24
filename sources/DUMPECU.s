* =============== P R O	G R A M =============================================
* ===========================================================================
* =============== DUMPECU ===================================================
* ===========================================================================
*
* A Target-Resident Command Driver program for use with Scott Howard's BD32
* Background mode Debuggger (BDM) for Motorola CPU32 processor cores used in
* SAAB Engine Control Units (ECU)
*
* This program can dump the entire FLASH memory from Saab T5.2, T5.5, T7 and
* T8 ECUs. Subroutines within the program determine the ECU and type of FLASH
* chip automatically. The user need only provide a filename for the FLASH
* BIN file when prompted.
*
* ===========================================================================
*
* How to use:
*   do prep  // sets up ECU's CPU to run the dumpecu program
*   dumpecu  // enter a filename for your BIN file when prompted
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
*
* WARNING: Use at your own risk, sadly this software comes with no guarantees
* This software is provided 'free' and in good faith, but the author does not
* accept liability for any damage arising from its use.
*
* ===========================================================================
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
		EVEN
*
START			dc.l	PROG_START	
*
Start_Msg		dc.b	'Trionic ECU DUMP script',$0D,$0A,$0
Dump_Msg 		dc.b	'DUMPing FLASH chips addresses',$0D,$0A,$0
End_Msg   		dc.b	'Trionic ECU DUMPed to: ',$0
*
FLASH_Size_Msg	dc.b	'FLASH size: 0x'
Bytes_Msg		dc.b	'0Cafe0 Bytes',$0D,$0A,$0
*
Progress_Msg	dc.b	'0x'
Progress_Msg1	dc.b	'0Cafe0-0Babe0',$0D,$0
*
CR_LF			dc.b	$0D,$0A,$0
*
FMODE			dc.b	'wb',0			* Write privileges for file
*
* ===========================================================================
*
* Subroutine function modules:
*
		EVEN
*
		include prepecu.s
		include flashid.s
		include showecu.s
		include getfname.s
		include printhex.s
* ---------------------------------------------------------------------------
*
		EVEN
*
PROG_START:
		lea.l	(STACK,pc),a7			* Stack pointer definition
		move.l	a0,a6					* Pointer to the parameters
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
		rol.l	#8,d2
		moveq.l	#5,d3
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

* Dump flash to file
		lea.l	(Dump_Msg,pc),a0		* Show DUMPing FLASH chips message
		moveq	#BD_PUTS,d0				* BD32 display string function call
		bgnd
		move.l	d7,a1					* Start address to read from
*		lea.l	0,a1
READ_WRITE:
		lea.l	(Progress_Msg1,pc),a0
		move.l	a1,d2					* start address of FLASH 'chunk'
		rol.l	#8,d2
		moveq.l	#5,d3
		jsr 	(hex2ascii,pc).w
		adda.w	#$1,a0	
		addi.w	#BUFF_SIZE-1,d2			* end address of FLASH 'chunk'
		rol.l	#8,d2
		moveq.l	#5,d3
		jsr 	(hex2ascii,pc).w
		lea.l	(Progress_Msg,pc),a0	* Show FLASH 'chunk' message
		moveq	#BD_PUTS,d0				* BD32 display string function call
		bgnd

		move.l	a1,a0
		move.l	(FILE,a5),d1			* File handle
		move.l	#BUFF_SIZE,d2			* Number of bytes to copy
		moveq	#BD_FWRITE,d0			* BD32 write to file function call
		bgnd
		cmpi.w	#BUFF_SIZE,d0			* Check the 'chunk' was written OK
		bne.b	File_Write_Error
		add.w	#BUFF_SIZE,a1			* Prepare to transfer another 'chunk'
		cmp.l	(FLASH_Size,pc),a1		* Check if all done
		bne.b	READ_WRITE
* Flash dumped to file
* Display end message
		lea.l	(End_Msg,pc),a0			* Show successful DUMP message
		moveq	#BD_PUTS,d0				* BD32 display string function call
		bgnd
		move.l	(4,a6),a0				* Pointer to file name
		lea.l 	(FILE_NAME,a5),a0		* Get BIN file's filename
		moveq	#BD_PUTS,d0				* BD32 display string function call
		bgnd
		lea.l	(CR_LF,pc),a0
		moveq	#BD_PUTS,d0				* BD32 display string function call
		bgnd
		bra.b	Close_File
*
PAR_ERR:
		addq	#1,d7					* Error 4! Wrong number of parameters
Unknown_FLASH:
		addq	#1,d7					* Error 3! Unknown FLASH chips 
File_Open_Error:
		addq	#1,d7					* Error 2! Could not open file
File_Write_Error:
		addq	#1,d7					* Error 1! Could not write to file
Close_File:
		move.l	(FILE,a5),d1			* File handle
		beq		Leave_Resident_Driver	* Check if file is open
		moveq	#BD_FCLOSE,d0			* Close file
		bgnd
Leave_Resident_Driver:
		move.l	d7,d1					* Exit code, !=0 is an error
		moveq	#BD_QUIT,d0				* Finished
		bgnd
*
				ds.w	10				* Reserve 10 Words for the Stack
STACK			ds.w	1
END_OF_CODE		dc.b	'END END END'
*
	END
