* =============== S U B	R O U T	I N E =======================================
* ===========================================================================
* =============== Flash_Programming =========================================
* ===========================================================================
*
* @brief		Program FLASH chip(s) in the ECU using appropriate algorithms
*				Exits Driver program if erasing FLASH chip(s) fails
*
* @param		FLASH_Type	0=?, 1=28F, 2=29F 8bit, 3=29F 16bit, 4=29C				
* @param		d6			0x5555 Part of 29Fxxx unlock sequence
* @param		d7			0xAAAA Part of 29Fxxx unlock sequence
*
* @param		a1			is the first FLASH address to program
* @param		a5			T5.x FLASH start address (always 0x000000)
*							0x5554 (0x2AAA*2) 29Fxxx unlock address
* @param		a6			0xAAAA (0x5555*2) 29Fxxx unlock address
*
* @registers	d0			varied uses
*				d1			varied uses
*				d2			varied uses
*				d3			varied uses
*				d4			varied uses
*				d5			varied uses
*
*				a0			Used for BD32 function calls
*				a3			is the address of the FLASH_Write_Buffer
*				a4			is the first FLASH address to program )add to d2) 
*
* @return		d0			SUCCESS / FAILURE
* @return		d6			0x5555 Part of 29Fxxx unlock sequence
* @return		d7			0xAAAA Part of 29Fxxx unlock sequence
*
* @param		a1			is the first FLASH address programmed
* @return		a5			T5.x FLASH start address (always 0x000000)
*							0x5554 (0x2AAA*2) 29Fxxx unlock address
* @return		a6			0xAAAA (0x5555*2) 29Fxxx unlock address
*
* ===========================================================================
* Created by Sophie Dexter
* Version 1.0
* 17-Jul-2012
* ===========================================================================
* Version 1.1
* 26-May-2013
*
* Clear d7 register on failure for correct BD32 error return code
*
* Removed a left over debug message
* ===========================================================================
* Version 1.2
* 28-Nov-2013
*
* Added support for Atmel 29Cxxx FLASH, Atmel chips no longer cause failure
*
* Simplified logic for selecting FLASH algorithm
*
* Use registers to store more things which in turn helps reduce code size by
* avoiding repeated operations. This places a requirement that greater care
* is needed to keep track of and preserve register contents.
*
* Other little tricks to reduce code size
* ===========================================================================
*
		EVEN
*
Flash_Programming:
*
* ===========================================================================
* =============== Initialise pointers into the FLASH chips and Buffer =======
* ===========================================================================
*
*	a1 - is the first FLASH address to program
*	a3 - is the address of the FLASH_Write_Buffer
*	a4 - is the first FLASH address to program (add to d2)
*
* ===========================================================================
*
		lea.l 	(BUFFER,pc),a3			* FLASH Write Buffer
		move.l	a1,a4					* Where to start programming in FLASH
		move.l	#BUFF_SIZE,d2			* Get number of bytes to program
*
* ===========================================================================
* =============== Work out which type of FLASH chips are fitted =============
* ===========================================================================
*
*	d1 - used for FLASH type
*	d2 - used to store number of bytes to program from buffer
*
* ===========================================================================
*
		move.b	(FLASH_Type,pc),d1
		subq.b	#1,d1					* 28F512/010
		beq.b	Flash_28F
		subq.b	#1,d1					* AMD 29F010
		beq.b	Flash_29F
		subq.b	#1,d1					* AMD 29F400T/BL802C 
		beq.w	Flash_29F400
		subq.b	#1,d1					* Atmel 29C512/010
		beq.w	Flash_29C
		bra.w	Programming_Error	
*
* ===========================================================================
* =============== Program 28F512/010 FLASH chip types =======================
* ===========================================================================
*
*	d0 - used to get the bytes for programming from the FLASH Write Buffer
*	d1 - used for delay loop counters and testing which FLASH chip type
*	d2 - used to store/countdown the number of bytes to program
*	d5 - used for programming retry counter
*
*	a3 - is the address of the FLASH_Write_Buffer
*	a4 - is the first FLASH address to program (add to d2)
*	a5 - used for Flash_Start_Address (already there)
*		 either 0x40000 for T5.5 or 0x60000Erase_FLASH_Chips for T5.2
*
* note -1 (a4,d2.l) FLASHBuffer because using count of bytes in d2
*
* ===========================================================================
*
Flash_28F:
Flash_28F_Another:
		move.b	-1(a3,d2.l),d0			* Get byte to be programmed into d0
		cmpi.b	#$FF,d0					* Check if data is 0xFF
		beq.b	Already_0xFF			* Don't need to program 0xFF
*										* because erased FLASH is 0xFF
		moveq	#F28_Write_Count,d5		* Allowed 25 retries to	program
* ---------------------------------------------------------------------------
Flash_Program_Loop:
		move.b	#F28_Program_Cmd,-1(a4,d2.l)	* FLASH program command
		move.b	d0,-1(a4,d2.l)			* Write	data to	flash address
		moveq 	#Count_10us,d1
