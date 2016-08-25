* =============== S U B	R O U T	I N E =======================================
* ===========================================================================
* =============== Show_ECU_Type =============================================
* ===========================================================================
*
* @brief		Displays a message indicating the type of ECU based on the 
*				size of the FLASH chip(s)
*
*				A type of calculation is used and the Carry bit checked.
*				I have chosen to do it this way because it results in 
*				smaller code size.
*
* @param		FLASH_Size	Size of FLASH chip(s) in Bytes
*
* @registers	d0			Holds FLASH size during calculation
*				d1			Holds ASCII characters for ECU message
*
*				a0			Holds ECU message string addresses
*
* @return		VOID		No return values
*
* ===========================================================================
* Created by Sophie Dexter
* Version 1.0
* 17-Jul-2012
* ===========================================================================
* Version 1.1
* 26-May-2013
*
* Remove check of FLASH size because script would have failed before getting
* here.
* ===========================================================================
*
		EVEN
*
ECU_Type_Msg	dc.b	'Found a T'
ECU_Msg			dc.b	'  ',$0D,$0A,$0
*
* ===========================================================================
*
		EVEN
*
Show_ECU_Type:
		move.l	(FLASH_Size,pc),d0		* d0 = 0x20000/40000/80000/100000
*										* or 0x00000000 if unknown !!!
		swap	d0						* d0 = 0x02/04/08/10
		lea.l	(ECU_Msg,pc),a0
		moveq	#'8',d1					* '8' - for T8 ECU
		rol.b	#$4,d0					* d0 = 0x01 - carry set /80/40/20
		bcs.b	Show_ECU_Type_Msg		* Trionic 8
		moveq	#'7',d1					* '7' - for T7 ECU
		rol.b	#$1,d0					* d0 = 0x01 - carry set /80/40
		bcs.b	Show_ECU_Type_Msg		* Trionic 7
		moveq	#'5',d1					* Display '5.' for T5.x ECU
		move.b	d1,(a0)+				* store the character
		moveq	#'.',d1
		move.b	d1,(a0)+				* store the character
		moveq	#'5',d1					* '5' - for T5.5 ECU
		rol.b	#$1,d0					* d0 = 0x01 - carry set /80
		bcs.b	Show_ECU_Type_Msg		* Trionic 5.5
		moveq	#'2',d1					* '2' - for T5.2 ECU
Show_ECU_Type_Msg:
		move.b	d1,(a0)					* store the character
		lea.l	(ECU_Type_Msg,pc),a0
		moveq	#BD_PUTS,d0				* BD32 display string function call
		bgnd
		rts
*		
* ===========================================================================
* =============== End of Show_ECU_Type ======================================
* ===========================================================================
