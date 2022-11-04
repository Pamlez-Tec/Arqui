@echo off
tasm /zi /l /w0 %1 > error.txt
tasm /zi /l /w0 %2 > c:\error1.txt

IF EXIST c:%1.obj GOTO fin
	echo se produjo un error mire el archivo ERROR.txt
	goto salir
:fin
	tlink /v %1 + %2
	td %1 %2 %3 %4 %5 %6 %7 %8 %9 
:salir