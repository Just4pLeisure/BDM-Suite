* =============== S U B	R O U T	I N E =======================================
* ===========================================================================
* =============== hex2ascii =================================================
* ===========================================================================
*
* @brief		Puts a 4 to 32-bit value into a string to be displayed later.
*				The value is presented in a 'long' 32 bit value (8 hex
*				digits)
*
*				The subroutine processes 8 < n < 1 (d3 + 1) digits
*				d2 must be rotated left by 4 * (8 - n) bits before calling
*
* @param		d2			Holds hex value to be put in a string
*							Must be present before calling hex2ascii
* @param		d3			Holds (number of digits - 1) to put in a string
*							Must be present before calling hex2ascii
* @param		a0			Holds hex value message string address
*							Must be present before calling hex2ascii
*
* @registers	d0			Used by BD32 function call - PUTS function code
*				d2			Holds hex value, is changed by calculation
*				d3			Holds a count of HEX digits to put in string
*				d4			Holds hex digit for ASCII lookup in Char_Tab
*
*				a0			Holds ECU message string addresses
*
* @return		(a0 - n)	6 digit HEX number as ASCII in string
*
* ===========================================================================
* Created by Sophie Dexter
* Version 1.0
* 17-Jul-2012
* ===========================================================================
*
		EVEN
*
Character_Array		dc.b	'0123456789ABCDEF'
*
* ===========================================================================
*
		EVEN
*
hex2ascii:
		rol.l	#4,d2
		move.b	d2,d4
		andi.l	#$0F,d4
		move.b	Character_Array(pc,d4),(a0)+
		dbra	d3,hex2ascii
		rts
*
* ===========================================================================
* =============== End of hex2ascii ==========================================
* ===========================================================================