Program_10us_Delay:
		nop
		dbra	d1,Program_10us_Delay
		move.b	#F28_Verify_Cmd,-1(a4,d2.l)		* FLASH verify command
		moveq 	#Count_6us,d1
Verify_6us_Delay:
		nop
		dbra	d1,Verify_6us_Delay
		cmp.b	-1(a4,d2.l),d0			* check that FLASH value is correct
		bne.b	Byte_Not_Programmed
* ---------------------------------------------------------------------------
Already_0xFF:
		subq.l	#1,d2					* Are we done yet?
		bne.b	Flash_28F_Another
		bra.b	Programming_Done
* ---------------------------------------------------------------------------
Byte_Not_Programmed:
		subq.b	#1,d5					* 25 retries to	program
		bne.b	Flash_Program_Loop		* Retry if some retries left		
* ---------------------------------------------------------------------------
Programming_Done:
		clr.w	(a5)					* Put_FLASH_In_Read_Mode
		tst.w	(a5)					* Only needed for AMD,
*										* does no harm for Intel
		tst.b	d5						* Error if d5 = 0, 25 attempts FAILED
		beq.w	Programming_Error		* Go back to where Flash_Prog fails
		bra.w	Programming_OK			* Go back to where Flash_Prog OK
* ===========================================================================
* =============== End of Program 28F512/010 FLASH chip types ================
* ===========================================================================
*
* ===========================================================================
* =============== Program AMD 29F010 FLASH chip types =======================
* ===========================================================================
*
*	d0 - used to select between FLASH chip1 and chip2
*	d2 - count of number of bytes - add to -1(a4) to get address to program
*	d3 - byte to program into FLASH
*	d4 - used for checking that FLASH is programmed
*	d5 - used to check for a programming timeout error 
*	d6 - 0x5555 Part of 29Fxxx unlock sequence
*	d7 - 0xAAAA Part of 29Fxxx unlock sequence
*
*	a3 - is the address of the FLASH_Write_Buffer
*	a4 - is the first FLASH address to program (add to d2)
*	a5 - 0x5554 (0x2AAA*2) 29Fxxx unlock address
*	a6 - 0xAAAA (0x5555*2) 29Fxxx unlock address
*
*============================================================================
*
Flash_29F:
		move.l	a4,d0					* work out if chip 1 or 2...
		add.l	d2,d0					* ...by adding address and byte count
		and.l	#1,d0					* ...to see if odd or even 
Flash_29F_Another:
		bchg	#0,d0					* swap between chip 1 and 2 for each
		move.b	-1(a3,d2.l),d3			* get a byte to program
		cmpi.b	#$FF,d3					* Check if data is 0xFF
		beq.b	Flash_29F_OK			* Don't need to program 0xFF
*										* because erased FLASH is 0xFF
		move.b	d7,(a6,d0.l)			* Program FLASH sequence
		move.b	d6,(a5,d0.l)			*
		move.b	#F29_Program_Cmd,(a6,d0.l)		* Program FLASH command
		move.b	d3,-1(a4,d2.l)			* Write	data to	flash address
		and.b	#F29_Ready_Mask,d3		* Isolate Bit 7 for testing
Flash_29F_Verify:
		move.b	-1(a4,d2.l),d4			* Read back from FLASH
		move.b	d4,d5					* store a copy to test for timeout
		and.b	#F29_Ready_Mask,d4
		cmp.b	d3,d4					* Test to see if Bit 7 matches
		beq.b	Flash_29F_OK
		btst	#F29_Timeout_Bit,d5		* Test to see if timeout
		beq.b	Flash_29F_Verify		* Not timed out so check again
		move.b	-1(a4,d2.l),d4			* Read back from FLASH
		and.b	#F29_Ready_Mask,d4
		cmp.b	d3,d4					* Test to see if Bit 7 matches
		beq.b	Flash_29F_OK
		move.b	d7,(a6,d0.l)			* Programming timed out if here
		move.b	d6,(a5,d0.l)			* Have to reset FLASH chip when...
		move.b	#F29_Reset_Cmd,(a6,d0.l)		* ...programming fails
		bra.w	Programming_Error		* Go back to where Flash_Prog fails
* ---------------------------------------------------------------------------
Flash_29F_OK:
		subq.l	#1,d2
		bne.b	Flash_29F_Another		* OK so program another one
		bra.b	Programming_OK
