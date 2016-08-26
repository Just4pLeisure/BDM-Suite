* =============== I N C L U D E   F I L E ===================================
* ===========================================================================
* =============== Equates for Program Failure Codes =========================
* ===========================================================================
*
* ===========================================================================
* Created by Sophie Dexter
* Version 1.2
* 28-Nov-2013
*
* A new addition to the 'Universal BDM scripts for Trionic'
* ===========================================================================
*
* Equates used to improve readability
*
ERROR_Unknown		EQU 1				* Unrecognised ECU or FLASH chips!
ERROR_FOpen			EQU 2				* Could not open BIN file!
ERROR_FRead			EQU 3				* Could not read from BIN file!
ERROR_FWrite		EQU 4				* Could not write to BIN file!
ERROR_Erase			EQU 5				* Unable to erase FLASH chips!
ERROR_Program		EQU 6				* Unable to program FLASH chips!
ERROR_Header		EQU 7				* Could not read HEADER information!
ERROR_Checksum		EQU 8				* Checksum is incorrect!
*
* ===========================================================================
