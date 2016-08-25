* =============== L I B R A R Y =============================================
* ===========================================================================
* =============== A collection of subroutines helpful for   =================
* =============== calculating the checksums in Trionic ECUs =================
* ===========================================================================
*
*	Search_For_Identifier
*	Get_T5_Identifier
*	Get_T7_Identifier
*	Get_T8_Identifier
*	Calculate_BYTE_Checksum
*	Calculate_LONG_Checksum
*
* ===========================================================================
* Created by Sophie Dexter
* Version 1.1
* 26-May-2013
*
* A new addition to the 'Universal BDM scripts for Trionic'
* ===========================================================================
*
* ===========================================================================
* =============== Search_For_Identifier =====================================
* ===========================================================================
*
* @brief		Search 'footer' region of the BIN for a specified identifier.
*				The search starts from the end of the footer region, working
*				backwards until the identifier is found.
*
* @param		d4			Holds type of identifier to search for
*
* @param		a2			Holds address to start searching from
*
* @registers	d2			Clear identifier value to 0x0
*
* @return		d0			Holds the type of identifier that was found
*							Will be 0x00 or 0xFF if identifier wasn't found
* @return		d1			Holds string length of found identifier
*
* @return		a2			Holds address where identifier was found
* 
* ===========================================================================
*
		EVEN
*
Search_For_Identifier:
		clr.l	d0						* initialise Identifier to 0x0
		clr.l	d1						* initialise String Length to 0x0
		clr.l	d2						* initialise Identifier value to 0x0
Identifier_Loop:
		move.b	(a2),d1					* String Length
		beq.b	Bad_Identifier			* Zero because erasing failed
		cmpi.b	#$FF,d1
		beq.b	Bad_Identifier			* 0xFF because programming failed
		move.b	-1(a2),d0				* Identifier
		suba.l	d1,a2					* Subtract string length and another
		subq.l	#2,a2					* 2 for length and identifier bytes
*										* to get to start of the string
		cmp.b	d4,d0					* Check to see if matching identifier
		bne.b	Identifier_Loop			* Keep looking
Bad_Identifier:
Identifier_Return:
		rts
*
* ===========================================================================
* =============== End of Search_For_Identifier ==============================
* ===========================================================================
*
* ===========================================================================
* =============== Get_T5_Identifier =========================================
* ===========================================================================
*
* @brief		Converts the address stored for the specified identifier from
*				ASCII text to a 32-bit hex number.
*
* @param		d4			Holds type of identifier to search for
*
* @registers	d0			Holds an ASCII character to convert to hex
* 				d1			Holds string length of found identifier
*
* 				a2			Holds address where identifier was found
*
* @return		d2			Holds specified identifier's value or
*							0x0 if the identifier was not found
* 
* ===========================================================================
*
		EVEN
*
Get_T5_Identifier:
		movea.l	#Last_Address_Of_ECU-4,a2
		jsr 	(Search_For_Identifier,pc).w
		cmp.b	d4,d0					* Check if identifier found
		bne.b	T5_Identifier_Return	* Identifier error
* ---------------------------------------------------------------------------
Convert_ASCII:
		move.b	(a2,d1.l),d0			* Get an ascii character
*										* from the ROM_Offset
		subi.b	#$30,d0					* Subtract ascii '0' (0x30)
		cmpi	#$A,d0					* see if the result is 0-9,
*										* less than 10 (0xA)
		bcs.b	Calculate_T5_Identifier	
		subq.b	#7,d0					* Subtract 7,
*										* ('A'(0x41) - '0'(0x30) - 10),
*										* because value is 10-15 - 0xA-0xF
* ---------------------------------------------------------------------------
Calculate_T5_Identifier:
		lsl.l	#4,d2					* ROM_Offset, 'shift' to make room 
		or.b	d0,d2					* put in next hex value
		subq.b	#1,d1					* 1 less hex value to get
		bne.b	Convert_ASCII			* keep going if not all values read
* ---------------------------------------------------------------------------
T5_Identifier_Return:
		rts
*
* ===========================================================================
* =============== End of Get_T5_Identifier ==================================
* ===========================================================================
*
* ===========================================================================
* =============== Get_T7_Identifier =========================================
* ===========================================================================
*
* @brief		Converts the address stored for the specified identifier as
*				a 32-bit hex number from little-endian to big-endian.
*
* @param		d4			Holds type of identifier to search for
*
* @registers	d0			Holds an ASCII character to convert to hex
* 				d1			Holds string length of found identifier
*
* 				a2			Holds address where identifier was found
*
* @return		d2			Holds specified identifier's value or
*							0x0 if the identifier was not found
* 
* ===========================================================================
*
		EVEN
*
Get_T7_Identifier:
		movea.l	#Last_Address_Of_ECU,a2
		jsr 	(Search_For_Identifier,pc).w
		cmp.b	d4,d0					* Check if identifier found
		bne.b	T7_Identifier_Return	* Identifier error
* ---------------------------------------------------------------------------
Calculate_T7_Identifier:
		move.b	(a2,d1.l),d0			* Get byte from the identifier string
		lsl.l	#8,d2					* ROM_Offset, 'shift' to make room 
		or.b	d0,d2					* put in next hex value
		subq.b	#1,d1					* 1 less hex value to get
		bne.b	Calculate_T7_Identifier	* keep going if not all values read
* ---------------------------------------------------------------------------
T7_Identifier_Return:
		rts
