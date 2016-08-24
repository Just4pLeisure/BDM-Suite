* =============== S U B	R O U T	I N E =======================================
* ===========================================================================
* =============== Erase_FLASH_Chips =========================================
* ===========================================================================
*
* @brief		Erase FLASH chip(s) in the ECU using appropriate algorithms
*				Exits Driver program if erasing FLASH chip(s) fails
*
* @param		FLASH_Size	Size of FLASH chip(s) in Bytes
* @param		FLASH_Type	0=?, 1=28F, 2=29F 8bit, 3=29F 16bit, 4=29C				
*
* @registers	d0			varied uses
*				d1			varied uses
*				d2			varied uses
*				d5			varied uses
*
*				a0			Used for BD32 function calls
*
* @return		d0			SUCCESS / FAILURE
* @return		d6			0x5555 Part of 29Fxxx unlock sequence
* @return		d7			0xAAAA Part of 29Fxxx unlock sequence
*
* @return		a5			T5.x FLASH start address (always 0x000000)
*							0x5554 (0x2AAA*2) 29Fxxx unlock address
* @return		a6			0xAAAA (0x5555*2) 29Fxxx unlock address
*
* ===========================================================================
* Created by Sophie Dexter
* Version 1.0
* 17-Jul-2012
* ===========================================================================
*
		EVEN
*
Erase_Msg		dc.b	'Erasing FLASH chips',$0D,$0A,0
*
* ===========================================================================
*
		EVEN
*
Erase_FLASH_Chips:
		lea.l	(Erase_Msg,pc),a0
		moveq	#BD_PUTS,d0	function call
		bgnd
*
* ===========================================================================
* =============== Work out which type of FLASH chips are fitted =============
* ===========================================================================
*
*	d0 - used as temporary storage
*	d1 - used for FLASH type: 0=?, 1=28F, 2=29F 8bit, 3=29F 16bit, 4=29C
*		 and to return an error value if the FlASH isn't unrecognised
*	d2 - used for FLASH size
*	d6 - 0x5555 1st part of FLASH chip unlock sequence
*	d7 - 0xAAAA 2nd part of FLASH chip unlock sequence
*
*	a5 - used for T5.x FLASH start address (always 0x000000)
*   a5 - 0x5554 (0x2AAA*2) 1st FLASH chip unlock address
*	a6 - 0xAAAA (0x5555*2) 2nd FLASH chip unlock address
*
* ===========================================================================
*
* Pre-load registers with values used in 28Fxxx erase and programming sequences
		clr.l	d0
		move.l	d0,a5
* Prepare to work out type of FLASH chip(s)
		move.b	(FLASH_Type,pc),d1
		move.l	(FLASH_Size,pc),d2		* Needed for T5.x
* Check FLASH chips type to use correct erase algorithm
		cmpi.b	#1,d1					* 28F512/010
		beq.b	Erase_28F512
* Pre-load registers with values used in 29Fxxx erase and programming sequences
		move.l	#$5555,d6
		move.l	#$AAAA,d7
		movea.l	d6,a5					* $2AAA*2 == $5554
		subq.l	#1,a5					* now  a3 == $5554
		movea.l	d7,a6					* $5555*2 == $AAAA
* Check for 29Fxxx FLASH chips
		cmpi.b	#2,d1					* 29F010 / 39F010
		beq.w	Erase_29F_8BIT
		cmpi.b	#3,d1					* AMD 29F400T/BL802C 
		beq.w	Erase_29F_16BIT
		cmpi.b	#4,d1					* Atmel 29Cxxx
		beq.b	Erase_29C512
* ERROR! FLASH chips not recocgnised if here
		bra.w	Erase_Failed
*
* ===========================================================================
* =============== Erase_Atmel ===============================================
* ===========================================================================
* 
* Atmel 29C010 FLASH chips don't need to be erased, simply return
*
* ===========================================================================
*
Erase_29C512:
Erase_29C010:
		bra.w	Erase_Failed			* Branch back to where Flash_Prog ends
