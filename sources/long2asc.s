* =============== S U B	R O U T	I N E =======================================
* ===========================================================================
* =============== long2ascii ================================================
* ===========================================================================
*
* @brief		Puts a 32-bit value into a string to be displayed later.
*				The value is presented in a 'long' 32 bit value (8 hex
*				digits)
*
* @param		d2			Holds hex value to be put in a string
*							Must be present before calling long2ascii
* @param		a0			Holds hex value message string address
*							Must be present before calling long2ascii
*
* @registers	d0			Used by BD32 function call - PUTS function code
*				d2			Holds hex value, is changed by calculation
*				d3			Holds a count of HEX digits to put in string
*				d4			Holds hex digit for ASCII lookup in Char_Tab
*
*				a0			Holds ECU message string addresses
*
* @return		(a0 - 8)	6 digit HEX number as ASCII in string
*
* ===========================================================================
* Created by Sophie Dexter
* Version 1.1
* 26-May-2013
*
* A new addition to the 'Universal BDM scripts for Trionic'
* ===========================================================================
*
		EVEN
*
* Character_Array commented out because re-using the array in hex2ascii.s
*Character_Array		dc.b	'0123456789ABCDEF'
*
* ===========================================================================
*
		EVEN
*
long2ascii:
		moveq.l	#7,d3
		clr.l	d4
long2ascii_loop:
		rol.l	#4,d2
		move.b	d2,d4
		andi.b	#$0F,d4
		move.b	Character_Array(pc,d4),(a0)+
		dbra	d3,hex2ascii_loop
		rts
*
* ===========================================================================
* =============== End of long2ascii =========================================
* ===========================================================================
