**Trionic BDM Suite**
====
**AKA** the **'Universal BD32 scripts for Trionic5.x, 7 and 8 ECUs'**

**Trionic BDM Suite** is a collection of BDM resident drivers (aka scripts) for reading (DUMPECU), updating (FLASHECU), verifying the **FB** checksum of (CHECKECU) and erasing (ERASEECU) Trionic ECUs found in Saab cars.

--------

**WARNING: Use at your own risk, sadly this software comes with no guarantees. This software is provided 'free' and in good faith, but the author does not accept liability for any damage arising from its use.**
 
--------
Introduction
===

Saab's Trionic ECU's use Motorola CPU32 based microprocessor chips which can be read and updated using Motorola's Background Debug Mode interface, BDM for short, which connects directly to the CPU on the ECU's circuit board. My BDM Resident Drivers used together with other Freeware software packages and a low cost adapter that connects to a PC's parallel port connector are all that the enthusiast needs to make this possible.

>**NOTE:** BDM is an umbrella term for a number of different interface circuits, **Only the CPU16/32 type of BDM adapter is suitable** for use with Saab's Trionic ECUs. Other, e.g. **CPU-08/12** adapters, with a 6-pin connector, and **PowerPC and Coldfire adapters**, which have a similar looking 10-pin connector, **CANNOT be used**.

>**NOTE:** You must connect the BDM adapter to a Parallel Port on your PC's motherboard or a PCI(e) plug-in circuit board. **USB to Parallel Port adapters CANNOT be used**.

