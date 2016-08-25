* =============== S U B	R O U T	I N E =======================================
* ===========================================================================
* =============== Get_FLASH_Id ==============================================
* ===========================================================================
*
* FLASH ID is obtained by putting the chip in a special mode where the
* manufacturer and device IDs can be read from the start and first addresses.
* 28Fxxx type FLASH chips require a programming voltage to be present for
* device identification. It is unlikely that a FLASH chip will be mis-
* identified because the 'normal' contents at these locations do no match any
* known FLASH chip type:
* Normally FF FF  F7 FC - how all T5 BIN files start
* Could be FF FF  FF FF - if the FLASH has been erased
* Could be 00 00  00 00 - if the FLASH has had all zeroes written to it
*
* ===========================================================================
*
* @brief		Identifies the type of FLASH chip(s) in the ECU
*				Exits Driver program if FLASH chip(s) is(are) unknown
*
* @param		VOID		No input parameters
*
* @registers	d0			Holds Vendor ID for comparisons
*				d1			Holds FLASH size during calculation
*				d2			Holds FLASH type (a number between 0 and 4)
*							0=?, 1=28F, 2=29F 8bit, 3=29F 16bit, 4=29C
*
*				a2			Holds FLASH chip ID addresses
*				a3			Holds return value addresses
*
* @return		FLASH_Id	Vender and device IDs concatenated to a long
* @return		FLASH_Size	Size of FLASH chip(s) in Bytes
*				d1			FLASH_Size
* @return		FLASH_Type	0=?, 1=28F, 2=29F 8bit, 3=29F 16bit, 4=29C
*				d2			FLASH_Type
*
* ===========================================================================
* Created by Sophie Dexter
* Version 1.0
* 17-Jul-2012
* ===========================================================================
* Version 1.1
* 26-May-2013
*
* A few changes to reduce code size
*
* As ever I have used a few tricks to get the code small. e.g. moveq and swap
* instructions to load a large number into a register. The rol instruction
* is used to multiply a number by a power of 2 (x2, x4, x8 etc)
*
* lea.l	$0,a2 uses less bytes than movea.l	#0,a2 to set a2 to 0x0000
* ===========================================================================
*
		EVEN
*
FLASH_Id:	dc.l	0
FLASH_Size:	dc.l	0
FLASH_Type:	dc.b	0	* 0=?, 1=28F, 2=29F 8bit, 3=29F 16bit, 4=29C
*
* ===========================================================================
*
		EVEN
*
Get_FLASH_Id:
* Read FLASH chip manufacturer and device Ids
		lea.l	$0,a2					* Base address of FLASH
		move.w	#$AAAA,$5555*2			*
		move.w	#$5555,$2AAA*2			*
		move.w	#$9090,$5555*2			*
		lea.l	(FLASH_Id,pc),a3
		move.w	(a2)+,(a3)+
		move.w	(a2),(a3)
		move.w	#$AAAA,$5555*2			* d7 = 0xAA
		move.w	#$5555,$2AAA*2			* d6 = 0x55
		move.w	#$F0F0,$5555*2			* Reset 29F/Cxxx FLASH chip
* Prepare to work out size of FLASH chip(s)
		move.l	(FLASH_Id,pc),d0
* Check for FLASH chips that might be in a T5.2 ECU
		moveq	#2,d1					* T5.2 is 128kBytes (0x20000)
		swap	d1						* swap: 0x2 becomes 0x20000
		moveq	#1,d2
		cmpi.b	#AMD28F512,d0			* AMD 28F512
		beq.b	FLASH_id_ret
		cmpi.b	#INTEL28F512,d0			* Intel 28F512
		beq.b	FLASH_id_ret
		moveq	#4,d2
		cmpi.b	#Atmel29C512,d0			* Atmel 29C512 Device id
		beq.b	FLASH_id_ret
* Check for FLASH chips that might be in a T5.5 ECU
		moveq	#1,d2
		rol.l	#$1,d1					* T5.5 is 256 kBytes (2x128kBytes)
		cmpi.b	#AMD28F010,d0			* AMD 28F010
		beq.b	FLASH_id_ret
		cmpi.b	#INTEL28F010,d0			* Intel 28F010
		beq.b	FLASH_id_ret
		moveq	#2,d2
		cmpi.b	#AMD29F010,d0			* AMD 29F010 Device id
		beq.b	FLASH_id_ret
		cmpi.b	#AMIC29010L,d0			* AMIC A29010L Device id
		beq.b	FLASH_id_ret
		cmpi.b	#SST39SF010A,d0			* SST/Microchip SST39SF010A Device id
		beq.b	FLASH_id_ret
		moveq	#4,d2
		cmpi.b	#Atmel29C010,d0			* Atmel 29C010 Device id
		beq.b	FLASH_id_ret
* Check for FLASH chips that might be in a T7 ECU
		moveq	#3,d2
		rol.l	#$1,d1					* T7 is 512 kBytes (2x256kBytes)
		cmpi.b	#AMD29F400T,d0			* AMD 29F400T
		beq.b	FLASH_id_ret
* Check for FLASH chips that might be in a T8 ECU
		rol.l	#$1,d1					* T8 is 1 MBytes (2x512kBytes)
		cmpi.b	#AMD29BL802C,d0			* AMD29BL802C
		beq.b	FLASH_id_ret
* ERROR! FLASH chips not recocgnised if here
		moveq	#0,d1					* don't know what we have
		moveq	#0,d2					* Set type and size to 0
*
FLASH_id_ret:
		lea.l	(FLASH_Size,pc),a3
		move.l	d1,(a3)
		lea.l	(FLASH_Type,pc),a3
		move.b	d2,(a3)
		rts
*
* ===========================================================================
* =============== End of Get_FLASH_Id =======================================
* ===========================================================================
