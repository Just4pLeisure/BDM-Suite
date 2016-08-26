* =============== P R O	G R A M =============================================
* ===========================================================================
* =============== CHECKECU ==================================================
* ===========================================================================
*
* A Target-Resident Command Driver program for use with Scott Howard's BD32
* Background mode Debuggger (BDM) for Motorola CPU32 processor cores used in
* SAAB Engine Control Units (ECU)
*
* This program provides a quick way to check that FLASHing was successful
* and quite likely to be error free. However, I suggest that you only use it
* once you have satisfied yourself that your BD32 setup is reliable.

* I say quite likely because I do not check every byte in the FLASH chips,
* only the part covered by the 'FB' checksum. The 'HEADER' is also checked
* because  have to read it to find the stored checksum and the address range
* for the FB checksum calculation (or equivalent in T5 ECUs).
*
* The check will give very good confidence in T5.2 and T5.5 ECUs.
* Slightly less in a T5.5 ECU that has 2 T5.2 BIN Files because I can only
* check one of the images.
* Most of the FLASH in a T7 ECU is checked, apart from Area 70000
* The T8 ECU is least checked because the 'recovery' area (up to 0x20000)
* isn't checked at all.
*
* Each type of ECU uses a slightly different scheme, notably different T8
* ECUs use one of two different calculation methods. I do the more common
* calculation first and if that fails I try the other method.
*
* ===========================================================================
*
* How to use:
*   do prep  // sets up ECU's CPU to run the dumpecu program
*   checkecu // hopefully your checksum is ok, use FLASHECU to reFLASH if not
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
* Version 1.1
* 26-May-2013
*
* A new addition to the 'Universal BDM scripts for Trionic'
* ===========================================================================
* Version 1.2
* 28-Nov-2013
*
* Bugfixes:
* FIXED a serious bug for T5.2/5 ECUS. which prevented the scripts working
* and displayed the '3: Error: Unrecognised ECU or FLASH chips' message
* This was due to a timing issue with the FLASH programming voltage and meant
* that I couldn't reliably detect 28F010 or 28F512 FLASH chips!
*
* Improvements:
* Better reporting of errors if they occur
* Improved control of FLASH programming voltage
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
* ---------------------------------------------------------------------------
STACK			dc.b	'STACK_IT'		* Reserve 4 Words for the Stack
* ---------------------------------------------------------------------------
Start_Msg		dc.b	'Trionic ECU Checksum Script'
CR_LF			dc.b	$0D,$0A,$0
*
FLASH_Size_Msg	dc.b	'FLASH size: 0x'
Bytes_Msg		dc.b	'0Fade0 Bytes',$0D,$0A,$0
*
Stored_Msg_Pt1	dc.b	'The checksum stored in FLASH is: 0x'
Stored_Msg_Pt2	dc.b	'CafeBabe',$0D,$0A,$0
*
Range_Msg_Pt1	dc.b	'Calculating ECU checksum for addresses: 0x'
Range_Msg_Pt2	dc.b	'0Deaf0-0Beef0',$0D,$0A,$0
*
Calcd_Msg_Pt1	dc.b	'The calculated checksum is: 0x'
Calcd_Msg_Pt2	dc.b	'FeedF00d',$0D,$0A,$0
*
End_Msg   	dc.b	'Stored and calculated checksum match :-)',$0D,$0A,$0
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
		include checksum.inc			* Checksum calculation constants
* ---------------------------------------------------------------------------
*
* Subroutine function modules:
*
		EVEN
*
		include prepecu.s
		include flashid.s
		include showecu.s
		include 6hex2asc.s
		include long2asc.s
		include chksums.s
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
* Read MC68332/377 Module Control Register (SIMCR/MCR)
* and use the value to work out if ECU is a T5/7
		movea.l	#$FFFA00,a0
		btst.b	#4,(a0)
		bne.b	Check_FLASH_OK
* Turn FLASH programming voltage off if T5/7
		andi.w	#$FFBF,($FFFC14).l
* ---------------------------------------------------------------------------
* Check that FLASH is recognised
Check_FLASH_OK:
		tst.w	d2						* d2 has FLASH_type, 0 means unknown
		bne.b	Identified_FLASH
		moveq	#ERROR_Unknown,d2		* Error 1! Unknown FLASH chips
		bra.w	End_Program
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
* ---------------------------------------------------------------------------
		clr.l	d4						* initialise Identifier to 0x0
		clr.l	d7						* initialise error flag to 0x0
