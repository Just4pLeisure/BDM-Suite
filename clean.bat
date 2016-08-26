@ECHO OFF

SET Outputs=release,listings
SET Cruft=SYM,S19
SET Extras=messages,prepares,notes,batches

FOR %%d in (%Outputs%) DO FOR %%f in (.\%%d\*.*) DO IF EXIST %%f DEL %%f
FOR %%d in (%Outputs%) DO IF EXIST .\%%d\NUL RMDIR .\%%d

CD .\sources

FOR %%e in (%Cruft%) DO IF EXIST .\*.%%e DEL .\*.%%e
touch .\*.*

CD ..

FOR %%f in (%Extras%) DO touch .\%%f\*.*