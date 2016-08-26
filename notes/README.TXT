********************************************************************************
*
*                       Trionic BDM Suite v1.2
*              For Saab Trionic 5.2, 5.5, 7 and 8 ECUs
*                       (c) 2013 Sophie Dexter
*
********************************************************************************
*
* BD32 'Target-Resident' drivers for Trionic ECU FLASHing in this package:
*
* CHECK - Verify FLASH contents in your ECU using the 'FB' CHECKSUM.
*         Calculates the checksum and compares it to the value in the
*         footer. A match is a good indication that your FLASH is OK.
*
* DUMP  - Dump (read) the FLASH in you ECU and save it to a BIN File.
*         You will be asked to enter the name of the BIN file you want
*         to save. Only 8 character 'DOS' names are allowed.
*
* ERASE - Erase the FLASH in your ECU
*         Erasing FLASH is not usually required but it may revive 'bad'
*         FLASH chips in Trionic 5 ECUs (try erasing a few times).
*
* FLASH - FLASH (program) a BIN file to the FLASH chip(s) in your ECU
*         You will be asked to enter the name of the BIN file you want
*         to use. Only 8 character 'DOS' names are allowed.
*
********************************************************************************
*
* WARNING: Use at your own risk, sadly this software comes with no guarantees.
* This software is provided 'free' and in good faith, but the author does not
* accept liability for any damage arising from its use.
* 
********************************************************************************
*
* Just 4 scripts that can FLASH, DUMP, CHECK and ERASE all Trionic ECUs: T5.2,
* 5.5, 7 and T8. The FLASH script also works with replacement Atmel 29C010/512,
* AMD 29F010, ST M29F010B, AMIC A29010 and Microchip/SST 39F010 FLASH chips in
* T5.5 ECUs. Simple to use though clever behind the scenes.
*
* Please refer to the Trionic Suite manuals for details of how to set-up the
* BDM environment so that you can reprogram the FLASH chips in your ECU. 
* 
* I strongly suggest you use a regulated power supply to power your ECU. Some
* laptops use a 16 Volt power supply which would be ideal for T5 ECUs. T7, T8
* and T5.x ECUs with replacement FLASH chips only require 12 Volts.
*
* Sophie x
* 
********************************************************************************
*
* How to use:
*
* Connect your T5, T7 or T8 ECU, BDM adapter and PC's LPT port.
* Turn everything on and boot your PC into DOS.
* NOTE: You may need to change your BIOS settings and/or edit BD32.CFG.
* Make sure the scripts are in the same folder as BD32.EXE and start BD32.
* Once BD32 has started type 'do dump' to DUMP or 'do flash' to FLASH your ECU.
* Enter the name of your BIN file when prompted.
* FLASHing or DUMPing a T5.2/5.5/7/8 ECU takes about 2/3/5/10 minutes.
* CHECKing an ECU takes no more than 2 seconds
* ERASing an ECU can take anywhere from a second to a minute.
*
* A few points on entering the BIN file's name:
* 1) Only BIN files are supported, the script adds '.BIN' to the filename.
* 2) The script accepts up to 8 characters for a name (DOS filename limit).
* 3) If your filename is shorter than 8 characters either press enter or
*    type a '.' after the filename so that the script will use your shorter
*    filename.
*
* What to expect to see in the BD32 window:
* 
* Progress messages are shown to indicate which operation is in progress
* Progress indicators show the statusof longer operations:
*   A 'spinner' rotates to indicate that your FLASH chips are being erased.
*   NOTE: there may be a pause before you see the spinner wih 28Fxxx chips.
*   The start and end addresses of the region of FLASH being read or programmed
*   is displayed during DUMPing and FLASHing of BIN files.
* All scripts aprt from the ERASE script which you should give a visual
* indication at every few seconds. The ERASE script may not show any indication
* for up to minute when ERASEing 'bad' 28Fxxx chips.
* At the end of the process a message indicating the outcome is displayed.
*
********************************************************************************
*
* USAGE:
*
* My new BDMSUITE batch file may do all that you need, type 'BDMSUITE' at the
* DOS prompt and give it a try.....
*
* Alternatively if you like more control run from within the BD32 window:
*
*   DO DUMP   -  Calculates the 'FB' Checksum then DUMPs your FLASH to a BIN
*                file. You can stop the script if the checksum is bad - why DUMP
*                a bad FLASH image?
*   DO FLASH  -  FLASH (programs) your BIN file into your ECU then verifies it
*                was successful by calculating and comparing the 'FB' checksum.
*   DO CHECK  -  Verfies your FLASH by using the 'FB' checksum.
*   DO ERASE  -  Erase the FLASH chips in your ECU.
*
* And if you're truly old-school the most basic commands are:
*
*   DO PREP   -  Followed by:
*   CHECKECU, DUMPECU, ERASEECU or FLASHECU
*
********************************************************************************