*
* ===========================================================================
* =============== End of Erase_Atmel ========================================
* ===========================================================================
*
* ===========================================================================
* =============== Erase 28F512/010 FLASH chip types =========================
* ===========================================================================
*
Erase_28F512:
Erase_28F010:
*
* ===========================================================================
* =============== Fill 28F FLASH with zeroes ================================
* ===========================================================================
*
* Fills AMD/Intel/CSI 28F512/28F010 chips with 0x00 prior to erasing them
*
* FLASH is read before writing 0x00, and writing 0x00 is skipped if the
* FLASH already has that value.
*
* ===========================================================================
*
*	d0 - used to store a copy of the number of bytes to program to zero
*	d1 - used for delay loop counters
*	d2 - used to store/countdown the number of bytes to program to zero
*	d5 - used for programming retry counter
*
*	a5 - used for T5.x FLASH_start_address (always 0x000000)
*
* ===========================================================================
*
Flash_Fill_With_Zero:
		move.l	d2,d0					* Store a copy of FLASH size
		move.w	#F28_Reset_Cmd,(a5)		* Reset FLASH chips
		move.w	#F28_Reset_Cmd,(a5)		* by writing FF twice
* ---------------------------------------------------------------------------
Program_A_Zero:
		clr.w	(a5)					* Put_FLASH_In_Read_Mode
		tst.b	-1(a5,d2.l)				* Check if zero
		beq.b	Already_Zero
		moveq	#F28_Write_Count,d5		* Allowed 25 retries to	program
Flash_Zero_Loop:
		move.b	#F28_Program_Cmd,-1(a5,d2.l)	* FLASH program command
		clr.b	-1(a5,d2.l)				* Write	0x00 data to flash address
		moveq 	#Count_10us,d1
Zero_Program_10us_Delay:
		nop
		dbra	d1,Zero_Program_10us_Delay
		move.b	#F28_Verify_Cmd,-1(a5,d2.l)		* FLASH verify command
		moveq 	#Count_6us,d1
Zero_Verify_6us_Delay:
		nop
		dbra	d1,Zero_Verify_6us_Delay
		tst.b	-1(a5,d2.l)				* Check if zero
		bne.b	Zero_Not_Programmed
* ---------------------------------------------------------------------------
Already_Zero:
		subq.l	#1,d2					* decrease counter for next byte
		bne.b	Program_A_Zero
		bra.b	Zeroing_Done
* ---------------------------------------------------------------------------
Zero_Not_Programmed:
		subq.w	#1,d5					* Reduce count of retries reamining
		bne.b	Flash_Zero_Loop			* Retry if some retries left
* ---------------------------------------------------------------------------
Zeroing_Done:		
		clr.w	(a5)					* Put_FLASH_In_Read_Mode
		tst.w	(a5)					* Only needed for AMD,
*										* does no harm for Intel
		tst.b	d5						* Error if d5 = 0, 25 attempts used
		bne.b	Erase_28F_FLASH			* OK to erase if < 25 attempts used
		bra.w	Erase_Failed
*
* ===========================================================================
* =============== End of Fill 28F FLASH with zeroes =========================
* ===========================================================================
*
* ===========================================================================
* =============== Erase_28F_FLASH ===========================================
* ===========================================================================
*
*	d0 - used to store 0xFF to check that bytes are erased
*		 also used to retrieve a copy of the number of bytes to check
*	d1 - used for delay loop counters
*	d2 - used to countdown the number of bytes to check have been erased
*	d5 - used for erase retry countdown counters
*		 store 2 16-bit numbers in 32-bit register d5 and use swap
*		 instruction to keep individual counters for each FLASH chip
*
*	a5 - used for T5.x FLASH_start_address (always 0x000000)
*
* ===========================================================================
*
Erase_28F_FLASH:
		move.l	d0,d2					* Retrieve the copy of FLASH size
		st		d0						* FLASH is 0xFF when erased
		move.l	#$03E803E8,d5			* Maximum 1000 (0x3E8) Erase attempts
