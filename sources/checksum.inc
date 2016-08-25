* =============== I N C L U D E   F I L E ===================================
* ===========================================================================
* =============== Equates for Checksum Calculation constants ================
* ===========================================================================
*
* ===========================================================================
* Created by Sophie Dexter
* Version 1.1
* 26-May-2013
*
* A new addition to the 'Universal BDM scripts for Trionic'
* ===========================================================================
*
* Equates used to improve readability
*
T52_Size			EQU	$20000			* T5.2 BIN file is 128 kBytes
T55_Size			EQU $40000			* T5.5 BIN file is 256 kBytes
T7_Size				EQU $80000			* T7 BIN file is 512 kBytes
T8_Size				EQU $100000			* T8 BIN file is 1 MBytes
*
Last_Address_Of_ECU	EQU	$7FFFF			* Last address of T5.x and T7 ECUs
ROM_Offset			EQU $FD				* Identifier for ROM_Offset in T5/7
Code_End			EQU $FE				* Identifier for Code_End in T5/7
*
FB_Checksum			EQU $FB				* Identifier for Checksum in T/8
*
T8_Footer_Address	EQU $020140			* Address of pointer to Footer in T8
T8_Code_End			EQU $FC				* Identifier for Code_End in T8
T8_Cipher_ADD		EQU $D6				* T8 Footer is encoded
T8_Cipher_XOR		EQU $21				* with a simple cipher
*
* ===========================================================================