Further information and help with using Trionic BDM Suite can be found on the [TrionicTuning](http://trionictuning.com) and [ECU Project](http://forum.ecuproject.com) forums.

Freeware software for tuning Saab Trionic ECUs is available at http://www.txsuite.org.

Motorola, and more recently Freescale, no longer exist following successive buyouts and NXP now hold the rights to  Motorola's legacy CPU chips. Full information about Motorola's CPU chips and links to download Scott Howard's Freeware BD32 and AS32 software packages are available on NXP's website:

- NXP's [MC68332: 32-Bit Microcontroller product page](http://www.nxp.com/products/microcontrollers-and-processors/more-processors/coldfire-plus-coldfire-32-bit-mcus/68kmpus-legacy/m683xx/32-bit-microcontroller:MC68332) includes datasheets and reference manuals for the CPU in T5.x and T7 ECUs.
- NXP's [MC68377: Microcontroller product page](http://www.nxp.com/pages/microcontroller:MC68377) includes datasheets and reference manuals for the CPU in T8 ECUs.
- [Direct download link for BD32](http://cache.nxp.com/files/microcontrollers/software_tools/debuggers/BD32-122DBG.zip), Scott Howard's Freeware Background Debug Monitor for 68300 Parts, needed to use my BDM Resident Drivers.
- [Direct download link for AS32](http://cache.nxp.com/files/microcontrollers/software_tools/assemblers/AS32V1-2ASM.zip), Scott Howard's Freeware DOS Based CPU32 Assembler, needed to assemble or 'compile' my BDM Resident Drivers.

----------
Change log
====
Version 1.2 - 01-Dec-2013
----
**Additions**

- Support for ATMEL 29C010 FLASH chips (finally!)
- A new ERASEECU script which erases the FLASH chips. It isn't usually necessary to erase FLASH chips separately from FLASHing them, but this script also uses my 'brute force' algorithm on 28Fxxx FLASH chips which may help to revive '**bad**' 28F010 FLASH. 

**Improvements**

- Better filename editing in FLASHECU and DUMPECU scripts
- Consistent error message style for each script
- Better control of the FLASH chip programming voltage.

**BUG FIX**

- Fixed a serious bug for T5.2/5 ECUS. which prevented the scripts working and displayed the '3: Error: Unrecognised ECU or FLASH chips' message. This was due to a timing issue with the FLASH programming voltage and meant that I couldn't reliably detect 28F010 or 28F512 FLASH chips!

----
Version 1.1 - 26-May-2013
----
**Additions**

- A new CHECKECU script which calculates the 'FB' checksum in just a few seconds. This is much faster than DUMPing the BIN file after FLASHing and then comparing files using DOS' 'fc' program to check that FLASHing was indeed successful.
- Enable editing of the filename as it is typed to allow mistakes to be corrected.

**Improvements**

- Improvements to error reporting messages.

**BUG FIX**

- Fixed a problem preventing the scripts working with T8 ECUs. Version 1.0 did not work for T8 ECUs because of a memory problem. To be quite honest I am still confused because the MC68377 reference manual is ambiguous when describing its SRAM Module configuration.
- Fixed several others small bugs.

----
Version 1.0 - 06-Sep-2012
----

- First release which provides DUMPECU and FLASHECU scripts

--------
Supported ECUs
====
- Trionic 5.2 ECUs used in MY93 Saab 9000 Aero cars
- Trionic 5.5 ECUs used in MY94-on Saab 9000 and ng900 cars
- Trionic 7 ECUs used in og9-3 and og9-5 cars
- Trionic 8 ECUs used in ng9-3 cars

--------
Supported FLASH Chips
====
All FLASH chips that were originally fitted in SAAB's Trionic ECUs:

- Intel 28F512 chips in T5.2 ECUs
- Intel, AMD and CSI 28F010 chips in T5.5 ECUs
- AMD 29F400T chips in T7 ECUs
- AMD 29BL802C chips in T8 ECUs

Sometimes the FLASH chips in ECU's go 'bad' and it is impossible to reprogram them. Unfortunately the original chip types are difficult or impossible to purchase. Newer generation FLASH chips are available but these use different programming algorithms.

My Resident Drivers also implement algorithms to support the following chips which can be used as replacements in T5.x ECUs:

- Atmel29C512 in T5.2 ECUs
- AMD29F010, SST39SF010A, AMIC29010L, ST M29F010B and Atmel29C010 in T5.5 ECUs

>**NOTE:** Always use Industrial versions of FLASH chips because they work over a wider temperature range.

--------
How to assemble the code
====
**Pre-requisites**

You will need Scott Howard's AS32 Freeware CPU32 cross-assembler. This is a 16-bit DOS application and must be run in a 'real' DOS environment. Make sure that the path to AS32.EXE is in your DOS 'PATH' setting. Please refer to Scott's AS32 documentation for details of how to setup, configure and use AS32.

- [Direct download link for AS32](http://cache.nxp.com/files/microcontrollers/software_tools/assemblers/AS32V1-2ASM.zip) on NXP's webserver.

I use Linux and the DOSEMU application to provide an emulated but 'real enough' DOS environment to be able to use BD32 without rebooting into DOS. The Linux Bash shell has come to Windows 10 and it *may* be possible to do the same if you use Windows.

You will need the 'touch' utility which I use to set file date and time stamps. Touch is bundled with FreeDOS, the DOS used by DOSEMU. If you are using another DOS environment you can still use FreeDOS' touch:

- Freedos' page about [touch](http://www.freedos.org/software/?prog=touch)
- [Direct download link for touch](http://www.ibiblio.org/pub/micro/pc-stuff/freedos/files/util/file/touch/1.44/touch144.zip)

**NOTE:** Touch uses your country code setting to specify the date and time format. Since I am British I use the British **dd-mm-yyyy hh:mm** format for date and time in my batch files.

**Assembling Trionic BDM Suite**

Run the **assemble** batch file to assemble Trionic BDM Suite, all 'object' files are put in the **release** folder, listing and symbol files are placed in the **listings** folder. Release files are 'touched' with the original release date and the time stamp represents the version number.

Optionally run the **clean** batch file to clean all output files from the assembler. **clean** also touches all source files with the current date and time.

-------
How to use the Trionic BDM Suite
====
**Pre-requisites**

You will need Scott Howard's BD32 application. This is a 16-bit DOS application and must be run in a 'real' DOS environment. Make sure that the path to BD32.EXE is in your DOS 'PATH' setting. Please refer to Scott's BD32 documentation for details of how to setup, configure and use BD32 and connect a parallel port BDM adapter. The Trionic Suite Manuals, installed along with the Trionic Suites available from http://www.txsuite.org, have further details specific to setting up a BDM environment so that you can reprogram the FLASH chips in your Saab Trionic ECU.

- [Direct download link for BD32](http://cache.nxp.com/files/microcontrollers/software_tools/debuggers/BD32-122DBG.zip) on NXP's webserver.

> **NOTE:** You may need to change your BIOS settings and/or edit BD32.CFG to get the BDM adapter to work reliably, refer to BD32.DOC and Trionic Suite documentation for details.

I use Linux and the DOSEMU application to provide an emulated but 'real enough' DOS environment to be able to use BD32 without rebooting into DOS. The Linux Bash shell has come to Windows 10 and it *may* be possible to do the same if you use Windows. 

>**NOTE:** DOSEMU needs an -s switch *AND* super user privileges to be able to use the parallel port. The parallel port and its address must also be configured in your dosumu.conf file too, please refer to DOSEMU's documentation.

>**NOTE:** BD32 will only work with LPT ports at the 'normal' DOS addresses for parallel ports. PCI and PCIe adapter cards are usually assigned their I/O address ranges by your computer's BIOS and this will almost certainly be different to those needed. My PCI parallel port card came with a DOS program to change the I/O address but this program can only be used in DOS. As a Linux user I use 'setpci' to change my card's addresses like this:

    setpci -v -d 14db:2120 0x10.l=0x378        // 0x378 is the LPT1 normal address
    setpci -v -d 14db:2120 0x14.l=0x778        // 0x778 is needed too for ECP mode

>My PCI card's VID and PID are 14db:2120, use lspci with the -nn and -v switches to find your card's Vendor and Product IDs.

**Providing power for your ECU**

I strongly suggest you use a regulated power supply to power your ECU. Some laptops use a 16 Volt power supply which would be ideal for T5 ECUs. T7, T8 and T5.x ECUs with replacement FLASH chips only require 12 Volts but it is OK to use a 16 Volt power supply with these too.

**Setting up**

You can use **Trionic BDM Suite** in the **release** folder if you assembled them yourself or you may prefer to copy everything to a new folder. If you downloaded a zipped copy of the pre-assembled **Universal BDM scripts for Trionic** simply unzip to a folder of your choosing.

- Copy a BIN file that you wish to update your ECU with to your Trionic BDM Suite folder

> **NOTE:** BD32 is a DOS program and only accepts DOS 8.3 style filenames. You will have to rename your BIN file if it has a long filename.

- Connect up your T5, T7 or T8 ECU, BDM adapter and PC's LPT port
- Turn everything on and boot your PC into DOS, or run the DOSEMU application

**Using Trionic BDM Suite**

There are three different ways to use **Trionic BDM Suite**:

1. My BDMSUITE batch file may do all that you need, type **BDMSUITE** at the DOS prompt and give it a try.....
2. Alternatively if you like more control run BD32.EXE then from within the BD32 window:

    DO DUMP - Calculates the 'FB' Checksum then DUMPs your FLASH to a BIN file. You can stop the script if the checksum is bad - why DUMP a bad FLASH image?
    
    DO FLASH - FLASH (programs) your BIN file into your ECU then verifies it was successful by calculating and comparing the 'FB' checksum.
    
    DO CHECK - Verifies your FLASH by using the 'FB' checksum.
    
    DO ERASE - Erase the FLASH chips in your ECU.

3. And if you're truly old-school the most basic commands are:

    BD32 - runs Scott Howard's BD32.EXE application
    
    DO PREP - Followed by one of:
    
    CHECKECU, DUMPECU, ERASEECU or FLASHECU

>**NOTES**

>- Enter the name of your BIN file when prompted:
>  - Only BIN files are supported, the script adds '.BIN' to the filename.
>  - The script accepts up to 8 characters for a name (DOS filename limit).
>  - If your filename is shorter than 8 characters either press the enter key or type a '.' after the filename and the script will use your shorter filename.
>- FLASHing or DUMPing a T5.2/5.5/7/8 ECU takes about 2/3/5/10 minutes respectively.
>- CHECKing an ECU takes no more than 2 seconds
>- ERASing an ECU can take anywhere from a second to a minute.

**What to expect to see in the BD32 window:**
 
All scripts apart from the ERASE script should give a visual indication of activity at least once every few seconds. The ERASE script may not show any indication for up to minute when ERASEing 'bad' 28Fxxx chips.

- Progress messages are shown to indicate which operation is in progress.
- Progress indicators show the status of longer operations:
 - The start and end addresses of the region of FLASH being read or programmed is displayed during DUMPing and FLASHing of BIN files.
 - A rotating 'spinner' is displayed to indicate that your FLASH chips are being erased. **NOTE:** there may be a pause before you see the spinner when erasing the original 28Fxx FLASH chips fitted in T5.x ECUS.
- At the end of the process a message indicating the outcome is displayed.

>**NOTE:** If you don't see the display change for more than a minute something has gone wrong !!! 

--------
License
====
Copyright 2012-2013 Sophie Dexter

Licensed under the Apache License, Version 2.0 (the "License"); you may not use this file except in compliance with the License. You may obtain a copy of the License at

http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software distributed under the License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the License for the specific language governing permissions and Limitations under the License.

--------
Credits
====
This would not have been possible without Patrik Servin's original work or subsequent contributions from J.K. Nillson, Dilemma, General Failure, johnc, uglybug., krzykoz and many others, please accept my apologies if I haven't mentioned you.

Sophie x