* ---------------------------------------------------------------------------
Erase_Flash:
		move.b	#F28_Erase_Cmd,-1(a5,d2.l)		* FLASH erase command
		move.b	#F28_Erase_Cmd,-1(a5,d2.l)		* FLASH erase command
		move.w	#Count_10ms,d1
Wait_10ms_For_Erase:
		nop
		dbra	d1,Wait_10ms_For_Erase	* Delay Loop
* ---------------------------------------------------------------------------
Verify_Erased:
		move.b	#F28_Era_Vfy_Cmd,-1(a5,d2.l)	* FLASH erase verify command
		moveq	#Count_6us,d1
Erase_Verify_6us_Delay:
		nop
		dbra	d1,Erase_Verify_6us_Delay
		cmp.b	-1(a5,d2.l),d0			* Verify FLASH Address is FF (Erased)
		bne.b	Byte_Not_Erased
* --------------- Byte is erased if here so move on to check next address ---
		swap	d5						* Swap 16-bit erase attempt counts
*										* for next address (odd/even chip)
		subq.l	#1,d2					* Point to the next address
*										* Have all locations been checked ?
*										* d2 initially =0x2/40000 for T5.2/5 
		bne.b	Verify_Erased			* Check next if not all done
		bra.b	Erasing_Done
* ---------------------------------------------------------------------------
Byte_Not_Erased:
		subq.w	#1,d5					* Reduce count of number of attempts
*										* remaining for this FLASH chip
		bne.b	Erase_Flash				* Try again if less than 1000 so far
* ---------------------------------------------------------------------------
Erasing_Done:
		clr.w	(a5)					* Put_FLASH_In_Read_Mode
		tst.w	(a5)					* Only needed for AMD,
*										* does no harm for Intel
		tst.w	d5						* Erase was ok if < 1000
		beq.w	Erase_Failed			* All retry attempts used up so fail
		bra.w	Erase_OK				* Erase_OK :-)
*
* ===========================================================================
* =============== End of Erase_28F_FLASH ====================================
* ===========================================================================
*
* ===========================================================================
* =============== Erase_AMD_29F =============================================
* ===========================================================================
*
* AMD 29F010 chips have an embedded erase algorithm
* Erase is checked by reading data to see if correct
* Bit DQ7 is inverted until erase algorithm is complete
* Bit DQ5 goes high if the erase process fails and a timeout error has occured
* Because DQ7 and DQ5 can change independently bit DQ7 needs to be checked
* again (with a second read of the FLASH chip) just in case a false timeout
* is indicated
*
*	d0 - used to select between FLASH chip1 and chip2
*	d5 - used to check if erasing was OK or if there was a timeout error
*		 also used as temporary storage
*	d6 - 0x5555 1st part of FLASH chip unlock sequence (already present)
*	d7 - 0xAAAA 2nd part of FLASH chip unlock sequence (already present)
*
*	a5 - 0x5554 (0x2AAA*2) 1st FLASH chip unlock address (already present) 
*	a6 - 0xAAAA (0x5555*2) 2nd FLASH chip unlock address (already present)
*
* ===========================================================================
*
Erase_29F010:
Erase_29F_8BIT:
		moveq	#1,d0
		clr.l	d3						* offset to 'Spinner' character
Erase_29F:
		move.b	d7,(a6,d0.l)			*
		move.b	d6,(a5,d0.l)			*
		move.b	#F29_Unlock_Cmd,(a6,d0.l)		* unlock FLASH sequence
		move.b	d7,(a6,d0.l)			*
		move.b	d6,(a5,d0.l)			*
		move.b	#F29_Erase_Cmd,(a6,d0.l)		* erase FLASH sequence
Erase_29F_Verify:
*
* display a spinning symbol to indicate activty
*
		move.l	d0,d5			* save a copy of d0 (odd or even chip)
		jsr		(Spinner,pc).w
		move.l	d5,d0			* restore d0 (odd or even chip)
