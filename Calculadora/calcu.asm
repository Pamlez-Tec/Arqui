include macrosP.pgl ;Incluimos macro

;Asignamos cuales procedimeintos externos que pertenecen a otro archivo, en este caso lib.asm, van a ser llamados desde
;este archivo
extrn Suma:far
extrn Resta:far
extrn ImprimirEnPantalla:far
extrn Multi_Proc:far
extrn Divi_Proc:far
extrn InicioInput:far
extrn InicioOperacion:far
extrn asignar:far
extrn RevisarDivision:far
extrn Decimales:far

Datos segment ;Inicio de segmento de datos

LineCommand db 0FFh Dup (?)

ayuda db "                        AYUDA DEL PROGRAMA CALCULADORA",10,13,
    db "                                               ", 10,13,
    db "-> Digite 1 para sumar", 10, 13,
    db "                                               ", 10,13,
    db "-> Digite 2 para resta",10,13,
    db "                                               ", 10,13,
    db "-> Digite 3 para multiplicacion",10,13,
    db "                                               ", 10,13,
    db "-> Digite 4 para division", 10,13,
    db "                                               ", 10,13,
    db "-> Digite OTRA TECLA para salir", 10,13,
    db "                                               ", 10,13,
    db "-> Debe digitar los operando 1 y luego el operando 2, con un ENTER, para reconocer el numero", 10,13,
    db "                                               ", 10,13,
    db "-> Numeros deben ser enteros entre 0 y 65535", 10,13,
    db "                                               ", 10,13,
    db "==============================================", 10,13,
    db "                                               ", 10,13,
    db "$", 10,13,
Datos endS ;Final del segmento de datos


Codigo Segment ;Inicio del segmento de codigo
    assume cs:codigo, ds:datos ;Le indicamos cual registro pertenece un segmento

;Funcion que compara el numero ingresado para poder enviarlo a su operación correspondiente
CompararOperacion proc near
    cmp al,01H ;Compara el caracter ingresado(que se guarda en al) si es igual a 1
    je SumaProc_ ;Si al y 01h son iguales, salta al procedimiento near de suma
    cmp al, 02h ;Compara el caracter ingresado(que se guarda en al) si es igual a 2
    je RestaProc;Si al y 02h son iguales, salta al procedimiento near de resta
    cmp al,03h ;Compara el caracter ingresado(que se guarda en al) si es igual a 3
    je MultiProc;Si al y 03h son iguales, salta al procedimiento near de multiplicacion
    cmp al,04h ;Compara el caracter ingresado(que se guarda en al) si es igual a 4
    je DiviProc;Si al y 04h son iguales, salta al procedimiento near de division
    Finalizar;Macro que finaliza el procedimiento si ningun caracter ingresado es igual a los anteriores.
endP

SumaProc_ proc near
    call InicioOperacion ;Llama al procedimiento far que esta en lib. Aquí se ingresan los caracteres del numero
    call Suma;LLama al procedimiento de suma far que esta en lib. Suma los numeros ingresados.
    call ImprimirEnPantalla;Llama a procedimiento far en lib, imprime el resultado de la suma de ambos numeros
    Finalizar;Macro que finaliza el programa
endP

RestaProc proc near
    call InicioOperacion ;Llama al procedimiento far que esta en lib. Aquí se ingresan los caracteres del numero
    call Resta;LLama al procedimiento de resta far que esta en lib. Resta los numeros ingresados.
    call ImprimirEnPantalla;Llama a procedimiento far en lib, imprime el resultado de la resta de ambos numeros
    Finalizar;Macro que finaliza el programa
endP

MultiProc proc near
    call InicioOperacion;Macro que finaliza el programa
    call Multi_Proc;LLama al procedimiento de multiplicacion far que esta en lib. Multiplica los numeros ingresados.
    call ImprimirEnPantalla;Llama a procedimiento far en lib, imprime el resultado de la multiplicacion de ambos numeros
    Finalizar;Macro que finaliza el programa
endP

DiviProc proc near
    call InicioOperacion;Macro que finaliza el programa
    call RevisarDivision;Procedimiento  far en lib que revisa si en el denominador hay un 0
    call Divi_Proc ;Procedimiento far en lib que divide, guarda residuo de la division para usarlo para imprimir decimales
    call ImprimirEnPantalla; Procedimiento far en lib que imprime la division entera
    ImprimirPunto ; Macro que imprime un punto
    call Decimales ;Procedimiento far lib que calcula e imprime primer decimal
    call Decimales ;Procedimiento far en lib que calcula e imprime segundo decimal
    call Decimales ;Procedimiento far lib que calcula e imprime primer decimal
    call Decimales ;Procedimiento far en lib que calcula e imprime segundo decimal
    Finalizar;Macro que finaliza el programa
endP

GetCommanderLine Proc near
    LongLC EQU 80h      
    Mov Bp,Sp 
    Mov Ax,Es
    Mov Ds,Ax
    Mov Di,2[Bp]
    Mov Ax,4[Bp]
    Mov Es,Ax
    Xor Cx,Cx
    Mov Cl,Byte Ptr Ds:[LongLC]
    Mov Si,2[LongLC]       
    cld                  
    Rep Movsb
    Ret 2*2; pop de linea de comando seg y offset.
GetCommanderLine EndP

LineaComandos proc near
    Xor Ax,Ax           
    Mov Ax,datos          
    Mov DS,Ax                 
    push ds ;Mete en pila el ds que ya apunta al segmento de datos
    Mov Ax,Seg LineCommand ; sp + 4 //Espacio
    Push Ax ;Guardamos en pila
    Lea Ax,LineCommand ; sp + 2 
    Push Ax
    call GetCommanderLine ; sp ;llamamos al procedimiento
    pop ds
    xor si,si
    cmp LineCommand[si],'/'
    jne salga
    inc si
    cmp LineCommand[si], '?'
    jne salga
    mov ah,09h
    mov dx, offset ayuda
    int 21h
    jmp Inicio
endP

LineaC:
    call LineaComandos ;Procedimiento near
Inicio:
    call asignar ;Asigna el segmento de datos en la lib
    call InicioInput ;LLama al procedimiento far que esta en librería para imprimir mensaje sobre escoger operacion y leer caracter ingresado
    call CompararOperacion ;Llama al procedimiento near que esta en este archivo para comparar el caracter ingresado
Salga:
    jmp Inicio

Codigo EndS ;Final del codigo de segmento

End LineaC ;Final del programa y le indica donde iniciar