*
* ===========================================================================
* =============== End of Get_T7_Identifier ==================================
* ===========================================================================
*
* ===========================================================================
* =============== Get_T8_Identifier =========================================
* ===========================================================================
*
* @brief		Decodes the address stored for the specified identifier as
*				a 32-bit hex number encoded using a simple XOR cipher.
*
*				The 'footer' in T8 ECUs is stored 'freeform' in as much as
*				there is no guarantee of EVEN byte alignment and so it must
*				be processed byte by byte
*
* @param		d4			Holds type of identifier to search for
*
* @registers	d0			varied uses
* 				d1			varied uses
*
* 				a2			Holds address where identifier was found
*
* @return		d2			Holds specified identifier's value or
*							0x0 if the identifier was not found
* 
* ===========================================================================
*
		EVEN
*
Get_T8_Identifier:
		movea.l	(T8_Footer_Address),a2
* ---------------------------------------------------------------------------
Search_For_T8_Identifier:
		clr.l	d0						* initialise Identifier to 0x0
		clr.l	d1						* initialise String Length to 0x0
		clr.l	d2						* initialise Identifier value to 0x0
T8_Identifier_Loop:
		move.b	(a2)+,d1				* String Length
		beq.b	Bad_T8_Identifier		* Zero because erasing failed
		cmpi.b	#$FF,d1
		beq.b	Bad_T8_Identifier		* 0xFF because programming failed
		add.b	#T8_Cipher_ADD,d1
		eor.b	#T8_Cipher_XOR,d1
		move.b	(a2)+,d0				* Identifier
		add.b	#T8_Cipher_ADD,d0
		eor.b	#T8_Cipher_XOR,d0
		cmp.b	d4,d0					* Check to see if matching identifier
		beq.b	Calculate_T8_Identifier	* Found the identifier
		adda.l	d1,a2					* Add string length ready to check
		bra.b	T8_Identifier_Loop		* Keep looking
* ---------------------------------------------------------------------------
Calculate_T8_Identifier:
		move.b	(a2)+,d0				* Get byte from the identifier string
		add.b	#T8_Cipher_ADD,d0
		eor.b	#T8_Cipher_XOR,d0
		lsl.l	#8,d2					* ROM_Offset, 'shift' to make room 
		or.b	d0,d2					* put in next byte value
		subq.b	#1,d1					* 1 less hex value to get
		bne.b	Calculate_T8_Identifier	* keep going if not all values read
		bra.b	T8_Identifier_Return
* ---------------------------------------------------------------------------
Bad_T8_Identifier:
		cmp.b	d4,d0					* Check to see if matching identifier
*										* this step sets the zero flag if OK
* ---------------------------------------------------------------------------
T8_Identifier_Return:
		rts
*
* ===========================================================================
* =============== End of Get_T8_Identifier ==================================
* ===========================================================================
*
* ===========================================================================
* =============== Calculate_BYTE_Checksum ===================================
* ===========================================================================
*
* @brief		Calculates a checksum between ROM_Offset and Code_End.
*
*				The 'BYTE' checksum is a simple 32-bit sum of all the 8-bit
*				values 
*
* @param		d2			The address to calculate from
* @param		d3			The address to calculate to
*
* @registers	d1			Used to fetch each byte when calculating
*
*				a2			Address to get the next value to add
*
* @return		d0			The calculated checksum is returned in d0
* 
* ===========================================================================
*
		EVEN
*
Calculate_BYTE_Checksum:
		movea.l	d2,a2   				* Address for checksum calculation
		clr.l	d0						* initialise checksum to 0x0 
		clr.l	d1						* initialise temporary store to 0x0
* ---------------------------------------------------------------------------
BYTE_Checksum_Loop:
		move.b	(a2)+,d1				* Get a BYTE
		add.l	d1,d0					* Add byte to the 32-bit checksum
		move.b	(a2)+,d1				* Get a BYTE
		add.l	d1,d0					* Add byte to the 32-bit checksum
		cmpa.l	d3,a2					* Check if at last address
		bne.b	BYTE_Checksum_Loop
		rts								* Checksum in d0
*
* ===========================================================================
* =============== End of Calculate_BYTE_Checksum ============================
* ===========================================================================
*
* ===========================================================================
* =============== Calculate_LONG_Checksum ===================================
* ===========================================================================
*
* @brief		Calculates a checksum between ROM_Offset and Code_End.
*
*				The 'LONG' checksum is a simple 32-bit sum of all the 32-bit
*				values 
*
* @param		d2			The address to calculate from
* @param		d3			The address to calculate to
*
* @registers	a2			Address to get the next value to add
*
* @return		d0			The calculated checksum is returned in d0
* 
* ===========================================================================
*
		EVEN
*
Calculate_LONG_Checksum:
		movea.l	d2,a2   				* Address for checksum calculation
		clr.l	d0						* initialise checksum to 0x0 
* ---------------------------------------------------------------------------
LONG_Checksum_Loop:
		add.l	(a2)+,d0				* Add a 32-bit value to checksum
		cmpa.l	d3,a2					* Check if at last address
		bne.b	LONG_Checksum_Loop
		rts								* Checksum in d0
*
* ===========================================================================
* =============== End of Calculate_LONG_Checksum ============================
* ===========================================================================
*
* ===========================================================================
* =============== End of chksums.s ==========================================
* ===========================================================================