* ---------------------------------------------------------------------------
		cmp.l	#T8_Size,(FLASH_Size,pc)		* Is this is a T8 ECU ?
		beq		Get_T8_Identifiers
		cmp.l	#T7_Size,(FLASH_Size,pc)		* Is this is a T7 ECU ?
		beq	Get_T7_Identifiers
*										* Assume a T5.x ECU if here
* ---------------------------------------------------------------------------
Get_T5_Identifiers:
* ---------------------------------------------------------------------------
* Look for the ROM_Offset identifier, 0xFD, get the offset address
*
		move.b	#ROM_Offset,d4			* Search for ROM_Offset identifier
		jsr 	(Get_T5_Identifier,pc).w
		bne		Identifier_Error		* Identifier error
		move.l	d2,d5					* Store first address for checksum
*										* calculation
* ---------------------------------------------------------------------------
* Look for the Code_End identifier, 0xFE, get the Code End address
*
		move.b	#Code_End,d4			* Search for Code_End identifier
		jsr 	(Get_T5_Identifier,pc).w
		bne		Identifier_Error		* Identifier error
		addq.l	#1,d2					* 
		move.l	d2,d6					* Store last address for checksum
*										* calculation
* ---------------------------------------------------------------------------
* Get the stored checksum
*
		move.l	(Last_Address_Of_ECU-3),d7		* Fetch stored T5 Checksum
* ---------------------------------------------------------------------------
		jsr 	(Show_Stored_Checksum,pc).w
		jsr 	(Show_Csum_Calc_Range,pc).w
* ---------------------------------------------------------------------------
* Calculate T5 Checksum
*
		move.l	d5,d2
		move.l	d6,d3
		cmp.l	d2,d3					* Check if Code_End is before
*										* ROM_Offset !!!
		bls		Identifier_Error
		cmpi.l	#Last_Address_Of_ECU,d3	* Check if Code_End is after last
*										* address of ECU
		bcc		Identifier_Error
* ---------------------------------------------------------------------------
		jsr 	(Calculate_BYTE_Checksum,pc).w
		bra	Show_Checksum
* ===========================================================================
Get_T7_Identifiers:
* ---------------------------------------------------------------------------
* Look for the ROM_Offset identifier, 0xFD, get the offset address
*
		move.b	#ROM_Offset,d4			* Search for ROM_Offset identifier
		jsr 	(Get_T7_Identifier,pc).w
		bne		Identifier_Error		* Identifier error
		move.l	d2,d5					* Store first address for checksum
*										* calculation
* ---------------------------------------------------------------------------
* Look for the Code_End identifier, 0xFE, get the Code End address
*
		move.b	#Code_End,d4			* Search for Code_End identifier
		jsr 	(Get_T7_Identifier,pc).w
		bne		Identifier_Error		* Identifier error
		move.l	d2,d6					* Store last address for checksum
*										* calculation
* ---------------------------------------------------------------------------
* Look for the Checksum identifier, 0xFB, get the stored checksum
*
		move.b	#FB_Checksum,d4			* Search for FB Checksum identifier
		jsr 	(Get_T7_Identifier,pc).w
		bne		Identifier_Error		* Identifier error
		move.l	d2,d7					* Copy stored T7 Checksum
* ---------------------------------------------------------------------------
		jsr 	(Show_Stored_Checksum,pc).w
		jsr 	(Show_Csum_Calc_Range,pc).w
* ---------------------------------------------------------------------------
* Calculate T7 Checksum
*
		move.l	d5,d2
		move.l	d6,d3
		cmp.l	d2,d3					* Check if Code_End is before
*										* ROM_Offset !!!
		bls	Identifier_Error
		cmpi.l	#Last_Address_Of_ECU,d3	* Check if Code_End is after last
*										* address of ECU
* ---------------------------------------------------------------------------
		bcc.b	Identifier_Error
		jsr 	(Calculate_LONG_Checksum,pc).w
		bra.b	Show_Checksum
* ===========================================================================
Get_T8_Identifiers:
* ---------------------------------------------------------------------------
* Look for the ROM_Offset identifier, 0xFD, get the offset address
*
		move.b	#ROM_Offset,d4			* Search for ROM_Offset identifier
		jsr 	(Get_T8_Identifier,pc).w
		bne	Identifier_Error			* Identifier error
		move.l	d2,d5					* Store first address for checksum
