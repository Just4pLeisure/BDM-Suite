@ECHO OFF

SET Outputs=release,listings
SET Scripts=DUMPECU,FLASHECU,CHECKECU
SET Cruft=SYM,S19
SET Extras=messages,prepares

FOR %%d IN (%Outputs%) DO IF NOT EXIST .\%%d\NUL MKDIR .\%%d
FOR %%d IN (%Outputs%) DO FOR %%f IN (.\%%d\*.*) DO DEL %%f

CD .\sources

FOR %%f IN (%Scripts%) DO as32 -l -s .\%%f.S >..\listings\%%f.LST
FOR %%f IN (%Scripts%) DO COPY .\%%f.SYM ..\listings\%%f.SYM
FOR %%f IN (%Scripts%) DO COPY .\%%f.S19 ..\release\%%f.D32
FOR %%e IN (%Cruft%) DO IF EXIST .\*.%%e DEL .\*.%%e

CD ..

FOR %%f IN (%Extras%) DO COPY .\%%f\*.* .\release\*.*

touch .\release\*.* 26-05-2013 01:01
