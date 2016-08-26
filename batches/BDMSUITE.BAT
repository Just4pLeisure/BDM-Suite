@echo off
:SHOWMENU
cls
@echo     +----------------------------------------------------------------------+
@echo     !                       Trionic BDM Suite v1.2                         !
@echo     !             For Saab Trionic 5.2, 5.5, 7 and 8 ECUs                  !
@echo     !----------------------------------------------------------------------!
@echo     !                                                                      !
@echo     !    C - Verify FLASH contents in your ECU using the 'FB' CHECKSUM     !
@echo     !        Calculates the checksum and compares it to the value in the   !
@echo     !        footer. A match is a good indication that your FLASH is OK.   !
@echo     !                                                                      !
@echo     !    D - DUMP (read) the FLASH in you ECU and save it to a BIN File    !
@echo     !        You will be asked to enter the name of the BIN file you       !
@echo     !        want to save. Only 8 character 'DOS' names are allowed.       !
@echo     !                                                                      !
@echo     !    E - ERASE the FLASH in your ECU                                   !
@echo     !        Erasing FLASH is not usually required but it may revive 'bad' !
@echo     !        FLASH chips in Trionic 5 ECUs (try erasing a few times).      !
@echo     !                                                                      !
@echo     !    F - FLASH (program) a BIN file to the FLASH chip(s) in your ECU   !
@echo     !        You will be asked to enter the name of the BIN file you       !
@echo     !        want to use. Only 8 character 'DOS' names are allowed.        !
@echo     !                                                                      !
@echo     !    X - EXIT to DOS prompt                     (c) 2013 Sophie Dexter !
@echo     +----------------------------------------------------------------------+
@echo _
choice /B /C:CDEFX /N     What do you want to do?
if errorlevel 5 goto EXIT
if errorlevel 4 goto FLASH
if errorlevel 3 goto ERASE
if errorlevel 2 goto DUMP
if errorlevel 1 goto CHECK
goto SHOWMENU

:CHECK
BD32 do checkw
goto SHOWMENU

:DUMP
BD32 do dumpw
goto SHOWMENU

:ERASE
BD32 do erasew
goto SHOWMENU

:FLASH
BD32 do flashw
goto SHOWMENU

:EXIT
