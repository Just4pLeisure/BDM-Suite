* =============== S U B	R O U T	I N E =======================================
* ===========================================================================
* =============== Spinner ===================================================
* ===========================================================================
*
* @brief		Prints one character of a spinning symbol.
*				The 'Spinner' is used to show that something is happening.
*
* @param		d3			offset for spinner character in Spinner_Tab
*							Must be preserved between calls
*
* @registers	d0			used by BD32 function call - PUTS function code
*				d3			Holds offset for spinner character in Spinner_Tab
*
*				a0			used by BD32 function call - Address of Spinner_Msg
*
* @return		d3			Holds offset for spinner character in Spinner_Tab
*
* ===========================================================================
* Created by Sophie Dexter
* Version 1.0
* 17-Jul-2012
* ===========================================================================
*
		EVEN
*
Spinner_Array	dc.b	'|/-\'
Spinner_Message	dc.b	'*',$0D,$0
*
* ===========================================================================
*
		EVEN
*
Spinner:
		andi.b	#$03,d3					* make sure that value in d3 is OK
		lea.l	(Spinner_Message,pc),a0
		move.b	Spinner_Array(pc,d3),(a0)
		moveq	#BD_PUTS,d0				* BD32 display string function call
		bgnd							* print one symbol of spinning icon
		addq	#1,d3					* point to next spinner character
		rts

* ===========================================================================
* =============== End of Spinner ============================================
* ===========================================================================
