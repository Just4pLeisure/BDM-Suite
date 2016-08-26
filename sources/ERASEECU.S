* =============== P R O	G R A M =============================================
* ===========================================================================
* =============== FLASHECU ==================================================
* ===========================================================================
*
* A Target-Resident Command Driver program for use with Scott Howard's BD32
* Background mode Debuggger (BDM) for Motorola CPU32 processor cores used in
* SAAB Engine Control Units (ECU)
*
* This program provides a means to erase the FLASH chips in Saab T5.2, T5.5,
* T7 and T8 ECUs. Subroutines within the program determine the type of ECU
* and FLASH chip automatically. 
*
* A type of 'brute' force method is used on 28Fxxx FLASH chips in T5.x ECUs
* if needed as a first step to try to recover so called 'BAD' FLASH chips.
*
* A normal erase procedure is used to erase 29C/29F/39F FLASH chips.
*
* NOTE: This program provides the only way to erase Atmel 29Cxxx FLASH chips
* which aren't normally erased before re-programming them
*
* ===========================================================================
*
* How to use:
*   do prep  // sets up ECU's CPU to run the dumpecu program
*   eraseecu // Attempt to recover 'BAD' FLASH, use before with FLASHECU
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
* Version 1.2
* 28-Nov-2013
*
* A new addition to the 'Universal BDM scripts for Trionic'
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
START		dc.l	PROG_START	
* ---------------------------------------------------------------------------
STACK		dc.b	'STACK_IT'		* Reserve 4 Words for the Stack
* ---------------------------------------------------------------------------
Start_Msg	dc.b	'Trionic ECU ERASE script',$0D,$0A,$0
End_Msg   	dc.b	'Trionic ECU FLASH chips have been ERASEed!',$0D,$0A,$0
*
FLASH_Size_Msg	dc.b	'FLASH size: 0x'
Bytes_Msg	dc.b	'0Fade0 Bytes'
CR_LF		dc.b	$0D,$0A,$0
*
FMODE		dc.b	'rb',0		* Binary read mode
*
* ===========================================================================
*
* Equates used to improve readability
*
		EVEN
*
		include ipd.inc					* BD32 function call constants
		include errors.inc				* Program Error Code constants
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
		include fullwipe.s
* ---------------------------------------------------------------------------
*
		EVEN
*
PROG_START:
		lea.l	(STACK+8,pc),a7			* Stack pointer definition
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
		jsr	(Get_FLASH_Id,pc).w
		tst.w	d2						* d2 has FLASH_type, 0 means unknown
		bne.b	Identified_FLASH
		moveq	#ERROR_Unknown,d2		* Error 1! Unknown FLASH chips
		bra.b	End_Program
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
* Wipe FLASH
*
		jsr	(Wipe_FLASH_Chips,pc).w
		tst.b	d0
		beq.b	Erase_Complete
		moveq	#ERROR_Erase,d2			* Error 5! Unable to erase FLASH
		bra.w	End_Program
* ---------------------------------------------------------------------------
Erase_Complete:
*
* Erasing complete, display end message
*
		lea.l	(End_Msg,pc),a0
		moveq	#BD_PUTS,d0				* BD32 display string function call
		bgnd
		clr.l	d2						* No errors
*
End_Program:
Leave_Resident_Driver:
		move.l	d2,d1					* Exit code, !=0 is an error
		moveq	#BD_QUIT,d0				* Finished
		bgnd
*
	END