*										* calculation
* ---------------------------------------------------------------------------
* Look for the T8 Code_End identifier, 0xFC, get the Code End address
*
		move.b	#T8_Code_End,d4			* Search for Code_End identifier
		jsr 	(Get_T8_Identifier,pc).w
		bne	Identifier_Error			* Identifier error
		move.l	d2,d6					* Store last address for checksum
*										* calculation
* ---------------------------------------------------------------------------
* Look for the Checksum identifier, 0xFB, get the stored checksum
*
		move.b	#FB_Checksum,d4			* Search for FB Checksum identifier
		jsr 	(Get_T8_Identifier,pc).w
		bne	Identifier_Error			* Identifier error
		move.l	d2,d7					* Copy stored T8 Checksum
* ---------------------------------------------------------------------------
		jsr 	(Show_Stored_Checksum,pc).w
		jsr 	(Show_Csum_Calc_Range,pc).w
* ---------------------------------------------------------------------------
* Calculate T8 Checksum
*
		move.l	d5,d2
		move.l	d6,d3
		cmp.l	d2,d3					* Check if Code_End is before
*										* ROM_Offset !!!
		bls.b	Identifier_Error
* ---------------------------------------------------------------------------
* Some T8 ECUs store a BYTE checksum, others use LONG.
*
* Try both methods, BYTE first:
		jsr 	(Calculate_BYTE_Checksum,pc).w
		cmp.l	d0,d7
		beq.b	Show_Checksum
		and.l	#$FFFFFFFC,d3			* Make sure d3 is aligned to a LONG
* Try LONG if BYTE checksum fails
		jsr 	(Calculate_LONG_Checksum,pc).w
		bra		Show_Checksum
* ===========================================================================
Show_Checksum:
		jsr 	(Show_Calc_Checksum,pc).w
		cmp.l	d2,d7
		beq.b	Checksums_Match
		moveq	#ERROR_Checksum,d2		* Error 8! Checksum does not match
		bra.b	End_Program
* ---------------------------------------------------------------------------
* Display end message
Checksums_Match:
		lea.l	(End_Msg,pc),a0			* Show Checksums match message
		moveq	#BD_PUTS,d0				* BD32 display string function call
		bgnd
		clr.l	d2						* No errors
		bra.b	Leave_Resident_Driver	* Check if file is open
* ---------------------------------------------------------------------------
Identifier_Error:
		moveq	#ERROR_Header,d2		* Error 7! Could not find BIN Header
End_Program:
Leave_Resident_Driver:
		move.l	d2,d1					* Exit code, !=0 is an error
		moveq	#BD_QUIT,d0				* Finished
		bgnd
* ===========================================================================
* =============== local subroutines =========================================
* ===========================================================================
Show_Stored_Checksum:
		lea.l	(Stored_Msg_Pt2,pc),a0
		move.l	d7,d2					* Checksum value stored in FLASH
		jsr 	(long2ascii,pc).w
		lea.l	(Stored_Msg_Pt1,pc),a0	* Show checksum stored in FLASH
		moveq	#BD_PUTS,d0				* BD32 display string function call
		bgnd
		rts
* ---------------------------------------------------------------------------
Show_Csum_Calc_Range:
		lea.l	(Range_Msg_Pt2,pc),a0
		move.l	d5,d2					* First address for checksum
*										* calculation
		jsr 	(hex2ascii,pc).w
		addq	#$1,a0	
		move.l	d6,d2					* Last address for checksum
*										* calculation
		jsr 	(hex2ascii,pc).w
		lea.l	(Range_Msg_Pt1,pc),a0	* Show FLASH address range for
*										* calculation
		moveq	#BD_PUTS,d0				* BD32 display string function call
		bgnd
		rts
* ---------------------------------------------------------------------------
Show_Calc_Checksum:
		lea.l	(Calcd_Msg_Pt2,pc),a0
		move.l	d0,d2					* Calculated checksum
		jsr 	(long2ascii,pc).w
		lea.l	(Calcd_Msg_Pt1,pc),a0	* Show calculated checksum message
		moveq	#BD_PUTS,d0				* BD32 display string function call
		bgnd
		rts
*	END