*
* ===========================================================================
* =============== End of Program AMD 29F010 FLASH chip types ================
* ===========================================================================
*
* ===========================================================================
* =============== Program AMD 29F400 FLASH chip types =======================
* ===========================================================================
*
*	d2 - count of number of bytes - add to -1(a4) to get address to program
*	d3 - byte to program into FLASH
*	d4 - used for checking that FLASH is programmed
*	d5 - used to check for a programming timeout error 
*	d6 - 0x5555 Part of 29Fxxx unlock sequence
*	d7 - 0xAAAA Part of 29Fxxx unlock sequence
*
*	a3 - is the address of the FLASH_Write_Buffer
*	a4 - is the first FLASH address to program (add to d2)
*	a5 - 0x5554 (0x2AAA*2) 29Fxxx unlock address
*	a6 - 0xAAAA (0x5555*2) 29Fxxx unlock address
*
*============================================================================
*
Flash_29F400:
Flash_29F400_Another:
		move.w	-2(a3,d2.l),d3			* get a byte to program
		cmpi.w	#$FFFF,d3				* Check if data is 0xFFFF
		beq.b	Flash_29F400_OK			* Don't need to program 0xFFFF
*										* because erased FLASH is 0xFFFF
		move.w	d7,(a6)					*
		move.w	d6,(a5)					*
		move.w	#F29_Program_Cmd,(a6)	* Program FLASH sequence
		move.w	d3,-2(a4,d2.l)			* Write	data to	flash address
		and.w	#F29_Ready_Mask,d3		* Isolate Bit 7 for testing
Flash_29F400_Verify:
		move.w	-2(a4,d2.l),d4			* Read back from FLASH
		move.w	d4,d5					* store a copy to test for timeout
		and.w	#F29_Ready_Mask,d4
		cmp.w	d3,d4					* Test to see if Bit 7 matches
		beq.b	Flash_29F400_OK
		btst	#5,d5					* Test to see if timeout
		beq.b	Flash_29F400_Verify		* Not timed out so check again
		move.w	-2(a4,d2.l),d4			* Read back from FLASH
		and.w	#F29_Ready_Mask,d4
		cmp.w	d3,d4					* Test to see if Bit 7 matches
		beq.b	Flash_29F400_OK
		move.w	d7,(a6)					* Programming timed out if here
		move.w	d6,(a5)					* Have to reset FLASH chip when...
		move.w	#F29_Reset_Cmd,(a6)		* ...programming fails
		bra.b	Programming_Error		* Go back to where Flash_Prog fails
* ---------------------------------------------------------------------------
Flash_29F400_OK:
		subq.l	#2,d2
		bne.b	Flash_29F400_Another	* OK so program another one
		bra.b	Programming_OK
*
* ===========================================================================
* =============== End of Program AMD 29F400 FLASH chip types ================
* ===========================================================================
*
* ===========================================================================
* =============== Program Atmel 29C010 FLASH chip types =====================
* ===========================================================================
*
*	d1 - used for delay loop counters
*	d2 - count of number of bytes - add to -2(a4) to get address to program
*	d3 - used for checking that FLASH is programmed
*	d6 - 0x5555 Part of 29Fxxx unlock sequence
*	d7 - 0xAAAA Part of 29Fxxx unlock sequence
*
*	a3 - is the address of the FLASH_Write_Buffer
*	a4 - is the first FLASH address to program (add to d2)
*	a5 - 0x5554 (0x2AAA*2) 29Fxxx unlock address
*	a6 - 0xAAAA (0x5555*2) 29Fxxx unlock address
*
* ===========================================================================
*
Flash_29C:
Flash_29C_Sector:
		move.w	d7,(a6)			*
		move.w	d6,(a5)			*
		move.w	#$A0A0,(a6)		* Program FLASH sequence
Flash_29C_Another:
		move.w	-2(a3,d2.l),-2(a4,d2.l)	* get a word to program
		subq.l	#2,d2
		bne.b	Flash_29C_Another	* OK so program another one
* ---------------------------------------------------------------------------
* Wait 10ms (plus margin) for ATMEL programming algorithm to complete
		move.w	#Count_10ms,d1
Program_10ms_Delay:
		nop
		dbra	d1,Program_10ms_Delay
* ---------------------------------------------------------------------------
* Verify the sector just programmed
		move.w	#BUFF_SIZE,d2		* Get number of bytes to compare
Verify_29C_Sector:
Verify_29C_Another:
		move.w	-2(a3,d2.l),d3		* get a word to verify
		cmp.w	-2(a4,d2.l),d3		* Compare FLASH with Buffer
		bne.b	Programming_Error	* Branch to where Flash_Prog fails
		subq.l	#2,d2
		bne.b	Verify_29C_Another	* OK so check another one
*		bra.b	Programming_OK		* All Checked and OK
*
* ===========================================================================
* =============== End of Program Atmel 29C010 FLASH chip types ==============
* ===========================================================================
*
* ===========================================================================
*	d0 - used to return pass/fail
* ===========================================================================
*
Programming_OK:
		clr.l	d0
		bra.b	Programming_Return
* ---------------------------------------------------------------------------
Programming_Error:
		moveq	#1,d0
Programming_Return:
		rts
*
* ===========================================================================
* =============== End of Flash_Programming ==================================
* ===========================================================================
