* =============== S U B	R O U T	I N E =======================================
* ===========================================================================
* =============== Preparation ===============================================
* ===========================================================================
*
* @brief		Configures Chip Selects, sets the clock frequency, disables
*				the watchdog and enables the FLASH programming voltage in T5 
*				ECUs based on the type of CPU detected (MC68332 or MC68377)
*
* @param		VOID		No input parameters
*
* @registers	d0			Holds temporary values
*
*				a0			Holds CPU configuration register addresses
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
* T8 part uses PLL lock status, both a better method than using a delay and
* reduces code size.
* ===========================================================================
* Version 1.2
* 28-Nov-2013
*
* Add a delay to allow programming voltage to be ready which is needed by
* 28Fxxx FLASH chips in T5.x ECUs
* ===========================================================================
*
		EVEN
*
Preparation:
* Read MC68332/377 Module Control Register (SIMCR/MCR)
* and use the value to work out if ECU is a T5/7 or a T8
		movea.l	#$FFFA00,a0
		btst.b	#4,(a0)
		bne.b	prep_T8
prep_T5orT7:
* Set MC68332 to 16 MHz (actually 16.78 MHz) for all ECU types (SYNCR)
* The main reason for doing this is to make the delay loops the same
* so that 16 and 20 Mhz ECUs will work with the same values
		adda.w	#$4,a0					* A0 = 0x00FFFA04
		move.b	#$7F,(a0)+				* multiply by 512 = 16.78 MHz
Synthesiser_Lock_Flag:
		btst.b	#3,(a0)					* test VCO lock bit
		beq.b	Synthesiser_Lock_Flag
* Disable watchdog and monitors (SYPCR)
		adda.w	#$1C,a0					* A0 = 0x00FFFA21
		clr.b	(a0)
* Chip select pin assignments (CSPAR0)
		adda.w	#$23,a0					* A0 = 0x00FFFA44
		move.w	#$3FFF,(a0)
* Boot Chip select read only, one wait state (CSBARBT)
		adda.w	#$4,a0					* A0 = 0x00FFFA48
		moveq	#$7,d0
		move.w	d0,(a0)+				* Base Addr 0x0 1MByte block size,
*										* Upper Byte to CSOR1
		move.w	#$6870,(a0)		*
* Chip select 1 and 2 upper lower bytes, zero wait states
* (CSBAR1, CSOR1, CSBAR2, CSBAR2)
		adda.w	#$6,a0					* A0 = 0x00FFFA50
		move.w	d0,(a0)+				* Synchronous mode selected,
*										* Upper Byte to CSOR1
		move.w	#$3030,(a0)+			* Base Addr 0x0 1MByte block size,
*										* Upper Byte to CSOR1
		move.w	d0,(a0)+				* Synchronous mode selected,
*										* Lower Byte to CSOR2
		move.w	#$5030,(a0)				* Base Addr 0x0 1MByte block size,
*										* Lower Byte to CSOR2
* PQS Data - turn on VPPH (PORTQS)
* This enables a programming for 28Fxxx FLASH chips in T5.x ECUs
* PORTQS latches I/O data. Writes drive	pins defined as outputs. Reads return
* data present on the pins.
* To avoid driving undefined data, first write a byte to PORTQS, then
* configure DDRQS.
		adda.w	#$1BE,a0				* A0 = 0x00FFFC14
		moveq	#$40,d0
		move.w	d0,(a0)+				* PQS Data Register (PORTQS)
*										* PQS Data Direction output (DDRQS)
		move.w	d0,(a0)					* PQS Data Direction Register (DDRQS)
* ---------------------------------------------------------------------------
* Wait 10ms (plus margin) for programming voltage to be ready
		move.w	#Count_10ms,d0
Voltage_10ms_Delay:
		nop
		dbra	d0,Voltage_10ms_Delay
* ---------------------------------------------------------------------------
		bra.b	prep_return
*
prep_T8:
* set MC68377 to double it's default speed (16 MHz?) (SYNCR)
		adda.w	#$8,a0					* A0 = 0x00FFFA08
		move.w	#$6908,(a0)+			* First set the MFD part
*										* (change 4x to 8x)
* wait for everything to settle checking the PLL lock register (SYNST)
T8_Synthesiser_Lock_Flag:
		btst.b	#9,(a0)					* test PLL lock status bit
		beq.b	T8_Synthesiser_Lock_Flag
		move.w	#$6808,-(a0)			* Now set the RFD part
*										* (change /2 to /1)
		adda.w	#$48,a0					* A0 = 0x00FFFA50
		clr.w	(a0)					* Disable watchdog and monitors (SYPCR)
*
prep_return:
		rts
*
* ===========================================================================
* =============== End of Preparation ========================================
* ===========================================================================
