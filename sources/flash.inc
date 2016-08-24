* =============== I N C L U D E   F I L E ===================================
* ===========================================================================
* =============== Equates for FLASH Chip constants ==========================
* ===========================================================================
*
* ===========================================================================
* Created by Sophie Dexter
* Version 1.0
* 17-Jul-2012
* ===========================================================================
*
* Equates used to improve readability
*
* FLASH chip type values, it is sufficient to only check the Device ID
*
INTEL28F512	EQU $B8			* Original for T5.5 ECUs
AMD28F512	EQU $25			* Original for T5.5 ECUs
INTEL28F010	EQU $B4			* Original for T5.5 ECUs
*							* Also CSI, On Semi and Catalyst
AMD28F010	EQU $A7			* Original for T5.5 ECUs
AMD29F400T	EQU $23			* Original for T7 ECUs (byte access)	
* 29F400T		EQU $2223	* Original for T7 ECUs (word access)
* AMD29F400B	EQU $AB		* (byte access)
* 29F400B		EQU $22AB	* (word access)
AMD29BL802C	EQU $81			* Original for T8 ECUs (byte access)
* AMD29BL802C	EQU $2281	* Original for T8 ECUs (word access)
Atmel29C512	EQU $5D			* May be used as a replacement in T5.2 ECUs
AMD29F010	EQU $20			* May be used as a replacement in T5.5 ECUs
*							* Also ST M29F010B
Atmel29C010	EQU $D5			* May be used as a replacement in T5.5 ECUs
SST39SF010A	EQU $B5			* May be used as a replacement in T5.5 ECUs
AMIC29010L	EQU $A4			* May be used as a replacement in T5.5 ECUs
*
F28_Write_Count	EQU 25		* 28Fxxx program algorithm is allowed 25 retries
F28_Erase_Count	EQU 1000	* 28Fxxx erase algorithm is allowed 1000 retries
F28_Reset_Cmd	EQU $FFFF	* Reset 28Fxxx by writing 0xFFFF to address 0x00
F28_Verify_Cmd	EQU $C0		* 28Fxxx FLASH verify command
F28_Program_Cmd	EQU $40		* 28Fxxx FLASH program command
F28_Erase_Cmd	EQU $20		* 28Fxxx FLASH erase command
F28_Era_Vfy_Cmd	EQU $A0		* 28Fxxx FLASH erase verify command
*
F29_Erase_Cmd	EQU $10		* 29Fxxx FLASH erase command
F29_Unlock_Cmd	EQU $80		* 29Fxxx FLASH unlock command
F29_Program_Cmd	EQU $A0		* 29Fxxx FLASH program command
F29_Reset_Cmd	EQU	$F0		* 29Fxxx FLASH reset command
F29_Timeout_Bit	EQU 5		* 29Fxxx FLASH Timeout Bit
F29_Ready_Bit	EQU 7		* 29Fxxx FLASH Ready Bit
F29_Ready_Mask	EQU $80		* 29Fxxx FLASH Bit Mask for the Ready Bit
*
* ===========================================================================
