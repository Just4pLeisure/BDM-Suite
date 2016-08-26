* =============== P R O	G R A M =============================================
* ===========================================================================
* =============== WAIT ----==================================================
* ===========================================================================
*
* A Target-Resident Command Driver program for use with Scott Howard's BD32
* Background mode Debuggger (BDM) for Motorola CPU32 processor cores used in
* SAAB Engine Control Units (ECU)
*
* This program provides simply waits for a key to be pressed. 
*
* ===========================================================================
*
* How to use:
*   wait     // Wait for a key to be pressed, return to BD32 when it is
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
*		EVEN
* ---------------------------------------------------------------------------
START		dc.l	PROG_START	
* ---------------------------------------------------------------------------
Start_Msg	dc.b	'Press any key to continue',$0D,$0A,$0
*
* ===========================================================================
*
* Equates used to improve readability
*
		EVEN
*
		include ipd.inc
* ---------------------------------------------------------------------------
*
		EVEN
*
PROG_START:
		lea.l	(Start_Msg,pc),a0		* Show what the program does
		moveq	#BD_PUTS,d0				* BD32 display string function call
		bgnd
* ---------------------------------------------------------------------------
		moveq	#BD_GETCHAR,d0			* Wait for a key to be pressed
		bgnd
* ---------------------------------------------------------------------------
		clr.l	d2						* No errors
		moveq	#BD_QUIT,d0				* Finished
		bgnd
* ---------------------------------------------------------------------------
	END