* ---------------------------------------------------------------------------
		move.b	(d0.l),d5				* read FLASH
		btst	#F29_Ready_Bit,d5		* Bit 7 is 0 until erased then is 1
		bne.b	Erase_29F_OK
		btst	#F29_Timeout_Bit,d5		* Bit 5 is 1 if erase times out
		beq.b	Erase_29F_Verify
		move.b	(d0.l),d5				* re-read FLASH !
		btst	#F29_Ready_Bit,d5		* check for possible 'false' timeout
		bne.b	Erase_29F_OK
		move.b	d7,(a6,d0.l)			* Erasing chip timed out if here
		move.b	d6,(a5,d0.l)			* Have to reset FLASH chip when...
		move.b	#F29_Reset_Cmd,(a6,d0.l)		* ...erasing fails
		bra.w	Erase_Failed			* Go back to Find_Flash... Fails
Erase_29F_OK:
		subq.l	#1,d0
		beq.b	Erase_29F				* Erase Chip OK so see if next chip
		bra.w	Erase_OK				* Erase_OK :-)
*
* ===========================================================================
* =============== End of Erase_AMD_29F ======================================
* ===========================================================================
*
* ===========================================================================
* =============== Erase_AMD_29F_16BIT =======================================
* ===========================================================================
*
* AMD 29F400 and 29BL802C chips have an embedded erase algorithm
* Erase is checked by reading data to see if correct
* Bit DQ7 is inverted until erase algorithm is complete
* Bit DQ5 goes high if the erase process fails and a timeout error has occured
* Because DQ7 and DQ5 can change independently bit DQ7 needs to be checked
* again (with a second read of the FLASH chip) just in case a false timeout
* is indicated
*
*	d5 - used to check for a erasing ok or if there was a timeout error 
*	d6 - 0x5555 1st part of FLASH chip unlock sequence (already present)
*	d7 - 0xAAAA 2nd part of FLASH chip unlock sequence (already present)
*
*	a5 - 0x5554 (0x2AAA*2) 1st FLASH chip unlock address (already present) 
*	a6 - 0xAAAA (0x5555*2) 2nd FLASH chip unlock address (already present)
*
* ===========================================================================
*
Erase_29F400:
Erase_29FBL802:
Erase_29F_16BIT:
		clr.l	d3						* offset to 'Spinner' character
		move.w	d7,(a6)					*
		move.w	d6,(a5)					*
		move.w	#F29_Unlock_Cmd,(a6)	* unlock FLASH sequence
		move.w	d7,(a6)					*
		move.w	d6,(a5)					*
		move.w	#F29_Erase_Cmd,(a6)		* erase FLASH sequence
Erase_29F_16_Verify:
* display a spinning symbol to indicate activty
		jsr		(Spinner,pc).w
* ---------------------------------------------------------------------------
		move.w	(a5),d5					* read FLASH
		btst	#F29_Ready_Bit,d5		* Bit 7 is 0 until erased then is 1
		bne.b	Erase_29F_16_OK
		btst	#F29_Timeout_Bit,d5		* Bit 5 is 1 if erase times out
		beq.b	Erase_29F_16_Verify
		move.w	(a5),d5					* re-read FLASH !
		btst	#F29_Ready_Bit,d5		* check for possible 'false' timeout
		bne.b	Erase_29F_16_OK
		move.w	d7,(a6)					* Erasing chip timed out if here
		move.w	d6,(a5)					* Have to reset FLASH chip when...
		move.w	#F29_Reset_Cmd,(a6)		* ...erasing fails
		bra.b	Erase_Failed			* Go back to Find_Flash... Fails
Erase_29F_16_OK:
*		bra.w	Erase_OK				* Erase_OK :-)
*
* ===========================================================================
* =============== End of Erase_AMD_29F_16BIT ================================
* ===========================================================================
*
* ===========================================================================
*	d0 - used to return pass/fail
* ===========================================================================
*	
Erase_OK:
* Erase routines return here if erased OK
		clr.l	d0						* 0 means FLASH was erased
		bra.b	Erase_Return
Erase_Failed:
* Erase routines return here if Erase FAILED
		moveq	#1,d0					* 1 means FAILED to erase FLASH
Erase_Return:
		rts
*
* ===========================================================================
* =============== End of Erase_FLASH_Chips ==================================
* ===========================================================================
